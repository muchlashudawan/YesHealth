import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:path/path.dart';
import './user_model.dart';

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
    }

    //databaseFactory = databaseFactoryFfi;

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
