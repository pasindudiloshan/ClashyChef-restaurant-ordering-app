import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../adminScreens/admin_home.dart';  // Admin home page
import '../provider.dart';
import 'navigation.dart';  // Regular user navigation page
import 'signup.dart';      // Sign-up page
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final String email = _usernameController.text.trim();
      final String password = _passwordController.text.trim();

      try {
        if (email == 'clashykitchen@gmail.com' && password == 'admin123') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminHome()),  // Admin page
          );
        } else {
          final QuerySnapshot userSnapshot = await FirebaseFirestore.instance
              .collection('customers')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

          if (userSnapshot.docs.isNotEmpty) {
            final DocumentSnapshot userDoc = userSnapshot.docs.first;
            final Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
            final String storedPassword = userData['password'];
            final String username = userData ['username'];

            if (storedPassword == password) {
              Provider.of<UserProvider>(context, listen: false).setUser(username, email);
              // Navigate to the regular user home (NavBarPage)
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => NavBarPage()),  // Regular user page
              );
            } else {
              _showErrorDialog('Login Failed', 'Incorrect Username or Password');
            }
          } else {
            _showErrorDialog('Login Failed', 'Incorrect Username or Password');
          }
        }
      } catch (e) {
        _showErrorDialog('Error', 'Something went wrong: $e');
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                const Text(
                  'LOGIN',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.person),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 60),

                // Sign In Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25.0),

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpPage()),
                    );
                  },
                  child: Text.rich(
                    TextSpan(
                      text: 'New to ClashyKitchen? ',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                      children: const [
                        TextSpan(
                          text: 'Sign Up',
                          style: TextStyle(
                            color: Colors.deepOrangeAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15.0),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NavBarPage()),
                    );
                  },
                  child: const Text(
                    'Skip for Now',
                    style: TextStyle(
                      color: Color(0xFFCE1E39),
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(height: 50),

                Image.asset(
                  'assets/sign_in_image.png',
                  height: 200,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
