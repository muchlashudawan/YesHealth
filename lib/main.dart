// Add these imports if not already present
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_size/window_size.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:badges/badges.dart' as badges;
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:async';

import 'customer_pages/home.dart';
import 'customer_pages/cart.dart';
import 'customer_pages/profile.dart';
import 'login/login.dart';
import 'usersAndItemsModel.dart';
import 'databaseHelper.dart';
import 'usersAndItemsModel.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows) {
    // setWindowMaxSize(const Size(1024, 768));
    // setWindowMinSize(const Size(512, 384));
    // Future<Null>.delayed(Duration(seconds: 1), () {
    //   setWindowFrame(
    //       Rect.fromCenter(center: Offset(1000, 500), width: 600, height: 1000));
    // });
  }
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserData(),
      child: MyApp(),
    ),
  );
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Your splash screen content
    return _buildSplashScreen();
  }

  Widget _buildSplashScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your logo or splash screen image
            Image.asset(
              'assets/logo_512.png',
              width: 200,
              height: 200,
            ),
            Text(
              "YesHealth",
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: HexColor("147158")),
            ),
            SizedBox(height: 20),
            // Loading indicator or any other content
            CircularProgressIndicator(color: Colors.green),
          ],
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        // Simulate asynchronous loading (e.g., fetching user data)
        future: Future.delayed(Duration(seconds: 4)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While data is loading, show the splash screen
            return SplashScreen();
          } else {
            // Once data is loaded, decide whether to show login or main app
            final userData = Provider.of<UserData>(context);
            if (userData.isLoggedIn) {
              // Use MaterialPageRoute with builder for the fade-out effect
              return MyMainApp();
            } else {
              // Use MaterialPageRoute with builder for the fade-out effect
              return LoginPage();
            }
          }
        },
      ),
    );
  }
}

class MyMainApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyMainApp> {
  int _currentIndex = 1;
  final PageController _pageController = PageController(initialPage: 1);

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      CartMenu(
          user: Provider.of<UserData>(context, listen: false).loggedInUser
              as User),
      HomePage(),
      Profile(),
    ];
  }

  void onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
      _pageController.animateToPage(
        index,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.0), // Adjust the height as needed
          child: AppBar(
  backgroundColor: HexColor("147158"),
  elevation: 0.0,
  title: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        'YesHealth',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      Row(
        children: [
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () {
              _showBottomSheet(context, Wishlist());
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications_sharp),
            onPressed: () {
              _showBottomSheet(context, NotificationPage());
            },
          ),
        ],
      ),
    ],
  ),
),

        ),
        body: PageView(
          controller: _pageController,
          children: _pages,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_rounded),
              label: "Keranjang",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profil",
            ),
          ],
          currentIndex: _currentIndex,
          selectedItemColor: HexColor("6AB29B"),
          backgroundColor: Color.fromARGB(255, 236, 236, 236),
          onTap: onItemTapped,
        ),
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
      ),
    );
  }

  // Function to show the bottom sheet
  void _showBottomSheet(BuildContext context, Widget page) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: page, // Replace with your desired page widget
        );
      },
    );
  }
}
class Wishlist extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    NumberFormat numberFormat = NumberFormat.decimalPattern('id');
    User loggedInUser = Provider.of<UserData>(context).loggedInUser! as User;

    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        // Fetch the wishlist items from the database
        future: UserHomeDatabaseHelper().getWishlist(loggedInUser.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error loading wishlist'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('Wishlist Kamu Kosong.'),
            );
          } else {
            // Build the wishlist items list using a ListView.builder
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> wishlistItem = snapshot.data![index];

                      // Build each wishlist item as a Dismissible widget
                      return Dismissible(
                        key: Key(wishlistItem['id'].toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 16.0),
                              child: Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        onDismissed: (direction) {
                          // Handle item removal from wishlist
                          UserHomeDatabaseHelper().removeFromWishlist(
                            loggedInUser.id,
                            wishlistItem['itemName'],
                            wishlistItem['imagePath'],
                          );
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Item name (left top bold)
                                      Text(
                                        wishlistItem['itemName'],
                                        style: TextStyle(
                                          fontSize: 32,
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
                                    File(wishlistItem['imagePath']),
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
              ],
            );
          }
        },
      ),
    );
  }
}

class NotificationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    NumberFormat numberFormat = NumberFormat.decimalPattern('id');
    User loggedInUser = Provider.of<UserData>(context).loggedInUser! as User;

    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        // Fetch the notifications from the database
        future: UserHomeDatabaseHelper().getNotifications(loggedInUser.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error loading notifications'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('Kamu Tidak Mempunyai Notifikasi.'),
            );
          } else {
            // Build the notifications list using a ListView.builder
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> notificationItem = snapshot.data![index];

                // Get the icon data from the database
                String? iconData = notificationItem['icon'];

                // Build each notification item as a Dismissible widget wrapped in a Container
                return Container(
                  margin: EdgeInsets.all(8), // Add margin to create spacing
                  child: Dismissible(
                    key: Key(notificationItem['id'].toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    onDismissed: (direction) {
                      UserHomeDatabaseHelper().removeNotification(
                        loggedInUser.id,
                        notificationItem['id'],
                      );
                    },
                    child: ListTile(
                      leading: _buildIconFromData(
                          notificationItem['icon'] ?? "failed"),
                      title: Text(notificationItem['title'] ?? "Placeholder"),
                      subtitle: Text(notificationItem['message'] ?? "Placeholder"),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  // Helper method to build Icon from icon data
  Widget _buildIconFromData(String? iconData) {
    // Use a default icon (e.g., notification icon) if the iconData is not available
    Icon icon = Icon(Icons.abc);

    if (iconData == 'success') {
      icon = Icon(Icons.check_circle, color: Colors.green, size: 40);
    } else if (iconData == 'failed') {
      icon = Icon(Icons.error, color: Colors.red, size: 40);
    }

    return icon;
  }
}
