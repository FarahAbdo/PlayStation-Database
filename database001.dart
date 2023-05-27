import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

Future<Database> open() async {
  final databasePath = await getDatabasesPath();
  final databaseName = 'app.db';
  final database = await openDatabase(
    join(databasePath, databaseName),
    onCreate: (db, version) async {
      await db.execute('''
CREATE TABLE games (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  description TEXT,
  image_url TEXT,
  price REAL,
  release_date TEXT,
  developer TEXT,
  publisher TEXT )
''');
      await db.execute('''
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  password TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP )
''');
      await db.execute('''
CREATE TABLE orders (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  game_id INTEGER NOT NULL,
  quantity INTEGER NOT NULL,
  price REAL NOT NULL,
  status TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP )
''');
      await db.execute('''
CREATE TABLE products (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  picture TEXT NOT NULL,
  description TEXT,
  price REAL,
  quantity INTEGER)
''');
      await db.execute('''
CREATE TABLE services (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  description TEXT,
  price REAL )
''');
    },
    version: 1,
  );
  return database;
}

// ... other functions

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DatabaseController _databaseController;

  @override
  void initState() {
    super.initState();
    _databaseController = DatabaseController();
    _databaseController.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Database Integration'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Total Cost'),
            Text(
              _databaseController.getTotalCost().toString(),
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class DatabaseController {
  Database _database;

  Future<void> init() async {
   _database = await open();

    // Sample data insertion, you can remove this if not needed
    await _database.transaction((txn) async {
      await txn.insert('games', {
        'name': 'Game 1',
        'description': 'Game description 1',
        'price': 29.99,
        'image_url': 'https://example.com/game1.png',
      });
      await txn.insert('users', {
        'first_name': 'John',
        'last_name': 'Doe',
        'password': 'password',
      });
    });
  }

  Future<double> getTotalCost() async {
    if (_database == null) {
      return 0.0;
    }
    List<Map<String, dynamic>> result = await _database.rawQuery('SELECT SUM(price * quantity) as total_cost FROM orders');
    if (result.isEmpty) {
      return 0.0;
    }
    return result.first['total_cost'] as double;
  }
    // products
  Future<void> insertProduct(Product product) async {
    final database = await open();
    await database.insert('products', product.toMap());
  }

  Future<void> updateProduct(Product product) async {
    final database = await open();
    await database.update('products', product.toMap(), where: 'id = ?', whereArgs: [product.id]);
  }

  Future<void> deleteProduct(int id) async {
    final database = await open();
    await database.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Product>> getAllProducts() async {
    final database = await open();
    final products = await database.query('products');
    return products.map((product) => Product.fromMap(product)).toList();
  }

  Future<Product> getProductById(int id) async {
    final database = await open();
    final product = await database.query('products', where: 'id = ?', whereArgs: [id]);
    return product.isNotEmpty ? Product.fromMap(product.first) : null;
  }

}


class Product {
  final int id;
  final String name;
  final String picture;
  final String description;
  final double price;
  final int quantity;

  Product({
    this.id,
    this.name,
    this.picture,
    this.description,
    this.price,
    this.quantity,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      picture: map['picture'],
      description: map['description'],
      price: map['price'],
      quantity: map['quantity'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'picture': picture,
      'description': description,
      'price': price,
      'quantity': quantity,
    };
  }
}

class Service {
  final int id;
  final String name;
  final String description;
  final double price;

  Service({
    this.id,
    this.name,
    this.description,
    this.price,
  });

  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      price: map['price'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
    };
  }
}