import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product.dart';

class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();
  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    final path = await getDatabasesPath();
    final dbPath = join(path, 'checkout.db');
    _db = await openDatabase(dbPath, version: 1, onCreate: _onCreate);
    await _ensureSeeded();
    return _db!;
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products(
        id TEXT PRIMARY KEY,
        name TEXT,
        price REAL,
        imageUrl TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE cart_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id TEXT,
        quantity INTEGER DEFAULT 1
      )
    ''');
  }

  Future _ensureSeeded() async {
    final database = await db;
    final count = Sqflite.firstIntValue(
      await database.rawQuery('SELECT COUNT(*) FROM products'),
    );
    if ((count ?? 0) == 0) {
      final products = [
        Product(
          id: '1',
          name: 'Zapatos',
          price: 120.0,
          imageUrl:
              'https://images.unsplash.com/photo-1519864600265-abb23847ef2c?auto=format&fit=crop&w=400&q=80',
        ),
        Product(
          id: '2',
          name: 'Camisa',
          price: 80.0,
          imageUrl:
              'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?auto=format&fit=crop&w=400&q=80',
        ),
        Product(
          id: '3',
          name: 'Pantalón',
          price: 150.0,
          imageUrl:
              'https://images.unsplash.com/photo-1512436991641-6745cdb1723f?auto=format&fit=crop&w=400&q=80',
        ),
        Product(
          id: '4',
          name: 'Gorra',
          price: 60.0,
          imageUrl:
              'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=400&q=80',
        ),
        Product(
          id: '5',
          name: 'Mochila',
          price: 200.0,
          imageUrl:
              'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80',
        ),
        Product(
          id: '6',
          name: 'Reloj',
          price: 300.0,
          imageUrl:
              'https://images.unsplash.com/photo-1465101046530-73398c7f28ca?auto=format&fit=crop&w=400&q=80',
        ),
      ];
      final batch = database.batch();
      for (final p in products) {
        batch.insert('products', p.toMap());
      }
      await batch.commit(noResult: true);
    }
  }

  Future<List<Product>> getProducts() async {
    final database = await db;
    final maps = await database.query('products', orderBy: 'name ASC');
    return maps.map((m) => Product.fromMap(m)).toList();
  }

  Future<void> addToCart(String productId) async {
    final database = await db;
    await database.insert('cart_items', {'product_id': productId, 'quantity': 1});
  }

  Future<void> clearCart() async {
    final database = await db;
    await database.delete('cart_items');
  }

  Future<List<Product>> getCartItems() async {
    final database = await db;
    final maps = await database.rawQuery('''
      SELECT p.* FROM cart_items c
      JOIN products p ON p.id = c.product_id
      ORDER BY c.id ASC
    ''');
    return maps.map((m) => Product.fromMap(m)).toList();
  }

  Future<double> getCartTotal() async {
    final database = await db;
    final res = await database.rawQuery('''
      SELECT SUM(p.price) as total
      FROM cart_items c
      JOIN products p ON p.id = c.product_id
    ''');
    final v = res.first['total'];
    if (v == null) return 0.0;
    if (v is int) return v.toDouble();
    return v as double;
  }
}
