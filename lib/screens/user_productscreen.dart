import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgts/user_productsItem.dart';
import '../widgts/app_drawer.dart';
import '../providers/products.dart';
import '../screens/Edit_ProductScreen.dart';

class user_productscreen extends StatelessWidget {
  static const routedname = '/user_productscreen';

  Future<void> _refresh(BuildContext ctx) async {
    await Provider.of<Products>(ctx,listen: false).FetchandSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    // final productData = Provider.of<Products>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your products'),
        actions: <Widget>[
          FlatButton(
            child: Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).pushNamed(Edit_ProductScreen.routedname);
            },
          ),
        ],
      ),
      drawer: app_drawer(),
      body: FutureBuilder(
        future: _refresh(context),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refresh(context),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Consumer<Products>(
                        builder: (ctx, productData, _) => ListView.builder(
                          itemCount: productData.iteams.length,
                          itemBuilder: (_, i) => UserProductsItem(
                            id: productData.iteams[i].id,
                            image: productData.iteams[i].image,
                            title: productData.iteams[i].title,
                          ),
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
