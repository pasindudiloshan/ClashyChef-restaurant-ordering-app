import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

import '../firebase.dart';

class DeleteItem extends StatefulWidget {
  const DeleteItem({Key? key}) : super(key: key);

  @override
  State<DeleteItem> createState() => _DeleteItemState();
}

class _DeleteItemState extends State<DeleteItem> {
  final FirebaseStorage _storage = FirebaseStorage.instanceFor(
    bucket: 'gs://clashy-kitchen.appspot.com',
  );
  late Future<List<Map<String, dynamic>>> _itemListFuture;
  final FireStoreService _fireStoreService = FireStoreService();
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _itemListFuture = _fetchItems();
  }

  Future<List<Map<String, dynamic>>> _fetchItems() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await FirebaseFirestore.instance.collection('items').get();

      return querySnapshot.docs.map((doc) {
        return {
          'itemId': doc['itemId'],
          'itemName': doc['itemName'],
          'imageUrl': doc['imageUrl'],
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch items: $e');
    }
  }

  Future<void> _deleteItem(int itemId, String imageUrl) async {
    try {
      await _fireStoreService.deleteItem(itemId, imageUrl);

      showToast(
        'Item Deleted',
        context: context,
        backgroundColor: const Color(0xFFF6C5C5),
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
      setState(() {
        _itemListFuture = _fetchItems();
      });
    } catch (e) {
      showToast(
        'Deletion Failed',
        context: context,
        backgroundColor: const Color(0xFFF6B8B8),
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
    }
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
          "Delete Item",
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
                              children: [
                                Text(
                                  '${item['itemId']}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  '${item['itemName']}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () async {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Confirm Deletion'),
                                  content: Text('Delete Item Permanently?'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        _deleteItem(item['itemId'], item['imageUrl']);
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            trailing: Icon(Icons.delete),
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
