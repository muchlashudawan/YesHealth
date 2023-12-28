import 'package:flutter/material.dart';
import 'dart:io';
import '../databaseHelper.dart';
import '../usersAndItemsModel.dart';
import 'package:intl/intl.dart';   

class DeleteItemPage extends StatefulWidget {
  @override
  _DeleteItemPageState createState() => _DeleteItemPageState();
}

class _DeleteItemPageState extends State<DeleteItemPage> {
  final ItemDatabaseHelper _databaseHelper = ItemDatabaseHelper();
  List<Item>? items;
  List<bool>? selectedItems;

  NumberFormat numberFormat = NumberFormat.decimalPattern('id');

  @override
  void initState() {
    super.initState();
    // Trigger the automatic refresh when the screen is loaded
    _refreshItems();
  }

  Future<void> _refreshItems() async {
    try {
      // Fetch the updated items from the database
      List<Item> updatedItems = await _databaseHelper.getItems();

      // Update the state with the new data
      setState(() {
        items = updatedItems;
        // Initialize selectedItems with false for each item
        selectedItems =
            List<bool>.generate(updatedItems.length, (index) => false);
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

  bool _isAnyCheckboxChecked() {
  // Check if at least one checkbox is checked
  return items?.any((item) => item.isSelected) ?? false;
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hapus Obat'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              _showDeleteConfirmation(context);
            },
          ),
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
                  if (items == null || items!.isEmpty)
                    Text('Tidak ada Obat di database.')
                  else
                    Title(
                      child: Text(
                        "Silahkan Pilih Obat Yang Akan Di Hapus.",
                        textScaleFactor: 1.2,
                      ),
                      color: Colors.black,
                    ),
                  SizedBox(height: 16.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: items?.asMap().entries.map((entry) {
                          int index = entry.key;
                          Item item = entry.value;
                          return Container(
                            margin: EdgeInsets.symmetric(vertical: 8.0),
                            padding: EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: selectedItems?[index] ?? false,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedItems?[index] = value ?? false;
                                    });
                                  },
                                ),
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
                                    Text(item.description ?? "Tidak AdA Deskripsi"),

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
                          );
                        }).toList() ??
                        [],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    int itemCount = selectedItems?.where((selected) => selected).length ?? 0;

    if (itemCount > 0) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Konfirmasi Hapus'),
            content:
                Text('Apakah Anda yakin ingin menghapus $itemCount Obat?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: Text('Tidak'),
              ),
              TextButton(
                onPressed: () async {
                  await _deleteSelectedItems();
                  Navigator.pop(context); // Close the dialog
                },
                child: Text('Ya'),
              ),
            ],
          );
        },
      );
    } else {
      // Show a message if no items are selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pilih setidaknya satu Obat untuk dihapus.'),
        ),
      );
    }
  }

  Future<void> _deleteSelectedItems() async {
    try {
      // Find the indices of selected items
      List<int> selectedIndices = [];
      for (int i = 0; i < selectedItems!.length; i++) {
        if (selectedItems![i]) {
          selectedIndices.add(i);
        }
      }

      // Delete selected items from the database
      for (int index in selectedIndices) {
        if (items != null && items!.isNotEmpty && index < items!.length) {
          await _databaseHelper.deleteItem(items![index].id!);
        }
      }

      // Refresh the items list after deletion
      await _refreshItems();

      // Show a toast or any other indication that the deletion is complete
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Obat berhasil dihapus.'),
        ),
      );
    } catch (error) {
      // Handle any errors that occurred during deletion
      print('Error deleting items: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting items.'),
        ),
      );
    }
  }
}
