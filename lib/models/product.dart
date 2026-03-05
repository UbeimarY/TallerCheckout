class Product {
  int? id;
  final String name;
  final String description;
  final double price;
  final String image;

  Product({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    this.image = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image': image,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String,
      price: (map['price'] as num).toDouble(),
      image: (map['image'] as String?) ?? '',
    );
  }
}
