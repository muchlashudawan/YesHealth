import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../user_model.dart';
import '../login/login.dart';

class HomeManagerPage extends StatelessWidget {
  String getGreeting() {
    DateTime now = DateTime.now();
    int hour = now.hour;

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

  @override
  Widget build(BuildContext context) {
    var userData = Provider.of<UserData>(context, listen: false);

    if (userData.loggedInUser == null) {
      Future.delayed(Duration.zero, () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ),
        );
      });
      return Container(); // Placeholder container, won't be displayed
    }

    void _addItem() async {}
    void _editItem() async {}
    void _deleteItem() async {}
    void _viewItem() async {}

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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                      onPressed: _addItem,
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.black),
                        minimumSize:
                            MaterialStateProperty.all<Size>(Size(150, 50)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add,
                              color: Colors
                                  .white), // Change to the appropriate icon
                          SizedBox(width: 8),
                          Text('Tambah Barang',
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                    SizedBox(height: 8.0),
                    ElevatedButton(
                      onPressed: _viewItem,
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.black),
                        minimumSize:
                            MaterialStateProperty.all<Size>(Size(150, 50)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.visibility,
                              color: Colors
                                  .white), // Change to the appropriate icon
                          SizedBox(width: 8),
                          Text('Lihat Barang',
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                    SizedBox(height: 8.0),
                    ElevatedButton(
                      onPressed: _editItem,
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.black),
                        minimumSize:
                            MaterialStateProperty.all<Size>(Size(150, 50)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.edit,
                              color: Colors
                                  .white), // Change to the appropriate icon
                          SizedBox(width: 8),
                          Text('Ubah Barang',
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                    SizedBox(height: 8.0),
                    ElevatedButton(
                      onPressed: _deleteItem,
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.black),
                        minimumSize:
                            MaterialStateProperty.all<Size>(Size(150, 50)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.delete,
                              color: Colors
                                  .white), // Change to the appropriate icon
                          SizedBox(width: 8),
                          Text('Hapus Barang',
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Center(
          child: Text(
        "Not Logged In",
        style: TextStyle(
          fontSize: 20.0, // Make the text size normal
          fontWeight: FontWeight.w600, // Light font weight
        ),
      ));
    }
  }
}
