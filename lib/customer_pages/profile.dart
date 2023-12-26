import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

import '../user_model.dart';
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
        // Check if the user is not logged in and navigate to the login page
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
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 16.0, top: 16.0), // Adjusted padding
                  child: Align(
                    alignment: Alignment.topLeft, // Align to the left
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getGreeting() + ",",
                          style: TextStyle(
                            fontSize: 20.0, // Make the text size normal
                            fontWeight: FontWeight.w600, // Light font weight
                          ),
                        ),
                        Text(
                          user.namaLengkap,
                          style: TextStyle(
                            fontSize: 30.0, // Make the text size bold
                            fontWeight: FontWeight.bold,
                            // Use a blue gradient color
                            foreground: Paint()
                              ..shader = LinearGradient(
                                colors: [Colors.green, HexColor('8ADAB2')],
                              ).createShader(
                                  Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Adjusted spacing between name and user information
                SizedBox(height: 24.0),
                Padding(
                  padding: EdgeInsets.only(left: 16.0), // Add left padding
                  child: Text(
                    "Informasi Anda Di YesHealth:",
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                // Display user information with icons
                ListTile(
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 0), // Adjusted padding
                  leading: Icon(Icons.email),
                  title: Text(user.email),
                ),
                ListTile(
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 0), // Adjusted padding
                  leading: Icon(Icons.person),
                  title: Text('Umur: ${user.umur.toString()}'),
                ),
                ListTile(
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 0), // Adjusted padding
                  leading: Icon(Icons.home),
                  title: Text(user.alamat),
                ),
                ListTile(
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 0), // Adjusted padding
                  leading: Icon(Icons.cake),
                  title: Text('Tanggal Lahir: ${user.tanggalLahir}'),
                ),
                ListTile(
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 0), // Adjusted padding
                  leading: Icon(Icons.male),
                  title: Text('Jenis Kelamin: ${user.jenisKelamin}'),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(
                          bottom: 70.0), // Adjust the value as needed
                      child: ElevatedButton(
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
                        child: Text('Logout'),
                      ),
                    ),
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
              fontSize: 20.0, // Make the text size normal
              fontWeight: FontWeight.w600, // Light font weight
            ),
          ));
        }
      },
    );
  }
}
