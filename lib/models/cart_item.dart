import 'product.dart';

class CartItem {
  final String id;
  final Product product;
  final String selectedSize;
  int quantity;

  CartItem({
    required this.id,
    required this.product,
    required this.selectedSize,
    this.quantity = 1,
  });

  int get totalItemPrice => product.rawPrice * quantity;

  Map<String, dynamic> toMap() {
    return {
      'productId': product.id,
      'name': product.name,
      'selectedSize': selectedSize,
      'quantity': quantity,
      'unitPrice': product.rawPrice,
      'image': product.image,
    };
  }
}
