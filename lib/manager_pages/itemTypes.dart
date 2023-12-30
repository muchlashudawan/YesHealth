import 'package:flutter/material.dart';
import '../databaseHelper.dart';
import '../usersAndItemsModel.dart';

class EditItemTypePage extends StatefulWidget {
  @override
  _EditItemTypePageState createState() => _EditItemTypePageState();
}

class _EditItemTypePageState extends State<EditItemTypePage> {
  final ItemTypeDatabaseHelper _databaseHelper = ItemTypeDatabaseHelper();
  List<TypeItem>? types = null;

  Future<void> _refreshTypes() async {
    try {
      // Fetch the updated TypeItem types from the database
      List<TypeItem> updatedTypes = await _databaseHelper.getItemTypes();

      // Update the state with the new data
      setState(() {
        types = updatedTypes;
      });

      // Show a toast or any other indication that the refresh is complete
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('List Tipe Obat Telah Di Perbarui.'),
        ),
      );
    } catch (error) {
      // Handle any errors that occurred during the refresh
      print('Error refreshing TypeItem types: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error refreshing TypeItem types.'),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Trigger the automatic refresh when the screen is loaded
    _refreshTypes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ubah Tipe Obat'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: RefreshIndicator(
          onRefresh: _refreshTypes,
          child: ListView(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (types != null || !types!.isEmpty)
                    Title(
                      child: Text(
                        "Terdapat ${types!.length} Data Di Database.",
                        textScaleFactor: 1.2,
                      ),
                      color: Colors.black,
                    ),
                  SizedBox(height: 16.0),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: (types != null && types!.isNotEmpty)
                        ? types!.map((type) {
                            return GestureDetector(
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 8.0),
                                padding: EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey, width: 2),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,

                                        children: [
                                          Text('${type.type} ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold, fontSize: 20)),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.edit),
                                          onPressed: () {
                                            _showEditModal(context, type);
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete),
                                          onPressed: () {
                                            _showDeleteConfirmationDialog(
                                                context, type);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList()
                        : [Text('Tidak ada tipe obat di database.')],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTypeDialog(context);
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.black,
      ),
    );
  }

  void _showEditModal(BuildContext context, TypeItem type) {
    // Set initial values for the text fields
    String newType = type.type;

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Ubah Data Tipe Obat'),
                TextFormField(
                  controller: TextEditingController(text: newType),
                  onChanged: (value) {
                    newType = value;
                  },
                  decoration: InputDecoration(labelText: 'Tipe Obat'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Tipe Obat tidak boleh kosong.';
                    }
                    // Add more checks as needed
                    if (value.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
                      return 'Tipe Obat tidak boleh mengandung simbol.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    // Validate the form
                    if (Form.of(context)!.validate()) {
                      // Create a new TypeItem with updated values
                      TypeItem updatedType = TypeItem(
                        id: type.id!,
                        type: newType,
                      );

                      try {
                        // Update the TypeItem type in the database
                        await _databaseHelper.updateItemType(
                            updatedType.id ?? 0, updatedType.type);

                        // Show a toast or any other indication that the update is complete
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Data Tipe Obat Berhasil Di Perbarui.'),
                          ),
                        );

                        // Close the modal
                        Navigator.pop(context);

                        // Refresh the list of TypeItem types
                        _refreshTypes();
                      } catch (error) {
                        // Handle any errors that occurred during the update
                        print('Error updating TypeItem type: $error');

                        // Show an error message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error updating TypeItem type.'),
                          ),
                        );
                      }
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

  void _showDeleteConfirmationDialog(BuildContext context, TypeItem type) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hapus Tipe Obat'),
          content: Text('Apakah Anda yakin ingin menghapus tipe obat ini?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  // Delete the TypeItem type from the database
                  await _databaseHelper.deleteItemType(type.id!);

                  // Show a toast or any other indication that the deletion is complete
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Tipe Obat Berhasil Dihapus.'),
                    ),
                  );

                  // Close the dialog
                  Navigator.of(context).pop();

                  // Refresh the list of TypeItem types
                  _refreshTypes();
                } catch (error) {
                  // Handle any errors that occurred during the deletion
                  print('Error deleting TypeItem type: $error');

                  // Show an error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting TypeItem type.'),
                    ),
                  );
                }
              },
              child: Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  void _showAddTypeDialog(BuildContext context) {
    String newType = '';
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Tambah Tipe Obat'),
          content: Form(
            key: _formKey,
            child: TextFormField(
              onChanged: (value) {
                newType = value;
              },
              decoration: InputDecoration(labelText: 'Tipe Obat'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Tipe Obat tidak boleh kosong.';
                }
                // Add more checks as needed
                if (value.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
                  return 'Tipe Obat tidak boleh mengandung simbol.';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                // Validate the form
                if (_formKey.currentState!.validate()) {
                  try {
                    // Add the new TypeItem type to the database
                    await _databaseHelper.addItemType(newType);

                    // Show a toast or any other indication that the addition is complete
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Tipe Obat Berhasil Ditambahkan.'),
                      ),
                    );

                    // Close the dialog
                    Navigator.of(context).pop();

                    // Refresh the list of TypeItem types
                    _refreshTypes();
                  } catch (error) {
                    // Handle any errors that occurred during the addition
                    print('Error adding TypeItem type: $error');

                    // Show an error message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error adding TypeItem type.'),
                      ),
                    );
                  }
                }
              },
              child: Text('Tambah'),
            ),
          ],
        );
      },
    );
  }
}
