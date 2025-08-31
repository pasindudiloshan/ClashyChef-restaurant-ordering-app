import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'itemCart.dart';
import 'itemDescription.dart';
import 'signup.dart';

class MenuPage extends StatefulWidget {
  final int initialTabIndex;

  const MenuPage({Key? key, required this.initialTabIndex}) : super(key: key);

  @override
  State<MenuPage> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _itemList = [];
  String _searchText = '';

  final subtitle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this, initialIndex: widget.initialTabIndex);
    _fetchItems();
  }

  void _fetchItems() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('items').get();
      final items = querySnapshot.docs.map((doc) {
        final data = doc.data();
        final itemId = data['itemId'].toString(); // Ensure itemId is a String
        return {
          'itemId': itemId,
          'itemName': data['itemName'],
          'itemDescription': data['itemDescription'],
          'itemPrice': data['itemPrice'],
          'imageUrl': data['imageUrl'],
          'categoryName': data['categoryName'],
        };
      }).toList();

      setState(() {
        _itemList = items;
      });
    } catch (e) {
      // Handle error
      print('Error fetching items: $e');
    }
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.all(4.0),
      child: Column(
        children: [
          SizedBox(height: 10.0),
          Container(
            height: 45.0,
            width: 300.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchText = value;
                  });
                },
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search items...',
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 7,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFCE1E39),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Our Menu",
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
          bottom: TabBar(
            isScrollable: true,
            controller: _tabController,
            tabs: [
              Tab(child: Text('All', style: subtitle)),
              Tab(child: Text('Main Course', style: subtitle)),
              Tab(child: Text('Burgers', style: subtitle)),
              Tab(child: Text('Pizza', style: subtitle)),
              Tab(child: Text('Appetizers', style: subtitle)),
              Tab(child: Text('Desserts', style: subtitle)),
              Tab(child: Text('Beverages', style: subtitle)),
            ],
            labelColor: Colors.amberAccent,
            unselectedLabelColor: Colors.white,
            indicatorColor: Colors.amberAccent,
          ),
        ),
        body: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTabContent('All'),
                  _buildTabContent('Main Course'),
                  _buildTabContent('Burgers'),
                  _buildTabContent('Pizza'),
                  _buildTabContent('Appetizers'),
                  _buildTabContent('Desserts'),
                  _buildTabContent('Beverages'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(String category) {
    List<Map<String, dynamic>> filteredItems = _itemList
        .where((item) => (category == 'All' || item['categoryName'] == category) &&
        (item['itemName'] as String).toLowerCase().contains(_searchText.toLowerCase()))
        .toList();

    return _buildHorizontalCards(filteredItems);
  }

  Widget _buildHorizontalCards(List<Map<String, dynamic>> itemList) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          (itemList.length / 2).ceil(),
              (rowIndex) {
            final startIndex = rowIndex * 2;
            final endIndex = startIndex + 2;
            final rowItems = itemList
                .sublist(startIndex, endIndex.clamp(0, itemList.length))
                .map((item) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: _buildCard(
                    context,
                    item['itemId'],
                    item['itemName'],
                    item['itemDescription'],
                    item['itemPrice'],
                    item['imageUrl'],
                    item['categoryName'],
                  ),
                ),
              );
            }).toList();

            if (rowItems.length == 1) {
              return Row(
                children: [
                  rowItems[0],
                  SizedBox(width: 160.0 + 4.0), // Width of card + horizontal padding
                ],
              );
            } else {
              return Row(children: rowItems);
            }
          },
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, String itemId, String itemName, String itemDescription, double itemPrice,
      String imageUrl, String categoryName) {
    return GestureDetector(
      onTap: () {

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItemDescriptionPage(
              itemID: itemId,
              itemCategory: categoryName,
              itemName: itemName,
              imagePath: imageUrl,
              description: itemDescription,
              price: itemPrice.toString(),
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 15),
        child: Container(
          width: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                child: Image.network(
                  imageUrl,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      itemName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Rs. $itemPrice',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Color(0xFFCE1E39), width: 2),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Color(0xFFCE1E39),
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
