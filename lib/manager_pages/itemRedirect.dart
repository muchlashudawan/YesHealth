import 'package:flutter/material.dart';

class ItemRedirectPage extends StatelessWidget {
  final String status;
  final String title;

  ItemRedirectPage({required this.status, required this.title});

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
              title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              "Klik tombol di bawah ini untuk kembali ke halaman sebelumnya",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Navigate back to the previous page
                Navigator.pop(context);
              },
              child: Text("Kembali"),
            ),
          ],
        ),
      ),
    );
  }
}
