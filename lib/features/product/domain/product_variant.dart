/// ERISH Product Variant Entity (Developer 2 Contract)
/// Represents a specific size/SKU combination with independent stock tracking.
class ProductVariant {
  final String sku;
  final String sizeLabel; // 'XS', 'S', 'M', 'L', 'XL'
  final int stockQuantity;

  const ProductVariant({
    required this.sku,
    required this.sizeLabel,
    required this.stockQuantity,
  });

  bool get isAvailable => stockQuantity > 0;

  Map<String, dynamic> toMap() {
    return {
      'sku': sku,
      'sizeLabel': sizeLabel,
      'stockQuantity': stockQuantity,
      'isAvailable': isAvailable,
    };
  }

  factory ProductVariant.fromMap(Map<String, dynamic> map) {
    return ProductVariant(
      sku: map['sku'] ?? '',
      sizeLabel: map['sizeLabel'] ?? '',
      stockQuantity: (map['stockQuantity'] as num?)?.toInt() ?? 0,
    );
  }

  ProductVariant copyWith({
    String? sku,
    String? sizeLabel,
    int? stockQuantity,
  }) {
    return ProductVariant(
      sku: sku ?? this.sku,
      sizeLabel: sizeLabel ?? this.sizeLabel,
      stockQuantity: stockQuantity ?? this.stockQuantity,
    );
  }
}
