import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:switcher_button/switcher_button.dart';

import '../firebase.dart';

class UpdateItem extends StatefulWidget {
  const UpdateItem({Key? key}) : super(key: key);

  @override
  State<UpdateItem> createState() => _UpdateItemState();
}

class _UpdateItemState extends State<UpdateItem> {
  late Future<List<Map<String, dynamic>>> _itemListFuture;
  final TextEditingController itemIdController = TextEditingController();
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController itemDescriptionController = TextEditingController();
  final TextEditingController itemPriceController = TextEditingController();
  String _searchText = '';

  late Stream<QuerySnapshot> _itemsStream;
  void _showSnackBar(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }


  String _imageFile = '';
  Uint8List? selectedImageInBytes;

  final FirebaseStorage _storage = FirebaseStorage.instanceFor(
    bucket: 'gs://hungry-bunny-6ef57.appspot.com',
  );

  final FireStoreService _fireStoreService = FireStoreService();

  String _selectedMeal = 'Main Course';
  bool _isBestSelling = false;

  @override
  void initState() {
    super.initState();
    _itemsStream = FirebaseFirestore.instance.collection('items').snapshots();
    _itemListFuture = _fetchItems();
  }

  Future<void> pickImage() async {
    try {
      FilePickerResult? fileResult = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (fileResult != null) {
        setState(() {
          _imageFile = fileResult.files.first.name!;
          selectedImageInBytes = fileResult.files.first.bytes;
        });
      }
    } catch (e) {
      // If an error occurred, show SnackBar with error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<String> uploadImage(Uint8List selectedImageInBytes) async {
    try {
      Reference ref = _storage.ref().child('images/$_imageFile');

      final metadata = SettableMetadata(contentType: 'image/jpeg');

      UploadTask uploadTask = ref.putData(selectedImageInBytes, metadata);

      await uploadTask.whenComplete(() => print("Image Uploaded"));
      return await ref.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      return '';
    }
  }

  void updateSelectedItem() async {
    showDialog(
      context: context,
      builder: (context) {
        double uploadProgress = 0.0;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: itemIdController,
                    enabled: false,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Item ID',
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    value: _selectedMeal,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedMeal = newValue!;
                      });
                    },
                    items: <String>[
                      'Main Course',
                      'Burgers',
                      'Pizza',
                      'Appetizers',
                      'Desserts',
                      'Beverages'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  TextField(
                    controller: itemNameController,
                    decoration: InputDecoration(
                      labelText: 'Item Name',
                    ),
                  ),
                  TextField(
                    controller: itemDescriptionController,
                    decoration: InputDecoration(
                      labelText: 'Item Description',
                    ),
                  ),
                  TextField(
                    controller: itemPriceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Item Price',
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.image_rounded),
                    title: Text('Upload Image'),
                    onTap: () async {
                      // Pick image using file_picker package
                      pickImage();
                    },
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Best Selling',
                        style: TextStyle(fontSize: 16.0),
                      ),
                      SizedBox(width: 10),
                      SwitcherButton(
                        value: _isBestSelling,
                        onChange: (value) {
                          setState(() {
                            _isBestSelling = value;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  LinearProgressIndicator(
                    value: uploadProgress,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () async {
                    final String enteredItemId = itemIdController.text.trim();
                    final String enteredItemName = itemNameController.text.trim();
                    final String enteredItemDescription = itemDescriptionController.text.trim();
                    final String enteredItemPrice = itemPriceController.text.trim();
                    if (enteredItemId.isEmpty ||
                        enteredItemName.isEmpty ||
                        enteredItemDescription.isEmpty ||
                        enteredItemPrice.isEmpty) {
                      _showSnackBar('All fields are required');
                      return;
                    }

                    if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(enteredItemPrice)) {
                      _showSnackBar('Invalid item price!');
                      return;
                    }

                    if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(enteredItemId)) {
                      _showSnackBar('Invalid Item ID!');
                      return;
                    }

                    if (selectedImageInBytes == null) {
                      _showSnackBar('Please select an image!');
                      return;
                    }

                    setState(() {
                      uploadProgress = 0.5;
                    });

                    final String imageUrl = await uploadImage(selectedImageInBytes!);

                    setState(() {
                      uploadProgress = 1.0;
                    });

                    await _fireStoreService.updateItem(
                      int.parse(enteredItemId),
                      _selectedMeal,
                      itemNameController.text,
                      itemDescriptionController.text,
                      double.parse(itemPriceController.text),
                      imageUrl,
                      _isBestSelling,
                    );

                    showToast(
                      'Item Updated',
                      context: context,
                      backgroundColor: const Color(0xFFE0FFE0),
                      textStyle: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      textPadding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.elliptical(10.0, 20.0),
                          bottom: Radius.elliptical(10.0, 20.0)),
                      textAlign: TextAlign.justify,
                      textDirection: TextDirection.ltr,
                      position: const StyledToastPosition(
                        align: Alignment.bottomCenter,
                        offset: 20.0,
                      ),
                    );


                    itemIdController.clear();
                    itemNameController.clear();
                    itemDescriptionController.clear();
                    itemPriceController.clear();


                    Navigator.pop(context);
                  },
                  child: Text("Update Item"),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.lightGreenAccent),
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _fetchItems() async {

    final QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
        .collection('items')
        .get();


    return querySnapshot.docs.map((doc) {
      return {
        'itemId': doc['itemId'],
        'itemName': doc['itemName'],
      };
    }).toList();
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Container(
        height: 45.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: TextField(
            onChanged: (value) {
              setState(() {
                _searchText = value;
              });
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Search items...',
              hintStyle: TextStyle(color: Colors.grey),
              prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20.0),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xF50B4EAF),
        title: const Text(
          "Update Item",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            SizedBox(height: 10.0,),
            _buildSearchBar(),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _itemListFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {

                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {

                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {

                    final itemList = snapshot.data!;
                    final filteredItems = _searchText.isEmpty
                        ? itemList
                        : itemList.where((item) {
                      final itemId = item['itemId'].toString().toLowerCase();
                      final itemName = item['itemName'].toString().toLowerCase();
                      final searchLower = _searchText.toLowerCase();

                      return itemId.contains(searchLower) ||
                          itemName.contains(searchLower);
                    }).toList();
                    return ListView.builder(
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          child: ListTile(
                            title: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${item['itemId']}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 25),
                                Text(
                                  '${item['itemName']}',
                                  //style: tiletext,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () async {

                              QuerySnapshot<Map<String, dynamic>> itemSnapshot = await FirebaseFirestore.instance
                                  .collection('items')
                                  .where('itemId', isEqualTo: item['itemId'])
                                  .limit(1)
                                  .get();

                              if (itemSnapshot.docs.isNotEmpty) {

                                Map<String, dynamic> itemData = itemSnapshot.docs.first.data();


                                setState(() {
                                  itemIdController.text = itemData['itemId'].toString();
                                  _selectedMeal = itemData['categoryName'];
                                  itemNameController.text = itemData['itemName'];
                                  itemDescriptionController.text = itemData['itemDescription'];
                                  itemPriceController.text = itemData['itemPrice'].toString();


                                });


                                updateSelectedItem();
                              } else {

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Item details not found')),
                                );
                              }
                            },
                            trailing: Icon(Icons.update_rounded,

                        ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
