import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:erish_app/features/product/domain/product_model.dart';
import 'package:erish_app/features/product/domain/product_variant.dart';
import 'package:erish_app/features/product/data/mock_product_repository.dart';
import 'package:erish_app/features/orders/domain/order_model.dart';
import 'package:erish_app/features/orders/data/mock_order_repository.dart';
import 'package:erish_app/features/cart/domain/cart_pricing_engine.dart';

void main() {
  group('Developer 2 - Sprint 3 Backend Testing & Launch Hardening', () {
    test(
      'Concurrency & Inventory Lock: simultaneous purchases cannot deplete stock below 0',
      () async {
        final repo = MockProductRepository();

        // Seed product with only 1 item in stock for size XS
        final scarceProduct = ProductModel(
          id: 'p-scarce',
          slug: 'scarce-dress',
          name: 'Scarce Dress',
          description: 'Only 1 left',
          category: 'Mini',
          priceInPaise: 219900,
          images: ['assets/images/product1.jpg'],
          variants: const [
            ProductVariant(sku: 'SCARCE-XS', sizeLabel: 'XS', stockQuantity: 1),
          ],
          createdAt: DateTime.now(),
        );

        await repo.saveProduct(scarceProduct);

        // Simulate 2 customers buying simultaneously
        final customer1Purchase = repo.updateStock('p-scarce', 'SCARCE-XS', -1);
        final customer2Purchase = repo.updateStock('p-scarce', 'SCARCE-XS', -1);

        await Future.wait([customer1Purchase, customer2Purchase]);

        final finalProduct = await repo.getProductById('p-scarce');
        final finalVariant = finalProduct!.variants.firstWhere(
          (v) => v.sku == 'SCARCE-XS',
        );

        // Clamped to 0, never negative
        expect(finalVariant.stockQuantity, 0);
        expect(finalVariant.isAvailable, isFalse);

        repo.dispose();
      },
    );

    test(
      'Payment Failure Audit: failed transactions transition order status to failed',
      () async {
        final orderRepo = MockOrderRepository();

        final pendingOrder = OrderModel(
          orderId: 'ORD-FAIL-TEST',
          customerName: 'Rohit Joshi',
          customerEmail: 'rohit@example.com',
          customerPhone: '9811223344',
          shippingAddress: const {'city': 'Pune', 'pincode': '411001'},
          items: const [],
          subtotalInPaise: 279900,
          shippingFeeInPaise: 0,
          totalInPaise: 279900,
          paymentStatus: 'pending',
          orderStatus: 'placed',
          createdAt: DateTime.now(),
        );

        await orderRepo.createOrder(pendingOrder);

        // Simulate payment failure (e.g. user cancelled UPI or bank dropped)
        await orderRepo.updatePaymentStatus('ORD-FAIL-TEST', 'failed');
        await orderRepo.updateOrderStatus('ORD-FAIL-TEST', 'cancelled');

        final failedOrder = await orderRepo.getOrder('ORD-FAIL-TEST');
        expect(failedOrder!.paymentStatus, 'failed');
        expect(failedOrder.orderStatus, 'cancelled');

        orderRepo.dispose();
      },
    );

    test(
      'Security Audit: client-side codebase does not leak server secrets',
      () {
        final libDir = Directory('lib');
        if (libDir.existsSync()) {
          final dartFiles = libDir
              .listSync(recursive: true)
              .whereType<File>()
              .where((f) => f.path.endsWith('.dart'));

          for (final file in dartFiles) {
            final content = file.readAsStringSync();
            expect(
              content.contains('RAZORPAY_KEY_SECRET') ||
                  content.contains('razorpay_webhook_secret') ||
                  content.contains('rzp_secret'),
              isFalse,
              reason: 'Secret key leaked in client file: ${file.path}',
            );
          }
        }
      },
    );

    test('Tax and Currency Formatting: accurately formats edge cases', () {
      expect(CartPricingEngine.formatPaise(0), '₹0');
      expect(CartPricingEngine.formatPaise(9900), '₹99');
      expect(CartPricingEngine.formatPaise(279900), '₹2,799');
      expect(CartPricingEngine.formatPaise(12500000), '₹125,000');
    });
  });
}
