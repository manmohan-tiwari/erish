import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  bool _isCartDrawerOpen = false;

  static const int freeShippingThreshold = 2500;

  List<CartItem> get items => List.unmodifiable(_items);
  bool get isCartDrawerOpen => _isCartDrawerOpen;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  int get totalAmount =>
      _items.fold(0, (sum, item) => sum + item.totalItemPrice);

  bool get hasFreeShipping => totalAmount >= freeShippingThreshold;

  int get amountUntilFreeShipping =>
      (freeShippingThreshold - totalAmount).clamp(0, freeShippingThreshold);

  double get freeShippingProgress =>
      (totalAmount / freeShippingThreshold).clamp(0.0, 1.0);

  int get standardShippingFee =>
      hasFreeShipping ? 0 : (_items.isEmpty ? 0 : 99);

  String get formattedTotal =>
      '₹${totalAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';

  void toggleCartDrawer() {
    _isCartDrawerOpen = !_isCartDrawerOpen;
    notifyListeners();
  }

  void openCartDrawer() {
    _isCartDrawerOpen = true;
    notifyListeners();
  }

  void closeCartDrawer() {
    _isCartDrawerOpen = false;
    notifyListeners();
  }

  void addItem(Product product, String size) {
    final existingIndex = _items.indexWhere(
      (item) => item.product.id == product.id && item.selectedSize == size,
    );

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += 1;
    } else {
      _items.add(
        CartItem(
          id: '${product.id}_$size',
          product: product,
          selectedSize: size,
        ),
      );
    }
    notifyListeners();
  }

  void updateQuantity(int index, int newQty) {
    if (index >= 0 && index < _items.length) {
      if (newQty <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = newQty;
      }
      notifyListeners();
    }
  }

  void removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
