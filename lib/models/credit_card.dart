class CreditCard {
  final int? id;
  final String number;
  final int expiryMonth;
  final int expiryYear;
  final String cvv;
  final String holder;
  final bool saved;

  CreditCard({
    this.id,
    required this.number,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cvv,
    required this.holder,
    this.saved = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'number': number,
      'expiry_month': expiryMonth,
      'expiry_year': expiryYear,
      'cvv': cvv,
      'holder': holder,
      'saved': saved ? 1 : 0,
    };
  }

  factory CreditCard.fromMap(Map<String, dynamic> map) {
    return CreditCard(
      id: map['id'] as int?,
      number: map['number'] as String? ?? '',
      expiryMonth: map['expiry_month'] as int? ?? 1,
      expiryYear: map['expiry_year'] as int? ?? 2030,
      cvv: map['cvv'] as String? ?? '',
      holder: map['holder'] as String? ?? '',
      saved: (map['saved'] as int? ?? 1) == 1,
    );
  }

  String masked() {
    final n = number.replaceAll(RegExp(r'\\s'), '');
    if (n.length < 4) return '****';
    return '**** **** **** ${n.substring(n.length - 4)}';
  }
}
