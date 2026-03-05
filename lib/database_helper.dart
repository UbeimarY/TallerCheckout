import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'models/product.dart';
import 'models/cart_item.dart';
import 'models/credit_card.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = await getDatabasesPath();
    final dbPath = join(path, 'checkout.db');
    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        price REAL NOT NULL,
        image TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE cart_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        FOREIGN KEY(product_id) REFERENCES products(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE credit_cards(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        number TEXT,
        expiry_month INTEGER,
        expiry_year INTEGER,
        cvv TEXT,
        holder TEXT,
        saved INTEGER
      )
    ''');
    await _seedProducts(db);
  }

  Future<void> _seedProducts(Database db) async {
    final products = [
      Product(name: 'Zapatillas Nova', description: 'Diseño cómodo y liviano', price: 79.99, image: '👟'),
      Product(name: 'Auriculares Beat', description: 'Sonido envolvente', price: 59.50, image: '🎧'),
      Product(name: 'Smartwatch Air', description: 'Monitoreo de salud', price: 129.00, image: '⌚'),
      Product(name: 'Mochila Pro', description: 'Resistente al agua', price: 45.25, image: '🎒'),
      Product(name: 'Camiseta Sport', description: 'Tela transpirable', price: 24.99, image: '👕'),
      Product(name: 'Botella Térmica', description: 'Acero inoxidable', price: 19.90, image: '🧴'),
    ];
    for (final p in products) {
      await db.insert('products', p.toMap());
    }
  }

  Future<List<Product>> getProducts() async {
    final db = await database;
    final maps = await db.query('products', orderBy: 'id DESC');
    return maps.map((e) => Product.fromMap(e)).toList();
  }

  Future<int> addToCart(int productId, int qty) async {
    final db = await database;
    final existing = await db.query('cart_items', where: 'product_id=?', whereArgs: [productId], limit: 1);
    if (existing.isNotEmpty) {
      final id = existing.first['id'] as int;
      final current = existing.first['quantity'] as int;
      return db.update('cart_items', {'quantity': current + qty}, where: 'id=?', whereArgs: [id]);
    } else {
      return db.insert('cart_items', {'product_id': productId, 'quantity': qty});
    }
  }

  Future<List<CartItem>> getCartItems() async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT ci.id, ci.product_id, ci.quantity, p.name, p.description, p.price, p.image
      FROM cart_items ci
      JOIN products p ON p.id = ci.product_id
      ORDER BY ci.id DESC
    ''');
    return rows.map((r) {
      final p = Product(
        id: r['product_id'] as int,
        name: r['name'] as String,
        description: r['description'] as String,
        price: (r['price'] as num).toDouble(),
        image: (r['image'] as String?) ?? '',
      );
      return CartItem(id: r['id'] as int, product: p, quantity: r['quantity'] as int);
    }).toList();
  }

  Future<int> getCartCount() async {
    final db = await database;
    final res = await db.rawQuery('SELECT COALESCE(SUM(quantity),0) as c FROM cart_items');
    return (res.first['c'] as int?) ?? 0;
    }

  Future<double> getCartTotal() async {
    final db = await database;
    final res = await db.rawQuery('''
      SELECT COALESCE(SUM(ci.quantity * p.price),0) as t
      FROM cart_items ci JOIN products p ON p.id = ci.product_id
    ''');
    final v = res.first['t'];
    if (v is int) return v.toDouble();
    if (v is double) return v;
    if (v is num) return v.toDouble();
    return 0;
  }

  Future<void> clearCart() async {
    final db = await database;
    await db.delete('cart_items');
  }

  Future<int> saveCreditCard(CreditCard card) async {
    final db = await database;
    return db.insert('credit_cards', card.toMap());
  }

  Future<CreditCard?> getLatestCreditCard() async {
    final db = await database;
    final rows = await db.query('credit_cards', orderBy: 'id DESC', limit: 1);
    if (rows.isEmpty) return null;
    return CreditCard.fromMap(rows.first);
  }
}
