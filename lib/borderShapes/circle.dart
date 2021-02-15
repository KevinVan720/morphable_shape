import 'package:flutter/material.dart';

import '../morphable_shape_border.dart';
import 'dart:math';

///Circle shape with a start and sweep angle
class CircleShape extends OutlinedShape {
  final double startAngle;
  final double sweepAngle;
  final DynamicBorderSide borderSide;

  const CircleShape(
      {DynamicBorderSide border = DynamicBorderSide.none,
      this.startAngle = 0,
      this.sweepAngle = 2 * pi,
      this.borderSide =
          const DynamicBorderSide(width: Length(10), color: Colors.white70)})
      : super(border: border);

  CircleShape.fromJson(Map<String, dynamic> map)
      : startAngle = map["startAngle"] ?? 0.0,
        sweepAngle = map["sweepAngle"] ?? (2 * pi),
        this.borderSide =
            const DynamicBorderSide(width: Length(10), color: Colors.white70);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst = {"type": "CircleShape"};
    rst["startAngle"] = startAngle;
    rst["sweepAngle"] = sweepAngle;
    return rst;
  }

  CircleShape copyWith({
    double? startAngle,
    double? sweepAngle,
  }) {
    return CircleShape(
      startAngle: startAngle ?? this.startAngle,
      sweepAngle: sweepAngle ?? this.sweepAngle,
    );
  }

  DynamicPath generateInnerDynamicPath(Rect rect) {
    final size = rect.size;

    List<DynamicNode> nodes = [];

    double startAngle = this.startAngle.clamp(0.0, 2 * pi);
    double sweepAngle = this.sweepAngle.clamp(0, 2 * pi);

    double borderWidth =
        borderSide.width.toPX(constraintSize: size.shortestSide);

    double alpha = sweepAngle / 2;
    double l = borderWidth;

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

  DynamicPath generateOuterDynamicPath(Rect rect) {
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
