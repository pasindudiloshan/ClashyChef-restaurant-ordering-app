import 'package:flutter/material.dart';
import 'order_list.dart';

class ManageOrders extends StatefulWidget {
  const ManageOrders({Key? key}) : super(key: key);

  @override
  State<ManageOrders> createState() => _ManageOrdersState();
}

class _ManageOrdersState extends State<ManageOrders> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFFCE1E39),
        title: const Text(
          "Manage Orders",
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
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedCard(
              title: "Pending Orders",
              onTap: () => _navigateToOrderList(context, 'Pending'),
            ),
            const SizedBox(height: 20),
            ElevatedCard(
              title: "Accepted Orders",
              onTap: () => _navigateToOrderList(context, 'Accepted'),
            ),
            const SizedBox(height: 20),
            ElevatedCard(
              title: "Completed Orders",
              onTap: () => _navigateToOrderList(context, 'Completed'),
            ),
            const SizedBox(height: 20),
            ElevatedCard(
              title: "Cancelled Orders",
              onTap: () => _navigateToOrderList(context, 'Cancelled'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToOrderList(BuildContext context, String orderStatus) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OrderList(orderStatus: orderStatus)),
    );
  }
}

class ElevatedCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const ElevatedCard({
    required this.title,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: const Color(0xFFCE1E39),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
