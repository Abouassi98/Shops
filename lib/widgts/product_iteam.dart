import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/product_detail.dart';
import '../providers/product.dart';
import '../providers/cart.dart';
import '../providers/auth.dart';

class product_iteam extends StatelessWidget {
//  final String id;
//  final String title;
//  final String imageUrl;
//
//  product_iteam({this.imageUrl, this.title, this.id});

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.of(context);
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final auth = Provider.of<Auth>(context, listen: false);
    void actionFavourite() {
      Icon(product.isFavourite ? Icons.favorite : Icons.favorite_border);
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .pushNamed(product_detail.routename, arguments: product.id);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: GridTile(
          child: Hero(tag: product.id,
                      child: FadeInImage(
              placeholder: AssetImage('assets/images/1.png'),
              image: NetworkImage(
                product.image,
              ),
              fit: BoxFit.cover,
            ),
          ),
          footer: GridTileBar(
            backgroundColor: Colors.black87,
            title: Text(product.title, textAlign: TextAlign.center),
            leading: Consumer<Product>(
              builder: (ctx, product, _) => IconButton(
                color: Theme.of(context).accentColor,
                icon: Icon(product.isFavourite
                    ? Icons.favorite
                    : Icons.favorite_border),
                onPressed: () async {
                  try {
                    await product.toggleFavourite(auth.token, auth.userId);
                    scaffold.showSnackBar(
                      (SnackBar(
                        content: Text('Done'),
                        duration: Duration(seconds: 2),
                      )),
                    );
                  } catch (_) {
                    scaffold.showSnackBar(SnackBar(
                      content: Text(
                        'افحص نتك يا فقير',
                        textAlign: TextAlign.center,
                      ),
                      duration: Duration(seconds: 2),
                    ));
                  }
                },
              ),
            ),
            trailing: IconButton(
              color: Theme.of(context).accentColor,
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                cart.addIteam(product.id, product.title, product.price);
                Scaffold.of(context).hideCurrentSnackBar();
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Added Item to Cart!'),
                    duration: Duration(seconds: 2),
                    action: SnackBarAction(
                      label: 'UNDO',
                      onPressed: () {
                        cart.removeSingleItem(product.id);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
