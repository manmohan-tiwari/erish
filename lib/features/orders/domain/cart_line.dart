/// ERISH Cart Line Item Contract (Developer 2 Scope)
/// Stored strictly with integer paise for financial integrity.
class CartLine {
  final String productId;
  final String sku;
  final String name;
  final String sizeLabel;
  final int quantity;
  final int unitPriceInPaise;
  final String image;

  const CartLine({
    required this.productId,
    required this.sku,
    required this.name,
    required this.sizeLabel,
    required this.quantity,
    required this.unitPriceInPaise,
    required this.image,
  });

  int get lineTotalInPaise => unitPriceInPaise * quantity;

  String get formattedUnitPrice {
    final rupees = unitPriceInPaise ~/ 100;
    return '₹${rupees.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  String get formattedLineTotal {
    final rupees = lineTotalInPaise ~/ 100;
    return '₹${rupees.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'sku': sku,
      'name': name,
      'sizeLabel': sizeLabel,
      'quantity': quantity,
      'unitPriceInPaise': unitPriceInPaise,
      'lineTotalInPaise': lineTotalInPaise,
      'image': image,
    };
  }

  factory CartLine.fromMap(Map<String, dynamic> map) {
    return CartLine(
      productId: map['productId'] ?? '',
      sku: map['sku'] ?? '',
      name: map['name'] ?? '',
      sizeLabel: map['sizeLabel'] ?? 'S',
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      unitPriceInPaise:
          (map['unitPriceInPaise'] as num?)?.toInt() ??
          (((map['unitPrice'] as num?)?.toInt() ?? 0) * 100),
      image: map['image'] ?? 'assets/images/product1.jpg',
    );
  }
}
