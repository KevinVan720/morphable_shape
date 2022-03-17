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
                  ? BoxDecoration(color: Colors.white)
                  : BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.fill,
                          image: NetworkImage(
                              "https://images.unsplash.com/photo-1557409239-720ef57b99d2?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=687&q=80")),
                      gradient: SweepGradient(
                          center: Alignment(0.03, -0.17),
                          startAngle: 0.1,
                          endAngle: 5.3,
                          colors: [
                            Colors.black87,
                            Color(0xFF04619f),
                            Color(0xFF358f74),
                            Color(0xFF923cb5),
                            Colors.black87,
                          ],
                          stops: [
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
