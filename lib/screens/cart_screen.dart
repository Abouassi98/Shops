import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart' show Cart;
import '../widgts/cart_iteam.dart';
import '../providers/orders.dart';

class cart_screen extends StatefulWidget {
  static const routedname = '/cart_screen';

  @override
  _cart_screenState createState() => _cart_screenState();
}

class _cart_screenState extends State<cart_screen> {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    var _isLoaded = false;
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Card(
            margin: EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 20),
                  ),
                  Spacer(),
                  Chip(
                    label: Text(
                      '\$${cart.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                          color:
                              Theme.of(context).primaryTextTheme.title.color),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  FlatButton(
                    child:_isLoaded?Center(child: CircularProgressIndicator(),) :Text('Order Now'),
                    onPressed: (cart.totalAmount <= 0 || _isLoaded)
                        ? null
                        : () async {
                            setState(() {
                              _isLoaded = true;
                            });
                            try {
                              await Provider.of<orders>(context, listen: false)
                                  .addOrder(cart.iteams.values.toList(),
                                      cart.totalAmount);
                              setState(() {
                                _isLoaded = false;
                              });
                              cart.clear();
                            } catch (_) {
                              await showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                        title: Text('An error ocurred'),
                                        content: Text('Something went wrong'),
                                        actions: <Widget>[
                                          FlatButton(
                                            child: Text('Okay'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          )
                                        ],
                                      ));
                            }
                          },
                    textColor: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: cart.iteams.length,
              itemBuilder: (ctx, i) => cart_iteam(
                id: cart.iteams.values
                    .toList()[i]
                    .id, //we write values till don't refer to map
                productId: cart.iteams.keys.toList()[i],
                price: cart.iteams.values.toList()[i].price,
                quantity: cart.iteams.values.toList()[i].quantity,
                title: cart.iteams.values.toList()[i].title,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
