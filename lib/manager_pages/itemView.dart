import 'package:flutter/material.dart';
import 'package:intl/intl.dart';   
import 'dart:io';
import '../databaseHelper.dart';
import '../usersAndItemsModel.dart';

class ViewItemPage extends StatefulWidget {
  @override
  _ViewItemPageState createState() => _ViewItemPageState();
}

class _ViewItemPageState extends State<ViewItemPage> {
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
        title: Text('Lihat Obat'),
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
          child: ListView(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (items != null || !items!.isEmpty)
                    Title(
                      child: Text(
                        "Terdapat ${items!.length} Data Di Database.",
                        textScaleFactor: 1.2,
                      ),
                      color: Colors.black,
                    ),
                  SizedBox(height: 16.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: (items != null && items!.isNotEmpty) ? items!.map((item) {
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${item.name} ', style: TextStyle(fontWeight: FontWeight.bold)),
                                    SizedBox(height: 8.0),
                                    Text('ID            : ${item.id}'),
                                    Text('Tipe         : ${item.type}'),
                                    Text('Kuantitas : ${numberFormat.format(item.quantity)}'),
                                    Text('Harga      : Rp. ${numberFormat.format(item.price)}'),
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
                    }).toList() : [Text('Tidak ada obat di database.')],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditModal(BuildContext context, Item item) {
    // Your existing code for showing the edit modal
    // ...
  }
}
