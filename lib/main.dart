// Add these imports if not already present
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_size/window_size.dart';
import 'dart:io';

import 'customer_pages/home.dart';
import 'customer_pages/cart.dart';
import 'customer_pages/profile.dart';
import 'login/login.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows) {
    setWindowMaxSize(const Size(1024, 768));
    setWindowMinSize(const Size(512, 384));
    Future<Null>.delayed(Duration(seconds: 1), () {
      setWindowFrame(
          Rect.fromCenter(center: Offset(1000, 500), width: 600, height: 1000));
    });
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserData(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Consumer<UserData>(
          builder: (context, userData, _) {
            if (userData.isLoggedIn) {
              return MyMainApp();
            } else {
              return LoginPage();
            }
          },
        ),
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

  final List<Widget> _pages = [
    CartMenu(),
    HomePage(),
    Profile(),
  ];

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
            backgroundColor: Colors.lightBlue,
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
                        // Handle click on heart icon
                        print("Heart icon clicked");
                        // Open bottom sheet
                        _showBottomSheet(context, Wishlist());
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.notifications_sharp),
                      onPressed: () {
                        // Handle click on notification icon
                        print("Notification icon clicked");
                        // Open bottom sheet
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
              label: "Cart",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profile",
            ),
          ],
          currentIndex: _currentIndex,
          selectedItemColor: Colors.lightBlue,
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Wishlist'),
      ),
      body: Center(
        child: Text('Content of the Wishlist goes here...'),
      ),
    );
  }
}

class NotificationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification Page'),
      ),
      body: Center(
        child: Text('Content of the Notification Page goes here...'),
      ),
    );
  }
}

// Rest of the code remains the same
