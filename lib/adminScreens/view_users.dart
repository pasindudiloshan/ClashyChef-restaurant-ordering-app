import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../firebase.dart';

class ViewUsers extends StatefulWidget {
  const ViewUsers({Key? key}) : super(key: key);

  @override
  State<ViewUsers> createState() => _ViewUsersState();
}

class _ViewUsersState extends State<ViewUsers> {
  final FireStoreService _fireStoreService = FireStoreService();

  late Future<List<Map<String, dynamic>>> _itemListFuture;

  @override
  void initState() {
    super.initState();
    _itemListFuture = _fetchItems();
  }

  Future<List<Map<String, dynamic>>> _fetchItems() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await FirebaseFirestore.instance.collection('customers').get();

      return querySnapshot.docs.map((doc) {
        return {
          'email': doc['email'],
          'username': doc['username'],
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch items: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xF50B4EAF),
        title: const Text(
          "Registered Customers",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _itemListFuture,
          builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              final itemList = snapshot.data!;
              return ListView.builder(
                itemCount: itemList.length,
                itemBuilder: (context, index) {
                  final user = itemList[index];
                  return Column(
                    children: [
                      Card(
                        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        child: ListTile(
                          leading: Text(
                            '${index + 1}',
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ' Username: ${user['username']}',
                              ),
                              SizedBox(height: 5),
                              Text(
                                ' Email: ${user['email']}',
                               // style: tiletext,
                              ),
                            ],
                          ),
                          onTap: () async {
                            //
                          },
                        ),
                      ),
                      SizedBox(height: 5),
                    ],
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
