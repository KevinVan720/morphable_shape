import 'package:flutter/material.dart';

import '../morphable_shape_border.dart';
import 'dart:math';

///Circle shape with a start and sweep angle
class CircleShape extends Shape {

  final double startAngle;
  final double sweepAngle;

  const CircleShape({this.startAngle = 0, this.sweepAngle = 2 * pi});

  CircleShape.fromJson(Map<String, dynamic> map)
      : startAngle = map["startAngle"]??0.0,
        sweepAngle = map["sweepAngle"]??(2 * pi);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst = {"name": this.runtimeType.toString()};
    rst["startAngle"]=startAngle;
    rst["sweepAngle"]=sweepAngle;
    return rst;
  }

  CircleShape copyWith({
  double? startAngle,
    double? sweepAngle,
}) {
    return CircleShape(
      startAngle: startAngle??this.startAngle,
      sweepAngle: sweepAngle??this.sweepAngle,
    );
  }


  DynamicPath generateDynamicPath(Rect rect) {
    final size = rect.size;

    List<DynamicNode> nodes = [];

    double startAngle = this.startAngle.clamp(0.0, 2 * pi);
    double sweepAngle = this.sweepAngle.clamp(0, 2 * pi);

    nodes.add(DynamicNode(
        position: Offset(size.width / 2 * (1 + cos(startAngle)),
            size.height / 2 * (1 + sin(startAngle)))));
    nodes.arcTo(
        Rect.fromCenter(
          center: Offset(rect.width / 2.0, rect.height / 2.0),
          width: rect.width,
          height: rect.height,
        ),
        startAngle,
        sweepAngle);
    if (sweepAngle < 2 * pi) {
      nodes.add(DynamicNode(position: Offset(size.width / 2, size.height / 2)));
    }

    return DynamicPath(nodes: nodes, size: size);
  }
}
