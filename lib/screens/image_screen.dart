import 'package:flutter/material.dart';

import 'dart:io';
import 'package:vector_math/vector_math_64.dart' show Vector3;

class image_screen extends StatefulWidget {
  static const routedname = '/image_screen';

  @override
  _image_screenState createState() => _image_screenState();
}

class _image_screenState extends State<image_screen> {
  @override
  double _scale = 1.0;
  double _previousScale = 1.0;
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context).settings.arguments as String;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: productId,
                child: GestureDetector(
                  onScaleStart: (ScaleStartDetails details) {
                    print(details);
                    _previousScale = _scale;
                    setState(() {});
                  },
                  onScaleUpdate: (ScaleUpdateDetails details) {
                    print(details);
                    _scale = _previousScale * details.scale;
                    setState(() {});
                  },
                  onScaleEnd: (ScaleEndDetails details) {
                    print(details);
                    _previousScale = 1.0;
                    setState(() {});
                  },
                  child: Transform(
                    alignment: FractionalOffset.center,
                    transform: Matrix4.diagonal3(
                      Vector3(_scale, _scale, _scale),
                    ),
                    child: Image.network(
                      productId,
                      fit: BoxFit.contain,
                      //enableLoadState: false,
                     
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
