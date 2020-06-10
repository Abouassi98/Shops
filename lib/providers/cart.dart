import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';


class CartItem {
  final String id;
  final double price;
  final int quantity;
  final String title;
  
  CartItem(
      {@required this.id,
      @required this.price,
      @required this.quantity,
      @required this.title,
      });
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _iteams = {};
  Map<String, CartItem> get iteams {
    return {..._iteams};
  }

  int get itemCount {
    return _iteams.length;
  }

  double get totalAmount {
    var total = 0.0;
    _iteams.forEach(
        (key, cartIteam) => total += cartIteam.quantity * cartIteam.price);
    return total;
  }

  void addIteam(String productId, String title, double price,) {
    if (_iteams.containsKey(productId)) {
      _iteams.update(
          productId,
          (exitingId) => CartItem(
              id: exitingId.id,
              title: exitingId.title,
              quantity: exitingId.quantity + 1,
              price: exitingId.price,
              ));
    } else {
      _iteams.putIfAbsent(
          productId,
          () => CartItem(
              
              id: DateTime.now().toString(),
              price: price,
              title: title,
              quantity: 1));
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _iteams.remove(productId);
    notifyListeners();
  }

  void clear() {
    _iteams = {};
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_iteams.containsKey(productId)) {
      return;
    }
    if (_iteams[productId].quantity > 1) {
      _iteams.update(
        productId,
        (exitingproduct) => CartItem(
          
            id: exitingproduct.id,
            price: exitingproduct.price,
            quantity: exitingproduct.quantity - 1,
            title: exitingproduct.title),
      );
      notifyListeners();
    } else {
      _iteams.remove(productId);
      notifyListeners();
    }
  }

  notifyListeners();
}
