import 'dart:math';

import 'package:dimension/dimension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_class_parser/flutter_class_parser.dart';
import 'package:morphable_shape/morphable_shape.dart';

import 'value_pickers.dart';

class MorphShapePage extends StatefulWidget {
  MorphableShapeBorder shape;

  MorphShapePage({this.shape});

  @override
  _MorphShapePageState createState() => _MorphShapePageState();
}

class _MorphShapePageState extends State<MorphShapePage>
    with SingleTickerProviderStateMixin {
  MorphableShapeBorder beginShapeBorder;
  MorphableShapeBorder endShapeBorder;

  AnimationController controller;
  Animation animation;

  double shapeWidth;
  double shapeHeight;

  MorphMethod method = MorphMethod.auto;
  bool showControl = true;
  int durationInSec = 3;

  @override
  void initState() {
    super.initState();

    beginShapeBorder = widget.shape;

    endShapeBorder = RectangleShapeBorder(
        border: DynamicBorderSide(
            width: 20,
            color: Colors.red,
            begin: 0.toPercentLength,
            end: 100.toPercentLength));

    controller = AnimationController(
        vsync: this, duration: Duration(seconds: durationInSec));
    Animation curve =
        CurvedAnimation(parent: controller, curve: Curves.easeInOutCubic);

    animation = Tween(begin: 0.0, end: 1.0).animate(curve)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed)
          controller.reverse();
        else if (status == AnimationStatus.dismissed) controller.forward();
      });

    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    if (shapeWidth == null) {
      shapeWidth =
          (min(screenSize.width, screenSize.height) * 0.8).clamp(200.0, 600.0);
      shapeHeight = shapeWidth;
    }

    print(shapeWidth.toString() + "," + shapeHeight.toString());

    MorphableShapeBorderTween shapeBorderTween = MorphableShapeBorderTween(
        begin: beginShapeBorder, end: endShapeBorder, method: method);

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black87,
          titleSpacing: 0.0,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image(
                  width: 30,
                  height: 30,
                  image: AssetImage('assets/images/Icon-192.png')),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: Text("Shape Morph"))
            ],
          ),
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          actions: [
            BottomSheetShapePicker(valueChanged: (shape) {
              setState(() {
                endShapeBorder = shape;
              });
            })
          ],
        ),
        body: Stack(
          children: [
            Center(
              child: Container(
                  color: Colors.black54,
                  child: AnimatedBuilder(
                      animation: animation,
                      builder: (BuildContext context, Widget child) {
                        double t = animation.value;
                        return Center(
                            child: Stack(
                          children: [
                            DecoratedShadowedShape(
                              decoration:
                                  BoxDecoration(color: Colors.amberAccent),
                              shape: shapeBorderTween.lerp(t),
                              child: Container(
                                width: shapeWidth,
                                height: shapeHeight,
                              ),
                            ),
                            showControl
                                ? CustomPaint(
                                    painter: MorphControlPointsPainter(
                                        DynamicPathMorph.lerpPaths(
                                                t,
                                                shapeBorderTween
                                                    .data.beginOuterPath,
                                                shapeBorderTween
                                                    .data.endOuterPath)
                                            .nodes
                                            .map((e) => e.position)
                                            .toList()),
                                    child: Container(
                                      width: shapeWidth,
                                      height: shapeHeight,
                                    ),
                                  )
                                : Container(
                                    width: shapeWidth,
                                    height: shapeHeight,
                                  ),
                          ],
                        ));
                      })),
            ),
            Positioned(
                right: 20,
                top: 20,
                child: Container(
                  width: 240,
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Morph Method: ",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      DropdownButton<MorphMethod>(
                        iconSize: 18,
                        isDense: true,
                        dropdownColor: Colors.grey,
                        value: method,
                        onChanged: (MorphMethod newValue) {
                          setState(() {
                            method = newValue;
                          });
                        },
                        items: MorphMethod.values.map((e) {
                          return DropdownMenuItem<MorphMethod>(
                            value: e,
                            child: Text(
                              e.toString().stripFirstDot(),
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                )),
            Positioned(
                right: 20,
                top: 60,
                child: Container(
                  width: 240,
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Control Points: ",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Switch(
                          value: showControl,
                          onChanged: (value) {
                            setState(() {
                              showControl = value;
                            });
                          }),
                    ],
                  ),
                )),
            Positioned(
                right: 20,
                top: 100,
                child: Container(
                  width: 240,
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Duration: ",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      DropdownButton<int>(
                        iconSize: 18,
                        isDense: true,
                        dropdownColor: Colors.grey,
                        value: durationInSec,
                        onChanged: (int newValue) {
                          setState(() {
                            durationInSec = newValue;
                            controller.duration =
                                Duration(seconds: durationInSec);
                          });
                        },
                        items: [1, 2, 3, 4, 5, 10, 15].map((e) {
                          return DropdownMenuItem<int>(
                            value: e,
                            child: Text(
                              e.toString().stripFirstDot(),
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                )),
          ],
        ));
  }
}

class MorphControlPointsPainter extends CustomPainter {
  List<Offset> controlPoints;

  MorphControlPointsPainter(this.controlPoints);

  @override
  void paint(Canvas canvas, Size size) {
    var myPaint = Paint();
    myPaint.color = Colors.red;
    myPaint.style = PaintingStyle.fill;
    myPaint.strokeWidth = 2.0;
    Path path = Path();
    controlPoints.forEach((element) {
      path.addOval(Rect.fromCircle(
          center: element, radius: min(4, 300 / controlPoints.length)));
    });
    canvas.drawPath(path, myPaint);
    myPaint.color = Colors.black;
    myPaint.style = PaintingStyle.stroke;
    myPaint.strokeWidth = 2.0;
    controlPoints.forEach((element) {
      path.addOval(Rect.fromCircle(
          center: element, radius: min(4, 300 / controlPoints.length)));
    });
    canvas.drawPath(path, myPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
