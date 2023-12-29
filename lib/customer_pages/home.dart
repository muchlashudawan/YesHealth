import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shimmer/shimmer.dart';
import '../databaseHelper.dart';
import '../usersAndItemsModel.dart';
import '../login/login.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String? _bannerImagePath;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _loadBanner();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadBanner() async {
    final banners = await BannerDatabaseHelper().getBanners();
    setState(() {
      if (banners.isNotEmpty) {
        _bannerImagePath = banners.first.filename;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    User loggedInUser = Provider.of<UserData>(context).loggedInUser as User;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: 130,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  HexColor("147158"),
                  HexColor("147158").withOpacity(0.0),
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(5),
                bottomRight: Radius.circular(5),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: ListView(
              children: [
                SizedBox(height: 10),
                IgnorePointer(
                  child: Container(
                    height: 170,
                    margin: EdgeInsets.all(10),
                    child: _bannerImagePath != null
                        ? Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                              image: DecorationImage(
                                image: FileImage(File(_bannerImagePath!)),
                                fit: BoxFit.fill,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                              border: Border.all(
                                color: Colors.black.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                          )
                        : Shimmer.fromColors(
                            // Shimmer effect for loading state
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                              ),
                            ),
                          ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: 14),
                      Expanded(
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value.toLowerCase();
                            });
                          },
                          decoration: InputDecoration(
                            hintText: "Search for Drugs...",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.send),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                FutureBuilder<Map<String, List<Item>>>(
                  future: ItemDatabaseHelper().getItemsByCategory(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          height: 300, // Adjust the height based on your design
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: 3,
                            itemBuilder: (context, index) {
                              return Container(
                                width: 120,
                                decoration: BoxDecoration(
                                  color: HexColor("6AB29B"),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                ),
                                // Add the content of each banner here
                              );
                            },
                          ),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                          'No items currently on sale, please check back later!',
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    } else {
                      return Column(
                        children: snapshot.data!.entries.map((entry) {
                          List<Item> filteredItems = entry.value
                              .where((item) => item.name
                                  .toLowerCase()
                                  .contains(_searchQuery))
                              .toList();

                          if (filteredItems.isNotEmpty) {
                            return _buildCategoryItems(
                                entry.key, filteredItems, loggedInUser);
                          } else {
                            return SizedBox.shrink();
                          }
                        }).toList(),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItems(
      String category, List<Item> items, User loggedInUser) {
    return Align(
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Text(
              category,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: items.map((item) {
                  return _buildItemCard(item, loggedInUser);
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(Item item, User loggedInUser) {
    bool isStockAvailable = item.quantity > 0;
    NumberFormat numberFormat = NumberFormat.decimalPattern('id');

    return GestureDetector(
      onTap: () {
        _showItemDetailsBottomSheet(item, loggedInUser);
      },
      child: Container(
        width: 150,
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isStockAvailable ? Colors.white : Colors.grey.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              child: Image.file(
                File(item.imagePath!),
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isStockAvailable ? Colors.black : Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Rp. ${numberFormat.format(item.price)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: isStockAvailable ? Colors.black : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showItemDetailsBottomSheet(Item item, User loggedInUser) {
    int selectedQuantity = 1;
    String? quantityError;
    NumberFormat numberFormat = NumberFormat.decimalPattern('id');
    bool isInWishlist = false;

    Future<void> checkWishlist() async {
      List<Map<String, dynamic>> wishlist =
          await UserHomeDatabaseHelper().getWishlist(loggedInUser.id);

      for (Map<String, dynamic> entry in wishlist) {
        if (entry['itemName'] == item.name &&
            entry['imagePath'] == item.imagePath) {
          setState(() {
            isInWishlist = true;
          });
          break;
        }
      }
    }

    void _showSnackbar(String message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: Duration(seconds: 2),
        ),
      );
    }

    Future<void> addToWishlist() async {
      await UserHomeDatabaseHelper()
          .addToWishlist(loggedInUser.id, item.name, item.imagePath!);
      setState(() {
        isInWishlist = true;
      });
      Navigator.of(context).pop(); // Close the bottom sheet
      _showSnackbar('${item.name} ditambahkan ke Wishlist');
    }

    Future<void> removeFromWishlist() async {
      await UserHomeDatabaseHelper()
          .removeFromWishlist(loggedInUser.id, item.name, item.imagePath!);
      setState(() {
        isInWishlist = false;
      });
      Navigator.of(context).pop(); // Close the bottom sheet
      _showSnackbar('${item.name} dihapus dari Wishlist');
    }

    checkWishlist();

    void addToCart() {
      checkWishlist();
      if (selectedQuantity.isNaN) {
        setState(() {
          quantityError = 'Jumlah yang dimasukkan harus berupa nomor.';
        });
      } else if (selectedQuantity > item.quantity) {
        setState(() {
          quantityError =
              'Jumlah yang dimasukkan lebih dari Jumlah Stok Yang Ada. Anda Bisa Membeli Obat Ini Max Sebanyak ${item.quantity}.';
        });
      } else if (selectedQuantity > 0) {
        Navigator.of(context).pop();
        _addToCart(item, loggedInUser, selectedQuantity);
      } else {
        setState(() {
          quantityError =
              'Jumlah yang dimasukkan tidak valid. Harap masukkan jumlah yang lebih dari 0.';
        });
      }
    }

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateModal) {
            return SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.name,
                          style: TextStyle(
                              fontSize: 26, fontWeight: FontWeight.bold),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(item.imagePath!),
                            height: 80,
                            width: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      item.quantity > 0
                          ? 'Tersedia ${numberFormat.format(item.quantity)} Pack'
                          : 'Obat Habis Terjual',
                      style: TextStyle(
                          fontSize: 16,
                          color: item.quantity > 0 ? Colors.green : Colors.red),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Rp. ${numberFormat.format(item.price)} @ Pack',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 8),
                    Text(item.description),
                    SizedBox(height: 16),
                    Visibility(
                      visible: quantityError != null,
                      child: Text(
                        quantityError ?? '',
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Visibility(
                      visible: item.quantity > 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Jumlah: ',
                            style: TextStyle(fontSize: 16),
                          ),
                          Container(
                            width: 160,
                            child: TextFormField(
                              initialValue: selectedQuantity.toString(),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                if (value.isEmpty) {
                                  selectedQuantity = 0;
                                } else {
                                  int parsedValue = int.tryParse(value) ?? 0;
                                  selectedQuantity =
                                      parsedValue < 0 ? 0 : parsedValue;
                                }
                                setStateModal(() {});
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    Visibility(
                      visible: item.quantity > 0,
                      child: ElevatedButton(
                        onPressed: () {
                          if (selectedQuantity <= item.quantity) {
                            addToCart();
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              selectedQuantity > item.quantity ||
                                      selectedQuantity <= 0
                                  ? Colors.grey
                                  : Colors.blue),
                          padding:
                              MaterialStateProperty.all(EdgeInsets.all(16)),
                          minimumSize:
                              MaterialStateProperty.all<Size>(Size(200, 50)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_cart, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Tambah Ke Keranjang',
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Visibility(
                      visible: item.quantity == 0,
                      child: ElevatedButton(
                        onPressed: () {
                          if (isInWishlist) {
                            removeFromWishlist();
                          } else {
                            addToWishlist();
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              isInWishlist ? Colors.red : Colors.blue),
                          padding:
                              MaterialStateProperty.all(EdgeInsets.all(16)),
                          minimumSize:
                              MaterialStateProperty.all<Size>(Size(200, 50)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isInWishlist
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Colors.white,
                            ),
                            SizedBox(width: 8),
                            Text(
                              isInWishlist
                                  ? 'Hapus dari Wishlist'
                                  : 'Tambahkan ke Wishlist',
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _addToCart(Item item, User loggedInUser, int quantity) async {
    try {
      // Check if the item is already in the cart
      print("User ID: ${loggedInUser.id}");
      List<Map<String, dynamic>> cartItems =
          await UserHomeDatabaseHelper().getCart(loggedInUser.id);

      print("Cart Items: $cartItems");

      bool itemExistsInCart = cartItems.any(
        (cartItem) =>
            cartItem['itemName'] == item.name &&
            cartItem['isSelected'] == false,
      );

      if (itemExistsInCart) {
        // If the item is already in the cart, update the quantity
        await UserHomeDatabaseHelper().updateCartItem(
          CartItem(
            name: item.name,
            quantity: cartItems.firstWhere(
                  (cartItem) =>
                      cartItem['itemName'] == item.name &&
                      cartItem['isSelected'] == false,
                )['quantity'] +
                quantity,
            price: item.price,
            imagePath: item.imagePath,
            isSelected: true, // Set isSelected to true
          ),
        );
      } else {
        // If the item is not in the cart, add it to the cart with isSelected set to true
        await UserHomeDatabaseHelper().addToCart(
          loggedInUser.id,
          item.name,
          quantity,
          item.price,
          item.imagePath!,
        );
      }

      // Show a snackbar to indicate successful addition to the cart
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('${quantity} ${item.name} telah ditambahkan ke keranjang.'),
          duration: Duration(seconds: 2),
        ),
      );
      await ItemDatabaseHelper()
          .updateItemQuantity(item.name, quantity, "take");

      // Refresh the UI or call setState if necessary
      setState(() {});
    } catch (e) {
      print('Error adding to cart: $e');
    }
  }
}
