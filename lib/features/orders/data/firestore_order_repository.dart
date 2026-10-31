import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/order_model.dart';
import '../domain/order_repository_interface.dart';

/// ERISH Production Firestore Order Repository (Developer 2 Implementation)
/// Manages transactions with `/orders/{orderId}`
class FirestoreOrderRepository implements IOrderRepository {
  final FirebaseFirestore _firestore;

  FirestoreOrderRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _ordersCollection =>
      _firestore.collection('orders');

  @override
  Future<String> createOrder(OrderModel order) async {
    await _ordersCollection.doc(order.orderId).set(order.toMap());
    return order.orderId;
  }

  @override
  Future<OrderModel?> getOrder(String orderId) async {
    final doc = await _ordersCollection.doc(orderId).get();
    if (doc.exists && doc.data() != null) {
      return OrderModel.fromMap(doc.id, doc.data()!);
    }
    return null;
  }

  @override
  Stream<List<OrderModel>> watchCustomerOrders(String customerEmail) {
    return _ordersCollection
        .where('customerEmail', isEqualTo: customerEmail.trim().toLowerCase())
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => OrderModel.fromMap(doc.id, doc.data()))
              .toList();
        })
        .handleError((_) => <OrderModel>[]);
  }

  @override
  Stream<List<OrderModel>> watchAllOrders() {
    return _ordersCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => OrderModel.fromMap(doc.id, doc.data()))
              .toList();
        })
        .handleError((_) => <OrderModel>[]);
  }

  @override
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _ordersCollection.doc(orderId).update({
      'orderStatus': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updatePaymentStatus(
    String orderId,
    String newStatus, {
    String? paymentId,
  }) async {
    final Map<String, dynamic> updateData = {
      'paymentStatus': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (paymentId != null) {
      updateData['razorpayPaymentId'] = paymentId;
    }
    await _ordersCollection.doc(orderId).update(updateData);
  }
}
