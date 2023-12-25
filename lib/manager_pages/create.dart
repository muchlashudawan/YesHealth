// registration_page.dart
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import './redirect_register.dart';
import '../database_helper.dart';
import '../user_model.dart';

class RegistrationManagerPage extends StatefulWidget {
  @override
  _RegistrationManagerPageState createState() =>
      _RegistrationManagerPageState();
}

class _RegistrationManagerPageState extends State<RegistrationManagerPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String? _usernameError;
  String? _passwordError;

  void _registerUser() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();
    String email = _emailController.text.trim();

    print("Username: " + username);
    print("Password: " + password);
    print("Email: " + email);

    // USERNAME VALIDATION
    if (!(RegExp(r'^[a-zA-Z0-9]+$').hasMatch(username))) {
      setState(() {
        _usernameError = 'Hanya huruf dan angka yang diperbolehkan.';
      });
      return;
    } else if (!(RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username))) {
      setState(() {
        _usernameError = 'Simbol tidak diperbolehkan, kecuali garis bawah (_).';
      });
      return;
    } else if (username.contains(' ')) {
      setState(() {
        _usernameError = 'Spasi tidak diperbolehkan.';
      });
      return;
    } else if (username.length < 2) {
      setState(() {
        _usernameError = 'Nama pengguna harus memiliki minimal 2 karakter.';
      });
      return;
    } else if (username.length > 16) {
      setState(() {
        _usernameError = 'Nama pengguna harus memiliki maksimal 16 karakter.';
      });
      return;
    } else if (!(RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username))) {
      setState(() {
        _usernameError = 'Tidak Boleh Ada Simbol';
      });
      return;
    } else {
      setState(() {
        _usernameError = null;
      });
    }

    // PASSWORD VALIDATION
    if (password == "admin" || password == "root") {
      setState(() {
        _passwordError = 'Hmmm... Jangan deh.';
      });
      return;
    } else if (password.isEmpty) {
      setState(() {
        _passwordError = 'Password tidak boleh kosong!';
      });
      return;
    } else if (password.length < 6) {
      setState(() {
        _passwordError = 'Password harus berisi minimal 6 karakter!';
      });
      return;
    } else {
      setState(() {
        _passwordError = null;
      });
    }

    print("All Good!");

    // Check if the username already exists
    UserManager? existingUser = await ManagerDatabaseHelper().getManagerByUsername(username);
    if (existingUser != null) {
      setState(() {
        _usernameError = 'Username sudah digunakan. Pilih username lain.';
      });
      return;
    } else {
      setState(() {
        _usernameError = null;
      });
    }

    void navigateToRedirectRegister(
        BuildContext context, String status, UserManager user) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              RedirectRegisterPage(status: status, user: user),
        ),
      );
    }

    UserManager newUser = UserManager(
        username: username,
        password: password,
        email: email,
        type: "manager"
    );

    // Insert user into the database
    ManagerDatabaseHelper()
        .insertManager(newUser.toMap())
        .then((int registrationStatus) {
      // Determine the registration status
      bool isSuccess = registrationStatus >
          0; // Assuming registration success if the ID is greater than 0

      // Navigate to redirect_register.dart
      navigateToRedirectRegister(
          context, isSuccess ? "success" : "failed", newUser);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Akun Manager'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Title(
                child: const Text(
                    "Silahkan Masukan Username & Password Anda Untuk Membuat Akun Manager YesHealth.",
                    textScaleFactor: 1.2),
                color: Colors.black,
              ),
              SizedBox(height: 16.0),
              Title(
                child:
                    const Text("Informasi Akun YesHealth", textScaleFactor: 1),
                color: Colors.black,
              ),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  errorText: _usernameError,
                  focusedErrorBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),

                maxLength: 16, // Set the maximum length to 3 characters
                maxLengthEnforcement:
                    MaxLengthEnforcement.enforced, // Enforce the maximum length
              ),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  errorText: _passwordError,
                  focusedErrorBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
              ),
              SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _registerUser,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
                  minimumSize: MaterialStateProperty.all<Size>(Size(200, 50)), // Adjust the size as needed

                ),
                child: Text('Buat Akun Manager',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
