import 'package:clashy_kitchen/screens/signup.dart';
import 'package:clashy_kitchen/screens/userOrders.dart';
import 'package:flutter/material.dart';
import 'package:custom_navigation_bar/custom_navigation_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'home.dart';
import 'itemCart.dart';
import 'menu.dart';


enum _SelectedTab { home, menu, cart, orders}

class NavBarPage extends StatefulWidget {
  @override
  _NavBarPageState createState() => _NavBarPageState();
}

class _NavBarPageState extends State<NavBarPage> {
  _SelectedTab _selectedTab = _SelectedTab.home;

  Widget _getPage(_SelectedTab tab) {
    switch (tab) {
      case _SelectedTab.home:
        return HomePage();
      case _SelectedTab.menu:
        return MenuPage(initialTabIndex: 0,);
      case _SelectedTab.cart:
        return CartPage();
      case _SelectedTab.orders:
        return UserOrders();
      default:
        return HomePage();
    }
  }

  void _handleIndexChanged(int index) {
    setState(() {
      _selectedTab = _SelectedTab.values[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: Scaffold(
        body: _getPage(_selectedTab),
        bottomNavigationBar: CustomNavigationBar(
          selectedColor: Color(0xFFCE1E39),
          strokeColor: Colors.white,
          backgroundColor: Colors.white,
          currentIndex: _SelectedTab.values.indexOf(_selectedTab),
          onTap: _handleIndexChanged,
          items: [
            CustomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.home),
            ),

            CustomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.burger),
            ),
            CustomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.cartShopping),
            ),
            CustomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.rectangleList),
            ),
          ],
        ),
      ),
    );
  }
}
