import 'dart:math';

import 'package:flutter/material.dart';
import '../MorphableShapeBorder.dart';

class StarShape extends Shape {
  final int corners;
  final double inset;

  const StarShape({this.corners=4, this.inset=0.5}) : assert(corners > 3 && inset>=0.0 && inset<=1.0);

  StarShape.fromJson(Map<String, dynamic> map)
      : corners=map["corners"],
  inset=map['inset'];

  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst={"name": this.runtimeType};
    rst["corners"]=corners;
    rst["inset"]=inset;
    return rst;
  }

  DynamicPath generateDynamicPath(Rect rect) {
    List<DynamicNode> nodes = [];

    final double height = 100;
    final double width = 100;

    final int vertices = corners * 2;
    final double alpha = (2 * pi) / vertices;
    final double radius = (height <= width ? height : width) / 2.0;
    final double centerX = width / 2;
    final double centerY = height / 2;

    for (int i = vertices + 1; i != 0; i--) {
      final double r;
      if(i.isEven) {
        r = radius;
      }else{
        r=radius*inset;
      }
      final double omega = alpha * i;
      nodes.add(DynamicNode(position: Offset((r * sin(omega)) + centerX, (r * cos(omega)) + centerY)));
    }

    return DynamicPath(size: Size(width, height), nodes: nodes)..resize(rect.size);
  }

  Path generatePath({double scale=1, Rect rect= const Rect.fromLTRB(0.0, 0.0, 0.0, 0.0)}) {
    final height = 100;
    final width = 100;

    final int vertices = corners * 2;
    final double alpha = (2 * pi) / vertices;
    final double radius = (height <= width ? height : width) / 2.0;
    final double centerX = width / 2;
    final double centerY = height / 2;

    final Path path = Path();
    for (int i = vertices + 1; i != 0; i--) {
      final double r;
      if(i.isEven) {
        r = radius;
      }else{
        r=radius*inset;
      }
      final double omega = alpha * i;
      if(i == vertices + 1) path.moveTo((r * sin(omega)) + centerX, (r * cos(omega)) + centerY);
      path.lineTo((r * sin(omega)) + centerX, (r * cos(omega)) + centerY);
    }

    path.close();
    final Matrix4 matrix4 = Matrix4.identity();
    matrix4.scale(rect.width / width, rect.height / height);
    return path.transform(matrix4.storage);
  }
}
