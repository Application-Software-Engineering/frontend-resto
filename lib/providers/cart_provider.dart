import 'package:flutter/material.dart';

class CartProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _cartItems = [];

  List<Map<String, dynamic>> get cartItems => _cartItems;

  int get itemCount => _cartItems.fold(0, (sum, item) => sum + (item['qty'] as int));

  int get totalPrice => _cartItems.fold(0, (sum, item) {
        final price = item['price'] as int;
        final qty = item['qty'] as int;
        return sum + (price * qty);
      });

  void addToCart(Map<String, dynamic> menuItem, int qty) {
    final existingIndex = _cartItems.indexWhere(
      (item) => item['id'] == menuItem['id'],
    );

    if (existingIndex >= 0) {
      _cartItems[existingIndex]['qty'] += qty;
    } else {
      _cartItems.add({
        'id': menuItem['id'],
        'name': menuItem['name'],
        'price': menuItem['price'],
        'image': menuItem['image'],
        'qty': qty,
      });
    }
    notifyListeners();
  }

  void removeFromCart(int menuId) {
    _cartItems.removeWhere((item) => item['id'] == menuId);
    notifyListeners();
  }

  void updateqty(int menuId, int newqty) {
    final index = _cartItems.indexWhere((item) => item['id'] == menuId);
    if (index >= 0) {
      if (newqty <= 0) {
        _cartItems.removeAt(index);
      } else {
        _cartItems[index]['qty'] = newqty;
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }
}
