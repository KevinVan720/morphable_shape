import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../MorphableShapeBorder.dart';
import 'dart:math';

class ArcShape extends Shape {
  final ShapeSide side;
  final Length arcHeight;
  final bool isOutward;

  const ArcShape({
    this.side = ShapeSide.bottom,
    this.isOutward = true,
    this.arcHeight = const Length(10),
  });

  ArcShape.fromJson(Map<String, dynamic> map)
      : side = ShapeSide.bottom,
        isOutward = map["isOutward"],
        arcHeight = map["arcHeight"];

  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst = {"name": this.runtimeType};
    rst["arcHeight"] = arcHeight;
    rst["isOutward"] = isOutward;
    return rst;
  }

  ArcShape copyWith({
    ShapeSide? side,
    bool? isOutward,
    Length? arcHeight,
  }) {
    return ArcShape(
      side: side ?? this.side,
      isOutward: isOutward ?? this.isOutward,
      arcHeight: arcHeight ?? this.arcHeight,
    );
  }

  DynamicPath generateDynamicPath(Rect rect) {
    final size = rect.size;
    double arcHeight = 0;
    if (side == ShapeSide.top || side == ShapeSide.bottom) {
      arcHeight = this
          .arcHeight
          .toPX(constraintSize: rect.height)
          .clamp(0, min(size.width / 2, size.height / 2) * 0.999);
    } else {
      this
          .arcHeight
          .toPX(constraintSize: rect.width)
          .clamp(0, min(size.width / 2, size.height / 2) * 0.999);
    }
    double theta1, theta2, theta3, radius;
    if (side == ShapeSide.top || side == ShapeSide.bottom) {
      theta1 = atan(size.width / (2 * arcHeight));
      theta2 = atan((2 * arcHeight) / size.width);
      theta3 = theta1 - theta2;
      radius = size.width / 2 * tan(theta3) + arcHeight;
    } else {
      theta1 = atan(size.height / (2 * arcHeight));
      theta2 = atan((2 * arcHeight) / size.height);
      theta3 = theta1 - theta2;
      radius = size.height / 2 * tan(theta3) + arcHeight;
    }

    List<DynamicNode> nodes = [];

    switch (this.side) {
      case ShapeSide.top:
        if (isOutward) {
          Rect circleRect = Rect.fromCenter(
              center: Offset(size.width / 2, radius),
              width: 2 * radius,
              height: 2 * radius);
          double startAngle = pi + theta3;
          double sweepAngle = pi - 2 * theta3;

          nodes.add(DynamicNode(position: Offset(0.0, arcHeight)));
          nodes.arcTo(circleRect, startAngle, sweepAngle);
          //addBezier(nodes, arcToCubicBezier(circleRect, startAngle, sweepAngle));
          nodes.add(DynamicNode(position: Offset(size.width, size.height)));
          nodes.add(DynamicNode(position: Offset(0.0, size.height)));
        } else {
          Rect circleRect = Rect.fromCenter(
              center: Offset(size.width / 2, arcHeight - radius),
              width: 2 * radius,
              height: 2 * radius);
          double startAngle = pi - theta3;
          double sweepAngle = pi - 2 * theta3;
          nodes.add(DynamicNode(position: Offset(0.0, 0.0)));
          nodes.arcTo(circleRect, startAngle, -sweepAngle);
          nodes.add(DynamicNode(position: Offset(size.width, size.height)));
          nodes.add(DynamicNode(position: Offset(0.0, size.height)));
        }
        break;
      case ShapeSide.bottom:
        if (isOutward) {
          Rect circleRect = Rect.fromCenter(
              center: Offset(size.width / 2, size.height - radius),
              width: 2 * radius,
              height: 2 * radius);
          double startAngle = theta3;
          double sweepAngle = pi - 2 * theta3;

          nodes.add(DynamicNode(position: Offset(0.0, 0.0)));
          nodes.add(DynamicNode(position: Offset(size.width, 0.0)));
          nodes.add(DynamicNode(
              position: Offset(size.width, size.height - arcHeight)));
          nodes.arcTo(circleRect, startAngle, sweepAngle);
        } else {
          Rect circleRect = Rect.fromCenter(
              center: Offset(size.width / 2, size.height - arcHeight + radius),
              width: 2 * radius,
              height: 2 * radius);
          double startAngle = -theta3;
          double sweepAngle = pi - 2 * theta3;
          nodes.add(DynamicNode(position: Offset(0.0, 0.0)));
          nodes.add(DynamicNode(position: Offset(size.width, 0.0)));
          nodes.add(DynamicNode(position: Offset(size.width, size.height)));
          nodes.arcTo(circleRect, startAngle, -sweepAngle);
        }
        break;
      case ShapeSide.left:
        if (isOutward) {
          Rect circleRect = Rect.fromCenter(
              center: Offset(radius, size.height / 2),
              width: 2 * radius,
              height: 2 * radius);
          double startAngle = pi / 2 + theta3;
          double sweepAngle = pi - 2 * theta3;
          nodes.add(DynamicNode(position: Offset(arcHeight, 0.0)));
          nodes.add(DynamicNode(position: Offset(size.width, 0.0)));
          nodes.add(DynamicNode(position: Offset(size.width, size.height)));
          nodes.add(DynamicNode(position: Offset(arcHeight, size.height)));
          nodes.arcTo(circleRect, startAngle, sweepAngle);
        } else {
          Rect circleRect = Rect.fromCenter(
              center: Offset(arcHeight - radius, size.height / 2),
              width: 2 * radius,
              height: 2 * radius);
          double startAngle = pi / 2 - theta3;
          double sweepAngle = pi - 2 * theta3;
          nodes.add(DynamicNode(position: Offset(0.0, 0.0)));
          nodes.add(DynamicNode(position: Offset(size.width, 0.0)));
          nodes.add(DynamicNode(position: Offset(size.width, size.height)));
          nodes.add(DynamicNode(position: Offset(0, size.height)));
          nodes.arcTo(circleRect, startAngle, -sweepAngle);
        }
        break;
      case ShapeSide.right: //right
        if (isOutward) {
          Rect circleRect = Rect.fromCenter(
              center: Offset(size.width - radius, size.height / 2),
              width: 2 * radius,
              height: 2 * radius);
          double startAngle = -(pi / 2 - theta3);
          double sweepAngle = pi - 2 * theta3;
          nodes.add(DynamicNode(position: Offset(size.width - arcHeight, 0.0)));
          nodes.arcTo(circleRect, startAngle, sweepAngle);
          nodes.add(DynamicNode(position: Offset(0.0, size.height)));
          nodes.add(DynamicNode(position: Offset(0.0, 0.0)));
        } else {
          Rect circleRect = Rect.fromCenter(
              center: Offset(size.width - arcHeight + radius, size.height / 2),
              width: 2 * radius,
              height: 2 * radius);
          double startAngle = -(pi / 2 + theta3);
          double sweepAngle = pi - 2 * theta3;
          nodes.add(DynamicNode(position: Offset(size.width, 0.0)));
          nodes.arcTo(circleRect, startAngle, -sweepAngle);
          nodes.add(DynamicNode(position: Offset(0.0, size.height)));
          nodes.add(DynamicNode(position: Offset(0.0, 0.0)));
        }
        break;
    }
    return DynamicPath(nodes: nodes, size: size);
  }

}
