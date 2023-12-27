import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import '../databaseHelper.dart';
import '../usersAndItemsModel.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _searchQuery = "";
  String? _bannerImagePath;

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  Future<void> _loadBanner() async {
    final banners = await BannerDatabaseHelper().getBanners();
    setState(() {
      if (banners.isNotEmpty) {
        _bannerImagePath = banners.first.filename;
      }
    });
  }

  Future<String> loadAsset() async {
    return await rootBundle.loadString('assets/obat.json');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // White box behind the navbar
        Container(
          height: 130,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.lightBlue,
                Colors.lightBlue.withOpacity(0.0), // Fade to transparent
              ],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(5),
              bottomRight: Radius.circular(5),
            ),
          ),
        ),

        // Home page content
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: ListView(
            children: [
              SizedBox(height: 10), // Add space below the app bar

              // Swipeable banner section
              IgnorePointer(
                child: Container(
                  height: 170,
                  margin: EdgeInsets.all(10),
                  child: _bannerImagePath != null
                      ? Container(
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
                      : PageView.builder(
                          itemCount: 3,
                          itemBuilder: (context, index) {
                            return Container(
                              width: 120,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withOpacity(0.4), // Light black shadow
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              // Add the content of each banner here
                            );
                          },
                        ),
                ),
              ),

              // Search box
              Container(
                margin: EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    SizedBox(width:14), // Increase the width to move the search icon to the right
                    Expanded(
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.toLowerCase();
                          });
                        },
                        decoration: InputDecoration(
                          hintText: "Search for Drugs...",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              // Dynamic Category List
              FutureBuilder(
                future: loadAsset(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    var obatData = json.decode(snapshot.data!);
                    return Column(
                      children: [
                        for (var category in obatData.keys)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Add spacing
                              SizedBox(height: 30),

                              // Category name
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 15, top: 5),
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),

                              // Add spacing
                              SizedBox(height: 10),

                              // Item List
                              Container(
                                height: 200,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      for (var obat in obatData[category])
                                        // Add a filter based on the search query
                                        if (obat['nama']
                                            .toLowerCase()
                                            .contains(_searchQuery))
                                          Container(
                                            width: 150,
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 10),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.5),
                                                  spreadRadius: 2,
                                                  blurRadius: 5,
                                                  offset: Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Image
                                                Container(
                                                  height: 120,
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.vertical(
                                                            top:
                                                                Radius.circular(
                                                                    10)),
                                                    image: DecorationImage(
                                                      image: AssetImage(
                                                          'assets/test_image.png'), // Update the image path
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),

                                                // Add spacing
                                                SizedBox(height: 10),

                                                // Name
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10),
                                                  child: Text(
                                                    obat['nama']
                                                        .toString()
                                                        .capitalize(),
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),

                                                // Add spacing
                                                SizedBox(height: 5),

                                                // Price
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10),
                                                  child: Text(
                                                      'Rp. ${obat['harga']}'),
                                                ),
                                              ],
                                            ),
                                          ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Function to get banner colors based on index
  Color _getBannerColor(int index) {
    switch (index) {
      case 0:
        return Colors.blue;
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      default:
        return Colors.green; // Default color
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    if (this.isEmpty) return this;
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
