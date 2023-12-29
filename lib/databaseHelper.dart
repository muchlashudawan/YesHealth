import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'usersAndItemsModel.dart';

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
      databaseFactoryOrNull = null;
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
            title TEXT,
            message TEXT,
            icon TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE user_cart(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId INTEGER,
            itemName TEXT,
            quantity INTEGER,
            isSelected BOOLEAN,
            price INTEGER,
            imagePath TEXT
          )
        ''');
      },
    );
  }

  // CART
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

  Future<void> addToCart(int userId, String itemName, int quantity, int price,
      String imagePath) async {
    try {
      // Check if the item is already in the cart
      CartItem existingCartItem = await getCartItem(userId, itemName);

      if (existingCartItem.id != null) {
        // If the item is already in the cart, update the quantity
        await updateCartItem(
          CartItem(
            id: existingCartItem.id,
            name: itemName,
            quantity: existingCartItem.quantity + quantity,
            price: price,
            imagePath: imagePath,
          ),
        );
      } else {
        // If the item is not in the cart, add it to the cart
        await _addToCartDatabase(userId, itemName, quantity, price, imagePath);
      }
    } catch (e) {
      print('Error adding to cart: $e');
    }
  }

  Future<void> removeFromCart(int userId, int cartItemId) async {
    try {
      // Remove the item from the cart
      await _removeFromCartDatabase(userId, cartItemId);
    } catch (e) {
      print('Error removing from cart: $e');
    }
  }

  Future<void> removeFromCartNoBack(int userId, int cartItemId) async {
    try {
      // Remove the item from the cart
      await _removeFromCartNoBackDatabase(userId, cartItemId);
    } catch (e) {
      print('Error removing from cart: $e');
    }
  }

  Future<void> _addToCartDatabase(int userId, String itemName, int quantity,
      int price, String imagePath) async {
    final db = await database;
    await db.insert('user_cart', {
      'userId': userId,
      'itemName': itemName,
      'quantity': quantity,
      'price': price,
      'imagePath': imagePath
    });
  }

  Future<void> _removeFromCartDatabase(int userId, int cartItemId) async {
    final db = await database;

    // Fetch the cart item before removing it
    CartItem cartItem = await getCartItemById(userId, cartItemId);

    // Remove the item from the cart
    await db.delete('user_cart',
        where: 'userId = ? AND id = ?', whereArgs: [userId, cartItemId]);

    // Add the item back to stock (assuming you have a method for this)
    ItemDatabaseHelper()
        .updateItemQuantity(cartItem.name, cartItem.quantity, "return");
  }

  Future<void> _removeFromCartNoBackDatabase(int userId, int cartItemId) async {
    final db = await database;
    print("Removed Item ${cartItemId} from cart. No Back");

    // Remove the item from the cart
    await db.delete('user_cart',
        where: 'userId = ? AND id = ?', whereArgs: [userId, cartItemId]);
  }

  Future<void> updateItemQuantity(
      String itemName, int quantityChange, String type) async {
    try {
      // Update the item quantity using ItemDatabaseHelper
      await ItemDatabaseHelper()
          .updateItemQuantity(itemName, quantityChange, type);
    } catch (e) {
      print('Error updating item quantity: $e');
    }
  }

  Future<CartItem> getCartItem(int userId, String itemName) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query('user_cart',
        where: 'userId = ? AND itemName = ?', whereArgs: [userId, itemName]);

    if (result.isNotEmpty) {
      return CartItem.fromMap(result.first);
    } else {
      return CartItem(
        name: 'defaultName', // Provide a default name
        quantity: 0, // Provide a default quantity
        price: 0, // Provide a default price
        // Add other required parameters with appropriate default values
      );
    }
  }

  Future<CartItem> getCartItemById(int userId, int cartItemId) async {
    final db = await database;
    List<Map<String, dynamic>> cartItems = await db.query(
      "user_cart",
      where: 'userId = ? AND id = ?',
      whereArgs: [userId, cartItemId],
    );

    if (cartItems.isNotEmpty) {
      return CartItem.fromMap(cartItems.first);
    } else {
      throw Exception('Cart item not found.');
    }
  }

  Future<List<Map<String, dynamic>>> getCart(int userId) async {
    print("Get Cart Executed!");

    final db = await database;
    return db.query('user_cart', where: 'userId = ?', whereArgs: [userId]);
  }

  // WISH LIST
  Future<int> addToWishlist(
      int userId, String itemName, String imagePath) async {
    final db = await database;
    return db.insert('wishlist',
        {'userId': userId, 'itemName': itemName, 'imagePath': imagePath});
  }

  Future<List<Map<String, dynamic>>> getWishlist(int userId) async {
    final db = await database;
    return db.query('wishlist', where: 'userId = ?', whereArgs: [userId]);
  }

  Future<void> removeFromWishlist(
      int userId, String itemName, String imagePath) async {
    final db = await database;
    await db.delete('wishlist',
        where: 'userId = ? AND itemName = ? AND imagePath = ?',
        whereArgs: [userId, itemName, imagePath]);
  }

  // NOTIFICATION
  Future<List<Map<String, dynamic>>> getNotifications(int userId) async {
    final db = await database;
    return db.query('notifications',
        where: 'userId = ?',
        whereArgs: [userId],
        columns: ['id', 'userId', 'title', 'message', 'icon']);
  }

  Future<int> addToNotifications(
      int userId, String title, String message, String icon) async {
    final db = await database;
    final notificationId = await db.insert('notifications', {
      'userId': userId,
      'title': title,
      'message': message,
      'icon': icon,
    });

    bool canVibrate = await Vibrate.canVibrate;

    if (canVibrate) {
      Vibrate.vibrate();
      Vibrate.vibrate();
    }
    return notificationId;
  }

  Future<void> removeNotification(int userId, int notificationId) async {
    final db = await database;
    await db.delete(
      'notifications',
      where: 'userId = ? AND id = ?',
      whereArgs: [userId, notificationId],
    );
  }
}

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
      databaseFactoryOrNull = null;
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
      databaseFactoryOrNull = null;
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
      databaseFactoryOrNull = null;
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
            description TEXT,
            price INTEGER,
            quantity INTEGER,
            imagePath TEXT
          )
        ''');
      },
    );
  }

  Future<int> addItem(Item item) async {
    try {
      final db = await database;

      // Check if an item with the same name and type already exists
      List<Map<String, dynamic>> existingItems = await db.query(
        'items',
        where: 'name = ? AND type = ?',
        whereArgs: [item.name, item.type],
      );

      if (existingItems.isNotEmpty) {
        // If exists, update the quantity instead of adding a new one
        int newQuantity = existingItems[0]['quantity'] + item.quantity;
        item = item.copyWith(quantity: newQuantity, id: existingItems[0]['id']);
        return await updateItem(item);
      } else {
        // If doesn't exist, insert a new item
        return await db.insert('items', {
          'name': item.name,
          'type': item.type,
          'description': item.description, // Added description field
          'price': item.price,
          'quantity': item.quantity,
          'imagePath': item.imagePath,
        });
      }
    } catch (e) {
      print('Error adding item: $e');
      rethrow; // Rethrow the error to propagate it to the calling code
    }
  }

  Future<int> updateItem(Item item) async {
    try {
      final db = await database;

      // Use copyWith to create a new Item with updated quantity
      Item updatedItem = item.copyWith();

      return await db.update(
        'items',
        updatedItem.toMap(),
        where: 'id = ?',
        whereArgs: [updatedItem.id],
      );
    } catch (e) {
      print('Error updating item: $e');
      rethrow;
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
          description: maps[i]['description'],
          price: maps[i]['price'],
          quantity: maps[i]['quantity'],
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
          description: map['description'],
          price: map['price'],
          quantity: map['quantity'],
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

  Future<void> updateItemQuantity(
      String itemName, int quantityChange, String actionType) async {
    try {
      // Fetch the existing item from the database based on the item name
      Item existingItem = await getItemByName(itemName);

      // Calculate the new quantity based on the action type
      int newQuantity;
      if (actionType == "return") {
        // For return, increase the quantity
        newQuantity = existingItem.quantity + quantityChange;
      } else if (actionType == "take") {
        // For take, decrease the quantity
        newQuantity = existingItem.quantity - quantityChange;
      } else {
        // Handle unsupported action type
        throw ArgumentError("Unsupported action type: $actionType");
      }

      print(
          "New Quantity: ${newQuantity} (${actionType}, ${existingItem.quantity} and ${quantityChange})");

      print("Final Quantity: ${newQuantity}");

      // Update the item quantity in the app database
      await updateItem(
        Item(
          id: existingItem.id,
          name: itemName,
          type: existingItem.type,
          description: existingItem.description,
          quantity: newQuantity,
          price: existingItem.price,
          imagePath: existingItem.imagePath,
        ),
      );
    } catch (e) {
      print('Error updating item quantity: $e');
    }

    print("\n");
  }

  Future<Item> getItemByName(String itemName) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'items',
        where: 'name = ?',
        whereArgs: [itemName],
      );

      if (maps.isNotEmpty) {
        return Item(
          id: maps.first['id'],
          name: maps.first['name'],
          type: maps.first['type'],
          description: maps.first['description'],
          price: maps.first['price'],
          quantity: maps.first['quantity'],
          imagePath: maps.first['imagePath'],
        );
      } else {
        throw Exception('Item not found.');
      }
    } catch (e) {
      print('Error getting item by name: $e');
      rethrow;
    }
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
      databaseFactoryOrNull = null;
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
