import 'package:flutter/material.dart';

class ItemRedirectPage extends StatelessWidget {
  final String status;
  final String title;

  ItemRedirectPage({required this.status, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              status == "success"
                  ? Icon(Icons.check_circle, color: Colors.green, size: 100)
                  : Icon(Icons.error, color: Colors.red, size: 100),
              Container(
                width: double.infinity,
                child: Text(
                  title,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                width: double.infinity,
                child: Text(
                  "Klik tombol di bawah ini untuk kembali ke halaman sebelumnya",
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
                child: Text('Kembali', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
