import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import '../firebase.dart';
import 'order_details.dart';

class OrderList extends StatefulWidget {
  final String orderStatus;

  const OrderList({Key? key, required this.orderStatus}) : super(key: key);

  @override
  State<OrderList> createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> {
  late Future<List<DocumentSnapshot>> _ordersFuture;
  final FireStoreService _fireStoreService = FireStoreService();

  @override
  void initState() {
    super.initState();
    _ordersFuture = _fetchOrders();
  }

  Future<List<DocumentSnapshot>> _fetchOrders() async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('orderStatus', isEqualTo: widget.orderStatus)
          .get();

      return querySnapshot.docs;
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isPending = widget.orderStatus.contains('Pending');
    bool isAccepted = widget.orderStatus.contains('Accepted');

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF3EA94C),
        title: Text(
          widget.orderStatus,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<DocumentSnapshot>>(
                future: _ordersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    final orders = snapshot.data!;
                    return ListView.builder(
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index].data()! as Map<String, dynamic>;
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                          child: ListTile(
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Order ID: ${order['orderId']}',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),

                                ),
                                const SizedBox(height: 5),
                                Text(
                                  order['email'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            trailing: isPending
                                ? _buildPendingButtons(order)
                                : isAccepted
                                ? _buildAcceptedButtons(order)
                                : null,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      OrderDetails(orderId: order['orderId']),
                                ),
                              );
                            },
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

  Widget _buildPendingButtons(Map<String, dynamic> order) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTextButton(
          onPressed: () async {
            await _fireStoreService.updateAcceptedOrder(order['orderId']);
            showToast(
              'Order marked as Accepted',
              context: context,
              backgroundColor: const Color(0xFFBBFFBB),
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
          },
          label: 'Accept',
          color: Colors.green,
        ),
        const SizedBox(width: 8),
        _buildTextButton(
          onPressed: () async {
            await _fireStoreService.updateCancelledOrder(order['orderId']);
            showToast(
              'Order marked as Cancelled',
              context: context,
              backgroundColor: const Color(0xFFFFD4D4),
              textStyle: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold, // Make text bold
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
          },
          label: 'Cancel',
          color: Colors.red,
        ),
      ],
    );
  }

  Widget _buildAcceptedButtons(Map<String, dynamic> order) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTextButton(
          onPressed: () async {
            await _fireStoreService.updateCompletedOrder(order['orderId']);
            showToast(
              'Order marked as Completed',
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
          },
          label: 'Complete',
          color: Colors.green,
        ),
        const SizedBox(width: 8),
        _buildTextButton(
          onPressed: () async {
            await _fireStoreService.updateCancelledOrder(order['orderId']);
            showToast(
              'Order marked as Cancelled',
              context: context,
              backgroundColor: const Color(0xFFFFD4D4),
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
          },
          label: 'Cancel',
          color: Colors.red,
        ),
      ],
    );
  }

  Widget _buildTextButton({
    required VoidCallback onPressed,
    required String label,
    required Color color,
  }) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      style: TextButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
    );
  }
}
