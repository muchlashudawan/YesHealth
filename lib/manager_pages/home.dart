import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:hexcolor/hexcolor.dart';

import '../usersAndItemsModel.dart';
import '../databaseHelper.dart';
import '../login/login.dart';
import 'itemAdd.dart';
import 'itemEdit.dart';
import 'itemDelete.dart';
import 'itemView.dart';
import 'changeBanner.dart';

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

    Future<void> _showLogoutConfirmation(BuildContext context) async {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Konfirmasi Logout'),
            content: Text('Apakah Anda yakin ingin keluar?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  userData.logout();
                  Navigator.popUntil(context, (route) => route.isFirst);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: Text('Ya', style: TextStyle(color: Colors.red)
                ),
              ),
            ],
          );
        },
      );
    }

    if (loggedInUserBase != null) {
      UserManager user = loggedInUserBase as UserManager; // Use type cast
      return Scaffold(
        appBar: AppBar(
          title: Text('YesHealth Manager Panel'),
          backgroundColor: Colors.black,
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                _showLogoutConfirmation(context);
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
                    fontSize: 30.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  user.username,
                  style: TextStyle(
                    fontSize: 40.0,
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
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.black),
                    minimumSize: MaterialStateProperty.all<Size>(
                        Size(200, 50)), // Adjust the size as needed
                  ),
                  child: Text('Tampilkan Menu',
                      style: TextStyle(color: Colors.white)),
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
              label: 'Tambah Obat',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddItemPage()),
                );
              },
            ),
            _buildBottomSheetButton(
              icon: Icons.visibility,
              label: 'Lihat Obat',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewItemPage()),
                );
              },
            ),
            _buildBottomSheetButton(
              icon: Icons.edit,
              label: 'Ubah Obat',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditItemPage()),
                );
              },
            ),
            _buildBottomSheetButton(
              icon: Icons.delete,
              label: 'Hapus Obat',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DeleteItemPage()),
                );
              },
            ),
            _buildBottomSheetButton(
              icon: Icons.filter_frames,
              label: 'Ubah Banner',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChangeBannerPage()),
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
