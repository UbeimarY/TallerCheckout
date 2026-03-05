import 'package:flutter/material.dart';
import '../models/product.dart';
import '../data/database_service.dart';

class CartProvider extends ChangeNotifier {
  final List<Product> _items = [];

  List<Product> get items => _items;
  int get count => _items.length;
  double get total => _items.fold(0, (sum, item) => sum + item.price);

  Future<void> init() async {
    await refresh();
  }

  Future<void> refresh() async {
    final list = await DatabaseService.instance.getCartItems();
    _items
      ..clear()
      ..addAll(list);
    notifyListeners();
  }

  Future<void> add(Product product) async {
    await DatabaseService.instance.addToCart(product.id);
    _items.add(product);
    notifyListeners();
  }

  Future<void> clear() async {
    await DatabaseService.instance.clearCart();
    _items.clear();
    notifyListeners();
  }
}
