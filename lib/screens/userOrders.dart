import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../adminScreens/order_details.dart';
import '../provider.dart';

class UserOrders extends StatefulWidget {
  const UserOrders({Key? key}) : super(key: key);

  @override
  State<UserOrders> createState() => _UserOrdersState();
}

class _UserOrdersState extends State<UserOrders> {
  late String _email;

  @override
  void initState() {
    super.initState();
    _getEmailFromProvider();
  }

  void _getEmailFromProvider() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _email = userProvider.email ?? '';
  }

  Future<List<Map<String, dynamic>>> _fetchUserOrders() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await FirebaseFirestore.instance
          .collection('orders')
          .where('email', isEqualTo: _email)
          .get();

      return querySnapshot.docs.map((doc) {
        return {
          'orderId': doc['orderId'],
          'orderStatus': doc['orderStatus'] ?? 'No Status',
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch user orders: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isLoggedIn = userProvider.username != null && userProvider.email != null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFCE1E39),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "My Orders",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: isLoggedIn
          ? Padding(
            padding: const EdgeInsets.all(20.0),
            child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _fetchUserOrders(),
                    builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              List<Map<String, dynamic>> orders = snapshot.data!;
              orders.sort((a, b) {
                // Define the order of statuses
                Map<String, int> statusOrder = {
                  'Pending': 0,
                  'Accepted': 1,
                  'Completed': 2,
                  'Cancelled': 3,
                };
                return statusOrder[a['orderStatus']]! - statusOrder[b['orderStatus']]!;
              });
              return ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 30.0),
                    child: Container(
                      color: Colors.lightGreenAccent, // Light green background for the card
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero, // Remove curveness
                        ),
                        title: Text(
                          'Order ID: ${order['orderId']}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold, // Bold the text
                          ),
                        ),
                        subtitle: Text(
                          'Order Status: ${order['orderStatus']}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold, // Bold the text
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderDetails(orderId: order['orderId']),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            }
            },
            ),
          )
          : Center(
        child: Text(
          'Login for order details',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
