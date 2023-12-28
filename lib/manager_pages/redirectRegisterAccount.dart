import 'package:flutter/material.dart';
import '../usersAndItemsModel.dart';

class RedirectRegisterPage extends StatelessWidget {
  final String status;
  final UserManager user;

  RedirectRegisterPage({required this.status, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              status == "success"
                  ? Icon(Icons.check_circle, color: Colors.green, size: 100)
                  : Icon(Icons.error, color: Colors.red, size: 100),
              Container(
                width: double.infinity,
                child: Text(
                  status == "success"
                    ? "Registrasi Akun Sukses"
                    : "Registrasi Akun Gagal",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                width: double.infinity,
                child: Text(
                  "Klik tombol di bawah ini untuk kembali ke halaman login",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  // Navigate back to the previous page
                  Navigator.pop(context);
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.blue),
                  minimumSize: MaterialStateProperty.all<Size>(
                      Size(200, 50)), // Adjust the size as needed
                ),
                child: Text('Kembali Ke Halaman Login', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
