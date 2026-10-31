import 'product_model.dart';

/// ERISH Product Repository Contract (Developer 2 Scope)
abstract class IProductRepository {
  Stream<List<ProductModel>> watchActiveProducts();
  Future<ProductModel?> getProductBySlug(String slug);
  Future<ProductModel?> getProductById(String id);
  Stream<List<ProductModel>> watchProductsByCategory(String category);
  Future<void> updateStock(String productId, String sku, int deltaQuantity);
  Future<void> saveProduct(ProductModel product);
}
