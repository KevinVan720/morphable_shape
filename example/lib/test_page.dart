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
                      gradient: SweepGradient(
                          center: Alignment(0.13, 0.1),
                          startAngle: 0.5,
                          endAngle: 6.3,
                          colors: [
                          Color(0xFFF6EA41),
                          Color(0xFFEEBD89),
                          Color(0xFFD13ABD),
                          Color(0xFFAEBAF8),
                          Color(0xFFB60F46),
                          Color(0xFFF6EA41),
                        ],
                          stops: [
                          0.01,
                          0.2,
                          0.5,
                          0.7,
                          0.8,
                          0.98
                        ]))
                  : BoxDecoration(
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
