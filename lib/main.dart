import 'package:flutter/material.dart';
import 'package:shops/screens/user_productscreen.dart';
import './screens/product_overview.dart';
import './screens/product_detail.dart';
import 'package:provider/provider.dart';
import './providers/products.dart';
import './providers/cart.dart';
import './screens/cart_screen.dart';
import './providers/orders.dart';
import './screens/order_sceen.dart';
import './screens/Edit_ProductScreen.dart';
import './screens/auth_screen.dart';
import './providers/auth.dart';
import './screens/splash_screen.dart';
import './helpers/custom_route.dart';
import './providers/photos.dart';
import './screens/image_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: Auth()),
          ChangeNotifierProxyProvider<Auth, Products>(
            create: null,
            update: (ctx, auth, previousproducts) => Products(
                auth.token,
                previousproducts == null ? [] : previousproducts.iteams,
                auth.userId),
          ),
          ChangeNotifierProvider.value(
            value: Cart(),
          ),
          ChangeNotifierProxyProvider<Auth, orders>(
            create: null,
            update: (ctx, auth, previousorder) => orders(auth.token,
                auth.userId, previousorder == null ? [] : previousorder.order),
          ),
          ChangeNotifierProvider.value(
            value: Photos(),
          ),
        ],
        child: Consumer<Auth>(
          builder: (ctx, auth, _) => MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              pageTransitionsTheme: PageTransitionsTheme(builders: {
                TargetPlatform.android: CustomPageTransationBuilder(),
                TargetPlatform.iOS: CustomPageTransationBuilder(),
              }),
              primarySwatch: Colors.purple,
              accentColor: Colors.deepOrange,
              fontFamily: 'Lato',
            ),
            home: auth.isAuth
                ? product_overview()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (cotext, snapshot) =>
                        snapshot.connectionState == ConnectionState.waiting
                            ? SplashScreen()
                            : AuthScreen(),
                  ),
            //        StreamBuilder(stream: FirebaseAuth.instance.onAuthStateChanged,builder: (ctx,userSnapShot){
            //   if(userSnapShot.hasData){
            //   return product_overview();
            //   }
            //   return AuthScreen();
            // }),
            routes: {
              product_detail.routename: (ctx) => product_detail(),
              cart_screen.routedname: (ctx) => cart_screen(),
              order_sceen.routedname: (ctx) => order_sceen(),
              user_productscreen.routedname: (ctx) => user_productscreen(),
              Edit_ProductScreen.routedname: (ctx) => Edit_ProductScreen(),
              image_screen.routedname: (ctx) => image_screen(),
            },
          ),
        ));
  }
}
