import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_size/window_size.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'package:hexcolor/hexcolor.dart';

import 'customer_pages/home.dart';
import 'customer_pages/cart.dart';
import 'customer_pages/profile.dart';
import 'login/login.dart';

void main() {
  if (Platform.isWindows) {
    WidgetsFlutterBinding.ensureInitialized();
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
        theme: ThemeData(primarySwatch: Colors.green),
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
      theme: ThemeData(primarySwatch: Colors.green),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: AppBar(
            backgroundColor: Colors.green,
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
                Icon(Icons.notifications_sharp),
              ],
            ),
          ),
        ),
        body: Stack(
          children: [
            PageView(
              controller: _pageController,
              children: _pages,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: BottomNavigationBar(
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
                selectedItemColor: HexColor("86A789"),
                backgroundColor: const Color.fromARGB(216, 255, 255, 255),
                onTap: onItemTapped,  
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
      ),
    );
  }
}
