// registration_page.dart
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:hexcolor/hexcolor.dart';
import 'redirectRegisterAccount.dart';
import '../databaseHelper.dart';
import '../usersAndItemsModel.dart';

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
  final TextEditingController _noTelpController = TextEditingController();

  DateTime? _selectedDate;
  String? _usernameError;
  String? _passwordError;
  String? _emailError;
  String? _namaError;
  String? _alamatError;
  String? _umurError;
  String? _tanggalLahirError;
  String? _genderError;
  String? _noTelpError;

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? errorText,
    bool obscureText = false,
    int? maxLength,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool readOnly = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      maxLength: maxLength,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: HexColor("304D30")),
        ),
        labelStyle: TextStyle(color: HexColor("304D30")),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }

  Widget _buildIntlPhoneField({
    required String label,
    required TextEditingController controller,
  }) {
    return IntlPhoneField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: HexColor("304D30")),
        ),
        labelStyle: TextStyle(color: HexColor("304D30")),
      ),
      initialCountryCode: 'ID',
      onChanged: (phone) {
        print(phone.completeNumber);
      },
    );
  }

  Widget _buildDropdownButtonFormField() {
    return DropdownButtonFormField<String>(
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
    );
  }



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
    String nomorTelpon = _noTelpController.text.trim();

    print("Username: " + username);
    print("Password: " + password);
    print("Email: " + email);
    print("Name: " + nama);
    print("alamat: " + alamat);
    print("Umur: " + umur);
    print("Tgl. Lahir: " + tanggalLahir);
    print("Gender: " + gender);
    print("noTelp: " + nomorTelpon);

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
      nomorTelpon: int.parse(nomorTelpon),
      type: "customer",
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
        backgroundColor: HexColor("304D30"),
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
                  textScaleFactor: 1.2,
                ),
                color: Colors.black,
              ),
              SizedBox(height: 16.0),
              Title(
                child:
                    const Text("Informasi Akun YesHealth", textScaleFactor: 1),
                color: Colors.black,
              ),
              SizedBox(height: 8.0),
              _buildTextField(
                label: 'Username',
                controller: _usernameController,
                errorText: _usernameError,
                maxLength: 16,
              ),
              _buildTextField(
                label: 'Alamat Email',
                controller: _emailController,
                errorText: _emailError,
              ),
              SizedBox(height: 8.0),
              _buildTextField(
                label: 'Password',
                controller: _passwordController,
                errorText: _passwordError,
                obscureText: true,
              ),
              SizedBox(height: 16.0),
              Title(
                child: const Text("Data Diri Anda", textScaleFactor: 1),
                color: Colors.black,
              ),
              SizedBox(height: 8.0),
              _buildTextField(
                label: 'Nama Lengkap',
                controller: _namaController,
                errorText: _namaError,
                maxLength: 64,
              ),
              _buildTextField(
                label: 'Umur',
                controller: _umurController,
                errorText: _umurError,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                maxLength: 3,
              ),
              _buildTextField(
                label: 'Alamat',
                controller: _alamatController,
                errorText: _alamatError,
                maxLength: 128,
              ),
              Title(
                child: const Text("Jenis Kelamin", textScaleFactor: 1),
                color: Colors.black,
              ),
              _buildDropdownButtonFormField(),
              SizedBox(height: 16.0),
              _buildIntlPhoneField(
                label: 'Nomor Telpon',
                controller: _noTelpController,
              ),
              _buildTextField(
                label: 'Tanggal Lahir',
                controller: _tanggalLahirController,
                errorText: _tanggalLahirError,
                readOnly: true,
                suffixIcon: IconButton(
                  onPressed: () => _selectDate(context),
                  icon: Icon(Icons.calendar_today),
                ),
              ),
              SizedBox(height: 16.0),
               ElevatedButton(
                onPressed: _registerUser,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(HexColor("004225")),
                  minimumSize: MaterialStateProperty.all<Size>(Size(200, 50)), // Adjust the size as needed

                ),
                child: Text('Buat Akun',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

