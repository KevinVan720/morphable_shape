import 'dart:math';

import 'package:flutter/material.dart';

import '../MorphableShapeBorder.dart';

class BubbleShape extends Shape {
  final AxisDirection position;

  final double borderRadius;
  final double arrowHeight;
  final double arrowWidth;

  final double arrowPositionPercent;

  const BubbleShape({
    this.position = AxisDirection.down,
    this.borderRadius = 12,
    this.arrowHeight = 10,
    this.arrowWidth = 10,
    this.arrowPositionPercent = 0.5,
  });

  BubbleShape.fromJson(Map<String, dynamic> map)
      : position = parseAxisDirection(map["position"]) ?? AxisDirection.down,
        borderRadius = map["borderRadius"],
        arrowHeight = map["arrowHeight"],
        arrowWidth = map["arrowWidth"],
        arrowPositionPercent = map["arrowPositionPercent"];

  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst = {"name": this.runtimeType};
    rst["position"] = position.toJson();
    rst["borderRadius"] = borderRadius;
    rst["arrowHeight"] = arrowHeight;
    rst["arrowWidth"] = arrowWidth;
    rst["arrowPositionPercent"] = arrowPositionPercent;
    return rst;
  }

  DynamicPath generateDynamicPath(Rect rect) {
    final size = rect.size;

    List<DynamicNode> nodes = [];

    final double centerX = (rect.left + rect.right) * arrowPositionPercent;
    final double centerY = (rect.top + rect.bottom) * arrowPositionPercent;

    final double spacingLeft =
        this.position == AxisDirection.left ? arrowHeight : 0;
    final double spacingTop =
        this.position == AxisDirection.up ? arrowHeight : 0;
    final double spacingRight =
        this.position == AxisDirection.right ? arrowHeight : 0;
    final double spacingBottom =
        this.position == AxisDirection.down ? arrowHeight : 0;

    final double left = spacingLeft + rect.left;
    final double top = spacingTop + rect.top;
    final double right = rect.right - spacingRight;
    final double bottom = rect.bottom - spacingBottom;

    double borderRadius = this.borderRadius.clamp(
        0,
        min(min(bottom - centerY + arrowWidth / 2, centerY - arrowWidth / 2- top),
            min(right - centerX + arrowWidth / 2, centerX - arrowWidth / 2- left)));

    double topLeftDiameter = max(2 * borderRadius, 0);
    double topRightDiameter = max(2 * borderRadius, 0);
    double bottomLeftDiameter = max(2 * borderRadius, 0);
    double bottomRightDiameter = max(2 * borderRadius, 0);

    //nodes.add(DynamicNode(position: Offset(left + topLeftDiameter, top)));
    //LEFT, TOP

    if (position == AxisDirection.up) {
      nodes.add(DynamicNode(position: Offset(centerX - arrowWidth, top)));
      nodes.add(DynamicNode(position: Offset(centerX, rect.top)));
      nodes.add(DynamicNode(position: Offset(centerX + arrowWidth, top)));
    }
    if (topRightDiameter > 0) {
      nodes.add(
          DynamicNode(position: Offset(right - topRightDiameter / 2, top)));
      addBezier(
          nodes,
          arcToCubicBezier(
              Rect.fromLTRB(
                  right - topRightDiameter, top, right, top + topRightDiameter),
              3 * pi / 2,
              pi / 2));
    } else {
      nodes.add(DynamicNode(position: Offset(right, top)));
    }
    //RIGHT, TOP

    if (position == AxisDirection.right) {
      nodes.add(DynamicNode(position: Offset(right, centerY - arrowWidth/2)));
      nodes.add(DynamicNode(position: Offset(rect.right, centerY)));
      nodes.add(DynamicNode(position: Offset(right, centerY + arrowWidth/2)));
    }
    if (bottomRightDiameter > 0) {
      nodes.add(DynamicNode(
          position: Offset(right, bottom - bottomRightDiameter / 2)));
      addBezier(
          nodes,
          arcToCubicBezier(
              Rect.fromLTRB(right - bottomRightDiameter,
                  bottom - bottomRightDiameter, right, bottom),
              0,
              pi / 2));
    } else {
      nodes.add(DynamicNode(position: Offset(right, bottom)));
    }

    if (position == AxisDirection.down) {
      nodes.add(DynamicNode(position: Offset(centerX + arrowWidth/2, bottom)));
      nodes.add(DynamicNode(position: Offset(centerX, rect.bottom)));
      nodes.add(DynamicNode(position: Offset(centerX - arrowWidth/2, bottom)));
    }
    if (bottomLeftDiameter > 0) {
      nodes.add(
          DynamicNode(position: Offset(left + bottomLeftDiameter / 2, bottom)));
      addBezier(
          nodes,
          arcToCubicBezier(
              Rect.fromLTRB(left, bottom - bottomLeftDiameter,
                  left + bottomLeftDiameter, bottom),
              pi / 2,
              pi / 2));
    } else {
      nodes.add(DynamicNode(position: Offset(left, bottom)));
    }
    //LEFT, BOTTOM

    if (position == AxisDirection.left) {
      nodes.add(DynamicNode(position: Offset(left, centerY + arrowWidth/2)));
      nodes.add(DynamicNode(position: Offset(rect.left, centerY)));
      nodes.add(DynamicNode(position: Offset(left, centerY - arrowWidth/2)));
    }
    if (topLeftDiameter > 0) {
      nodes.add(DynamicNode(position: Offset(left, top + topLeftDiameter / 2)));
      addBezier(
          nodes,
          arcToCubicBezier(
              Rect.fromLTRB(
                  left, top, left + topLeftDiameter, top + topLeftDiameter),
              pi,
              pi / 2));
    } else {
      nodes.add(DynamicNode(position: Offset(left, top)));
    }

    return DynamicPath(nodes: nodes, size: size);
  }

  Path generatePath(
      {double scale = 1, Rect rect = const Rect.fromLTRB(0.0, 0.0, 0.0, 0.0)}) {
    final Path path = new Path();

    double topLeftDiameter = max(borderRadius, 0);
    double topRightDiameter = max(borderRadius, 0);
    double bottomLeftDiameter = max(borderRadius, 0);
    double bottomRightDiameter = max(borderRadius, 0);

    final double spacingLeft =
        this.position == AxisDirection.left ? arrowHeight : 0;
    final double spacingTop =
        this.position == AxisDirection.up ? arrowHeight : 0;
    final double spacingRight =
        this.position == AxisDirection.right ? arrowHeight : 0;
    final double spacingBottom =
        this.position == AxisDirection.down ? arrowHeight : 0;

    final double left = spacingLeft + rect.left;
    final double top = spacingTop + rect.top;
    final double right = rect.right - spacingRight;
    final double bottom = rect.bottom - spacingBottom;

    final double centerX = (rect.left + rect.right) * arrowPositionPercent;

    path.moveTo(left + topLeftDiameter / 2.0, top);
    //LEFT, TOP

    if (position == AxisDirection.up) {
      path.lineTo(centerX - arrowWidth, top);
      path.lineTo(centerX, rect.top);
      path.lineTo(centerX + arrowWidth, top);
    }
    path.lineTo(right - topRightDiameter / 2.0, top);

    path.quadraticBezierTo(right, top, right, top + topRightDiameter / 2);
    //RIGHT, TOP

    if (position == AxisDirection.right) {
      path.lineTo(
          right, bottom - (bottom * (1 - arrowPositionPercent)) - arrowWidth);
      path.lineTo(rect.right, bottom - (bottom * (1 - arrowPositionPercent)));
      path.lineTo(
          right, bottom - (bottom * (1 - arrowPositionPercent)) + arrowWidth);
    }
    path.lineTo(right, bottom - bottomRightDiameter / 2);

    path.quadraticBezierTo(
        right, bottom, right - bottomRightDiameter / 2, bottom);
    //RIGHT, BOTTOM

    if (position == AxisDirection.down) {
      path.lineTo(centerX + arrowWidth, bottom);
      path.lineTo(centerX, rect.bottom);
      path.lineTo(centerX - arrowWidth, bottom);
    }
    path.lineTo(left + bottomLeftDiameter / 2, bottom);

    path.quadraticBezierTo(left, bottom, left, bottom - bottomLeftDiameter / 2);
    //LEFT, BOTTOM

    if (position == AxisDirection.left) {
      path.lineTo(
          left, bottom - (bottom * (1 - arrowPositionPercent)) + arrowWidth);
      path.lineTo(rect.left, bottom - (bottom * (1 - arrowPositionPercent)));
      path.lineTo(
          left, bottom - (bottom * (1 - arrowPositionPercent)) - arrowWidth);
    }
    path.lineTo(left, top + topLeftDiameter / 2);

    path.quadraticBezierTo(left, top, left + topLeftDiameter / 2, top);

    path.close();

    return path;
  }
}
