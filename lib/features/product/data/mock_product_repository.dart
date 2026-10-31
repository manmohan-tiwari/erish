import 'dart:async';
import '../domain/product_model.dart';
import '../domain/product_repository_interface.dart';

/// ERISH In-Memory Mock Product Repository for Dev 1 decoupling and unit testing
class MockProductRepository implements IProductRepository {
  final List<ProductModel> _products = List.from(ProductModel.seedProducts);
  final _controller = StreamController<List<ProductModel>>.broadcast();

  MockProductRepository() {
    _emit();
  }

  void _emit() {
    _controller.add(List.unmodifiable(_products.where((p) => p.isActive)));
  }

  @override
  Stream<List<ProductModel>> watchActiveProducts() {
    // Emit initial immediately on subscription
    return Stream.value(
      List<ProductModel>.unmodifiable(_products.where((p) => p.isActive)),
    ).concatWith([_controller.stream]);
  }

  @override
  Future<ProductModel?> getProductBySlug(String slug) async {
    try {
      return _products.firstWhere((p) => p.slug == slug || p.id == slug);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<ProductModel?> getProductById(String id) async {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<List<ProductModel>> watchProductsByCategory(String category) {
    if (category.toLowerCase() == 'all' ||
        category.toLowerCase() == 'all dresses') {
      return watchActiveProducts();
    }
    return watchActiveProducts().map(
      (list) => list
          .where((p) => p.category.toLowerCase() == category.toLowerCase())
          .toList(),
    );
  }

  @override
  Future<void> updateStock(
    String productId,
    String sku,
    int deltaQuantity,
  ) async {
    final productIndex = _products.indexWhere((p) => p.id == productId);
    if (productIndex == -1) return;

    final product = _products[productIndex];
    final updatedVariants = product.variants.map((variant) {
      if (variant.sku == sku) {
        final newQty = (variant.stockQuantity + deltaQuantity).clamp(0, 9999);
        return variant.copyWith(stockQuantity: newQty);
      }
      return variant;
    }).toList();

    _products[productIndex] = ProductModel(
      id: product.id,
      slug: product.slug,
      name: product.name,
      description: product.description,
      category: product.category,
      priceInPaise: product.priceInPaise,
      compareAtPriceInPaise: product.compareAtPriceInPaise,
      images: product.images,
      variants: updatedVariants,
      tag: product.tag,
      isActive: product.isActive,
      fabricCare: product.fabricCare,
      fitGuide: product.fitGuide,
      shippingInfo: product.shippingInfo,
      createdAt: product.createdAt,
    );
    _emit();
  }

  @override
  Future<void> saveProduct(ProductModel product) async {
    final idx = _products.indexWhere((p) => p.id == product.id);
    if (idx >= 0) {
      _products[idx] = product;
    } else {
      _products.add(product);
    }
    _emit();
  }

  void dispose() {
    _controller.close();
  }
}

extension _StreamConcat<T> on Stream<T> {
  Stream<T> concatWith(Iterable<Stream<T>> others) async* {
    yield* this;
    for (final s in others) {
      yield* s;
    }
  }
}
