import 'package:flutter/material.dart';
import '../providers/products.dart';
import 'package:provider/provider.dart';
import '../screens/Edit_ProductScreen.dart';
import 'dart:io';
import '../providers/photos.dart';
import '../screens/image_screen.dart';

class UserProductsItem extends StatelessWidget {
  final String id;
  final String title;
  final String image;
  UserProductsItem({this.id, this.title, this.image});
  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.of(context);
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .pushNamed(image_screen.routedname, arguments: image);
      },
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundImage: NetworkImage(image),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        trailing: Container(
          width: 100,
          child: Row(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.edit),
                color: Theme.of(context).primaryColor,
                onPressed: () {
                  Navigator.of(context)
                      .pushNamed(Edit_ProductScreen.routedname, arguments: id);
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                color: Theme.of(context).errorColor,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text('Are you sure'),
                      content: Text('Do you want to remove this product'),
                      actions: [
                        FlatButton(
                          child: Text('No'),
                          onPressed: (){
                            Navigator.of(ctx).pop();
                          },
                        ),
                        FlatButton(
                          child: Text('Yes'),
                          onPressed: () async {
                            try {
                              await Provider.of<Photos>(context, listen: false)
                                  .deletePhoto(image);
                              await Provider.of<Products>(context,
                                      listen: false)
                                  .deleteProduct(id);
                              scaffold.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Your Product already deleted',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            } catch (_) {
                              scaffold.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Deleting Field',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            }
                            Navigator.of(ctx).pop();
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
