import 'package:flutter/material.dart';
import '../models/dp_helper.dart';
import './product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/http_exceptions.dart';
import 'dart:io';
import '../models/dp_model.dart';
class Products with ChangeNotifier {
 // DBHelper mydatebase=DBHelper();

  final String idToken;
  final String userId;
  Products(this.idToken, this._iteams, this.userId);
  List<Product> _iteams = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  //var showFavourite = false;

  List<Product> get iteams {
    // if (showFavourite) {
    //  return _iteams.where((prodIteam) => prodIteam.isFavourite).toList();
    //}
    return [..._iteams];
  }

  List<Product> get favourite {
    return _iteams.where((prodIteam) => prodIteam.isFavourite).toList();
  }

  Product findById(String id) {
    return _iteams.firstWhere((prod) => prod.id == id);
  }

  Future<void> FetchandSetProducts([bool filterByuser=false]) async {
    final filterString=filterByuser?'orderBy="creatorId"&equalTo="$userId"':'';
    var url =
        'https://shops-fb193.firebaseio.com/products.json?auth=$idToken&$filterString ';
     try {
      final response = await http.get(url);
      final extraData = jsonDecode(response.body) as Map<String, dynamic>;
      if (extraData == null) {
     
        return;
      }
      url =
          'https://shops-fb193.firebaseio.com/userFavourites/$userId.json?auth=$idToken';
      final favouriteResponse = await http.get(url);
      final favouriteData = json.decode(favouriteResponse.body);
      final List<Product> loadedProducts = [];
      print(extraData);
      extraData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
            id: prodId,
            description: prodData['descriptions'],
            image: prodData['image'],
            price: prodData['price'],
            title: prodData['title'],
            isFavourite: favouriteData == null
                ? false
                : favouriteData[prodId] ?? false));
      });
      _iteams = loadedProducts;
    //  mydatebase.getData('products','products.db');
      notifyListeners();
      print(json.decode(response.body));
    } 
    catch (error) {
       throw error ;
     }
  }

  Future<void> addproduct(Product product) async {
    final url =
        'https://shops-fb193.firebaseio.com/products.json?auth=$idToken';

    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'title': product.title,
            'descriptions': product.description,
            'price': product.price,
            'image': product.image,
            'creatorId': userId,
          },
        ),
      );
     //mydatebase.insertData(product);
      final _newProduct = Product(
          id: json.decode(response.body)['name'],
          description: product.description,
          image: product.image,
          price: product.price,
          title: product.title);
      _iteams.add(_newProduct);

      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> deleteProduct(String id) async {
    final url =
        'https://shops-fb193.firebaseio.com/products/$id.json?auth=$idToken';
    final exitingDataIndex = _iteams.indexWhere((prod) => prod.id == id);
    var exitingData = _iteams[exitingDataIndex];
    _iteams.removeAt(exitingDataIndex);
   // mydatebase.deleteData(Product());
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _iteams.insert(exitingDataIndex, exitingData);
      notifyListeners();
      throw Http_Exceptions(message: 'Could not delete the product');
    }
    exitingData = null;
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _iteams.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url =
          'https://shops-fb193.firebaseio.com/products/$id.json?auth=$idToken'; //final cuz id is dynamic value we have to use final because this will only be final at runtime
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'descriptions': newProduct.description,
            'price': newProduct.price,
            'image': newProduct.image,
          }));
      _iteams[prodIndex] = newProduct;
    //  mydatebase.updateData(Product());
      notifyListeners();
    } else {}
  }
}
