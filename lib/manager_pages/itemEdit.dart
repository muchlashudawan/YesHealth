import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../databaseHelper.dart';
import '../usersAndItemsModel.dart';

class EditItemPage extends StatefulWidget {
  @override
  _EditItemPageState createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  final ItemDatabaseHelper _databaseHelper = ItemDatabaseHelper();
  List<Item>? items = null;

  Future<void> _refreshItems() async {
    try {
      // Fetch the updated items from the database
      List<Item> updatedItems = await _databaseHelper.getItems();

      // Update the state with the new data
      setState(() {
        items = updatedItems;
      });

      // Show a toast or any other indication that the refresh is complete
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('List Obat Telah Di Perbarui.'),
        ),
      );
    } catch (error) {
      // Handle any errors that occurred during the refresh
      print('Error refreshing items: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error refreshing items.'),
        ),
      );
    }
  }

  NumberFormat numberFormat = NumberFormat.decimalPattern('id');

  @override
  void initState() {
    super.initState();
    // Trigger the automatic refresh when the screen is loaded
    _refreshItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ubah Obat'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshItems,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: RefreshIndicator(
          onRefresh: _refreshItems,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Title(
                  child: Text(
                    "Silahkan Pilih Obat Yang Akan Di Edit Datanya.",
                    textScaleFactor: 1.2,
                  ),
                  color: Colors.black,
                ),
                SizedBox(height: 16.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (items != null && items!.isNotEmpty)
                      ...items!.map((item) {
                        return GestureDetector(
                          onTap: () {
                            _showEditModal(context, item);
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 8.0),
                            padding: EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 2),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('${item.name} ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      SizedBox(height: 8.0),
                                      Text('ID            : ${item.id}'),
                                      Text('Tipe         : ${item.type}'),
                                      Text(
                                          'Kuantitas : ${numberFormat.format(item.quantity)}'),
                                      Text(
                                          'Harga      : Rp. ${numberFormat.format(item.price)}'),
                                    ],
                                  ),
                                ),
                                if (item.imagePath != null)
                                  Container(
                                    margin: EdgeInsets.only(left: 16.0),
                                    child: Image.file(
                                      File(item.imagePath!),
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList()
                    else
                      Text('Tidak ada obat di database.'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditModal(BuildContext context, Item item) {
    // Set initial values for the text fields
    String newName = item.name;
    String newType = item.type;
    String newQuantity = item.quantity.toString();
    String newPrice = item.price.toString();
    String? newImagePath = item.imagePath;

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Ubah Data Obat'),
                TextField(
                  controller: TextEditingController(text: newName),
                  onChanged: (value) {
                    newName = value;
                  },
                  decoration: InputDecoration(labelText: 'Nama Obat'),
                ),
                TextField(
                  controller: TextEditingController(text: newType),
                  onChanged: (value) {
                    newType = value;
                  },
                  decoration: InputDecoration(labelText: 'Tipe Obat'),
                ),
                TextField(
                  controller: TextEditingController(text: newQuantity),
                  onChanged: (value) {
                    newQuantity = value;
                  },
                  decoration: InputDecoration(labelText: 'Kuantitas'),
                ),
                TextField(
                  controller: TextEditingController(text: newPrice),
                  onChanged: (value) {
                    newPrice = value;
                  },
                  decoration: InputDecoration(labelText: 'Harga Obat per Pack'),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    // Create a new Item with updated values
                    Item updatedItem = Item(
                      id: item.id,
                      name: newName,
                      type: newType,
                      quantity: int.parse(newQuantity),
                      price: int.parse(newPrice),
                      imagePath: newImagePath,
                    );

                    try {
                      // Update the item in the database
                      await _databaseHelper.updateItem(updatedItem);

                      // Show a toast or any other indication that the update is complete
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Data Obat Berhasil Di Perbarui.'),
                        ),
                      );

                      // Close the modal
                      Navigator.pop(context);
                    } catch (error) {
                      // Handle any errors that occurred during the update
                      print('Error updating item: $error');

                      // Show an error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error updating item.'),
                        ),
                      );
                    }
                  },
                  child: Text('Simpan Perubahan'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
