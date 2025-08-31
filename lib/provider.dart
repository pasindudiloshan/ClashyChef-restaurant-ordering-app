import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String? username;
  String? email;

  void setUser(String username, String email,) {
    this.username = username;
    this.email = email;
    notifyListeners();
  }

  void clearUser() {
    username = null;
    email = null;
    notifyListeners();
  }
}
