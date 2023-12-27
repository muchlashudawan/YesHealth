import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddItemPage extends StatefulWidget {
  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  late String itemName;
  late String itemType;
  late int itemPrice;
  late XFile? pickedImage;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        pickedImage = pickedFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              onChanged: (value) => itemName = value,
              decoration: InputDecoration(labelText: 'Item Name'),
            ),
            TextField(
              onChanged: (value) => itemType = value,
              decoration: InputDecoration(labelText: 'Item Type'),
            ),
            TextField(
              onChanged: (value) => itemPrice = int.tryParse(value) ?? 0,
              decoration: InputDecoration(labelText: 'Item Price'),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image'),
            ),

            ElevatedButton(
              onPressed: () {
                // Implement logic to add item to the database
                // ...
              },
              child: Text('Add Item'),
            ),
          ],
        ),
      ),
    );
  }
}
