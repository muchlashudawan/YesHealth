// user_model.dart
abstract class UserBase {
  int get id;
  String get username;
  String get password;
  String get email;
  String get namaLengkap;

  Map<String, dynamic> toMap();
}

class User implements UserBase {
  late int id;
  late String username;
  late String password;
  late String email;
  late String namaLengkap;
  late String alamat;
  late int umur;
  late String jenisKelamin;
  late String tanggalLahir;

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.email,
    required this.namaLengkap,
    required this.alamat,
    required this.umur,
    required this.jenisKelamin,
    required this.tanggalLahir,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      email: map['email'],
      namaLengkap: map['namaLengkap'],
      alamat: map['alamat'],
      umur: map['umur'],
      jenisKelamin: map['jenisKelamin'],
      tanggalLahir: map['tanggalLahir']
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'email': email,
      'namaLengkap': namaLengkap,
      'alamat': alamat,
      'umur': umur,
      'jenisKelamin': jenisKelamin,
      'tanggalLahir': tanggalLahir,
    };
  }
}

class UserManager implements UserBase {
  // Add the id property for UserManager
  @override
  int get id => throw UnimplementedError('UserManager does not have an id');

  late String username;
  late String password;
  late String email;
  late String namaLengkap;

  UserManager({
    required this.username,
    required this.password,
    required this.email,
    required this.namaLengkap,
  });

  factory UserManager.fromMap(Map<String, dynamic> map) {
    return UserManager(
      username: map['username'],
      password: map['password'],
      email: map['email'],
      namaLengkap: map['namaLengkap'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'password': password,
      'email': email,
      'namaLengkap': namaLengkap,
    };
  }
}
