import 'package:hive/hive.dart';
part 'payment_info.g.dart';

@HiveType(typeId: 0)
class PaymentInfo {
  @HiveField(0)
  final String cardNumber;
  @HiveField(1)
  final String validUntil;
  @HiveField(2)
  final String cvv;
  @HiveField(3)
  final String cardHolder;
  @HiveField(4)
  final String promoCode;
  @HiveField(5)
  final int paymentMethod;

  PaymentInfo({
    required this.cardNumber,
    required this.validUntil,
    required this.cvv,
    required this.cardHolder,
    required this.promoCode,
    required this.paymentMethod,
  });
}
