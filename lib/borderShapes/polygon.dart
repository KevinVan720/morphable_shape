import 'dart:math';

import 'package:flutter/material.dart';

import '../MorphableShapeBorder.dart';

class PolygonShape extends Shape {
  final int sides;

  const PolygonShape({this.sides = 5}) : assert(sides >= 3);

  PolygonShape.fromJson(Map<String, dynamic> map) : sides = map["sides"];

  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst = {"name": this.runtimeType};
    rst["sides"] = sides;
    return rst;
  }

  DynamicPath generateDynamicPath(Rect rect) {
    List<DynamicNode> nodes = [];

    final height = 100.0;
    final width = 100.0;

    double startAngle;
    if (sides.isOdd) {
      startAngle = -pi / 2;
    } else {
      startAngle = -pi / 2 + (pi / sides);
    }

    final double section = (2.0 * pi / sides);
    final double polygonSize = min(width, height);
    final double radius = polygonSize / 2;
    final double centerX = width / 2;
    final double centerY = height / 2;

    nodes.add(DynamicNode(
        position: Offset((centerX + radius * cos(startAngle)),
            (centerY + radius * sin(startAngle)))));

    for (int i = 1; i < sides; i++) {
      nodes.add(DynamicNode(
          position: Offset((centerX + radius * cos(startAngle + section * i)),
              (centerY + radius * sin(startAngle + section * i)))));
    }

    return DynamicPath(size: Size(width, height), nodes: nodes)..resize(rect.size);
  }

  Path generatePath(
      {double scale = 1, Rect rect = const Rect.fromLTRB(0.0, 0.0, 0.0, 0.0)}) {
    final height = 100.0;
    final width = 100.0;

    double startAngle;
    if (sides.isOdd) {
      startAngle = -pi / 2;
    } else {
      startAngle = -pi / 2 + (pi / sides);
    }

    final double section = (2.0 * pi / sides);
    final double polygonSize = min(width, height);
    final double radius = polygonSize / 2;
    final double centerX = width / 2;
    final double centerY = height / 2;

    final Path polygonPath = new Path();
    polygonPath.moveTo((centerX + radius * cos(startAngle)),
        (centerY + radius * sin(startAngle)));

    for (int i = 1; i < sides; i++) {
      polygonPath.lineTo((centerX + radius * cos(startAngle + section * i)),
          (centerY + radius * sin(startAngle + section * i)));
    }

    polygonPath.close();

    final Matrix4 matrix4 = Matrix4.identity();
    matrix4.scale(rect.width / width, rect.height / height);
    return polygonPath.transform(matrix4.storage);
    //return polygonPath;
  }
}
