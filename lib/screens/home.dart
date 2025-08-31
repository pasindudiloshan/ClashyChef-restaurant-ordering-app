import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider.dart';
import 'itemDescription.dart';
import 'menu.dart';
import 'profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _fetchItems() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
          .collection('items')
          .where('isBestSelling', isEqualTo: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return {
          'itemId': (doc['itemId']).toString(),
          'itemName': doc['itemName'] ?? 'No Name',
          'itemDescription': doc['itemDescription'] ?? 'No Description',
          'itemPrice': (doc['itemPrice'] ?? 0.0).toDouble(),
          'imageUrl': doc['imageUrl'] ?? '',
          'categoryName': doc['categoryName'] ?? '',
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch items: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final username = userProvider.username ?? 'Time to Eat!';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'assets/restaurant_logo.png',
                      height: 80,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => UserProfile()),
                        );
                      },
                      child: Image.asset(
                        'assets/profile.png',
                        height: 30,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Hi, $username",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MenuPage(initialTabIndex: 0)),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCE1E39),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      ),
                      child: const Text(
                        'Menu',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Stack(
                  children: [
                    SizedBox(
                      height: 150,
                      child: PageView(
                        controller: _pageController,
                        children: const [
                          BannerWidget(imagePath: 'assets/banner 2.jpeg'),
                          BannerWidget(imagePath: 'assets/banner 1.jpg'),
                          BannerWidget(imagePath: 'assets/banner 3.jpeg'),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 10,
                      top: 65,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_left, size: 30, color: Colors.black),
                        onPressed: () {
                          if (_currentPage > 0) {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeIn,
                            );
                            setState(() {
                              _currentPage--;
                            });
                          }
                        },
                      ),
                    ),
                    Positioned(
                      right: 10,
                      top: 65,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_right, size: 30, color: Colors.black),
                        onPressed: () {
                          if (_currentPage < 2) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeIn,
                            );
                            setState(() {
                              _currentPage++;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: const [
                          CategoryWidget(imagePath: 'assets/c1.png', label: 'Mains', tabIndex: 1),
                          CategoryWidget(imagePath: 'assets/c2.png', label: 'Burgers', tabIndex: 2),
                          CategoryWidget(imagePath: 'assets/c3.png', label: 'Pizza', tabIndex: 3),
                          CategoryWidget(imagePath: 'assets/c4.png', label: 'Pasta', tabIndex: 4),
                          CategoryWidget(imagePath: 'assets/c5.png', label: 'Desserts', tabIndex: 5),
                          CategoryWidget(imagePath: 'assets/c6.png', label: 'Beverages', tabIndex: 6),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Most Popular',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: _fetchItems(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text('No items found'));
                        }

                        final items = snapshot.data!;
                        return SizedBox(
                          height: 250,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ItemDescriptionPage(
                                        itemID: item['itemId'],
                                        itemCategory: item['categoryName'],
                                        itemName: item['itemName'],
                                        imagePath: item['imageUrl'],
                                        description: item['itemDescription'],
                                        price: item['itemPrice'].toString(),
                                      ),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 15),
                                  child: SizedBox(
                                    width: 160,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            item['imageUrl'],
                                            height: 150,
                                            width: 160,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          item['itemName'],
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          ("Rs. "+item['itemPrice'].toString()),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
                Center(
                  child: Image.asset(
                    'assets/home_last_image.png',
                    height: 500,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BannerWidget extends StatelessWidget {
  final String imagePath;

  const BannerWidget({required this.imagePath, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          imagePath,
          width: 300,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class CategoryWidget extends StatelessWidget {
  final String imagePath;
  final String label;
  final int tabIndex;

  const CategoryWidget({required this.imagePath, required this.label, required this.tabIndex, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MenuPage(initialTabIndex: tabIndex)),
        );
      },
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              imagePath,
              height: 60,
              width: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
