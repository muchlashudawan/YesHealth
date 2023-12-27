import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

import '../usersAndItemsModel.dart';
import '../login/login.dart';

class Profile extends StatelessWidget {
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
    return Consumer<UserData>(
      builder: (context, userData, child) {
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

        UserBase? loggedInUserBase = userData.loggedInUser;
        if (loggedInUserBase != null) {
          User user = loggedInUserBase as User; // Use type cast
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        getGreeting() + ",",
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        user.namaLengkap,
                        style: TextStyle(
                          fontSize: 36.0,
                          fontWeight: FontWeight.bold,
                          foreground: Paint()
                            ..shader = LinearGradient(
                              colors: [Colors.green, HexColor('8ADAB2')],
                            ).createShader(
                                Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          "Informasi Anda Di YesHealth:",
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                        leading: Icon(Icons.email),
                        title: Text(
                          user.email,
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ),
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                        leading: Icon(Icons.person),
                        title: Text(
                          'Umur: ${user.umur.toString()}',
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ),
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                        leading: Icon(Icons.home),
                        title: Text(
                          user.alamat,
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ),
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                        leading: Icon(Icons.cake),
                        title: Text(
                          'Tanggal Lahir: ${user.tanggalLahir}',
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ),
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                        leading: Icon(Icons.male),
                        title: Text(
                          'Jenis Kelamin: ${user.jenisKelamin}',
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: () {
                          var userData =
                              Provider.of<UserData>(context, listen: false);
                          userData.logout();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginPage(),
                            ),
                          );
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.red),
                          minimumSize:
                              MaterialStateProperty.all<Size>(Size(200, 50)),
                        ),
                        child: Text('Logout',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ],
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
      },
    );
  }
}
