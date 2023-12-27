import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../user_model.dart';
import '../database_helper.dart';
import '../login/login.dart';
import './addItem.dart';
import './editItem.dart';
import './deleteItem.dart';
import './viewItem.dart';

class HomeManagerPage extends StatefulWidget {
  @override
  _HomeManagerPageState createState() => _HomeManagerPageState();
}

class _HomeManagerPageState extends State<HomeManagerPage> {
  late DateTime _currentTime;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    // Update the time every millisecond
    Timer.periodic(Duration(microseconds: 100), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  String getGreeting() {
    int hour = _currentTime.hour;

    if (hour >= 0 && hour < 12) {
      return 'Selamat Pagi';
    } else if (hour >= 12 && hour < 17) {
      return 'Selamat Siang';
    } else if (hour >= 17 && hour < 19) {
      return 'Selamat Sore';
    } else {
      return 'Selamat Malam';
    }
  }

  String _formatMilliseconds(int milliseconds) {
    return milliseconds.toString().padLeft(2, '0');
  }

  String _formatMicroseconds(int microseconds) {
    // Ensure the microseconds are between 1 and 99
    int formattedMicroseconds = (microseconds % 100).toInt();
    return formattedMicroseconds.toString().padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) {
    var userData = Provider.of<UserData>(context, listen: false);
    UserBase? loggedInUserBase = userData.loggedInUser;

    if (loggedInUserBase != null) {
      UserManager user = loggedInUserBase as UserManager; // Use type cast
      return Scaffold(
        appBar: AppBar(
          title: Text('Manager Panel'),
          backgroundColor: Colors.black,
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                userData.logout();
                Navigator.popUntil(context, (route) => route.isFirst);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  getGreeting() + ",",
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  user.username,
                  style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..shader = LinearGradient(
                        colors: [Colors.blue, Colors.lightBlueAccent],
                      ).createShader(
                        Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
                      ),
                  ),
                ),
                SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: () {
                    _showBottomSheet(context);
                  },
                  child: Text('Menu'),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Center(
        child: Text(
          "Not Logged In",
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
  }
}

void _showBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildBottomSheetButton(
              icon: Icons.add,
              label: 'Tambah Item',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddItemPage()),
                );
              },
            ),
            _buildBottomSheetButton(
              icon: Icons.visibility,
              label: 'Lihat Item',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewItemPage()),
                );
              },
            ),
            _buildBottomSheetButton(
              icon: Icons.edit,
              label: 'Ubah Item',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditItemPage()),
                );
              },
            ),
            _buildBottomSheetButton(
              icon: Icons.delete,
              label: 'Hapus Item',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DeleteItemPage()),
                );
              },
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildBottomSheetButton({
  required IconData icon,
  required String label,
  required VoidCallback onPressed,
}) {
  return ListTile(
    onTap: onPressed,
    leading: Icon(icon),
    title: Text(label),
  );
}

void _editItem() async {
  print("Edited Item");

  // Show a dialog or navigate to a page to collect item details
  // Create an updated Item object with the collected details
  Item updatedItem = Item(id: 1, name: 'Updated Item', type: 'Type', price: 10);

  // Update the item in the database
  await ItemDatabaseHelper().updateItem(updatedItem);

  // Refresh the UI or show a success message
}

void _deleteItem() async {
  print("Deleted Item");

  int itemIdToDelete = 1; // Replace with the actual item ID
  await ItemDatabaseHelper().deleteItem(itemIdToDelete);

  // Refresh the UI or show a success message
}

void _viewItem() async {
  print("Viewing Items");

  List<Item> items = await ItemDatabaseHelper().getItems();

  // Display items in a list or grid
  for (var item in items) {
    print('Item: ${item.name}, Type: ${item.type}, Price: ${item.price}');
  }
}
