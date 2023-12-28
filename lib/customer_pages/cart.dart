import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:math';
import '../login/login.dart';
import '../databaseHelper.dart';
import '../usersAndItemsModel.dart';

class CartMenu extends StatefulWidget {
  final User user;

  CartMenu({required this.user});

  @override
  _CartMenuState createState() => _CartMenuState();
}

class _CartMenuState extends State<CartMenu> {
  late List<CartItem> cartItems;

  @override
  void initState() {
    super.initState();
    _loadCart();
    cartItems = [];
  }

  Future<void> _loadCart() async {
    final items = await UserHomeDatabaseHelper().getCart(widget.user.id);
    setState(() {
      cartItems = items.map((item) {
        return CartItem(
          id: item['id'],
          name: item['itemName'],
          quantity: item['quantity'],
          price: item['price'],
          isSelected: true, // Set isSelected to true
          imagePath: item['imagePath'],
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    NumberFormat numberFormat = NumberFormat.decimalPattern('id');

    return Scaffold(
      body: cartItems.isEmpty
          ? Center(
              child: Text("Keranjang Anda Kosong."),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      return Dismissible(
                        key: UniqueKey(),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: EdgeInsets.only(right: 16.0),
                            child: Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        onDismissed: (direction) {
                          _removeFromCart(cartItems[index]);
                        },
                        child: Card(
                          elevation: 4,
                          margin: EdgeInsets.all(8),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Item name and type (top left)
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Item name (left top bold)
                                      Text(
                                        cartItems[index].name,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      // Quantity (bottom left)
                                      Text(
                                        'Kuantitas: x${numberFormat.format(cartItems[index].quantity)}',
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                      // Total price (bottom left)
                                      Text(
                                        'Total: Rp ${numberFormat.format(cartItems[index].quantity * cartItems[index].price)}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Item image on the right
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: Image.file(
                                    File(cartItems[index].imagePath!),
                                    height: 80,
                                    width: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      _checkout();
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.blue),
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
                          'Check Out',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void _updateCart(CartItem item) async {
    await UserHomeDatabaseHelper().updateCartItem(item);
  }

  void _removeFromCart(CartItem item) async {
    if (item.id != null) {
      await UserHomeDatabaseHelper().removeFromCart(widget.user.id, item.id!);
      
      _loadCart();
    }
  }

  void _checkout() async {
    NumberFormat numberFormat = NumberFormat.decimalPattern('id');
    bool notificationAdded = false;

    // Get selected items and remove them from the cart
    List<CartItem> selectedItems =
        cartItems.where((item) => item.isSelected).toList();

    if (selectedItems.isNotEmpty) {
      double totalPriceAllItem = 0;

      // Calculate total price of all selected items
      for (var item in selectedItems) {
        totalPriceAllItem += item.quantity * item.price;
      }

      // Build the item list string for the confirmation dialog
      String itemList = "";
      for (var item in selectedItems) {
        itemList +=
            "${item.name}\n${numberFormat.format(item.quantity)} x ${numberFormat.format(item.price)} = Rp. ${numberFormat.format(item.quantity * item.price)}\n\n";
      }

      bool confirm = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Konfirmasi Pembelian"),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(itemList),
                Text(
                    "Semua Obat Ini Bernilai Rp. ${numberFormat.format(totalPriceAllItem)}."),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false); // "Batal"
                },
                child: Text("Batal"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true); // "Gas, Bayar!"
                },
                child: Text("Gas, Bayar!"),
              ),
            ],
          );
        },
      );

      if (confirm == true) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return FutureBuilder(
              future: Future.delayed(
                Duration(
                    seconds:
                        Random().nextInt(6) + 5), // Simulate 5-10 seconds delay
                () => "success",
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (!notificationAdded) {
                    User loggedInUser =
                        Provider.of<UserData>(context, listen: false)
                            .loggedInUser! as User;

                    // Get the names of the selected items
                    List<String> itemNames =
                        selectedItems.map((item) => item.name).toList();

                    // Create the notification message based on the number of items
                    String notificationMessage;
                    if (itemNames.length == 1) {
                      notificationMessage =
                          "Kamu Berhasil Membeli ${itemNames[0]}.";
                    } else if (itemNames.length == 2) {
                      notificationMessage =
                          "Kamu Berhasil Membeli ${itemNames[0]} dan ${itemNames[1]}.";
                    } else {
                      String firstItems =
                          itemNames.sublist(0, itemNames.length - 1).join(', ');
                      String lastItem = itemNames.last;
                      notificationMessage =
                          "Kamu Berhasil Membeli $firstItems, dan $lastItem.";
                    }

                    UserHomeDatabaseHelper().addToNotifications(loggedInUser.id,
                        "Transaksi Sukses!", "Terimakasih telah Berbelanja di YesHealth, " + notificationMessage, "success");
                    notificationAdded = true;
                  }

                  return AlertDialog(
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 64),
                        SizedBox(height: 16),
                        Text("Kamu Berhasil Membeli ${numberFormat.format(selectedItems.length)} Obat.", style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold)),
                        SizedBox(height: 16),
                        Text("Terimakasih Telah Berbelanja di YesHealth!"),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text("OK"),
                      ),
                    ],
                  );
                } else {
                  return AlertDialog(
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text("Sedang Melakukan Pembayaran",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(height: 16),
                        Text("Mohon Tunggu Sebentar",
                            style: TextStyle(fontWeight: FontWeight.normal)),
                      ],
                    ),
                  );
                }
              },
            );
          },
        );
        _loadCart();
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("No items selected."),
            content: Text("Please select items to purchase."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }
}
