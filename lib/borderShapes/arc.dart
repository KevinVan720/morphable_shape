import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../MorphableShapeBorder.dart';
import 'dart:math';

class ArcShape extends Shape {
  final AxisDirection position;
  final double arcHeight;
  final bool isOutward;

  const ArcShape({
    this.position = AxisDirection.down,
    this.isOutward = true,
    this.arcHeight = 10,
  });

  ArcShape.fromJson(Map<String, dynamic> map)
      : position = parseAxisDirection(map["position"])??AxisDirection.down,
        isOutward = map["isOutward"],
        arcHeight = map["arcHeight"];

  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst = {"name": this.runtimeType};
    rst["position"] = position.toJson();
    rst["arcHeight"] = arcHeight;
    rst["isOutward"] = isOutward;
    return rst;
  }

  DynamicPath generateDynamicPath(Rect rect) {

    final size = rect.size;
    double arcHeight =
    this.arcHeight.clamp(0, min(size.width / 2, size.height / 2)*0.999);
    double theta1, theta2, theta3, radius;
    if (position == AxisDirection.up || position == AxisDirection.down) {
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

    List<DynamicNode> nodes=[];

    switch (this.position) {
      case AxisDirection.up:
        if (isOutward) {
          Rect circleRect = Rect.fromCenter(
              center: Offset(size.width / 2, radius),
              width: 2 * radius,
              height: 2 * radius);
          double startAngle = pi + theta3;
          double sweepAngle = pi - 2 * theta3;

          nodes.add(DynamicNode(position: Offset(0.0, arcHeight)));
          addBezier(nodes, arcToCubicBezier(circleRect, startAngle, sweepAngle));
          nodes.add(DynamicNode(position: Offset(size.width, size.height)));
          nodes.add(DynamicNode(position: Offset(0.0, size.height)));

        } else {
          Rect circleRect = Rect.fromCenter(
              center: Offset(size.width / 2, arcHeight - radius),
              width: 2 * radius,
              height: 2 * radius);
          double startAngle = pi - theta3;
          double sweepAngle = pi - 2 * theta3;

          addBezier(nodes, arcToCubicBezier(circleRect, startAngle, -sweepAngle));
          nodes.add(DynamicNode(position: Offset(size.width, size.height)));
          nodes.add(DynamicNode(position: Offset(0.0, size.height)));
        }
        break;
      case AxisDirection.down:
        if (isOutward) {
          Rect circleRect = Rect.fromCenter(
              center: Offset(size.width / 2, size.height - radius),
              width: 2 * radius,
              height: 2 * radius);
          double startAngle = theta3;
          double sweepAngle = pi - 2 * theta3;

          nodes.add(DynamicNode(position: Offset(0.0, 0.0)));
          nodes.add(DynamicNode(position: Offset(size.width, 0.0)));
          nodes.add(DynamicNode(position: Offset(size.width, size.height-arcHeight)));
          addBezier(nodes, arcToCubicBezier(circleRect, startAngle, sweepAngle));
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
          addBezier(nodes, arcToCubicBezier(circleRect, startAngle, -sweepAngle));
        }
        break;
      case AxisDirection.left:
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
          addBezier(nodes, arcToCubicBezier(circleRect, startAngle, sweepAngle));

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
          addBezier(
              nodes, arcToCubicBezier(circleRect, startAngle, -sweepAngle));
        }
        break;
      case AxisDirection.right: //right
        if (isOutward) {
          Rect circleRect = Rect.fromCenter(
              center: Offset(size.width - radius, size.height / 2),
              width: 2 * radius,
              height: 2 * radius);
          double startAngle = -(pi / 2 - theta3);
          double sweepAngle = pi - 2 * theta3;
          nodes.add(DynamicNode(position: Offset(size.width - arcHeight, 0.0)));
          addBezier(nodes, arcToCubicBezier(circleRect, startAngle, sweepAngle));
          nodes.add(DynamicNode(position: Offset(0.0, size.height)));
          nodes.add(DynamicNode(position: Offset(0.0,0.0)));

        } else {
          Rect circleRect = Rect.fromCenter(
              center: Offset(size.width - arcHeight + radius, size.height / 2),
              width: 2 * radius,
              height: 2 * radius);
          double startAngle = -(pi / 2 + theta3);
          double sweepAngle = pi - 2 * theta3;
          nodes.add(DynamicNode(position: Offset(size.width, 0.0)));
          addBezier(nodes, arcToCubicBezier(circleRect, startAngle, -sweepAngle));
          nodes.add(DynamicNode(position: Offset(0.0, size.height)));
          nodes.add(DynamicNode(position: Offset(0.0,0.0)));
        }
        break;
    }
    return DynamicPath(nodes: nodes, size: size);
  }

  Path generatePath(
      {Rect rect = const Rect.fromLTRB(0.0, 0.0, 0.0, 0.0), double scale = 1}) {
    return generateDynamicPath(rect).getPath(rect.size);

    final size = rect.size;
    double arcHeight =
        this.arcHeight.clamp(0, min(size.width / 2, size.height / 2));
    double theta1, theta2, theta3, radius;
    if (position == AxisDirection.up || position == AxisDirection.down) {
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

    switch (this.position) {
      case AxisDirection.up:
        if (isOutward) {
          Rect circleRect = Rect.fromCenter(
              center: Offset(size.width / 2, radius),
              width: 2 * radius,
              height: 2 * radius);
          double startAngle = pi + theta3;
          double sweepAngle = pi - 2 * theta3;
          return Path()
            ..moveTo(0.0, arcHeight)
            ..arcTo(circleRect, startAngle, sweepAngle, false)
            ..lineTo(size.width, size.height)
            ..lineTo(0.0, size.height)
            ..close();
        } else {
          Rect circleRect = Rect.fromCenter(
              center: Offset(size.width / 2, arcHeight - radius),
              width: 2 * radius,
              height: 2 * radius);
          double startAngle = pi - theta3;
          double sweepAngle = pi - 2 * theta3;
          return Path()
            ..arcTo(circleRect, startAngle, -sweepAngle, false)
            ..lineTo(size.width, size.height)
            ..lineTo(0.0, size.height)
            ..close();
        }
      case AxisDirection.down:
        if (isOutward) {
          Rect circleRect = Rect.fromCenter(
              center: Offset(size.width / 2, size.height - radius),
              width: 2 * radius,
              height: 2 * radius);
          double startAngle = theta3;
          double sweepAngle = pi - 2 * theta3;
          return Path()
            ..lineTo(size.width, 0.0)
            ..lineTo(size.width, size.height - arcHeight)
            ..arcTo(circleRect, startAngle, sweepAngle, false)
            ..close();
        } else {
          Rect circleRect = Rect.fromCenter(
              center: Offset(size.width / 2, size.height - arcHeight + radius),
              width: 2 * radius,
              height: 2 * radius);
          double startAngle = -theta3;
          double sweepAngle = pi - 2 * theta3;
          return Path()
            ..lineTo(size.width, 0.0)
            ..lineTo(size.width, size.height)
            ..arcTo(circleRect, startAngle, -sweepAngle, false)
            ..close();
        }
      case AxisDirection.left:
        if (isOutward) {
          Rect circleRect = Rect.fromCenter(
              center: Offset(radius, size.height / 2),
              width: 2 * radius,
              height: 2 * radius);
          double startAngle = pi / 2 + theta3;
          double sweepAngle = pi - 2 * theta3;
          return Path()
            ..moveTo(arcHeight, 0.0)
            ..lineTo(size.width, 0.0)
            ..lineTo(size.width, size.height)
            ..lineTo(arcHeight, size.height)
            ..arcTo(circleRect, startAngle, sweepAngle, false)
            ..close();
        } else {
          Rect circleRect = Rect.fromCenter(
              center: Offset(arcHeight - radius, size.height / 2),
              width: 2 * radius,
              height: 2 * radius);
          double startAngle = pi / 2 - theta3;
          double sweepAngle = pi - 2 * theta3;
          return Path()
            ..moveTo(0, 0.0)
            ..lineTo(size.width, 0.0)
            ..lineTo(size.width, size.height)
            ..lineTo(0, size.height)
            ..arcTo(circleRect, startAngle, -sweepAngle, false)
            ..close();
        }
        break;
      case AxisDirection.right: //right
        if (isOutward) {
          Rect circleRect = Rect.fromCenter(
              center: Offset(size.width - radius, size.height / 2),
              width: 2 * radius,
              height: 2 * radius);
          double startAngle = -(pi / 2 - theta3);
          double sweepAngle = pi - 2 * theta3;
          return Path()
            ..moveTo(size.width - arcHeight, 0.0)
            ..arcTo(circleRect, startAngle, sweepAngle, false)
            ..lineTo(0.0, size.height)
            ..lineTo(0.0, 0.0)
            ..close();
        } else {
          Rect circleRect = Rect.fromCenter(
              center: Offset(size.width - arcHeight + radius, size.height / 2),
              width: 2 * radius,
              height: 2 * radius);
          double startAngle = -(pi / 2 + theta3);
          double sweepAngle = pi - 2 * theta3;
          return Path()
            ..moveTo(size.width, 0.0)
            ..arcTo(circleRect, startAngle, -sweepAngle, false)
            ..lineTo(0.0, size.height)
            ..lineTo(0.0, 0.0)
            ..close();
        }
      default:
        return Path();
    }

  }
}
