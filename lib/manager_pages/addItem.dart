import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hexcolor/hexcolor.dart';

class AddItemPage extends StatefulWidget {
  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  late String itemName;
  late String itemType;
  late int itemPrice;

  String _btnColor = "004225";

  String? _itemNameError;
  String? _itemTypeError;
  String? _itemPriceError;

  void _sumbitItem() {
    // ITEMNAME VALIDATION
    if (itemName == null || itemName.isEmpty) {
      setState(() {
        _itemNameError = "Nama Barang Tidak Boleh Kosong";
      });
    } else if (itemName.length <= 3) {
      setState(() {
        _itemNameError = "Nama Barang Tidak Boleh Kurang Dari 3 Karakter";
      });
    } else {
      setState(() {
        _itemNameError = null;
      });
    }

    // ITEMTYPE VALIDATION
    if (itemType == null || itemType.isEmpty) {
      setState(() {
        _itemTypeError = "Tipe Barang Tidak Boleh Kosong";
      });
    } else if (itemType.length <= 3) {
      setState(() {
        _itemTypeError = "Tipe Barang Tidak Boleh Kurang Dari 3 Karakter";
      });
    } else {
      setState(() {
        _itemTypeError = null;
      });
    }

    // ITEMTYPE VALIDATION
    if (itemPrice == null) {
      setState(() {
        _itemPriceError = "Harga Barang Tidak Boleh Kosong";
      });
    } else if (itemPrice <= 0) {
      setState(() {
        _itemPriceError = "Harga Barang Tidak Boleh Kurang Dari 0";
      });
    } else {
      setState(() {
        _itemPriceError = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambahkan Barang Ke Database'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Title(
              child: Text("Silahkan Masukan Informasi Mengenai Barang Yang Akan Di Tambahkan.", textScaleFactor: 1.2),
              color: Colors.black
            ),
            SizedBox(height: 16.0),
            TextField(
              onChanged: (value) => itemName = value,
              decoration: InputDecoration(labelText: 'Nama Barang', errorText: _itemNameError),
            ),
              SizedBox(height: 8.0),
            TextField(
              onChanged: (value) => itemType = value,
              decoration: InputDecoration(labelText: 'Tipe Barang', errorText: _itemTypeError),
            ),
              SizedBox(height: 8.0),
            TextField(
              onChanged: (value) => itemPrice = int.tryParse(value) ?? 0,
              decoration: InputDecoration(labelText: 'Harga Barang', errorText: _itemPriceError),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
                onPressed: _sumbitItem,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(HexColor(_btnColor)),
                  minimumSize: MaterialStateProperty.all<Size>(Size(200, 50)), // Adjust the size as needed

                ),
                child: Text('Tambahkan Barang',
                    style: TextStyle(color: Colors.white)),
              ),
          ],
        ),
      ),
    );
  }
}
