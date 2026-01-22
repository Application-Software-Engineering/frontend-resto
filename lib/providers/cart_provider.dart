import 'package:flutter/material.dart';
import 'package:frontend_resto/models/menu_model.dart';

class CartItem {
  final MenuModel menu;
  int quantity;

  CartItem({required this.menu, this.quantity = 1});

  int get subtotal => menu.price * quantity;
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => _cartItems;

  int get itemCount => _cartItems.length; // Number of unique items, or we could sum quantities. Usually badge shows unique items or total qty. User said "cart ada angkanya", usually total count. Let's assume unique items for now as "2" was in the design. Or maybe specific count? Let's stick to unique items count usually. Or no, food apps usually show total items? Let's go with unique items (e.g. 2 types of food).

  int get totalItems {
     return _cartItems.fold(0, (sum, item) => sum + item.quantity); 
  }

  int get totalPrice => _cartItems.fold(0, (sum, item) => sum + item.subtotal);

  void addToCart(MenuModel menu, int quantity) {
    // Check if item already exists
    final index = _cartItems.indexWhere((item) => item.menu.id == menu.id);
    if (index >= 0) {
      _cartItems[index].quantity += quantity;
    } else {
      _cartItems.add(CartItem(menu: menu, quantity: quantity));
    }
    notifyListeners();
  }

  void removeFromCart(int index) {
    _cartItems.removeAt(index);
    notifyListeners();
  }

  void incrementQuantity(int index) {
    _cartItems[index].quantity++;
    notifyListeners();
  }

  void decrementQuantity(int index) {
    if (_cartItems[index].quantity > 1) {
      _cartItems[index].quantity--;
    } else {
      _cartItems.removeAt(index);
    }
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }
}
