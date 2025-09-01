import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderDetails extends StatefulWidget {
  final int orderId;

  const OrderDetails({Key? key, required this.orderId}) : super(key: key);

  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  late Future<DocumentSnapshot<Map<String, dynamic>>> _orderDetailsFuture;

  @override
  void initState() {
    super.initState();
    _orderDetailsFuture = _fetchOrderDetails();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _fetchOrderDetails() async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> orderSnapshot =
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId.toString())
          .get();

      return orderSnapshot;
    } catch (e) {
      throw Exception('Failed to fetch order details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Order Details",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF3EA94C),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _orderDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final orderData = snapshot.data!.data()!;
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),
                  Text(
                    'Order ID:   ${orderData['orderId']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Username:   ${orderData['username']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Email:   ${orderData['email']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Address:   ${orderData['address']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Phone Number:   ${orderData['phoneNumber']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Order Status:   ${orderData['orderStatus']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total Price: Rs.  ${orderData['totalPrice']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Items:',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView(
                      children: (orderData['items'] as Map<String, dynamic>)
                          .entries
                          .map(
                            (entry) => Card(
                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                          child: ListTile(
                            title: Text(
                              entry.value['name'],
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Quantity:   ${entry.value['quantity']}',
                                  style: const TextStyle(fontWeight: FontWeight.normal),
                                ),
                                Text(
                                  'Subtotal: Rs.  ${entry.value['subtotal']}',
                                  style: const TextStyle(fontWeight: FontWeight.normal),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                          .toList(),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
