import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../databaseHelper.dart';
import '../usersAndItemsModel.dart';

class ChangeBannerPage extends StatefulWidget {
  @override
  _ChangeBannerPageState createState() => _ChangeBannerPageState();
}

class _ChangeBannerPageState extends State<ChangeBannerPage> {
  final BannerDatabaseHelper _databaseHelper = BannerDatabaseHelper();

  late String _btnColor;
  bool isBannerSubmitted = false;
  String? _bannerImagePath;

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  void _loadBanner() async {
    final banners = await _databaseHelper.getBanners();
    setState(() {
      isBannerSubmitted = banners.isNotEmpty;
      _btnColor = isBannerSubmitted ? "0000FF" : "00FF00";
      if (isBannerSubmitted) {
        _bannerImagePath = banners.first.filename;
      }
    });
  }

  Future<void> _pickBannerImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (pickedFile != null) {
        // Show a snackbar message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Banner telah berhasil dipasang.'),
          ),
        );

        // Save the picked image to the database
        await _databaseHelper.addBanner(BannerModel(filename: pickedFile.path));

        setState(() {
          _bannerImagePath = pickedFile.path;
          isBannerSubmitted = true;
          _btnColor = "0000FF";
        });
      }
    } catch (e) {
      print('Error picking banner image: $e');
      // Handle error as needed
    }
  }

  Future<void> _removeBanner() async {
    try {
      // Assuming there is only one banner
      final banners = await _databaseHelper.getBanners();
      if (banners.isNotEmpty) {
        await _databaseHelper.deleteBanner(banners.first.filename);

        // Show a snackbar message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Banner telah berhasil dihapus.'),
          ),
        );

        setState(() {
          isBannerSubmitted = false;
          _btnColor = "00FF00";
          _bannerImagePath = null;
        });
      } else {
        // Show a snackbar message if there is no banner to remove
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tidak ada banner untuk dihapus.'),
          ),
        );
      }
    } catch (e) {
      print('Error removing banner: $e');
      // Handle error as needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ubah Banner'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Title(
                  child: Text(
                    "Preview Banner",
                    textScaleFactor: 1.2,
                  ),
                  color: Colors.black,
                ),
                SizedBox(height: 16.0),
                if (isBannerSubmitted)
                  Container(
                    height: 170,
                    width: 130,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      image: DecorationImage(
                        image: FileImage(File(_bannerImagePath!)),
                        fit: BoxFit
                            .fill, // Ensure the image covers the entire container
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withOpacity(0.4), // Light black shadow
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.black
                            .withOpacity(0.1), // Light black outline
                        width: 1,
                      ),
                    ),
                  )
                else
                  Container(
                    height: 170,
                    margin: EdgeInsets.all(10),
                    child: PageView.builder(
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 120,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          // Add the content of each banner here
                        );
                      },
                    ),
                  ),
                SizedBox(height: 16.0),
                ElevatedButton.icon(
                  onPressed: () {
                    isBannerSubmitted ? _removeBanner() : _pickBannerImage();
                  },
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all<Size>(Size(200, 50)),
                    backgroundColor: MaterialStateProperty.all<Color>(
                        isBannerSubmitted ? Colors.red : Colors.blue),
                  ),
                  icon: Icon(isBannerSubmitted
                      ? Icons.photo
                      : Icons.add_photo_alternate),
                  label: Text(
                    isBannerSubmitted ? 'Hapus Banner' : 'Tambahkan Banner',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
