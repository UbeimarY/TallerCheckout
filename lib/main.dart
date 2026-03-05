import 'package:flutter/material.dart';
import 'models/product.dart';
import 'models/credit_card.dart';
import 'database_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'checkout',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5A5FEA)),
        useMaterial3: false,
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
      ),
      routes: {
        '/': (_) => const ProductsScreen(),
        '/payment': (_) => const PaymentDataScreen(),
        '/confirm': (_) => const PaymentConfirmScreen(),
      },
    );
  }
}

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final db = DatabaseHelper.instance;
  List<Product> products = [];
  int cartCount = 0;
  double total = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await db.getProducts();
    final count = await db.getCartCount();
    final t = await db.getCartTotal();
    setState(() {
      products = list;
      cartCount = count;
      total = t;
    });
  }

  Future<void> _add(Product p) async {
    await db.addToCart(p.id!, 1);
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${p.name} añadido al carrito')));
  }

  void _showDetails(Product p) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    p.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '\$${p.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF5A5FEA),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(p.description),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _add(p);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5A5FEA),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Añadir al carrito'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        actions: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/payment',
                ).then((_) => _load()),
              ),
              if (cartCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF5A5FEA),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$cartCount',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5A5FEA), Color(0xFF7A7EF5)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x225A5FEA),
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total del carrito',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: .78,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: products.length,
                itemBuilder: (_, i) {
                  final p = products[i];
                  return GestureDetector(
                    onTap: () => _showDetails(p),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 10,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Center(
                                child: Text(
                                  p.image.isNotEmpty ? p.image : '🛍️',
                                  style: const TextStyle(fontSize: 36),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              p.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$${p.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Color(0xFF5A5FEA),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => _add(p),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFEEF0FF),
                                  foregroundColor: const Color(0xFF5A5FEA),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                ),
                                child: const Text('Añadir'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentDataScreen extends StatefulWidget {
  const PaymentDataScreen({super.key});

  @override
  State<PaymentDataScreen> createState() => _PaymentDataScreenState();
}

class _PaymentDataScreenState extends State<PaymentDataScreen> {
  final db = DatabaseHelper.instance;
  final numberCtrl = TextEditingController();
  final monthCtrl = TextEditingController();
  final yearCtrl = TextEditingController();
  final cvvCtrl = TextEditingController();
  final holderCtrl = TextEditingController();
  bool saveCard = true;
  double total = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final t = await db.getCartTotal();
    final saved = await db.getLatestCreditCard();
    setState(() {
      total = t;
      if (saved != null) {
        numberCtrl.text = saved.number;
        monthCtrl.text = saved.expiryMonth.toString().padLeft(2, '0');
        yearCtrl.text = saved.expiryYear.toString();
        holderCtrl.text = saved.holder;
      }
    });
  }

  @override
  void dispose() {
    numberCtrl.dispose();
    monthCtrl.dispose();
    yearCtrl.dispose();
    cvvCtrl.dispose();
    holderCtrl.dispose();
    super.dispose();
  }

  Future<void> _proceed() async {
    final card = CreditCard(
      number: numberCtrl.text,
      expiryMonth: int.tryParse(monthCtrl.text) ?? 1,
      expiryYear: int.tryParse(yearCtrl.text) ?? 2030,
      cvv: cvvCtrl.text,
      holder: holderCtrl.text,
      saved: saveCard,
    );
    if (saveCard) {
      await db.saveCreditCard(card);
    }
    if (!mounted) return;
    Navigator.pushNamed(context, '/confirm', arguments: card);
  }

  Widget _methodChip(String label, bool selected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF5A5FEA) : const Color(0xFFE9EBF5),
        borderRadius: BorderRadius.circular(18),
        boxShadow: selected
            ? [
                const BoxShadow(
                  color: Color(0x335A5FEA),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xFF5A5FEA),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          Icon(
            Icons.check_circle,
            size: 16,
            color: selected ? Colors.white : const Color(0xFF5A5FEA),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.pop(context)),
        title: const Text('Payment data'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Total price', style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 6),
            Text(
              '\$${total.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 36,
                color: Color(0xFF5A5FEA),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Payment Method'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _methodChip('PayPal', false),
                _methodChip('Credit', true),
                _methodChip('Wallet', false),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: numberCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Card number',
                prefixIcon: const Icon(Icons.credit_card),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: monthCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Month',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: yearCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Year',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: cvvCtrl,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'CVV',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: holderCtrl,
              decoration: InputDecoration(
                labelText: 'Card holder',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Save card data for future payments'),
                Switch(
                  value: saveCard,
                  onChanged: (v) => setState(() => saveCard = v),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _proceed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5A5FEA),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Proceed to confirm'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentConfirmScreen extends StatefulWidget {
  const PaymentConfirmScreen({super.key});

  @override
  State<PaymentConfirmScreen> createState() => _PaymentConfirmScreenState();
}

class _PaymentConfirmScreenState extends State<PaymentConfirmScreen> {
  final db = DatabaseHelper.instance;
  final promoCtrl = TextEditingController();
  double total = 0;
  CreditCard? card;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final t = await db.getCartTotal();
    setState(() {
      total = t;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is CreditCard) card = arg;
  }

  @override
  void dispose() {
    promoCtrl.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    await db.clearCart();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Pago realizado')));
    Navigator.popUntil(context, ModalRoute.withName('/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.pop(context)),
        title: const Text('Payment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF5A5FEA),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x335A5FEA),
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '\$50 off',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'On your first order',
                    style: TextStyle(color: Colors.white70),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '* Promo code valid for orders over \$150.',
                    style: TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Payment information'),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Edit'),
                ),
              ],
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 10,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.credit_card, color: Color(0xFF5A5FEA)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      card != null
                          ? 'Card holder\n${card!.masked()}'
                          : 'No card selected',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Use promo code'),
            const SizedBox(height: 8),
            TextField(
              controller: promoCtrl,
              decoration: InputDecoration(
                hintText: 'PROMO20-08',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total'),
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _pay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5A5FEA),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Pay'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
