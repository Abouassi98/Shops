import 'package:flutter/material.dart';
import '../providers/cart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/dp_model.dart';
import '../models/dp_helper.dart';
class orderItem implements DataBaseModel {
  String id;
  double amount;
  List<CartItem> products;
  DateTime dateTime;
  orderItem({
    this.id,
    this.amount,
    this.products,
    this.dateTime,
  });

  @override
  String database() {
    return 'orders.db';
  }

  @override
  String getId() {
    return this.id;
  }

  @override
  String table() {
    return 'orders';
  }

  orderItem.fromMap(Map<String, dynamic> map) {
    this.id = map['id'];
    this.amount = map['amount'];
    this.products = (map['products'] as List<dynamic>)
        .map((e) => CartItem(
            id: e['id'],
            price: e['price'],
            quantity: e['quantity'],
            title: e['title']))
        .toList();
    this.dateTime = DateTime.parse(map['dateTime']);
  }
  @override
  Map<String, dynamic> tomap() {
    return {
      'id': this.id,
      'amount': this.amount,
      'products': this
          .products
          .map((item) => {
                'price': item.price,
                'quantity': item.quantity,
                'title': item.title
              })
          .toList(),
      'dateTime': DateTime.now().toIso8601String(),
    };
  }
}

class orders with ChangeNotifier {
//DBHelper mydatebase=DBHelper();
  final String idToken;
  final String userId;
  List<orderItem> _order = [];
  orders(this.idToken, this.userId, this._order);

  List<orderItem> get order {
    return [..._order];
  }

  Future<void> addOrder(
    List<CartItem> cartProduct,
    double total,
  ) async {
    final url =
        'https://shops-fb193.firebaseio.com/orders/$userId.json?auth=$idToken';
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            //first map
            'amount': total,
            'dateTime': DateTime.now().toIso8601String(),
            'cartProducts': cartProduct
                .map((cart) => {
                      //cuz map into map
                      //second map

                      "price": cart.price,
                      "quantity": cart.quantity,
                      "title": cart.title,
                    })
                .toList(),
          },
        ),
      );
      _order.insert(
        0,
        orderItem(
          id: json.decode(response.body)['name'],
          amount: total,
          dateTime: DateTime.now(),
          products: cartProduct,
        ),
      );
    //  mydatebase.insertData(orderItem());
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> fetchproducts() async {
    final url =
        'https://shops-fb193.firebaseio.com/orders/$userId.json?auth=$idToken';
    try {
      final response = await http.get(url);
      final extraData = jsonDecode(response.body) as Map<String, dynamic>;
      if (extraData == null) {
        return;
      }
      final List<orderItem> loadedOrder = [];
      extraData.forEach((orderId, orderKey) {
        loadedOrder.add(orderItem(
          id: orderId,
          amount: orderKey['amount'],
          dateTime: DateTime.parse(orderKey['dateTime']),
          products: (orderKey['cartProducts'] as List<dynamic>)
              .map(
                (key) => CartItem(
                    id: key['id'],
                    price: key['price'],
                    quantity: key['quantity'],
                    title: key['title']),
              )
              .toList(),
        ));
      });
      _order = loadedOrder.reversed.toList();
     //  mydatebase.getData('orders','orders.db');
      notifyListeners();
    } catch (error) {
      print('error');
    }
  }
}
