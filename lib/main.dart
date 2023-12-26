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
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    if (Platform.isWindows) {
      setWindowMaxSize(const Size(1024, 768));
      setWindowMinSize(const Size(512, 384));
      Future<Null>.delayed(Duration(seconds: 1), () {
        setWindowFrame(Rect.fromCenter(
            center: Offset(1000, 500), width: 600, height: 1000));
      });
    }
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
    theme: ThemeData(primarySwatch: Colors.green),
    debugShowCheckedModeBanner: false,
    home: Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/login_bg.png"), // Replace with your image asset
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Main Content
        Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(60.0),
            child: AppBar(
              backgroundColor: Colors.transparent, // Make app bar transparent
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
            backgroundColor: Colors.transparent, // Make bottom navigation bar transparent
            onTap: onItemTapped,
          ),
          backgroundColor: Colors.transparent, // Make the background color transparent
        ),
      ],
    ),
  );
}

}
