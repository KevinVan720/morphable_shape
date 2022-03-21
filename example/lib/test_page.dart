import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:morphable_shape/morphable_shape.dart';

class TestPage extends StatefulWidget {
  const TestPage({Key key}) : super(key: key);

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  bool toggleStyle = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 200,
          height: 200,
          child: GestureDetector(
            onTap: () {
              setState(() {
                toggleStyle = !toggleStyle;
              });
            },
            child: AnimatedDecoratedShadowedShape(
              duration: Duration(milliseconds: 2000),
              shape: RectangleShapeBorder(),
              decoration: toggleStyle
                  ? BoxDecoration(color: Colors.grey)
                  : BoxDecoration(
                      gradient: LinearGradient(colors: [
                      Colors.black87,
                      Color(0xFF04619f),
                      Color(0xFF358f74),
                      Color(0xFF923cb5),
                      Colors.black87,
                    ], stops: [
                      0.1,
                      0.3,
                      0.45,
                      0.8,
                      0.98
                    ])),
            ),
          ),
        ),
      ),
    );
  }
}
