import 'cart_line.dart';

/// ERISH Order Model (Developer 2 Contract)
/// Reflects Firestore `/orders/{orderId}` schema with full audit fields and integer paise values.
class OrderModel {
  final String orderId;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final Map<String, dynamic> shippingAddress;
  final List<CartLine> items;
  final int subtotalInPaise;
  final int shippingFeeInPaise;
  final int totalInPaise;
  final String paymentStatus; // 'pending', 'paid', 'failed', 'refunded'
  final String
  orderStatus; // 'placed', 'confirmed', 'packed', 'shipped', 'delivered', 'cancelled'
  final String paymentMethod;
  final String? razorpayOrderId;
  final String? razorpayPaymentId;
  final DateTime createdAt;

  const OrderModel({
    required this.orderId,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.shippingAddress,
    required this.items,
    required this.subtotalInPaise,
    required this.shippingFeeInPaise,
    required this.totalInPaise,
    this.paymentStatus = 'pending',
    this.orderStatus = 'placed',
    this.paymentMethod = 'UPI',
    this.razorpayOrderId,
    this.razorpayPaymentId,
    required this.createdAt,
  });

  String get formattedTotal {
    final rupees = totalInPaise ~/ 100;
    return '₹${rupees.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'shippingAddress': shippingAddress,
      'items': items.map((i) => i.toMap()).toList(),
      'subtotalInPaise': subtotalInPaise,
      'shippingFeeInPaise': shippingFeeInPaise,
      'totalInPaise': totalInPaise,
      'paymentStatus': paymentStatus,
      'orderStatus': orderStatus,
      'paymentMethod': paymentMethod,
      'razorpayOrderId': razorpayOrderId,
      'razorpayPaymentId': razorpayPaymentId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory OrderModel.fromMap(String id, Map<String, dynamic> data) {
    final rawItems = data['items'] as List<dynamic>? ?? [];
    final itemsList = rawItems
        .map((e) => CartLine.fromMap(Map<String, dynamic>.from(e)))
        .toList();

    final createdStr = data['createdAt'] as String?;
    final createdAt = createdStr != null
        ? DateTime.tryParse(createdStr) ?? DateTime.now()
        : DateTime.now();

    return OrderModel(
      orderId: id,
      customerName: data['customerName'] ?? '',
      customerEmail: data['customerEmail'] ?? '',
      customerPhone: data['customerPhone'] ?? '',
      shippingAddress: Map<String, dynamic>.from(data['shippingAddress'] ?? {}),
      items: itemsList,
      subtotalInPaise: (data['subtotalInPaise'] as num?)?.toInt() ?? 0,
      shippingFeeInPaise: (data['shippingFeeInPaise'] as num?)?.toInt() ?? 0,
      totalInPaise: (data['totalInPaise'] as num?)?.toInt() ?? 0,
      paymentStatus: data['paymentStatus'] ?? 'pending',
      orderStatus: data['orderStatus'] ?? 'placed',
      paymentMethod: data['paymentMethod'] ?? 'UPI',
      razorpayOrderId: data['razorpayOrderId'],
      razorpayPaymentId: data['razorpayPaymentId'],
      createdAt: createdAt,
    );
  }
}
