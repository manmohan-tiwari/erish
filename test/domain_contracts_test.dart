import 'package:flutter_test/flutter_test.dart';
import 'package:erish_app/features/product/domain/product_model.dart';
import 'package:erish_app/features/product/domain/product_variant.dart';
import 'package:erish_app/features/product/data/mock_product_repository.dart';
import 'package:erish_app/features/orders/domain/cart_line.dart';
import 'package:erish_app/features/orders/domain/order_model.dart';
import 'package:erish_app/features/orders/data/mock_order_repository.dart';

void main() {
  group('Developer 2 - Sprint 1 Domain Contracts & Paise Math', () {
    test(
      'ProductModel properly formats integer paise to Indian Rupee notation',
      () {
        final product = ProductModel(
          id: 'test-1',
          slug: 'test-dress',
          name: 'Test Dress',
          description: 'Description',
          category: 'Maxi',
          priceInPaise: 279900,
          compareAtPriceInPaise: 349900,
          images: ['assets/images/product1.jpg'],
          variants: const [
            ProductVariant(sku: 'SKU-S', sizeLabel: 'S', stockQuantity: 5),
            ProductVariant(sku: 'SKU-M', sizeLabel: 'M', stockQuantity: 0),
          ],
          createdAt: DateTime.now(),
        );

        expect(product.formattedPrice, '₹2,799');
        expect(product.formattedCompareAtPrice, '₹3,499');
        expect(product.totalStock, 5);
        expect(product.inStock, isTrue);
        expect(product.availableSizes, ['S']);
      },
    );

    test('CartLine calculates line totals strictly in integer paise', () {
      const line = CartLine(
        productId: 'p1',
        sku: 'ERISH-JPM-S',
        name: 'Jaipur Paisley Maxi',
        sizeLabel: 'S',
        quantity: 3,
        unitPriceInPaise: 279900,
        image: 'assets/images/product1.jpg',
      );

      expect(line.lineTotalInPaise, 839700);
      expect(line.formattedUnitPrice, '₹2,799');
      expect(line.formattedLineTotal, '₹8,397');
    });

    test(
      'MockProductRepository fetches products and updates stock levels',
      () async {
        final repo = MockProductRepository();

        final product = await repo.getProductBySlug('jaipur-paisley-maxi');
        expect(product, isNotNull);
        expect(product!.priceInPaise, 279900);

        // Decrement stock by 1
        await repo.updateStock(product.id, 'ERISH-JPM-XS', -1);
        final updated = await repo.getProductById(product.id);
        final updatedVariant = updated!.variants.firstWhere(
          (v) => v.sku == 'ERISH-JPM-XS',
        );
        expect(updatedVariant.stockQuantity, 7); // Initial was 8

        repo.dispose();
      },
    );

    test(
      'MockOrderRepository creates orders and updates audit status',
      () async {
        final repo = MockOrderRepository();

        final order = OrderModel(
          orderId: 'ORD-TEST-99',
          customerName: 'Ananya Roy',
          customerEmail: 'ananya@example.com',
          customerPhone: '9876543210',
          shippingAddress: const {'city': 'Bangalore', 'pincode': '560001'},
          items: const [
            CartLine(
              productId: 'p2',
              sku: 'ERISH-ADK-S',
              name: 'Azure Drift Kaftan',
              sizeLabel: 'S',
              quantity: 1,
              unitPriceInPaise: 299900,
              image: 'assets/images/product2.jpg',
            ),
          ],
          subtotalInPaise: 299900,
          shippingFeeInPaise: 0,
          totalInPaise: 299900,
          createdAt: DateTime.now(),
        );

        final createdId = await repo.createOrder(order);
        expect(createdId, 'ORD-TEST-99');

        final fetched = await repo.getOrder(createdId);
        expect(fetched, isNotNull);
        expect(fetched!.orderStatus, 'placed');
        expect(fetched.formattedTotal, '₹2,999');

        await repo.updateOrderStatus(createdId, 'confirmed');
        final updated = await repo.getOrder(createdId);
        expect(updated!.orderStatus, 'confirmed');

        repo.dispose();
      },
    );
  });
}
