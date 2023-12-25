import 'package:flutter/material.dart';
import '../user_model.dart';

class RedirectRegisterPage extends StatelessWidget {
  final String status;
  final UserManager user;

  RedirectRegisterPage({required this.status, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            status == "success"
                ? Icon(Icons.check_circle, color: Colors.green, size: 100)
                : Icon(Icons.error, color: Colors.red, size: 100),
            Text(
              status == "success"
                  ? "Registrasi Akun Sukses"
                  : "Registrasi Akun Gagal",
              style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
            ),
            Text(
              "Klik tombol di bawah ini untuk kembali ke halaman login",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Navigate back to login page
                Navigator.pop(context);
              },
              child: Text("Return to Login"),
            ),
          ],
        ),
      ),
    );
  }
}
