import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart';

import '../MorphableShapeBorder.dart';

const double magicC=0.551915;

class RoundRectShape extends Shape {
  final BorderRadius borderRadius;

  const RoundRectShape({
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  RoundRectShape.fromJson(Map<String, dynamic> map)
      : borderRadius = parseBorderRadius(map["borderRadius"])??BorderRadius.zero;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst={"name": this.runtimeType};
    rst["borderRadius"]=borderRadius.toJson();
    return rst;
  }

  DynamicPath generateDynamicPath(Rect rect) {
    List<DynamicNode> nodes = [];

    final double left = rect.left;
    final double top = rect.top;
    final double bottom = rect.bottom;
    final double right = rect.right;

    final double maxSize = min(rect.width / 2.0, rect.height / 2.0);

    double topLeftRadius = borderRadius.topLeft.x.abs().clamp(0, maxSize);
    double topRightRadius = borderRadius.topRight.x.abs().clamp(0, maxSize);
    double bottomLeftRadius = borderRadius.bottomLeft.x.abs().clamp(0, maxSize);
    double bottomRightRadius = borderRadius.bottomRight.x.abs().clamp(0, maxSize);

    nodes.add(DynamicNode(position: Offset(left + topLeftRadius, top)));
    nodes.add(DynamicNode(position: Offset(right - topRightRadius, top)));

    double arc = topRightRadius > 0 ? 90 : -270;
    addBezier(nodes, arcToCubicBezier(Rect.fromLTRB(right - topRightRadius * 2.0, top, right,
        top + topRightRadius * 2.0),
      radians(-90),
      radians(arc)));

    nodes.add(DynamicNode(position: Offset(right, bottom - bottomRightRadius)));

    arc = bottomRightRadius > 0 ? 90 : -270;
    addBezier(nodes, arcToCubicBezier(Rect.fromLTRB(right - bottomRightRadius * 2.0,
        bottom - bottomRightRadius * 2.0, right, bottom),
      0,
      radians(arc)));

    nodes.add(DynamicNode(position: Offset(left + bottomLeftRadius, bottom)));

    arc = bottomLeftRadius > 0 ? 90 : -270;

    addBezier(nodes, arcToCubicBezier(Rect.fromLTRB(left, bottom - bottomLeftRadius * 2.0,
        left + bottomLeftRadius * 2.0, bottom),
      radians(90),
      radians(arc)));

    nodes.add(DynamicNode(position: Offset(left, top + topLeftRadius)));

    arc = topLeftRadius > 0 ? 90 : -270;
    addBezier(nodes, arcToCubicBezier(   Rect.fromLTRB(
        left, top, left + topLeftRadius * 2.0, top + topLeftRadius * 2.0),
      radians(180),
      radians(arc),));

    return DynamicPath(size: rect.size, nodes: nodes);
  }

  Path generatePath(
      {double scale = 1, Rect rect = const Rect.fromLTRB(0.0, 0.0, 0.0, 0.0)}) {
    final Path path = Path();

    final double left = rect.left;
    final double top = rect.top;
    final double bottom = rect.bottom;
    final double right = rect.right;

    final double maxSize = min(rect.width / 2.0, rect.height / 2.0);

    double topLeftRadius = borderRadius.topLeft.x.abs();
    double topRightRadius = borderRadius.topRight.x.abs();
    double bottomLeftRadius = borderRadius.bottomLeft.x.abs();
    double bottomRightRadius = borderRadius.bottomRight.x.abs();

    if (topLeftRadius > maxSize) {
      topLeftRadius = maxSize;
    }
    if (topRightRadius > maxSize) {
      topRightRadius = maxSize;
    }
    if (bottomLeftRadius > maxSize) {
      bottomLeftRadius = maxSize;
    }
    if (bottomRightRadius > maxSize) {
      bottomRightRadius = maxSize;
    }

    path.moveTo(left + topLeftRadius, top);
    path.lineTo(right - topRightRadius, top);


    double arc = topRightRadius > 0 ? 90 : -270;
    /*
    path.arcTo(
        Rect.fromLTRB(right - topRightRadius * 2.0, top, right,
            top + topRightRadius * 2.0),
        radians(-90),
        radians(arc),
        false);
    */
    path.cubicTo(right-topRightRadius*(1-magicC), top, right, top+topRightRadius*(1-magicC), right, top+topRightRadius);

    path.lineTo(right, bottom - bottomRightRadius);
    arc = bottomRightRadius > 0 ? 90 : -270;
    path.arcTo(
        Rect.fromLTRB(right - bottomRightRadius * 2.0,
            bottom - bottomRightRadius * 2.0, right, bottom),
        0,
        radians(arc),
        false);

    path.lineTo(left + bottomLeftRadius, bottom);

    arc = bottomLeftRadius > 0 ? 90 : -270;
    path.arcTo(
        Rect.fromLTRB(left, bottom - bottomLeftRadius * 2.0,
            left + bottomLeftRadius * 2.0, bottom),
        radians(90),
        radians(arc),
        false);

    path.lineTo(left, top + topLeftRadius);

    arc = topLeftRadius > 0 ? 90 : -270;
    path.arcTo(
        Rect.fromLTRB(
            left, top, left + topLeftRadius * 2.0, top + topLeftRadius * 2.0),
        radians(180),
        radians(arc),
        false);

    path.close();

    return path;
  }
}
