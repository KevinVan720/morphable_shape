import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_class_parser/toJson.dart';

import '../MorphableShapeBorder.dart';

class CutCornerShape extends Shape {
  DynamicBorderRadius borderRadius;

  CutCornerShape(
      {this.borderRadius = const DynamicBorderRadius.all(DynamicRadius.zero)});

  Shape copyWith({DynamicBorderRadius? borderRadius}) {
    return CutCornerShape(borderRadius: borderRadius ?? this.borderRadius);
  }

  CutCornerShape.fromJson(Map<String, dynamic> map)
      : borderRadius = DynamicBorderRadius.all(DynamicRadius.zero);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst = {"name": this.runtimeType};

    return rst;
  }

  DynamicPath generateDynamicPath(Rect rect) {
    final size = rect.size;

    List<DynamicNode> nodes = [];

    BorderRadius borderRadius = this.borderRadius.toBorderRadius(size);

    final topLeftRadius = borderRadius.topLeft.x.clamp(0, size.width / 2);
    final topRightRadius = borderRadius.topRight.x.clamp(0, size.width / 2);
    final bottomLeftRadius = borderRadius.bottomLeft.x.clamp(0, size.width / 2);
    final bottomRightRadius =
        borderRadius.bottomRight.x.clamp(0, size.width / 2);

    final leftTopRadius = borderRadius.topLeft.y.clamp(0, size.height / 2);
    final rightTopRadius = borderRadius.topRight.y.clamp(0, size.height / 2);
    final leftBottomRadius =
        borderRadius.bottomLeft.y.clamp(0, size.height / 2);
    final rightBottomRadius =
        borderRadius.bottomRight.y.clamp(0, size.height / 2);

    nodes.add(
        DynamicNode(position: Offset(rect.left + topLeftRadius, rect.top)));
    nodes.add(
        DynamicNode(position: Offset(rect.right - topRightRadius, rect.top)));
    nodes.add(
        DynamicNode(position: Offset(rect.right, rect.top + rightTopRadius)));
    nodes.add(DynamicNode(
        position: Offset(rect.right, rect.bottom - rightBottomRadius)));
    nodes.add(DynamicNode(
        position: Offset(rect.right - bottomRightRadius, rect.bottom)));
    nodes.add(DynamicNode(
        position: Offset(rect.left + bottomLeftRadius, rect.bottom)));
    nodes.add(DynamicNode(
        position: Offset(rect.left, rect.bottom - leftBottomRadius)));
    nodes.add(
        DynamicNode(position: Offset(rect.left, rect.top + leftTopRadius)));
    nodes.add(
        DynamicNode(position: Offset(rect.left + topLeftRadius, rect.top)));

    return DynamicPath(nodes: nodes, size: size);
  }
}
