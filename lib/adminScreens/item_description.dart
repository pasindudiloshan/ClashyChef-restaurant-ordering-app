import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ItemDescription extends StatefulWidget {
  final int itemId;

  const ItemDescription({Key? key, required this.itemId}) : super(key: key);

  @override
  _ItemDescriptionState createState() => _ItemDescriptionState();
}

class _ItemDescriptionState extends State<ItemDescription> {
  late Future<Map<String, dynamic>> _itemDetailsFuture;

  @override
  void initState() {
    super.initState();
    _itemDetailsFuture = _fetchItemDetails(widget.itemId.toString());
  }

  Future<Map<String, dynamic>> _fetchItemDetails(String itemId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
          .instance
          .collection('items')
          .where(FieldPath.documentId, isEqualTo: itemId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        return {
          'itemName': data['itemName'] ?? 'No Name',
          'itemDescription': data['itemDescription'] ?? 'No Description',
          'itemPrice': (data['itemPrice'] ?? 0.0).toDouble(),
          'imageUrl': data['imageUrl'] ?? '',
        };
      } else {
        throw Exception('Item not found with itemId: $itemId');
      }
    } catch (e) {
      throw Exception('Failed to fetch item details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Item Details',
          style: TextStyle(color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,),
        ),
        backgroundColor: Color(0xff1872a4),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _itemDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final itemDetails = snapshot.data!;
            return ItemDetailsSection(
              itemName: itemDetails['itemName'] ?? 'No Name',
              itemDescription: itemDetails['itemDescription'] ?? 'No Description',
              itemPrice: itemDetails['itemPrice'] ?? 0.0,
              itemImageUrl: itemDetails['imageUrl'] ?? '',
            );
          }
        },
      ),
    );
  }
}

class ItemDetailsSection extends StatelessWidget {
  final String itemName;
  final String itemDescription;
  final double itemPrice;
  final String itemImageUrl;

  const ItemDetailsSection({
    required this.itemName,
    required this.itemDescription,
    required this.itemPrice,
    required this.itemImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            itemName,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          Image.network(
            itemImageUrl,
            height: 300,
            fit: BoxFit.fitWidth,
            errorBuilder: (context, error, stackTrace) {
              print('Error loading image from $itemImageUrl: $error');
              return Icon(Icons.error);
            },
          ),

          SizedBox(height: 8),
          Text(
            itemDescription,
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Rs. $itemPrice',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          SizedBox(height: 16),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}
