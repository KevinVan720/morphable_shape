import 'dart:math';

import 'package:flutter/material.dart';
import 'package:morphable_shape/morphable_shape.dart';

///Circle shape with a start and sweep angle
class CircleShape extends OutlinedShape {
  final double startAngle;
  final double sweepAngle;

  const CircleShape({
    DynamicBorderSide border = DynamicBorderSide.none,
    this.startAngle = 0,
    this.sweepAngle = 2 * pi,
  }) : super(border: border);

  CircleShape.fromJson(Map<String, dynamic> map)
      : startAngle = map["startAngle"] ?? 0.0,
        sweepAngle = map["sweepAngle"] ?? (2 * pi),
        super(
            border: parseDynamicBorderSide(map["border"]) ??
                DynamicBorderSide.none);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst = {"type": "CircleShape"};
    rst.addAll(super.toJson());
    rst["startAngle"] = startAngle;
    rst["sweepAngle"] = sweepAngle;
    return rst;
  }

  CircleShape copyWith({
    double? startAngle,
    double? sweepAngle,
    DynamicBorderSide? border,
  }) {
    return CircleShape(
      border: border ?? this.border,
      startAngle: startAngle ?? this.startAngle,
      sweepAngle: sweepAngle ?? this.sweepAngle,
    );
  }

  DynamicPath generateOuterDynamicPath(Rect rect) {
    final size = rect.size;

    List<DynamicNode> nodes = [];

    double startAngle = this.startAngle.clamp(0.0, 2 * pi);
    double sweepAngle = this.sweepAngle.clamp(0, 2 * pi);

    nodes.addArc(
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
