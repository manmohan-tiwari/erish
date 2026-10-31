/// ERISH Cart Pricing & Discount Engine (Developer 2 Scope)
/// Operates strictly with integer paise for 100% financial consistency with the server.
class CartPricingEngine {
  // Threshold: ₹2,500 = 250,000 paise
  static const int freeShippingThresholdInPaise = 250000;
  static const int standardShippingFeeInPaise = 9900; // ₹99
  static const int expressShippingFeeInPaise = 19900; // ₹199

  /// Computes shipping fee based on subtotal and shipping tier
  static int calculateShippingFee({
    required int subtotalInPaise,
    bool isExpress = false,
  }) {
    if (subtotalInPaise <= 0) return 0;
    if (isExpress) return expressShippingFeeInPaise;
    return subtotalInPaise >= freeShippingThresholdInPaise
        ? 0
        : standardShippingFeeInPaise;
  }

  /// Verifies and applies promotion code to the subtotal in integer paise
  static DiscountResult applyDiscount({
    required int subtotalInPaise,
    required String? code,
  }) {
    if (code == null || code.trim().isEmpty || subtotalInPaise <= 0) {
      return const DiscountResult.none();
    }

    final normalized = code.trim().toUpperCase();

    if (normalized == 'WELCOME10') {
      // 10% off subtotal capped at ₹500 (50,000 paise)
      final raw = (subtotalInPaise * 0.10).round();
      final discount = raw > 50000 ? 50000 : raw;
      return DiscountResult(
        isValid: true,
        code: 'WELCOME10',
        discountInPaise: discount,
        description: '10% Welcome Discount applied (up to ₹500)',
      );
    }

    if (normalized == 'ERISHJOY') {
      // Flat ₹500 off on orders >= ₹2,000
      if (subtotalInPaise >= 200000) {
        return const DiscountResult(
          isValid: true,
          code: 'ERISHJOY',
          discountInPaise: 50000,
          description: '₹500 Festive Joy discount applied',
        );
      } else {
        return const DiscountResult(
          isValid: false,
          code: 'ERISHJOY',
          discountInPaise: 0,
          description: 'Code ERISHJOY requires a minimum order of ₹2,000',
        );
      }
    }

    if (normalized == 'SUMMER20') {
      // 20% off capped at ₹1,000 (100,000 paise)
      final raw = (subtotalInPaise * 0.20).round();
      final discount = raw > 100000 ? 100000 : raw;
      return DiscountResult(
        isValid: true,
        code: 'SUMMER20',
        discountInPaise: discount,
        description: '20% Summer Solstice discount applied (up to ₹1,000)',
      );
    }

    return const DiscountResult(
      isValid: false,
      code: '',
      discountInPaise: 0,
      description: 'Invalid or expired promotional code',
    );
  }

  /// Computes the complete order price breakdown in paise
  static PriceBreakdown calculateOrder({
    required int subtotalInPaise,
    bool isExpress = false,
    String? discountCode,
  }) {
    final discount = applyDiscount(
      subtotalInPaise: subtotalInPaise,
      code: discountCode,
    );

    final shipping = calculateShippingFee(
      subtotalInPaise: subtotalInPaise,
      isExpress: isExpress,
    );

    final grandTotal = (subtotalInPaise - discount.discountInPaise + shipping)
        .clamp(0, 99999999);

    return PriceBreakdown(
      subtotalInPaise: subtotalInPaise,
      discount: discount,
      shippingFeeInPaise: shipping,
      grandTotalInPaise: grandTotal,
    );
  }

  /// Helper to format any integer paise amount to Indian Rupee notation
  static String formatPaise(int paise) {
    final rupees = paise ~/ 100;
    return '₹${rupees.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }
}

class DiscountResult {
  final bool isValid;
  final String code;
  final int discountInPaise;
  final String description;

  const DiscountResult({
    required this.isValid,
    required this.code,
    required this.discountInPaise,
    required this.description,
  });

  const DiscountResult.none()
    : isValid = false,
      code = '',
      discountInPaise = 0,
      description = '';

  String get formattedDiscount =>
      CartPricingEngine.formatPaise(discountInPaise);
}

class PriceBreakdown {
  final int subtotalInPaise;
  final DiscountResult discount;
  final int shippingFeeInPaise;
  final int grandTotalInPaise;

  const PriceBreakdown({
    required this.subtotalInPaise,
    required this.discount,
    required this.shippingFeeInPaise,
    required this.grandTotalInPaise,
  });

  String get formattedSubtotal =>
      CartPricingEngine.formatPaise(subtotalInPaise);
  String get formattedShipping => shippingFeeInPaise == 0
      ? 'FREE'
      : CartPricingEngine.formatPaise(shippingFeeInPaise);
  String get formattedGrandTotal =>
      CartPricingEngine.formatPaise(grandTotalInPaise);
}
