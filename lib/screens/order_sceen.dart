import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart';
import '../widgts/app_drawer.dart';
import '../widgts/order_item.dart';

class order_sceen extends StatelessWidget {
  static const routedname = '/order_sceen';

  @override
  Future<void> _Refresh(BuildContext ctx) async {
    await Provider.of<orders>(ctx).fetchproducts();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Your Orders'),
        ),
        drawer: app_drawer(),
        body: FutureBuilder(
            future: Provider.of<orders>(context, listen: false).fetchproducts(),
            builder: (
              ctx,
              snapShotData,
            ) {
              if (snapShotData.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapShotData.error != null) {
                return Text('An error has occured');
              } else {
                return Consumer<orders>(
                    builder: (ctx, orderData, child) => RefreshIndicator(
                          onRefresh: () => _Refresh(context),
                          child: ListView.builder(
                            itemCount: orderData.order.length,
                            itemBuilder: (ctx, i) =>
                                order_item(orderData.order[i]),
                          ),
                        ));
              }
            }),);
  }
}
