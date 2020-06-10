import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../models/dp_model.dart';

class Product with ChangeNotifier implements DataBaseModel {
  String id;
  String title;
  String description;
  String image;
  double price;
  bool isFavourite;

  Product(
      {this.id,
      this.title,
      this.image,
      this.description,
      this.price,
      this.isFavourite = false});

  Future<void> toggleFavourite(String idToken, String userId) async {
    final url =
        'https://shops-fb193.firebaseio.com/userFavourites/$userId/$id.json?auth=$idToken';
    final oldVlue = isFavourite;
    isFavourite = !isFavourite;
    notifyListeners();
    try {
      await http.put(
//we can send a put request here because now I really just want to send true or false as a value.
        url,
        body: json.encode(
          isFavourite,
        ),
      );
    } catch (error) {
      isFavourite = oldVlue;
      notifyListeners();
      throw error;
    }
  }

  @override
  String database() {
   return 'products.db';
  }

  @override
  String getId() {
   return this.id;
  }

  @override
  String table() {
    return 'products';
  }

  @override
  Map<String, dynamic> tomap() {
    return {
      'id': this.id,
      'tite': this.title,
      'description': this.description,
      'image': image,
      'price': this.price,
      'isFavourite': this.isFavourite
    };
  }

  Product.fromMap(Map<String, dynamic> map) {
    this.id = map['id'];
    this.title = map['title'];
    this.description = map['description'];
    this.image = map['image'];
    this.price = map['price'];
    this.isFavourite = map['isFavourite'];
  }


}
