// lib/providers/cart_provider.dart
import 'package:flutter/foundation.dart';
import 'package:caffe_pandawa/models/Product.dart';
import 'package:caffe_pandawa/models/CartItems.dart'; // Menggunakan model Anda

class CartProvider extends ChangeNotifier {
  final Map<int, CartItems> _items = {};

  Map<int, CartItems> get items => _items;

  int get itemCount => _items.length;

  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.totalPrice;
    });
    return total;
  }

  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      _items.update(
        product.id,
        (existingItem) {
          existingItem.quantity += 1;
          existingItem.totalHarga = existingItem.totalPrice;
          return existingItem;
        },
      );
    } else {
      final newItem = CartItems(
        product: product,
        quantity: 1,
        totalHarga: product.harga, // totalHarga awal sama dengan harga produk
        isPlusMinusInvisible: false,
      );
      _items.putIfAbsent(product.id, () => newItem);
    }
    notifyListeners();
  }

  void updateQuantity(int productId, double newQuantity) {
    if (_items.containsKey(productId)) {
      if (newQuantity > 0) {
        _items[productId]!.quantity = newQuantity;
      } else {
        _items.remove(productId);
      }
      notifyListeners();
    }
  }

  void removeItem(int productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
