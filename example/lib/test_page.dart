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
                  ? BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Colors.cyanAccent, Colors.purpleAccent]))
                  : BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.fill,
                          image: NetworkImage(
                              "https://images.unsplash.com/photo-1647369098673-94c0590a15a7?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=802&q=80"))),
            ),
          ),
        ),
      ),
    );
  }
}
