// user_model.dart
abstract class UserBase {
  int get id;
  String get username;
  String get password;
  String get email;
  String get type;

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
  late int nomorTelpon;
  late String type;

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
    required this.nomorTelpon,
    required this.type,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? 0,
      username: map['username'] ?? '',
      password: map['password'] ?? '',
      email: map['email'] ?? '',
      namaLengkap: map['namaLengkap'] ?? '',
      alamat: map['alamat'] ?? '',
      umur: map['umur'] ?? 0,
      jenisKelamin: map['jenisKelamin'] ?? '',
      tanggalLahir: map['tanggalLahir'] ?? '',
      nomorTelpon: map['nomorTelpon'] ?? 0,
      type: map['type'] ?? '',
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
      'nomorTelpon': nomorTelpon,
      'type': type,
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
  late String type;

  UserManager({
    required this.username,
    required this.password,
    required this.email,
    required this.type,
  });

  factory UserManager.fromMap(Map<String, dynamic> map) {
    return UserManager(
      username: map['username'],
      password: map['password'],
      email: map['email'],
      type: map['type'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'password': password,
      'email': email,
      'type': type,
    };
  }
}
