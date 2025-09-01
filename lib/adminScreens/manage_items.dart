import 'dart:typed_data';
import 'package:clashy_kitchen/adminScreens/update_item.dart';
import 'package:clashy_kitchen/adminScreens/view_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:switcher_button/switcher_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../firebase.dart';
import 'delete_item.dart';

class ManageItems extends StatefulWidget {
  const ManageItems({Key? key}) : super(key: key);

  @override
  State<ManageItems> createState() => _ManageItemsState();
}

class _ManageItemsState extends State<ManageItems> {
  final TextEditingController itemIdController = TextEditingController();
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController itemDescriptionController = TextEditingController();
  final TextEditingController itemPriceController = TextEditingController();
  bool _isBestSelling = false;
  late Stream<QuerySnapshot> _itemsStream;

  Uint8List? selectedImageInBytes;

  final FirebaseStorage _storage = FirebaseStorage.instanceFor(
    bucket: 'gs://clashy-kitchen.appspot.com',
  );

  final FireStoreService _fireStoreService = FireStoreService();

  String _selectedMeal = 'Main Course';

  @override
  void initState() {
    super.initState();
    _itemsStream = FirebaseFirestore.instance.collection('items').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Items',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFCE1E39),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedCard(
              title: "View Items",
              onTap: () => _navigateTo(context, const ViewItem()),
            ),
            const SizedBox(height: 20),
            ElevatedCard(
              title: "Update Item",
              onTap: () => _navigateTo(context, const UpdateItem()),
            ),
            const SizedBox(height: 20),
            ElevatedCard(
              title: "Add Item",
              onTap: () => addItem(),
            ),
            const SizedBox(height: 20),
            ElevatedCard(
              title: "Delete Item",
              onTap: () => _navigateTo(context, const DeleteItem()),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => page));
  }

  Future<void> addItem() async {
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
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Item ID'),
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
                    decoration: const InputDecoration(labelText: 'Item Name'),
                  ),
                  TextField(
                    controller: itemDescriptionController,
                    decoration: const InputDecoration(labelText: 'Item Description'),
                  ),
                  TextField(
                    controller: itemPriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Item Price'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.image_rounded),
                    title: const Text('Upload Image'),
                    onTap: pickImage,
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text('Best Selling', style: TextStyle(fontSize: 16.0)),
                      const SizedBox(width: 10),
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
                  const SizedBox(height: 15),
                  LinearProgressIndicator(
                    value: uploadProgress,
                    backgroundColor: Colors.grey[100],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () async {
                    try {
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
                        uploadProgress = 0.5;    // Update progress to 50%
                      });

                      final String imageUrl = await uploadImage(selectedImageInBytes!);

                      setState(() {
                        uploadProgress = 1.0;    // Update progress to 100%
                      });

                      final QuerySnapshot<Map<String, dynamic>> existingItem =
                      await FirebaseFirestore.instance
                          .collection('items')
                          .where('itemId', isEqualTo: int.parse(enteredItemId))
                          .get();

                      if (existingItem.docs.isNotEmpty) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Error'),
                            content: const Text('An item with the same Item ID already exists.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                        return;
                      }

                      await _fireStoreService.addItem(
                        int.parse(enteredItemId),
                        _selectedMeal,
                        enteredItemName,
                        enteredItemDescription,
                        double.parse(enteredItemPrice),
                        imageUrl,
                        _isBestSelling,
                      );

                      showToast(
                        'New Item Added',
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
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.lightGreenAccent),
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                  ),
                  child: const Text("Add Item"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      setState(() {
        selectedImageInBytes = result.files.first.bytes;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<String> uploadImage(Uint8List imageBytes) async {
    Reference ref = _storage.ref().child('images/${DateTime.now().millisecondsSinceEpoch}.png');
    UploadTask uploadTask = ref.putData(imageBytes);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }
}

class ElevatedCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const ElevatedCard({
    Key? key,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      color: const Color(0xFFE0E0E0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Colors.red,
        ),
        onTap: onTap,
      ),
    );
  }
}
