import 'package:flutter/material.dart';

class EditItemPage extends StatefulWidget {
  @override
  _EditItemPageState createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  late String itemName;
  late String itemType;
  late int itemPrice;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Item'),
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
              onPressed: () {
                // Implement logic to edit item in the database
                // ...
              },
              child: Text('Edit Item'),
            ),
          ],
        ),
      ),
    );
  }
}
