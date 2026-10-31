import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

interface IncomingLineItem {
  productId: string;
  sku: string;
  quantity: number;
}

interface CreateOrderRequest {
  items: IncomingLineItem[];
  customerName: string;
  customerEmail: string;
  customerPhone: string;
  shippingAddress: Record<string, unknown>;
  shippingMethod?: "standard" | "express";
  discountCode?: string;
}

/**
 * Server-Side Trusted Order Creation
 * Re-validates prices strictly against Firestore documents, enforces stock constraints,
 * and creates trusted order document with 'pending' status.
 */
export const createOrder = functions.https.onCall(
  async (data: CreateOrderRequest, context) => {
    const firestore = admin.firestore();

    if (!data.items || !Array.isArray(data.items) || data.items.length === 0) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Order must contain at least one line item."
      );
    }

    if (!data.customerEmail || !data.customerName) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Customer name and email are mandatory."
      );
    }

    let calculatedSubtotalPaise = 0;
    const verifiedOrderItems = [];

    // 1. Validate each line item against Firestore product catalog
    for (const item of data.items) {
      if (!item.productId || !item.sku || !item.quantity || item.quantity <= 0) {
        throw new functions.https.HttpsError(
          "invalid-argument",
          "Invalid line item parameters."
        );
      }

      const productDoc = await firestore.collection("products").doc(item.productId).get();
      if (!productDoc.exists) {
        throw new functions.https.HttpsError(
          "not-found",
          `Product ${item.productId} was not found in catalog.`
        );
      }

      const productData = productDoc.data()!;
      if (productData.isActive === false) {
        throw new functions.https.HttpsError(
          "failed-precondition",
          `Product ${productData.name} is currently archived or inactive.`
        );
      }

      // Check variant matching SKU
      const variants = productData.variants || [];
      const matchedVariant = variants.find((v: { sku: string }) => v.sku === item.sku);

      if (!matchedVariant) {
        throw new functions.https.HttpsError(
          "not-found",
          `Size variant for SKU ${item.sku} does not exist.`
        );
      }

      // Check stock availability
      if (matchedVariant.stockQuantity < item.quantity) {
        throw new functions.https.HttpsError(
          "resource-exhausted",
          `Insufficient stock for ${productData.name} (${matchedVariant.sizeLabel}). Available: ${matchedVariant.stockQuantity}`
        );
      }

      // Use TRUSTED price from Firestore (server-side only)
      const trustedPriceInPaise: number =
        typeof productData.priceInPaise === "number"
          ? productData.priceInPaise
          : (productData.rawPrice || 0) * 100;

      const lineTotalPaise = trustedPriceInPaise * item.quantity;
      calculatedSubtotalPaise += lineTotalPaise;

      verifiedOrderItems.push({
        productId: item.productId,
        sku: item.sku,
        name: productData.name,
        sizeLabel: matchedVariant.sizeLabel,
        quantity: item.quantity,
        unitPriceInPaise: trustedPriceInPaise,
        lineTotalInPaise: lineTotalPaise,
        image: productData.image || "assets/images/product1.jpg",
      });
    }

    // 2. Shipping Calculation
    // Free shipping threshold: ₹2,500 (250000 paise). Express: ₹199 (19900 paise).
    let shippingFeeInPaise = 0;
    if (data.shippingMethod === "express") {
      shippingFeeInPaise = 19900;
    } else {
      shippingFeeInPaise = calculatedSubtotalPaise >= 250000 ? 0 : 9900;
    }

    // 3. Discount Code Verification
    let discountInPaise = 0;
    const appliedCode = data.discountCode?.trim().toUpperCase();
    if (appliedCode === "WELCOME10") {
      // 10% off up to ₹500
      const rawDiscount = Math.round(calculatedSubtotalPaise * 0.1);
      discountInPaise = Math.min(rawDiscount, 50000);
    } else if (appliedCode === "ERISHJOY") {
      // Flat ₹500 off on orders >= ₹2,000
      if (calculatedSubtotalPaise >= 200000) {
        discountInPaise = 50000;
      }
    }

    const grandTotalInPaise = Math.max(
      0,
      calculatedSubtotalPaise - discountInPaise + shippingFeeInPaise
    );

    // 4. Generate Order ID
    const randomSuffix = Math.floor(1000 + Math.random() * 9000);
    const orderId = `ORD-${Date.now().toString().slice(-6)}-${randomSuffix}`;

    // 5. Store pending order in Firestore
    const orderRecord = {
      orderId,
      customerName: data.customerName.trim(),
      customerEmail: data.customerEmail.trim().toLowerCase(),
      customerPhone: data.customerPhone.trim(),
      shippingAddress: data.shippingAddress || {},
      items: verifiedOrderItems,
      subtotalInPaise: calculatedSubtotalPaise,
      discountInPaise,
      discountCode: appliedCode || null,
      shippingFeeInPaise,
      totalInPaise: grandTotalInPaise,
      paymentStatus: "pending",
      orderStatus: "placed",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      userId: context.auth ? context.auth.uid : "guest",
    };

    await firestore.collection("orders").doc(orderId).set(orderRecord);

    return {
      success: true,
      orderId,
      subtotalInPaise: calculatedSubtotalPaise,
      shippingFeeInPaise,
      discountInPaise,
      totalInPaise: grandTotalInPaise,
    };
  }
);

