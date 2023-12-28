import 'dart:convert';
import 'dart:io';
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
    return Column(
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
          height: 200,
          margin: EdgeInsets.only(bottom: 16),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              Item item = items[index];
              return _buildItemCard(item, loggedInUser);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard(Item item, User loggedInUser) {
    return GestureDetector(
      onTap: () {
        _showItemDetailsBottomSheet(item, loggedInUser);
      },
      child: Container(
        width: 150,
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Rp. ${item.price.toString()}',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _addToCart(Item item, User loggedInUser) async {
    try {
      // Check if the item is already in the cart
      List<Map<String, dynamic>> cartItems =
          await UserHomeDatabaseHelper().getCart(loggedInUser.id);

      bool itemExistsInCart = cartItems.any((cartItem) =>
          cartItem['itemName'] == item.name && cartItem['isSelected'] == 0);

      if (itemExistsInCart) {
        // If the item is already in the cart, update the quantity
        await UserHomeDatabaseHelper().updateCartItem(
          CartItem(
            name: item.name,
            quantity: cartItems.firstWhere(
                  (cartItem) =>
                      cartItem['itemName'] == item.name &&
                      cartItem['isSelected'] == 0,
                )['quantity'] +
                1,
            price: item.price,
            imagePath: item.imagePath,
          ),
        );
      } else {
        // If the item is not in the cart, add it to the cart
        await UserHomeDatabaseHelper().addToCart(
          loggedInUser.id,
          item.name,
          1, // Initial quantity
          item.price,
          item.imagePath!,
        );
      }

      // Show a snackbar to indicate successful addition to the cart
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.name} telah di tambahkan ke keranjang.'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error adding to cart: $e');
    }
  }

  void _showItemDetailsBottomSheet(Item item, User loggedInUser) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Rp. ${item.price.toString()}',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _addToCart(item, loggedInUser);
                },
                child: Text('Tambah Ke Keranjang'),
              ),
            ],
          ),
        );
      },
    );
  }
}
