import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../features/product/domain/product_model.dart';

/// ERISH Firestore Database Seeder (Developer 2 Implementation)
/// Seeds the Firestore database `products` collection with standard paise-based catalog items.
class FirestoreSeeder {
  static Future<void> seedIfEmpty() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final productsCollection = firestore.collection('products');

      final snapshot = await productsCollection.limit(1).get();
      if (snapshot.docs.isEmpty) {
        debugPrint(
          'Seeding Firestore products collection with initial paise catalog...',
        );

        final batch = firestore.batch();
        for (final product in ProductModel.seedProducts) {
          final docRef = productsCollection.doc(product.id);
          batch.set(docRef, product.toMap());
        }
        await batch.commit();
        debugPrint(
          'Firestore database seeded successfully with ${ProductModel.seedProducts.length} products.',
        );
      } else {
        debugPrint('Firestore products collection already contains data.');
      }
    } catch (e) {
      debugPrint('FirestoreSeeder note (offline or local mode): $e');
    }
  }
}
