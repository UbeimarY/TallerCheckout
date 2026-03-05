import 'product.dart';

class CartItem {
  final int id;
  final Product product;
  final int quantity;

  CartItem({required this.id, required this.product, required this.quantity});
}
