import 'package:flutter/material.dart';
import './product_iteam.dart';
import 'package:provider/provider.dart';
import '../providers/products.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFavourite;
  ProductsGrid(this.showFavourite);
  @override
  Widget build(BuildContext context) {
    final productData = Provider.of<Products>(context);
    final products = showFavourite?productData.favourite: productData.iteams;
    return GridView.builder(
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 3 / 2,
          crossAxisCount: 2,
          crossAxisSpacing:10,
          mainAxisSpacing: 10),
      itemBuilder: (context, i) => ChangeNotifierProvider.value(
        value: products[i],
        child:productData.iteams.length<=0?Text('No Iteams has been added') :product_iteam(),
      ),
      itemCount: products.length,
    );
  }
}
