import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart';

import '../MorphableShapeBorder.dart';

const double magicC=0.551915;

class RoundRectShape extends Shape {
  final BorderRadius borderRadius;

  RoundRectShape({
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  Shape copyWith() {
    return BubbleShape();
  }


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

    //nodes.add(DynamicNode(position: Offset(left + topLeftRadius, top)));
    nodes.add(DynamicNode(position: Offset(right - topRightRadius, top)));

    double arc = topRightRadius > 0 ? 90 : -270;
    nodes.arcTo(Rect.fromLTRB(right - topRightRadius * 2.0, top, right,
        top + topRightRadius * 2.0),
        radians(-90),
        radians(arc));

    nodes.add(DynamicNode(position: Offset(right, bottom - bottomRightRadius)));

    arc = bottomRightRadius > 0 ? 90 : -270;
    nodes.arcTo(Rect.fromLTRB(right - bottomRightRadius * 2.0,
        bottom - bottomRightRadius * 2.0, right, bottom),
        0,
        radians(arc));

    nodes.add(DynamicNode(position: Offset(left + bottomLeftRadius, bottom)));

    arc = bottomLeftRadius > 0 ? 90 : -270;

    nodes.arcTo(Rect.fromLTRB(left, bottom - bottomLeftRadius * 2.0,
        left + bottomLeftRadius * 2.0, bottom),
        radians(90),
        radians(arc));

    nodes.add(DynamicNode(position: Offset(left, top + topLeftRadius)));

    arc = topLeftRadius > 0 ? 90 : -270;
    nodes.arcTo(Rect.fromLTRB(
        left, top, left + topLeftRadius * 2.0, top + topLeftRadius * 2.0),
        radians(180),
        radians(arc));

    return DynamicPath(size: rect.size, nodes: nodes);
  }

}
