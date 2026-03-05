
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/payment_info.dart';
import 'providers/cart_provider.dart';
import 'screens/product_list_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/confirmation_screen.dart';
import 'screens/payment_history_screen.dart';
import 'data/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(PaymentInfoAdapter());
  await Hive.openBox<PaymentInfo>('payments');
  await DatabaseService.instance.db;
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final cp = CartProvider();
            cp.init();
            return cp;
          },
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Taller Checkout',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => ProductListScreen(),
        '/checkout': (_) => CheckoutScreen(),
        '/confirmation': (_) => ConfirmationScreen(),
        '/history': (_) => PaymentHistoryScreen(),
      },
    );
  }
}
