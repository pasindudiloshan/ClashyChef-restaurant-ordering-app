import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider.dart';
import 'home.dart';
import 'signup.dart';
import 'signin.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
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

  Future<List<Map<String, dynamic>>> _fetchUserDetails() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await FirebaseFirestore.instance
          .collection('customers')
          .where('email', isEqualTo: _email)
          .get();

      return querySnapshot.docs.map((doc) {
        return {
          'username': doc['username'] ?? 'No Name',
          'email': doc['email'] ?? 'No Email',
          'phoneNumber': doc['phone'] ?? 'No Phone Number',
          'address': doc['address'] ?? 'No Address',
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch user details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Profile",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xff05af0d),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _email.isNotEmpty
          ? FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchUserDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final userDetails = snapshot.data!;
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: userDetails.length,
                    itemBuilder: (context, index) {
                      final user = userDetails[index];
                      return Padding(
                        padding: const EdgeInsets.only(
                            left: 20.0, right: 20.0, top: 30.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 18),
                            Text(
                              'Username: ${user['username']}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'Email: ${user['email']}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'Phone Number: ${user['phoneNumber']}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'Address: ${user['address']}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 30),
                            const Divider(),
                            const SizedBox(height: 18),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    if (userProvider.username != null &&
                        userProvider.email != null) {
                      return ListTile(
                        leading: const Icon(Icons.logout,
                            color: Colors.deepOrange),
                        title: const Text(
                          'Sign Out',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        onTap: () {
                          userProvider.clearUser(); // Clear user data
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomePage()),
                          );
                        },
                      );
                    } else {
                      return Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.login,
                                color: Colors.deepOrange),
                            title: const Text(
                              'Sign In',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            onTap: () {
                              Navigator.pushNamed(
                                  context, '/signin');
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.app_registration,
                                color: Colors.deepOrange),
                            title: const Text(
                              'Sign Up',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            onTap: () {
                              Navigator.pushNamed(
                                  context, '/signup');
                            },
                          ),
                        ],
                      );
                    }
                  },
                ),
                const SizedBox(height: 20),
              ],
            );
          }
        },
      )
          : Center(
        child: Column(
          children: [
            const SizedBox(height: 100),
            const Text(
              'Login for profile details',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 150),
            ListTile(
              leading: const Icon(Icons.login, color: Colors.deepOrange),
              title: const Text(
                'Sign In',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          LoginPage()),
                );
              },
            ),
            ListTile(
              leading:
              const Icon(Icons.app_registration, color: Colors.deepOrange),
              title: const Text(
                'Sign Up',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          SignUpPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
