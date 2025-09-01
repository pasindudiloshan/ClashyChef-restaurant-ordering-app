import 'package:clashy_kitchen/screens/signin.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../item_model.dart';
import '../provider.dart';
import 'cart.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';

import 'itemCart.dart';

class ItemDescriptionPage extends StatelessWidget {
  final String itemName;
  final String imagePath;
  final String description;
  final String price;
  final String itemID;
  final String itemCategory;

  const ItemDescriptionPage({
    required this.itemName,
    required this.imagePath,
    required this.description,
    required this.price,
    required this.itemID,
    required this.itemCategory, // Displayed in the AppBar
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFCE1E39),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              itemCategory,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            GestureDetector(
              onTap: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CartPage()),
                );
              },
              child: Image.asset(
                'assets/cart.png',
                height: 30,
                width: 30,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item name
            Text(
              itemName,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),

            // Item image
            Center(
              child: Image.network(
                imagePath,
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),


            Text(
              description,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black54,
                fontWeight: FontWeight.w600
              ),
            ),
            const SizedBox(height: 10),


            Text(
              ("Rs."+price), // Display the dynamic price
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const Spacer(),


            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Center(
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      String? username = Provider.of<UserProvider>(context, listen: false).username;

                      if (username != null && username.isNotEmpty) {
                        Item item = Item(
                          name: itemName,
                          price: double.parse(price),
                          imageUrl: imagePath,
                          quantity: 1,
                          subtotal: double.parse(price),
                        );
                        Provider.of<Cart>(context, listen: false).addItem(item);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Item added to cart'),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                        );
                        showTopSnackBar(
                          Overlay.of(context),
                          const CustomSnackBar.success(
                            message: "Please login to place your order",
                            backgroundColor: Colors.lightGreenAccent,
                            textStyle: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Add to Cart',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFCE1E39),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
