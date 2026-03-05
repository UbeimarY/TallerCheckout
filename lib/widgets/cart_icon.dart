import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class CartIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    int count = Provider.of<CartProvider>(context).count;
    return Stack(
      children: [
        IconButton(
          icon: Icon(Icons.shopping_cart),
          onPressed: () => Navigator.pushNamed(context, '/checkout'),
        ),
        if (count > 0)
          Positioned(
            right: 0,
            child: CircleAvatar(
              radius: 10,
              backgroundColor: Colors.red,
              child: Text('$count', style: TextStyle(fontSize: 12, color: Colors.white)),
            ),
          ),
      ],
    );
  }
}
