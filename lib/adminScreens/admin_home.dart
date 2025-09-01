import 'package:clashy_kitchen/adminScreens/view_users.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider.dart';
import '../screens/signin.dart';
import 'manage_items.dart';
import 'manage_orders.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "Clashy Kitchen Admin",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            backgroundColor: const Color(0xFF3EA94C),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Builder(
            builder: (BuildContext innerContext) {
              final username = Provider.of<UserProvider>(innerContext).username ?? 'Admin';

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Hi, $username",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Image
                      Center(
                        child: Image.asset(
                          'assets/admin_img.png',
                          height: 300,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Manage Orders Button
                      ElevatedCard(
                        icon: Icons.chevron_right,
                        title: "Manage Orders",
                        onTap: () => _navigateTo(innerContext, const ManageOrders()),
                      ),
                      const SizedBox(height: 20),

                      ElevatedCard(
                        icon: Icons.chevron_right,
                        title: "Manage Items",
                        onTap: () => _navigateTo(innerContext, const ManageItems()),
                      ),
                      const SizedBox(height: 20),

                      // View Users Button
                      ElevatedCard(
                        icon: Icons.chevron_right,
                        title: "View Users",
                        onTap: () => _navigateTo(innerContext, const ViewUsers()),
                      ),
                      const SizedBox(height: 60),


                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: SizedBox(
                          height: 50.0,
                          child: ElevatedButton(
                            onPressed: () {
                              userProvider.clearUser();
                              Navigator.pushReplacement(
                                innerContext,
                                MaterialPageRoute(builder: (context) => const LoginPage()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            child: const Text(
                              'Log Out',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }


  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}

class ElevatedCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const ElevatedCard({
    required this.icon,
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
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon, size: 30, color: Colors.green),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
