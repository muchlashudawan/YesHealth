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

class Item {
  int? id;
  String name;
  String type;
  String description;
  int price;
  int quantity;
  bool isSelected;
  String? imagePath;

  Item(
      {this.id,
      required this.name,
      required this.type,
      required this.description,
      required this.price,
      required this.quantity,
      this.isSelected = false,
      required this.imagePath});

  Item copyWith({
    int? id,
    String? name,
    String? type,
    String? description,
    int? price,
    int? quantity,
    String? imagePath,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'description': description,
      'price': price,
      'quantity': quantity,
      'imagePath': imagePath,
    };
  }
}

class TypeItem {
  int? id;
  String type;

  TypeItem({
    this.id,
    required this.type,
  });

  TypeItem copyWith({
    int? id,
    String? type,
  }) {
    return TypeItem(
      id: id ?? this.id,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
    };
  }
}


class CartItem {
  int? id;
  String name;
  int quantity;
  int price;
  bool isSelected;
  String? imagePath;

  CartItem({
    this.id,
    required this.name,
    required this.quantity,
    required this.price,
    this.isSelected = true,
    this.imagePath,
  });

  CartItem.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        name = map['itemName'],
        quantity = map['quantity'],
        price = map['price'],
        isSelected = map['isSelected'] == 1,
        imagePath = map['imagePath'];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemName': name,
      'quantity': quantity,
      'price': price,
      'isSelected': isSelected ? 1 : 0,
      'imagePath': imagePath,
    };
  }
}

class BannerModel {
  final String filename;

  BannerModel({
    required this.filename,
  });

  Map<String, dynamic> toMap() {
    return {
      'filename': filename,
    };
  }

  factory BannerModel.fromMap(Map<String, dynamic> map) {
    return BannerModel(
      filename: map['filename'],
    );
  }
}
