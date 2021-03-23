import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:morphable_shape/morphable_shape.dart';

///Circle shape with a start and sweep angle
class CircleShape extends OutlinedShape {
  const CircleShape({
    DynamicBorderSide border = DynamicBorderSide.none,
  }) : super(border: border);

  CircleShape.fromJson(Map<String, dynamic> map)
      : super(
            border: parseDynamicBorderSide(map["border"]) ??
                DynamicBorderSide.none);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst = {"type": "CircleShape"};
    rst.addAll(super.toJson());
    return rst;
  }

  CircleShape copyWith({
    DynamicBorderSide? border,
  }) {
    return CircleShape(
      border: border ?? this.border,
    );
  }

  bool isSameMorphGeometry(Shape shape) {
    return shape is CircleShape ||
        shape is RectangleShape ||
        shape is RoundedRectangleShape;
  }

  DynamicPath generateOuterDynamicPath(Rect rect) {
    final size = rect.size;

    List<DynamicNode> nodes = [];

    nodes.addArc(
        Rect.fromCenter(
          center: Offset(rect.width / 2.0, rect.height / 2.0),
          width: rect.width,
          height: rect.height,
        ),
        -pi / 2,
        pi / 2,
        splitTimes: 1);
    nodes.addArc(
        Rect.fromCenter(
          center: Offset(rect.width / 2.0, rect.height / 2.0),
          width: rect.width,
          height: rect.height,
        ),
        0,
        pi / 2,
        splitTimes: 1);
    nodes.addArc(
        Rect.fromCenter(
          center: Offset(rect.width / 2.0, rect.height / 2.0),
          width: rect.width,
          height: rect.height,
        ),
        pi / 2,
        pi / 2,
        splitTimes: 1);
    nodes.addArc(
        Rect.fromCenter(
          center: Offset(rect.width / 2.0, rect.height / 2.0),
          width: rect.width,
          height: rect.height,
        ),
        pi,
        pi / 2,
        splitTimes: 1);

    return DynamicPath(nodes: nodes, size: size);
  }
}
