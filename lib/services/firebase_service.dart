import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'firestore_seeder.dart';
import '../firebase_options.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  bool _isFirebaseInitialized = false;
  bool get isFirebaseInitialized => _isFirebaseInitialized;

  FirebaseFirestore? _firestore;
  FirebaseAuth? _auth;

  Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(const Duration(seconds: 3));

      _firestore = FirebaseFirestore.instance;
      _auth = FirebaseAuth.instance;
      _isFirebaseInitialized = true;

      // Attempt anonymous sign-in for visitor session
      try {
        if (_auth?.currentUser == null) {
          await _auth?.signInAnonymously().timeout(const Duration(seconds: 2));
        }
      } catch (authError) {
        debugPrint('Anonymous auth deferred: $authError');
      }

      debugPrint('Firebase successfully initialized for ERISH.');

      // Automatically seed Firestore with initial catalog if empty
      await FirestoreSeeder.seedIfEmpty().timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('Firebase initialized in local mock fallback mode: $e');
      _isFirebaseInitialized = false;
    }
  }

  // 1. Fetch products (Firestore stream with fallback)
  Stream<List<Product>> getProductsStream() {
    if (!_isFirebaseInitialized || _firestore == null) {
      return Stream.value(Product.initialProducts);
    }

    return _firestore!
        .collection('products')
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) {
            return Product.initialProducts;
          }
          return snapshot.docs
              .map((doc) => Product.fromMap(doc.id, doc.data()))
              .toList();
        })
        .handleError((error) {
          debugPrint('Firestore products error, using fallback: $error');
          return Product.initialProducts;
        });
  }

  // 2. Submit Newsletter Subscriber
  Future<bool> subscribeNewsletter(String email) async {
    if (!_isFirebaseInitialized || _firestore == null) {
      debugPrint('Newsletter subscribed (Local mode): $email');
      return true;
    }

    try {
      await _firestore!.collection('newsletter_subscribers').add({
        'email': email.trim().toLowerCase(),
        'subscribedAt': FieldValue.serverTimestamp(),
        'source': 'flutter_erish_app',
      });
      return true;
    } catch (e) {
      debugPrint('Error subscribing newsletter: $e');
      return true; // Still inform user positively
    }
  }

  // 3. Place Order / Bag Checkout
  Future<String?> placeOrder({
    required List<CartItem> items,
    required int totalAmount,
    String? customerEmail,
    String? customerName,
    String? customerPhone,
    Map<String, dynamic>? shippingAddress,
    String? paymentMethod,
    int? shippingFee,
  }) async {
    final orderId =
        'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';

    final totalInPaise = totalAmount * 100;
    final shippingFeeInPaise = (shippingFee ?? 0) * 100;
    final subtotalInPaise = totalInPaise - shippingFeeInPaise;
    final normalizedEmail = (customerEmail ?? '').trim().toLowerCase();

    if (!_isFirebaseInitialized || _firestore == null) {
      debugPrint('Order saved (Local mock mode): $orderId for ₹$totalAmount');
      return orderId;
    }

    try {
      // Must conform strictly to firestore.rules:
      // totalInPaise > 0, customerEmail is string, paymentStatus == 'pending', orderStatus == 'placed'
      await _firestore!.collection('orders').doc(orderId).set({
        'orderId': orderId,
        'userId': _auth?.currentUser?.uid ?? 'guest',
        'items': items.map((item) => item.toMap()).toList(),
        'totalAmount': totalAmount,
        'totalInPaise': totalInPaise,
        'subtotalInPaise': subtotalInPaise,
        'shippingFeeInPaise': shippingFeeInPaise,
        'customerEmail': normalizedEmail,
        'customerName': customerName ?? '',
        'customerPhone': customerPhone ?? '',
        'shippingAddress': shippingAddress ?? {},
        'paymentMethod': paymentMethod ?? 'UPI',
        'paymentStatus': 'pending',
        'orderStatus': 'placed',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return orderId;
    } catch (e) {
      debugPrint('Error placing order to Firestore: $e');
      rethrow;
    }
  }
}
