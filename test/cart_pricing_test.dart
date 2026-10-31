import 'package:flutter_test/flutter_test.dart';
import 'package:erish_app/features/cart/domain/cart_pricing_engine.dart';
import 'package:erish_app/features/cart/data/payment_service.dart';

void main() {
  group('Developer 2 - Sprint 2 Cart Pricing Engine & Discounts', () {
    test('Standard shipping is free above ₹2,500 and ₹99 below', () {
      // Subtotal ₹2,000 (below threshold) -> ₹99 shipping
      final below = CartPricingEngine.calculateShippingFee(
        subtotalInPaise: 200000,
        isExpress: false,
      );
      expect(below, 9900);

      // Subtotal ₹2,500 (at threshold) -> FREE shipping
      final at = CartPricingEngine.calculateShippingFee(
        subtotalInPaise: 250000,
        isExpress: false,
      );
      expect(at, 0);

      // Subtotal ₹3,200 (above threshold) -> FREE shipping
      final above = CartPricingEngine.calculateShippingFee(
        subtotalInPaise: 320000,
        isExpress: false,
      );
      expect(above, 0);

      // Express priority delivery is always ₹199
      final express = CartPricingEngine.calculateShippingFee(
        subtotalInPaise: 350000,
        isExpress: true,
      );
      expect(express, 19900);
    });

    test('WELCOME10 provides 10% discount capped at ₹500', () {
      // Subtotal ₹2,000 -> 10% is ₹200 (20,000 paise)
      final res1 = CartPricingEngine.applyDiscount(
        subtotalInPaise: 200000,
        code: 'WELCOME10',
      );
      expect(res1.isValid, isTrue);
      expect(res1.discountInPaise, 20000);
      expect(res1.formattedDiscount, '₹200');

      // Subtotal ₹8,000 -> 10% is ₹800, but capped at ₹500 (50,000 paise)
      final res2 = CartPricingEngine.applyDiscount(
        subtotalInPaise: 800000,
        code: 'welcome10',
      );
      expect(res2.isValid, isTrue);
      expect(res2.discountInPaise, 50000);
      expect(res2.formattedDiscount, '₹500');
    });

    test('ERISHJOY requires ₹2,000 minimum order', () {
      // Below ₹2,000 -> Invalid
      final invalid = CartPricingEngine.applyDiscount(
        subtotalInPaise: 150000,
        code: 'ERISHJOY',
      );
      expect(invalid.isValid, isFalse);
      expect(invalid.discountInPaise, 0);

      // Above ₹2,000 -> Flat ₹500 off
      final valid = CartPricingEngine.applyDiscount(
        subtotalInPaise: 279900,
        code: 'ERISHJOY',
      );
      expect(valid.isValid, isTrue);
      expect(valid.discountInPaise, 50000);
      expect(valid.formattedDiscount, '₹500');
    });

    test(
      'calculateOrder accurately combines subtotal, discount, and shipping',
      () {
        // Subtotal ₹2,799, code ERISHJOY (-₹500), standard shipping (free because > ₹2500)
        final breakdown = CartPricingEngine.calculateOrder(
          subtotalInPaise: 279900,
          discountCode: 'ERISHJOY',
          isExpress: false,
        );

        expect(breakdown.subtotalInPaise, 279900);
        expect(breakdown.discount.discountInPaise, 50000);
        expect(breakdown.shippingFeeInPaise, 0);
        // 279900 - 50000 + 0 = 229900
        expect(breakdown.grandTotalInPaise, 229900);
        expect(breakdown.formattedGrandTotal, '₹2,299');
      },
    );

    test(
      'PaymentService mock handles simulated checkout flow safely',
      () async {
        final service = PaymentService();
        final result = await service.processCheckoutPayment(
          orderId: 'ORD-TEST-100',
          amountInPaise: 229900,
          customerName: 'Kavita Singh',
          customerEmail: 'kavita@example.com',
          customerPhone: '9876543210',
          paymentMethod: 'UPI',
        );

        expect(result.isSuccess, isTrue);
        expect(result.orderId, 'ORD-TEST-100');
        expect(result.paymentId, isNotNull);
      },
    );
  });
}
