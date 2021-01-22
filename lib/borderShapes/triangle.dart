import 'dart:ui';

import 'package:flutter/material.dart';

import '../MorphableShapeBorder.dart';

bool validOffset(Offset offset) {
  return offset.dx >= 0 && offset.dx <= 2 && offset.dy >= 0 && offset.dy <= 2;
}

class TriangleShape extends Shape {
  final Offset point1;
  final Offset point2;
  final Offset point3;

  TriangleShape(
      {this.point1 = const Offset(0, 0),
      this.point2 = const Offset(1, 0),
      this.point3 = const Offset(1.5, 1)});

  Shape copyWith() {
    return BubbleShape();
  }


  TriangleShape.fromJson(Map<String, dynamic> map)
      : point1=parseOffset(map['point1']) ?? const Offset(0, 0),
        point2=parseOffset(map['point2']) ?? const Offset(1, 0),
        point3=parseOffset(map['point3']) ?? const Offset(1.5, 1);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst = {"name": this.runtimeType};
    rst["point1"] = point1.toJson();
    rst["point2"] = point2.toJson();
    rst["point3"] = point3.toJson();
    return rst;
  }

  DynamicPath generateDynamicPath(Rect rect) {
    List<DynamicNode> nodes = [];

    final width = rect.width;
    final height = rect.height;

    Offset point3 = this.point3.clamp(Offset.zero, Offset(2, 2));
    Offset point2 = this.point2.clamp(Offset.zero, point3);
    Offset point1 = this.point1.clamp(Offset.zero, point2);

    assert(point3.dx - point1.dy >= 1 || point3.dy == point1.dx);

    if (point1.dx < 1) {
      nodes.add(DynamicNode(position: Offset(point1.dx * width, 0)));
    } else if (point1.dx == 1) {
      nodes.add(DynamicNode(position: Offset(width, point1.dy * height)));
    } else {
      nodes.add(DynamicNode(position: Offset(width * (point1.dx - 1), height)));
    }
    if (point2.dx < 1) {
      nodes.add(DynamicNode(position: Offset(point2.dx * width, 0)));
    } else if (point2.dx == 1) {
      nodes.add(DynamicNode(position: Offset(width, point2.dy * height)));
    } else if (point2.dy == 1) {
      nodes.add(DynamicNode(position: Offset(width * (point2.dx - 1), height)));
    } else {
      nodes.add(DynamicNode(position: Offset(0, height * (2 - point2.dy))));
    }
    if (point3.dx == 1) {
      nodes.add(DynamicNode(position: Offset(width, point3.dy * height)));
    } else if (point3.dy == 1) {
      nodes.add(DynamicNode(position: Offset(width * (point3.dx - 1), height)));
    } else {
      nodes.add(DynamicNode(position: Offset(0, height * (2 - point3.dy))));
    }

    return DynamicPath(size: rect.size, nodes: nodes);
  }

}
