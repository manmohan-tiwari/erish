import 'package:flutter/foundation.dart';

class PaymentResult {
  final bool isSuccess;
  final String orderId;
  final String? paymentId;
  final String? errorMessage;

  const PaymentResult.success({required this.orderId, required this.paymentId})
    : isSuccess = true,
      errorMessage = null;

  const PaymentResult.failure({
    required this.orderId,
    required this.errorMessage,
  }) : isSuccess = false,
       paymentId = null;
}

/// ERISH Razorpay Payment Service (Developer 2 Implementation)
/// Manages client invocation and graceful fallback for local and web testing
class PaymentService {
  static const String publicRazorpayKey = 'rzp_test_51ERISHLabelTestKey';

  Future<PaymentResult> processCheckoutPayment({
    required String orderId,
    required int amountInPaise,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required String paymentMethod,
  }) async {
    try {
      debugPrint(
        'Initiating payment of ₹${amountInPaise ~/ 100} for $orderId via $paymentMethod...',
      );

      // In real device with Razorpay plugin or local mock:
      await Future.delayed(const Duration(milliseconds: 600));

      final mockPaymentId =
          'pay_${DateTime.now().millisecondsSinceEpoch.toString().substring(4)}';

      return PaymentResult.success(orderId: orderId, paymentId: mockPaymentId);
    } catch (e) {
      return PaymentResult.failure(
        orderId: orderId,
        errorMessage: e.toString(),
      );
    }
  }
}
