import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/payment_info.dart';

class PaymentHistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final box = Hive.box<PaymentInfo>('payments');
    return Scaffold(
      appBar: AppBar(title: Text('Historial de Pagos')),
      body: box.isEmpty
          ? Center(child: Text('No hay pagos guardados'))
          : ListView.builder(
              itemCount: box.length,
              itemBuilder: (context, i) {
                final payment = box.getAt(i);
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: Icon(Icons.credit_card, color: Colors.blue),
                    title: Text('Método: ${payment?.paymentMethod == 0 ? 'PayPal' : payment?.paymentMethod == 1 ? 'Credit' : 'Wallet'}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tarjeta: ${payment?.cardNumber ?? ''}'),
                        Text('Titular: ${payment?.cardHolder ?? ''}'),
                        Text('Válida hasta: ${payment?.validUntil ?? ''}'),
                        Text('CVV: ${payment?.cvv ?? ''}'),
                        Text('Promo: ${payment?.promoCode ?? ''}'),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
