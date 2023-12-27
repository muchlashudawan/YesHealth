// your_cart.dart
import 'package:flutter/material.dart';

class CartMenu extends StatefulWidget {
  @override
  _CartMenuState createState() => _CartMenuState();
}

class _CartMenuState extends State<CartMenu> {
  List<CartItem> cartItems = [
    CartItem(name: "Item 1", isSelected: false),
    CartItem(name: "Item 2", isSelected: false),
    CartItem(name: "Item 3", isSelected: false),
  ]; // Replace with your actual cart items

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: cartItems.isEmpty
          ? Center(
              child: Text("Keranjang Anda kosong."),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 4, // Add elevation for a shadow effect
                        margin: EdgeInsets.all(8),
                        child: ListTile(
                          title: Text(cartItems[index].name),
                          leading: Checkbox(
                            value: cartItems[index].isSelected,
                            onChanged: (value) {
                              setState(() {
                                cartItems[index].isSelected = value!;
                              });
                            },
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              // Remove item from the cart
                              setState(() {
                                cartItems.removeAt(index);
                              });
                            },
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
                      // Get selected items and remove them from the cart
                      List<CartItem> selectedItems =
                          cartItems.where((item) => item.isSelected).toList();

                      // This is just a placeholder, you can replace it with your actual buy logic
                      if (selectedItems.isNotEmpty) {
                        setState(() {
                          cartItems.removeWhere((item) => item.isSelected);
                        });

                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Pembelian Selesai."),
                              content: Text(
                                  "Terima kasih atas pembelian Anda sebanyak ${selectedItems.length} item."),
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
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Tidak ada item yang dipilih."),
                              content: Text("Silakan pilih item untuk dibeli."),
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
                    },
                    child: Text("Beli"),
                    style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all<Size>(Size(200, 50)),
                    )
                  ),
                ),
              ],
            ),
    );
  }
}

class CartItem {
  final String name;
  bool isSelected;

  CartItem({required this.name, required this.isSelected});
}
