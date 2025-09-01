import 'package:flutter/material.dart';
import '../item_model.dart';

class Cart with ChangeNotifier {
  Map<String, Item> _items = {};

  Map<String, Item> get items {
    return {..._items};
  }

  void addItem(Item item) {
    if (_items.containsKey(item.name)) {
      _items.update(
        item.name,
            (existingItem) => Item(
          name: existingItem.name,
          price: existingItem.price,
          imageUrl: existingItem.imageUrl,
          quantity: existingItem.quantity + item.quantity,
          subtotal: existingItem.subtotal + (item.quantity * item.price),
        ),
      );
    } else {
      _items.putIfAbsent(
        item.name,
            () => Item(
          name: item.name,
          price: item.price,
          imageUrl: item.imageUrl,
          quantity: item.quantity,
          subtotal: item.quantity * item.price,
        ),
      );
    }
    notifyListeners();
  }

  void increaseQuantity(String itemName) {
    if (_items.containsKey(itemName)) {
      _items.update(
        itemName,
            (item) => Item(
          name: item.name,
          price: item.price,
          imageUrl: item.imageUrl,
          quantity: item.quantity + 1,
          subtotal: (item.quantity + 1) * item.price,
        ),
      );
      notifyListeners();
    }
  }

  void decreaseQuantity(String itemName) {
    if (_items.containsKey(itemName)) {
      _items.update(
        itemName,
            (item) => Item(
          name: item.name,
          price: item.price,
          imageUrl: item.imageUrl,
          quantity: item.quantity > 1 ? item.quantity - 1 : 1,
          subtotal: (item.quantity > 1 ? item.quantity - 1 : 1) * item.price,
        ),
      );
      notifyListeners();
    }
  }

  void removeItem(String itemName) {
    if (_items.containsKey(itemName)) {
      _items.remove(itemName);
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
