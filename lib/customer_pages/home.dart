import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../databaseHelper.dart';
import '../usersAndItemsModel.dart';
import '../login/login.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _bannerImagePath;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadBanner();
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
          // White box behind the navbar
          Container(
            height: 130,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.lightBlue,
                  Colors.lightBlue.withOpacity(0.0), // Fade to transparent
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(5),
                bottomRight: Radius.circular(5),
              ),
            ),
          ),

          // Home page content
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: ListView(
              children: [
                SizedBox(height: 10), // Add space below the app bar

                // Swipeable banner section
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
                                fit: BoxFit
                                    .fill, // Ensure the image covers the entire container
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(0.4), // Light black shadow
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                              border: Border.all(
                                color: Colors.black
                                    .withOpacity(0.1), // Light black outline
                                width: 1,
                              ),
                            ),
                          )
                        : PageView.builder(
                            itemCount: 3,
                            itemBuilder: (context, index) {
                              return Container(
                                width: 120,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(
                                          0.4), // Light black shadow
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                // Add the content of each banner here
                              );
                            },
                          ),
                  ),
                ),

                // Search box
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

                // Dynamic category-wise item display
                FutureBuilder<Map<String, List<Item>>>(
                  future: ItemDatabaseHelper().getItemsByCategory(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                          'Tidak ada barang yang sedang dijual, kembali lagi nanti!',
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
            // Remove the fixed height here
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
        if (isStockAvailable) {
          _showItemDetailsBottomSheet(item, loggedInUser);
        }
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
    int selectedQuantity = 0; // Default quantity
    String? quantityError; // Error message for invalid quantity
    NumberFormat numberFormat = NumberFormat.decimalPattern('id');

    void addToCart() {
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
        print("User Selected Quantity Is $selectedQuantity");
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
                        // Product image on the right-top side
                        Text(
                          item.name,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
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
                    SizedBox(height: 16),
                    // Error text for invalid quantity
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Jumlah: ',
                          style: TextStyle(fontSize: 16),
                        ),
                        // Input field for quantity with error text
                        Container(
                          width: 160,
                          child: TextFormField(
                            initialValue: selectedQuantity.toString(),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              // Update selected quantity when the user types
                              if (value.isEmpty) {
                                selectedQuantity = 0;
                              } else {
                                int parsedValue = int.tryParse(value) ?? 0;
                                selectedQuantity =
                                    parsedValue < 0 ? 0 : parsedValue;
                                // Clear error message if the input is valid
                              }
                              // Update the UI
                              setStateModal(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    // Stretched "Tambah Ke Keranjang" button
                    ElevatedButton(
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
                        padding: MaterialStateProperty.all(EdgeInsets.all(16)),
                        minimumSize:
                            MaterialStateProperty.all<Size>(Size(200, 50)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_cart,
                              color: Colors.white), // Add cart icon
                          SizedBox(
                              width: 8), // Add some space between icon and text
                          Text(
                            'Tambah Ke Keranjang',
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
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
