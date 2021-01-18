import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_class_parser/toJson.dart';

import '../MorphableShapeBorder.dart';

class CutCornerShape extends Shape {
  final BorderRadius borderRadius;

  const CutCornerShape({this.borderRadius=const BorderRadius.all(Radius.zero)});

  CutCornerShape.fromJson(Map<String, dynamic> map)
      : borderRadius = parseBorderRadius(map["borderRadius"])??BorderRadius.zero;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst={"name": this.runtimeType};
    rst["borderRadius"]=borderRadius.toJson();
    return rst;
  }

  DynamicPath generateDynamicPath(Rect rect) {
    final size = rect.size;

    List<DynamicNode> nodes = [];

    final topLeftDiameter = max(borderRadius.topLeft.x, 0);
    final topRightDiameter = max(borderRadius.topRight.x, 0);
    final bottomLeftDiameter = max(borderRadius.bottomLeft.x, 0);
    final bottomRightDiameter = max(borderRadius.bottomRight.x, 0);

    nodes.add(DynamicNode(position: Offset(rect.left + topLeftDiameter, rect.top)));
    nodes.add(DynamicNode(position: Offset(rect.right - topRightDiameter, rect.top)));
    nodes.add(DynamicNode(position: Offset(rect.right, rect.top + topRightDiameter)));
    nodes.add(DynamicNode(position: Offset(rect.right, rect.bottom - bottomRightDiameter)));
    nodes.add(DynamicNode(position: Offset(rect.right - bottomRightDiameter, rect.bottom)));
    nodes.add(DynamicNode(position: Offset(rect.left + bottomLeftDiameter, rect.bottom)));
    nodes.add(DynamicNode(position: Offset(rect.left, rect.bottom - bottomLeftDiameter)));
    nodes.add(DynamicNode(position: Offset(rect.left, rect.top + topLeftDiameter)));
    nodes.add(DynamicNode(position: Offset(rect.left + topLeftDiameter, rect.top)));

    return DynamicPath(nodes: nodes, size: size);
  }

  Path generatePath({double scale=1, Rect rect= const Rect.fromLTRB(0.0, 0.0, 0.0, 0.0)}) {
    final topLeftDiameter = max(borderRadius.topLeft.x, 0);
    final topRightDiameter = max(borderRadius.topRight.x, 0);
    final bottomLeftDiameter = max(borderRadius.bottomLeft.x, 0);
    final bottomRightDiameter = max(borderRadius.bottomRight.x, 0);

    return Path()
      ..moveTo(rect.left + topLeftDiameter, rect.top)
      ..lineTo(rect.right - topRightDiameter, rect.top)
      ..lineTo(rect.right, rect.top + topRightDiameter)
      ..lineTo(rect.right, rect.bottom - bottomRightDiameter)
      ..lineTo(rect.right - bottomRightDiameter, rect.bottom)
      ..lineTo(rect.left + bottomLeftDiameter, rect.bottom)
      ..lineTo(rect.left, rect.bottom - bottomLeftDiameter)
      ..lineTo(rect.left, rect.top + topLeftDiameter)
      ..lineTo(rect.left + topLeftDiameter, rect.top)
      ..close();
  }
}
