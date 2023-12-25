// registration_page.dart
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import './redirect_register.dart';
import '../database_helper.dart';
import '../user_model.dart';

const List<String> genderList = <String>['Laki-Laki', 'Perempuan'];

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _umurController = TextEditingController();
  final TextEditingController _tanggalLahirController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();

  DateTime? _selectedDate;
  String? _usernameError;
  String? _passwordError;
  String? _emailError;
  String? _namaError;
  String? _alamatError;
  String? _umurError;
  String? _tanggalLahirError;
  String? _genderError;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _tanggalLahirController.text =
            DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  void _registerUser() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();
    String email = _emailController.text.trim();
    String nama = _namaController.text.trim();
    String alamat = _alamatController.text.trim();
    String umur = _umurController.text.trim();
    String tanggalLahir = _tanggalLahirController.text.trim();
    String gender = _genderController.text.trim();

    print("Username: " + username);
    print("Password: " + password);
    print("Email: " + email);
    print("Name: " + nama);
    print("alamat: " + alamat);
    print("Umur: " + umur);
    print("Tgl. Lahir: " + tanggalLahir);
    print("Gender: " + gender);

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

    // EMAIL VALIDATION
    if (!(RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
        .hasMatch(email))) {
      setState(() {
        _emailError = 'Alamat Email Tidak Valid';
      });
      return;
    } else {
      setState(() {
        _emailError = null;
      });
    }

    // NAMA VALIDATION
    if (nama.length < 2) {
      setState(() {
        _namaError = 'Nama Lengkap harus memiliki minimal 2 karakter.';
      });
      return;
    } else {
      setState(() {
        _namaError = null;
      });
    }

    // UMUR VALIDATION
    if (int.parse(umur) <= 0) {
      setState(() {
        _umurError = "Umur Tidak Boleh Kurang Atau Sama Dengan Nol.";
      });
    } else {
      setState(() {
        _umurError = null;
      });
    }

    // ALAMAT VALIDATION
    if (alamat.length < 2) {
      setState(() {
        _alamatError = 'Alamat harus memiliki minimal 2 karakter.';
      });
      return;
    } else {
      setState(() {
        _alamatError = null;
      });
    }

    // GENDER VALIDATION
    if (gender != "Laki-Laki" && gender != "Perempuan") {
      setState(() {
        _genderError = 'Jenis Kelamin Tidak Valid.';
      });
      return;
    } else {
      setState(() {
        _genderError = null;
      });
    }

    // TANGGAL LAHIR VALIDATION
    try {
      DateTime TanggalLahir = DateTime.parse(tanggalLahir);

      DateTime gg = TanggalLahir;
    } catch (e) {
      // Handle the case when parsing fails
      // For example, show an error message or take appropriate action
      setState(() {
        _tanggalLahirError = "Tanggal Lahir Tidak Valid.";
      });
    }

    setState(() {
      _tanggalLahirError = null;
    });

    print("All Good!");

    // Check if the username already exists
    User? existingUser = await DatabaseHelper().getUserByUsername(username);
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

    // Check if the email already exists
    existingUser = await DatabaseHelper().getUserByEmail(email);
    if (existingUser != null) {
      setState(() {
        _emailError =
            'Alamat email sudah digunakan. Gunakan alamat email lain.';
      });
      return;
    } else {
      setState(() {
        _emailError = null;
      });
    }

    void navigateToRedirectRegister(
        BuildContext context, String status, User user) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              RedirectRegisterPage(status: status, user: user),
        ),
      );
    }

    User newUser = User(
      id: 0,
      username: username,
      password: password,
      email: email,
      namaLengkap: nama,
      umur: int.parse(umur),
      alamat: alamat,
      tanggalLahir: tanggalLahir,
      jenisKelamin: gender,
    );

    // Insert user into the database
    DatabaseHelper().insertUser(newUser.toMap()).then((int registrationStatus) {
      // Determine the registration status
      bool isSuccess = registrationStatus >
          0; // Assuming registration success if the ID is greater than 0

      // Navigate to redirect_register.dart
      navigateToRedirectRegister(
          context, isSuccess ? "success" : "failed", newUser);
    });
  }

  String dropdownValue = 'Laki-Laki'; // Set a default value

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Akun'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Title(
                child: const Text(
                    "Silahkan Masukan Data Diri Anda Untuk Membuat Akun YesHealth.",
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
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Alamat Email',
                  errorText: _emailError,
                  focusedErrorBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
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
              SizedBox(height: 16.0),
              Title(
                child: const Text("Data Diri Anda", textScaleFactor: 1),
                color: Colors.black,
              ),
              TextField(
                controller: _namaController,
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap',
                  errorText: _namaError,
                  focusedErrorBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
                maxLength: 64, // Set the maximum length to 3 characters
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
              ),
              TextField(
                controller: _umurController,
                decoration: InputDecoration(
                  labelText: 'Umur',
                  errorText: _umurError,
                  focusedErrorBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                maxLength: 3, // Set the maximum length to 3 characters
                maxLengthEnforcement:
                    MaxLengthEnforcement.enforced, // Enforce the maximum length
              ),
              TextField(
                controller: _alamatController,
                decoration: InputDecoration(
                  labelText: 'Alamat',
                  errorText: _alamatError,
                  focusedErrorBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
                maxLength: 128, // Set the maximum length to 3 characters
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
              ),
              TextField(
                controller: _tanggalLahirController,
                decoration: InputDecoration(
                  labelText: 'Tanggal Lahir',
                  errorText: _tanggalLahirError,
                  focusedErrorBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () => _selectDate(context),
                    icon: Icon(Icons.calendar_today),
                  ),
                ),
                readOnly: true,
              ),
              SizedBox(height: 6.0),
              Title(
                child: const Text("Jenis Kelamin", textScaleFactor: 1),
                color: Colors.black,
              ),
              DropdownButtonFormField<String>(
                value: dropdownValue,
                decoration: InputDecoration(
                  errorText: _genderError,
                  focusedErrorBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
                onChanged: (String? value) {
                  // This is called when the user selects an item.
                  setState(() {
                    dropdownValue = value!;
                    _genderController.text = value;
                  });
                },
                items: genderList.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _registerUser,
                child: Text('Register'),
              ),
              SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }
}
