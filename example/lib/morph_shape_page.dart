import 'dart:math';

import 'package:flutter/material.dart';
import 'package:morphable_shape/morphable_shape.dart';
import 'package:morphable_shape/preset_shape_map.dart';
import 'value_pickers.dart';

class MorphShapePage extends StatefulWidget {
  Shape shape;

  MorphShapePage({this.shape});

  @override
  _MorphShapePageState createState() => _MorphShapePageState();
}

class _MorphShapePageState extends State<MorphShapePage>
    with SingleTickerProviderStateMixin {
  Shape startShape;
  Shape endShape;

  AnimationController controller;
  Animation animation;

  double shapeWidth;
  double shapeHeight;

  @override
  void initState() {
    super.initState();

    startShape = widget.shape;

    endShape = StarShape();

    controller =
        AnimationController(vsync: this, duration: Duration(seconds: 3));
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
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    shapeWidth=(min(screenSize.width, screenSize.height)*0.8).clamp(200.0, 400.0);
    shapeHeight=shapeWidth;

    MorphableShapeBorder startBorder;
    MorphableShapeBorder endBorder;

    startBorder = MorphableShapeBorder(
        shape: startShape, borderColor: Colors.redAccent, borderWidth: 1);
    endBorder = MorphableShapeBorder(
        shape: endShape, borderColor: Colors.redAccent, borderWidth: 1);

    MorphableShapeBorderTween shapeBorderTween =
        MorphableShapeBorderTween(begin: startBorder, end: endBorder);

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black87,
          titleSpacing: 0.0,
          title: Text("Shape Morphing"),
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
                endShape = shape;
              });
            })
          ],
        ),
        body: Container(
          color: Colors.black54,
          child: AnimatedBuilder(
              animation: animation,
              builder: (BuildContext context, Widget child) {
                double t = animation.value;
                return Center(
                  child: CustomPaint(
                      painter: MorphControlPointsPainter(
                          PathMorph.lerpPoints(t, shapeBorderTween.data)),
                      child:Material(
                        animationDuration: Duration.zero,
                        shape: shapeBorderTween.lerp(t),
                        clipBehavior: Clip.antiAlias,
                        child: Container(
                          color: Colors.amberAccent,
                          width: shapeWidth,
                          height: shapeHeight,
                          child: CustomPaint(
                            painter: MorphControlPointsPainter(
                                PathMorph.lerpPoints(t, shapeBorderTween.data)),
                          ),
                        ),
                      )),
                );
              })
        ));
  }
}

class MorphControlPointsPainter extends CustomPainter {
  List<Offset> controlPoints;
  var myPaint;

  MorphControlPointsPainter(this.controlPoints) {
    myPaint = Paint();
    myPaint.color = Color.fromRGBO(255, 0, 0, 1.0);
    myPaint.style = PaintingStyle.fill;
    myPaint.strokeWidth = 5.0;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path();
    controlPoints.forEach((element) {
      path.addOval(Rect.fromCircle(center: element, radius: min(10,1000/controlPoints.length)));
    });
    canvas.drawPath(path, myPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
