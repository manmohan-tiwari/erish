import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import * as crypto from "crypto";
// eslint-disable-next-line @typescript-eslint/no-var-requires
const Razorpay = require("razorpay");

const RAZORPAY_KEY_ID = process.env.RAZORPAY_KEY_ID || "rzp_test_placeholder";
const RAZORPAY_KEY_SECRET = process.env.RAZORPAY_KEY_SECRET || "rzp_secret_placeholder";
const RAZORPAY_WEBHOOK_SECRET = process.env.RAZORPAY_WEBHOOK_SECRET || "rzp_webhook_secret_placeholder";

const getRazorpayClient = () => {
  return new Razorpay({
    key_id: RAZORPAY_KEY_ID,
    key_secret: RAZORPAY_KEY_SECRET,
  });
};

/**
 * 1. Cloud Function: initiateRazorpayPayment
 * Creates a server-side order with Razorpay in integer paise.
 */
export const initiateRazorpayPayment = functions.https.onCall(
  async (data: { orderId: string }) => {
    if (!data.orderId) {
      throw new functions.https.HttpsError("invalid-argument", "Order ID is required.");
    }

    const firestore = admin.firestore();
    const orderDoc = await firestore.collection("orders").doc(data.orderId).get();

    if (!orderDoc.exists) {
      throw new functions.https.HttpsError("not-found", "Order does not exist.");
    }

    const orderData = orderDoc.data()!;
    if (orderData.paymentStatus === "paid") {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "This order has already been paid."
      );
    }

    const amountInPaise: number = orderData.totalInPaise;

    try {
      const razorpay = getRazorpayClient();
      const razorpayOrder = await razorpay.orders.create({
        amount: amountInPaise,
        currency: "INR",
        receipt: data.orderId,
        notes: {
          customerName: orderData.customerName,
          customerEmail: orderData.customerEmail,
        },
      });

      // Update Firestore order with Razorpay Order ID
      await firestore.collection("orders").doc(data.orderId).update({
        razorpayOrderId: razorpayOrder.id,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      return {
        success: true,
        orderId: data.orderId,
        razorpayOrderId: razorpayOrder.id,
        amount: amountInPaise,
        currency: "INR",
        keyId: RAZORPAY_KEY_ID,
      };
    } catch (error: any) {
      functions.logger.error("Razorpay order creation error:", error);
      throw new functions.https.HttpsError(
        "internal",
        `Failed to initiate payment gateway: ${error.message || error}`
      );
    }
  }
);

/**
 * 2. Razorpay Webhook Handler
 * Verifies HMAC SHA256 signature, enforces idempotency, updates payment/order status,
 * and automatically decrements inventory.
 */
export const handleRazorpayWebhook = functions.https.onRequest(
  async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).send("Method Not Allowed");
      return;
    }

    const signature = req.headers["x-razorpay-signature"] as string;
    if (!signature) {
      functions.logger.warn("Missing Razorpay signature header.");
      res.status(400).send("Signature missing");
      return;
    }

    const rawBody = (req as any).rawBody;
    const expectedSignature = crypto
      .createHmac("sha256", RAZORPAY_WEBHOOK_SECRET)
      .update(rawBody)
      .digest("hex");

    if (expectedSignature !== signature) {
      functions.logger.error("Invalid Razorpay webhook signature.");
      res.status(401).send("Invalid signature");
      return;
    }

    const payload = req.body;
    const event = payload.event;
    const eventId = payload.entity ? payload.entity.id : payload.id || `evt_${Date.now()}`;

    functions.logger.info(`Processing Razorpay webhook event: ${event} [${eventId}]`);

    const firestore = admin.firestore();

    // Idempotency check: Ignore duplicate deliveries
    const webhookRef = firestore.collection("payment_webhooks").doc(eventId);
    const existingWebhook = await webhookRef.get();
    if (existingWebhook.exists) {
      functions.logger.info(`Webhook event ${eventId} already processed. Acknowledging.`);
      res.status(200).json({ status: "already_processed" });
      return;
    }

    if (event === "payment.captured" || event === "order.paid") {
      const paymentEntity = payload.payload.payment.entity;
      const razorpayOrderId = paymentEntity.order_id;
      const razorpayPaymentId = paymentEntity.id;

      // Find order matching razorpayOrderId
      const orderQuery = await firestore
        .collection("orders")
        .where("razorpayOrderId", isEqualTo: razorpayOrderId)
        .limit(1)
        .get();

      if (orderQuery.empty) {
        functions.logger.warn(`No matching order for Razorpay Order ${razorpayOrderId}`);
        res.status(404).send("Order not found");
        return;
      }

      const orderDoc = orderQuery.docs[0];
      const orderData = orderDoc.data();

      // Transactional stock deduction & status update
      await firestore.runTransaction(async (transaction) => {
        // 1. Mark order paid & confirmed
        transaction.update(orderDoc.ref, {
          paymentStatus: "paid",
          orderStatus: "confirmed",
          razorpayPaymentId,
          paidAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        // 2. Decrement variant inventory in /products/
        const items = orderData.items || [];
        for (const item of items) {
          if (!item.productId || !item.sku) continue;

          const prodRef = firestore.collection("products").doc(item.productId);
          const prodDoc = await transaction.get(prodRef);
          if (!prodDoc.exists) continue;

          const prodData = prodDoc.data()!;
          const variants = prodData.variants || [];

          const updatedVariants = variants.map((v: { sku: string; stockQuantity: number }) => {
            if (v.sku === item.sku) {
              const newStock = Math.max(0, v.stockQuantity - (item.quantity || 1));
              return { ...v, stockQuantity: newStock, isAvailable: newStock > 0 };
            }
            return v;
          });

          transaction.update(prodRef, { variants: updatedVariants });
        }

        // 3. Record webhook delivery to guarantee idempotency
        transaction.set(webhookRef, {
          eventId,
          event,
          razorpayOrderId,
          razorpayPaymentId,
          processedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      });

      functions.logger.info(`Successfully confirmed order ${orderData.orderId} and deducted stock.`);
    }

    res.status(200).json({ status: "ok" });
  }
);

