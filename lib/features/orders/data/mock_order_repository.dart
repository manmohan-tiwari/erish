import 'dart:async';
import '../domain/order_model.dart';
import '../domain/order_repository_interface.dart';

/// In-memory mock implementation of Order Repository
class MockOrderRepository implements IOrderRepository {
  final List<OrderModel> _orders = [];
  final _controller = StreamController<List<OrderModel>>.broadcast();

  void _emit() {
    _controller.add(List.unmodifiable(_orders));
  }

  @override
  Future<String> createOrder(OrderModel order) async {
    _orders.add(order);
    _emit();
    return order.orderId;
  }

  @override
  Future<OrderModel?> getOrder(String orderId) async {
    try {
      return _orders.firstWhere((o) => o.orderId == orderId);
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<List<OrderModel>> watchCustomerOrders(String customerEmail) {
    return _controller.stream.map(
      (orders) => orders
          .where(
            (o) => o.customerEmail.toLowerCase() == customerEmail.toLowerCase(),
          )
          .toList(),
    );
  }

  @override
  Stream<List<OrderModel>> watchAllOrders() {
    return _controller.stream;
  }

  @override
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    final idx = _orders.indexWhere((o) => o.orderId == orderId);
    if (idx >= 0) {
      final old = _orders[idx];
      _orders[idx] = OrderModel(
        orderId: old.orderId,
        customerName: old.customerName,
        customerEmail: old.customerEmail,
        customerPhone: old.customerPhone,
        shippingAddress: old.shippingAddress,
        items: old.items,
        subtotalInPaise: old.subtotalInPaise,
        shippingFeeInPaise: old.shippingFeeInPaise,
        totalInPaise: old.totalInPaise,
        paymentStatus: old.paymentStatus,
        orderStatus: newStatus,
        paymentMethod: old.paymentMethod,
        razorpayOrderId: old.razorpayOrderId,
        razorpayPaymentId: old.razorpayPaymentId,
        createdAt: old.createdAt,
      );
      _emit();
    }
  }

  @override
  Future<void> updatePaymentStatus(
    String orderId,
    String newStatus, {
    String? paymentId,
  }) async {
    final idx = _orders.indexWhere((o) => o.orderId == orderId);
    if (idx >= 0) {
      final old = _orders[idx];
      _orders[idx] = OrderModel(
        orderId: old.orderId,
        customerName: old.customerName,
        customerEmail: old.customerEmail,
        customerPhone: old.customerPhone,
        shippingAddress: old.shippingAddress,
        items: old.items,
        subtotalInPaise: old.subtotalInPaise,
        shippingFeeInPaise: old.shippingFeeInPaise,
        totalInPaise: old.totalInPaise,
        paymentStatus: newStatus,
        orderStatus: old.orderStatus,
        paymentMethod: old.paymentMethod,
        razorpayOrderId: old.razorpayOrderId,
        razorpayPaymentId: paymentId ?? old.razorpayPaymentId,
        createdAt: old.createdAt,
      );
      _emit();
    }
  }

  void dispose() {
    _controller.close();
  }
}
