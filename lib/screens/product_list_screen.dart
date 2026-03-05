import 'package:flutter/material.dart';
import '../models/product.dart';
import '../data/database_service.dart';
import '../widgets/product_card.dart';
import '../widgets/cart_icon.dart';

class ProductListScreen extends StatefulWidget {
  ProductListScreen({super.key});
  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Product> _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await DatabaseService.instance.getProducts();
    setState(() {
      _products = items;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Productos'),
        actions: [
          CartIcon(),
          IconButton(
            icon: Icon(Icons.history),
            tooltip: 'Ver historial de pagos',
            onPressed: () => Navigator.pushNamed(context, '/history'),
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: GridView.builder(
                padding: EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.7,
                ),
                itemCount: _products.length,
                itemBuilder: (_, i) => ProductCard(product: _products[i]),
              ),
            ),
    );
  }
}
