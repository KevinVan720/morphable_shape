import 'dart:math';

import 'package:flutter/material.dart';
import 'package:morphable_shape/morphable_shape.dart';

class MorphShapePage extends StatefulWidget {

  Shape shape;

  MorphShapePage({this.shape});

  @override
  _MorphShapePageState createState() => _MorphShapePageState();
}

class _MorphShapePageState extends State<MorphShapePage>  with SingleTickerProviderStateMixin {
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
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    Animation curve =
    CurvedAnimation(parent: controller, curve: Curves.easeInOut);

    animation = Tween(begin: 0.0, end: 1.0).animate(curve)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed)
          controller.reverse();
        else if (status == AnimationStatus.dismissed) controller.forward();
      });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {

    Size screenSize=MediaQuery.of(context).size;

    if(screenSize.width>screenSize.height) {
      shapeWidth=screenSize.width/2*0.8;
      shapeHeight=min(screenSize.height, shapeWidth);
    }

    MorphableShapeBorder startBorder;
    MorphableShapeBorder endBorder;

    startBorder = MorphableShapeBorder(
        shape: startShape, borderColor: Colors.redAccent, borderWidth: 1);
    endBorder = MorphableShapeBorder(
        shape: endShape, borderColor: Colors.redAccent, borderWidth: 1);

     MorphableShapeBorderTween shapeBorderTween =
        MorphableShapeBorderTween(begin: startBorder, end: endBorder);

    return Scaffold(appBar: AppBar(
    titleSpacing: 0.0,
    title: Text("Edit Shape"),
    centerTitle: true,
    elevation: 0,
    leading: IconButton(
    icon: Icon(Icons.arrow_back),
    onPressed: () {
      Navigator.of(context).pop();
    },
    ),),
    body: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Center(
          child: Material(
            shape: startBorder,
            clipBehavior: Clip.antiAlias,
            animationDuration: Duration.zero,
            elevation: 10,
            child: Container(
              width: shapeWidth,
              height: shapeHeight,
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.9),
              ),
              child: Center(child: Text("Hello")),
            ),
          ),
        ),
        AnimatedBuilder(
            animation: animation,
            builder: (BuildContext context, Widget child) {
              double t = animation.value;
              return Center(
                child: Material(
                  animationDuration: Duration.zero,
                  shape: shapeBorderTween.lerp(t),
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    color: Colors.amberAccent,
                    width: shapeWidth,
                    height: shapeHeight,
                  ),
                ),
              );
            })
      ],
    ));
  }
}
