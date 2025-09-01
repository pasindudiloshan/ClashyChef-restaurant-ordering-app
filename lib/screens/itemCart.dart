import 'package:clashy_kitchen/screens/userOrders.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase.dart';
import '../provider.dart';
import 'cart.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CartPage extends StatefulWidget {
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final fireStoreService = FireStoreService();

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Calculate total price
    double totalPrice = cart.items.values.fold(
      0,
          (previousValue, item) => previousValue + (item.price * item.quantity),
    );

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFFCE1E39),
        title: Text(
          "My Cart",
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: cart.items.isEmpty
            ? Center(
          child: Text(
            'Cart is Empty',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
            : Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cart.items.length,
                itemBuilder: (context, index) {
                  var item = cart.items.values.toList()[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 15.0),
                    padding: EdgeInsets.all(15.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200], // Light gray background
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                        color: Color(0xFFCE1E39),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Image.network(
                          item.imageUrl,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Rs. ${item.price}',
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 20),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                cart.increaseQuantity(item.name);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red,
                                ),
                                child: Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              'Qty: ${item.quantity}',
                              style: TextStyle(color: Colors.black),
                            ),
                            SizedBox(height: 8.0),
                            GestureDetector(
                              onTap: () {
                                cart.decreaseQuantity(item.name);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red,
                                ),
                                child: Icon(
                                  Icons.remove,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 8.0),
                        IconButton(
                          icon: Icon(Icons.delete),
                          color: Colors.red,
                          onPressed: () {
                            cart.removeItem(item.name);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 10.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Text(
                'Total: Rs. $totalPrice',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 50.0,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,

                ),
                onPressed: () async {
                  await _confirmOrder(context, cart, userProvider, totalPrice);
                },
                child: Text(
                  'Confirm Order',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmOrder(BuildContext context, Cart cart, UserProvider userProvider, double totalPrice) async {
    String email = userProvider.email ?? '';
    String username = userProvider.username ?? '';

    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('customers').doc(email).get();
    String phoneNumber = userSnapshot['phone'] ?? '';
    String address = userSnapshot['address'] ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Order'),
          content: const Text('Are you sure you want to confirm this order?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                 Navigator.of(context).pop();

                await fireStoreService.addPendingOrder(cart.items, totalPrice, username, email, phoneNumber, address);

                 cart.clearCart();

                await Fluttertoast.showToast(
                  msg: "Order Placed Successfully!",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.TOP_RIGHT,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                );

                await Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => UserOrders()),
                );
              },
              child: const Text('OK'),
            )
          ],
        );
      },
    );
  }
}
