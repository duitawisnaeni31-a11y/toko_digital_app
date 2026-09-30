import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // Pembuatan Basis Data & Tabel SQLite
  Future<Database> _initDB() async {
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'toko_digital.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // 1. Tabel master_products (id, name, price)
        await db.execute('''
          CREATE TABLE master_products (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            price REAL
          )
        ''');

        // 2. Tabel local_cart (id, product_id, name, price, quantity)
        await db.execute('''
          CREATE TABLE local_cart (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            product_id INTEGER,
            name TEXT,
            price REAL,
            quantity INTEGER
          )
        ''');
      },
    );
  }

  // Operasi Database Keranjang Belanja
  Future<List<Map<String, dynamic>>> getCartItems() async {
    final db = await database;
    return await db.query('local_cart');
  }

  Future<int> insertCart(Map<String, dynamic> item) async {
    final db = await database;
    return await db.insert('local_cart', item);
  }

  Future<int> updateCartQuantity(int id, int quantity) async {
    final db = await database;
    return await db.update('local_cart', {'quantity': quantity}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteCartItem(int id) async {
    final db = await database;
    return await db.delete('local_cart', where: 'id = ?', whereArgs: [id]);
  }
}