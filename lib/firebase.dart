import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'item_model.dart';

class FireStoreService {
  final CollectionReference items = FirebaseFirestore.instance.collection('items');
  final CollectionReference users = FirebaseFirestore.instance.collection('users');
  final FirebaseStorage _storage = FirebaseStorage.instanceFor(
    bucket: 'gs://clashy-kitchen.appspot.com',
  );



  Future<void> addUser(String email, String username, String phoneNumber, String address, String hashedPassword) {
    return users.doc(email).set({
      'email': email,
      'username': username,
      'phoneNumber':phoneNumber,
      'address':address,
      'password': hashedPassword,
    });
  }

  Future<void> addItem(int itemId, String categoryName, String itemName, String itemDescription, double itemPrice, String ImageUrl, bool isBestSelling) {
    return FirebaseFirestore.instance.collection('items').doc(itemId.toString()).set({
      'itemId': itemId,
      'categoryName': categoryName,
      'itemName': itemName,
      'itemDescription': itemDescription,
      'itemPrice': itemPrice,
      'imageUrl': ImageUrl,
      'isBestSelling': isBestSelling,
    });
  }


  Stream<QuerySnapshot> getItemsStream() {
    final itemsStream = items.orderBy('itemId', descending: true).snapshots();
    return itemsStream;
  }

  Stream<QuerySnapshot> getUsersStream() {
    final itemsStream = users.orderBy('email', descending: true).snapshots();
    return itemsStream;
  }


  Future<void> updateItem(int itemId, String categoryName, String itemName, String itemDescription, double itemPrice, String ImageUrl, bool isBestSelling) {
    return FirebaseFirestore.instance.collection('items').doc(itemId.toString()).update({

      'itemId': itemId,
      'categoryName': categoryName,
      'itemName': itemName,
      'itemDescription':itemDescription,
      'itemPrice':itemPrice,
      'imageUrl':ImageUrl,
      'isBestSelling': isBestSelling,

    });
  }

  Future<void> addPendingOrder(Map<String, Item> items, double totalPrice, String username, String email, String phoneNumber, String address) async {
    try {
      int latestOrderId = await _getLatestOrderId();

      int orderId = latestOrderId + 1;

      CollectionReference orders = FirebaseFirestore.instance.collection('orders');

      DocumentReference orderRef = orders.doc(orderId.toString());

      await orderRef.set({
        'orderId': orderId,
        'email': email,
        'username': username,
        'address': address,
        'phoneNumber': phoneNumber,
        'totalPrice': totalPrice,
        'orderStatus': "Pending",
        'items': items.map((key, item) => MapEntry(key, {
          'name': item.name,
          'quantity': item.quantity,
          'subtotal':item.subtotal,
        })),
        'timestamp': DateTime.now(),
      });

      print('Order added with ID: $orderId');
    } catch (e) {
      print('Error adding order: $e');
    }
  }

  Future<int> _getLatestOrderId() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('orders').orderBy('orderId', descending: true).limit(1).get();
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first['orderId'];
      } else {
        return 0;
      }
    } catch (e) {
      print('Error getting latest order ID: $e');
      return 0;
    }
  }


  Future<void> updateAcceptedOrder(int orderId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('orders').where('orderId', isEqualTo: orderId).limit(1).get();

      if (querySnapshot.docs.isNotEmpty) {

        DocumentReference orderRef = querySnapshot.docs.first.reference;

        await orderRef.update({
          'orderStatus': 'Accepted',
        }

        );

        String recipientEmail = querySnapshot.docs.first['email'];
        print('Order status updated successfully for id: $orderId');
      } else {
        print('No document found with orderId: $orderId');
      }
    } catch (e) {
      print('Error updating order status: $e');
    }
  }

  Future<void> updateCancelledOrder(int orderId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('orders').where('orderId', isEqualTo: orderId).limit(1).get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentReference orderRef = querySnapshot.docs.first.reference;

        await orderRef.update({
          'orderStatus': 'Cancelled',
        });
        String recipientEmail = querySnapshot.docs.first['email'];

        print('Order status updated successfully for id: $orderId');
      } else {
        print('No document found with orderId: $orderId');
      }
    } catch (e) {
      print('Error updating order status: $e');
    }
  }

  Future<void> updateCompletedOrder(int orderId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('orders').where('orderId', isEqualTo: orderId).limit(1).get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentReference orderRef = querySnapshot.docs.first.reference;

        await orderRef.update({
          'orderStatus': 'Completed',
        });
        String recipientEmail = querySnapshot.docs.first['email'];

        print('Order status updated successfully for id: $orderId');
      } else {
        print('No document found with orderId: $orderId');
      }
    } catch (e) {
      print('Error updating order status: $e');
    }
  }


  Stream<QuerySnapshot> getBestSellingStream() {
    final bestSellingStream = items.where('isBestSelling', isEqualTo: true).snapshots();
    return bestSellingStream;
  }



  Future<void> deleteItem(int itemId, String imageUrl) async {
    try {
      await items.doc(itemId.toString()).delete();

      String imageName = extractFilenameFromUrl(imageUrl);
      print('Image Name: $imageName');

      Reference imageRef = _storage.ref().child('images/$imageName');

      await imageRef.delete();
    } catch (error) {
      throw Exception('Failed to delete item: $error');
    }
  }

  Future<void> addFavorite(String email, int itemId) {
    String documentId = '$email-$itemId';

    return FirebaseFirestore.instance.collection('favorites').doc(documentId).set({
      'email': email,
      'itemId': itemId,
    });
  }

  Future<void> deleteFavorite(String email, int itemId) async {
    try {
      await FirebaseFirestore.instance
          .collection('favorites')
          .where('email', isEqualTo: email)
          .where('itemId', isEqualTo: itemId)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) async {
          await doc.reference.delete();
        });
      });
    } catch (e) {
    }
  }

  Future<bool> isFavorite(String email, int itemId) async {
    try {
      final FirebaseFirestore _firestore = FirebaseFirestore.instance;
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('favorites')
          .where('email', isEqualTo: email)
          .where('itemId', isEqualTo: itemId)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print("Error checking favorite: $e");
      return false;
    }
  }


  String extractFilenameFromUrl(String imageUrl) {
    try {
      List<String> parts = imageUrl.split('/');
      String encodedFilename = parts.last;
      String decodedFilename = Uri.decodeComponent(encodedFilename);
      String filename = decodedFilename.split('/').last.split('?').first;
      return filename;
    } catch (e) {
      throw Exception('Failed to extract filename from URL: $e');
    }
  }



}
