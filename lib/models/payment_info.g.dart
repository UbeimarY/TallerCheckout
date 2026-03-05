// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_info.dart';

class PaymentInfoAdapter extends TypeAdapter<PaymentInfo> {
  @override
  final int typeId = 0;

  @override
  PaymentInfo read(BinaryReader reader) {
    return PaymentInfo(
      cardNumber: reader.readString(),
      validUntil: reader.readString(),
      cvv: reader.readString(),
      cardHolder: reader.readString(),
      promoCode: reader.readString(),
      paymentMethod: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, PaymentInfo obj) {
    writer.writeString(obj.cardNumber);
    writer.writeString(obj.validUntil);
    writer.writeString(obj.cvv);
    writer.writeString(obj.cardHolder);
    writer.writeString(obj.promoCode);
    writer.writeInt(obj.paymentMethod);
  }
}
