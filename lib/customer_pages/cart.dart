import 'package:flutter/material.dart';
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
          isSelected: item['isSelected'] == 1,
          imagePath: item['imagePath'],
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: cartItems.isEmpty
          ? Center(
              child: Text("Your cart is empty."),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 4,
                        margin: EdgeInsets.all(8),
                        child: ListTile(
                          title: Text(cartItems[index].name),
                          leading: Checkbox(
                            value: cartItems[index].isSelected,
                            onChanged: (value) {
                              setState(() {
                                cartItems[index].isSelected = value!;
                              });
                              _updateCart(cartItems[index]);
                            },
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              _removeFromCart(cartItems[index]);
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
                      _checkout();
                    },
                    child: Text("Buy"),
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
    // Get selected items and remove them from the cart
    List<CartItem> selectedItems =
        cartItems.where((item) => item.isSelected).toList();

    // This is just a placeholder, you can replace it with your actual buy logic
    if (selectedItems.isNotEmpty) {
      await UserHomeDatabaseHelper().removeSelectedItems(widget.user.id);
      _loadCart();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Purchase Completed."),
            content: Text(
                "Thank you for your purchase of ${selectedItems.length} items."),
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
