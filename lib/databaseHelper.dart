import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'usersAndItemsModel.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  late Database _database;

  Future<Database> get database async {
    _database = await initDatabase();
    return _database;
  }

  Future<Database> initDatabase() async {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final path = join(await getDatabasesPath(), 'user_database.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
         CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT,
            password TEXT,
            email TEXT,
            namaLengkap TEXT,
            alamat TEXT,
            umur INTEGER,
            jenisKelamin TEXT,
            tanggalLahir TEXT,
            nomorTelpon INTEGER,
            type TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;

    // Query the maximum id from the existing users
    var result = await db.rawQuery('SELECT MAX(id) as maxId FROM users');
    int nextId = (result.first['maxId'] as int?) ?? 0;

    // Set the id of the new user
    user['id'] = nextId + 1;

    // Insert the user into the database
    return await db.insert('users', user);
  }

  Future<User?> getUser(String username, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<User?> getUserByUsername(String username) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    } else {
      return null;
    }
  }
}

class ManagerDatabaseHelper extends DatabaseHelper {
  static final ManagerDatabaseHelper _managerInstance =
      ManagerDatabaseHelper._internal();

  factory ManagerDatabaseHelper() {
    return _managerInstance;
  }

  ManagerDatabaseHelper._internal() : super._internal();

  @override
  Future<Database> initDatabase() async {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final path = join(await getDatabasesPath(), 'manager_database.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE managers(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT,
            password TEXT,
            email TEXT,
            namaLengkap TEXT,
            type TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertManager(Map<String, dynamic> manager) async {
    final db = await database;

    // Query the maximum id from the existing managers
    var result = await db.rawQuery('SELECT MAX(id) as maxId FROM managers');
    int nextId = (result.first['maxId'] as int?) ?? 0;

    // Set the id of the new manager
    manager['id'] = nextId + 1;

    // Insert the manager into the database
    return await db.insert('managers', manager);
  }

  Future<UserManager?> getManager(String username, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'managers',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (maps.isNotEmpty) {
      return UserManager.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<UserManager?> getManagerByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'managers',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return UserManager.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<UserManager?> getManagerByUsername(String username) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'managers',
      where: 'username = ?',
      whereArgs: [username],
    );

    if (maps.isNotEmpty) {
      return UserManager.fromMap(maps.first);
    } else {
      return null;
    }
  }
}

class ItemDatabaseHelper {
  static final ItemDatabaseHelper _instance = ItemDatabaseHelper._internal();

  factory ItemDatabaseHelper() {
    return _instance;
  }

  ItemDatabaseHelper._internal();

  late Database _database;

  Future<Database> get database async {
    _database = await initDatabase();
    return _database;
  }

  Future<Database> initDatabase() async {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final path = join(await getDatabasesPath(), 'items_database.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE items(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            type TEXT,
            price INTEGER,
            imagePath TEXT
          )
        ''');
      },
    );
  }

  Future<int> addItem(Item item) async {
    final db = await database;
    return db.insert('items', item.toMap());
  }

  Future<int> updateItem(Item item) async {
    try {
      final db = await database;
      return await db.update(
        'items',
        item.toMap(),
        where: 'id = ?',
        whereArgs: [item.id],
      );
    } catch (e) {
      print('Error updating item: $e');
      rethrow; // Rethrow the error to propagate it to the calling code
    }
  }

  Future<int> deleteItem(int itemId) async {
    try {
      final db = await database;
      return await db.delete('items', where: 'id = ?', whereArgs: [itemId]);
    } catch (e) {
      print('Error deleting item: $e');
      rethrow; // Rethrow the error to propagate it to the calling code
    }
  }

  Future<List<Item>> getItems() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('items');

      return List.generate(maps.length, (i) {
        return Item(
          id: maps[i]['id'],
          name: maps[i]['name'],
          type: maps[i]['type'],
          price: maps[i]['price'],
          imagePath: maps[i]['imagePath'],
        );
      });
    } catch (e) {
      print('Error getting items: $e');
      rethrow; // Rethrow the error to propagate it to the calling code
    }
  }

  Future<Map<String, List<Item>>> getItemsByCategory() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('items');

      Map<String, List<Item>> categoryMap = {};

      for (var map in maps) {
        Item item = Item(
          id: map['id'],
          name: map['name'],
          type: map['type'],
          price: map['price'],
          imagePath: map['imagePath'],
        );

        if (!categoryMap.containsKey(item.type)) {
          categoryMap[item.type] = [];
        }

        categoryMap[item.type]!.add(item);
      }

      return categoryMap;
    } catch (e) {
      print('Error getting items by category: $e');
      rethrow; // Rethrow the error to propagate it to the calling code
    }
  }

  Future<List<String>> getCategories() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('items');

      Set<String> categories = {};

      for (var map in maps) {
        String category = map['type'];
        categories.add(category);
      }

      return categories.toList();
    } catch (e) {
      print('Error getting categories: $e');
      rethrow; // Rethrow the error to propagate it to the calling code
    }
  }
}

// databaseHelper.dart
class UserHomeDatabaseHelper {
  static final UserHomeDatabaseHelper _instance =
      UserHomeDatabaseHelper._internal();

  factory UserHomeDatabaseHelper() {
    return _instance;
  }

  UserHomeDatabaseHelper._internal();

  late Database _database;

  Future<Database> get database async {
    _database = await initDatabase();
    return _database;
  }

  Future<Database> initDatabase() async {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final path = join(await getDatabasesPath(), 'users_home.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE wishlist(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId INTEGER,
            itemName TEXT,
            imagePath TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE notifications(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId INTEGER,
            message TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE user_cart(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId INTEGER,
            itemName TEXT,
            quantity INTEGER,
            price INTEGER,
            imagePath TEXT
          )
        ''');
      },
    );
  }

  Future<void> updateCartItem(CartItem item) async {
    print("Update Cart Item Executed!");

    final db = await database;
    await db.update(
      'user_cart',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<void> removeSelectedItems(int userId) async {
    print("Remove Selected Items Executed!");

    final db = await database;
    await db.delete(
      'user_cart',
      where: 'userId = ? AND isSelected = ?',
      whereArgs: [userId, 1],
    );
  }

  Future<void> removeFromCart(int userId, int cartItemId) async {
    print("Remove From Cart Executed!");

    final db = await database;
    await db.delete(
      'user_cart',
      where: 'userId = ? AND id = ?',
      whereArgs: [userId, cartItemId],
    );
  }

  Future<int> addToWishlist(
      int userId, String itemName, String imagePath) async {
    final db = await database;
    return db.insert('wishlist',
        {'userId': userId, 'itemName': itemName, 'imagePath': imagePath});
  }

  Future<int> addToNotifications(int userId, String message) async {
    final db = await database;
    return db.insert('notifications', {'userId': userId, 'message': message});
  }

  Future<int> addToCart(int userId, String itemName, int quantity, int price,
      String imagePath) async {
      print("Add to Cart Executed!");

    final db = await database;
    return db.insert('user_cart', {
      'userId': userId,
      'itemName': itemName,
      'quantity': quantity,
      'price': price,
      'imagePath': imagePath
    });
  }

  Future<List<Map<String, dynamic>>> getWishlist(int userId) async {
    final db = await database;
    return db.query('wishlist', where: 'userId = ?', whereArgs: [userId]);
  }

  Future<List<Map<String, dynamic>>> getNotifications(int userId) async {
    final db = await database;
    return db.query('notifications', where: 'userId = ?', whereArgs: [userId]);
  }

  Future<List<Map<String, dynamic>>> getCart(int userId) async {
      print("Get Cart Executed!");

    final db = await database;
    return db.query('user_cart', where: 'userId = ?', whereArgs: [userId]);
  }
}

class BannerDatabaseHelper {
  static final BannerDatabaseHelper _instance =
      BannerDatabaseHelper._internal();

  factory BannerDatabaseHelper() {
    return _instance;
  }

  BannerDatabaseHelper._internal();

  late Database _database;

  Future<Database> get database async {
    _database = await initDatabase();
    return _database;
  }

  Future<Database> initDatabase() async {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final path = join(await getDatabasesPath(), 'banners_database.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE banners(
            filename TEXT
          )
        ''');
      },
    );
  }

  Future<int> addBanner(BannerModel bannerModel) async {
    final db = await database;
    return db.insert('banners', bannerModel.toMap());
  }

  Future<int> updateBanner(BannerModel bannerModel) async {
    try {
      final db = await database;
      return await db.update(
        'banners',
        bannerModel.toMap(),
        where: 'filename = ?', // Update based on filename instead of id
        whereArgs: [bannerModel.filename],
      );
    } catch (e) {
      print('Error updating bannerModel: $e');
      rethrow; // Rethrow the error to propagate it to the calling code
    }
  }

  Future<int> deleteBanner(String filename) async {
    try {
      final db = await database;
      return await db
          .delete('banners', where: 'filename = ?', whereArgs: [filename]);
    } catch (e) {
      print('Error deleting bannerModel: $e');
      rethrow; // Rethrow the error to propagate it to the calling code
    }
  }

  Future<List<BannerModel>> getBanners() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('banners');

      return List.generate(maps.length, (i) {
        return BannerModel.fromMap(maps[i]);
      });
    } catch (e) {
      print('Error getting banners: $e');
      rethrow; // Rethrow the error to propagate it to the calling code
    }
  }
}
