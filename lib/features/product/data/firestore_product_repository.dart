import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/product_model.dart';
import '../domain/product_repository_interface.dart';

/// ERISH Production Firestore Product Repository (Developer 2 Implementation)
/// Connects to `/products/` collection with resilient fallback
class FirestoreProductRepository implements IProductRepository {
  final FirebaseFirestore _firestore;

  FirestoreProductRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _productsCollection =>
      _firestore.collection('products');

  @override
  Stream<List<ProductModel>> watchActiveProducts() {
    return _productsCollection
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) {
            return ProductModel.seedProducts;
          }
          return snapshot.docs
              .map((doc) => ProductModel.fromMap(doc.id, doc.data()))
              .toList();
        })
        .handleError((error) {
          return ProductModel.seedProducts;
        });
  }

  @override
  Future<ProductModel?> getProductBySlug(String slug) async {
    try {
      final query = await _productsCollection
          .where('slug', isEqualTo: slug)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return ProductModel.fromMap(
          query.docs.first.id,
          query.docs.first.data(),
        );
      }

      // Check by doc id if slug search returned none
      final doc = await _productsCollection.doc(slug).get();
      if (doc.exists && doc.data() != null) {
        return ProductModel.fromMap(doc.id, doc.data()!);
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<ProductModel?> getProductById(String id) async {
    try {
      final doc = await _productsCollection.doc(id).get();
      if (doc.exists && doc.data() != null) {
        return ProductModel.fromMap(doc.id, doc.data()!);
      }
      return null;
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
    return _productsCollection
        .where('isActive', isEqualTo: true)
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ProductModel.fromMap(doc.id, doc.data()))
              .toList();
        })
        .handleError((_) => <ProductModel>[]);
  }

  @override
  Future<void> updateStock(
    String productId,
    String sku,
    int deltaQuantity,
  ) async {
    final docRef = _productsCollection.doc(productId);

    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists || snapshot.data() == null) return;

      final product = ProductModel.fromMap(snapshot.id, snapshot.data()!);
      final updatedVariants = product.variants.map((v) {
        if (v.sku == sku) {
          final newStock = (v.stockQuantity + deltaQuantity).clamp(0, 99999);
          return v.copyWith(stockQuantity: newStock);
        }
        return v;
      }).toList();

      transaction.update(docRef, {
        'variants': updatedVariants.map((v) => v.toMap()).toList(),
      });
    });
  }

  @override
  Future<void> saveProduct(ProductModel product) async {
    await _productsCollection
        .doc(product.id)
        .set(product.toMap(), SetOptions(merge: true));
  }
}
