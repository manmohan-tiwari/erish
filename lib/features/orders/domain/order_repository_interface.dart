import 'order_model.dart';

/// ERISH Order Repository Interface (Developer 2 Scope)
abstract class IOrderRepository {
  Future<String> createOrder(OrderModel order);
  Future<OrderModel?> getOrder(String orderId);
  Stream<List<OrderModel>> watchCustomerOrders(String customerEmail);
  Stream<List<OrderModel>> watchAllOrders();
  Future<void> updateOrderStatus(String orderId, String newStatus);
  Future<void> updatePaymentStatus(
    String orderId,
    String newStatus, {
    String? paymentId,
  });
}
