import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart';

import '../morphable_shape_border.dart';

const double magicC = 0.551915;

class RoundRectShape extends Shape {
  final DynamicBorderRadius borderRadius;

  const RoundRectShape({
    this.borderRadius =
        const DynamicBorderRadius.all(DynamicRadius.circular(Length(0))),
  });

  RoundRectShape copyWith({DynamicBorderRadius? borderRadius}) {
    return RoundRectShape(borderRadius: borderRadius ?? this.borderRadius);
  }

  RoundRectShape.fromJson(Map<String, dynamic> map)
      : borderRadius = parseDynamicBorderRadius(map["borderRadius"]) ??
            DynamicBorderRadius.all(DynamicRadius.circular(Length(0)));

  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst = {"name": this.runtimeType.toString()};
    rst["borderRadius"] = borderRadius.toJson();
    return rst;
  }

  DynamicPath generateDynamicPath(Rect rect) {
    Size size = rect.size;
    List<DynamicNode> nodes = [];

    final double left = rect.left;
    final double top = rect.top;
    final double bottom = rect.bottom;
    final double right = rect.right;

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

    nodes.add(DynamicNode(position: Offset(right - topRightRadius, top)));

    double arc = 90;
    nodes.arcTo(
        Rect.fromLTRB(right - topRightRadius * 2.0, top, right,
            top + rightTopRadius * 2.0),
        radians(-90),
        radians(arc));

    nodes.add(DynamicNode(position: Offset(right, bottom - rightBottomRadius)));

    nodes.arcTo(
        Rect.fromLTRB(right - bottomRightRadius * 2.0,
            bottom - rightBottomRadius * 2.0, right, bottom),
        0,
        radians(arc));

    nodes.add(DynamicNode(position: Offset(left + bottomLeftRadius, bottom)));

    nodes.arcTo(
        Rect.fromLTRB(left, bottom - leftBottomRadius * 2.0,
            left + bottomLeftRadius * 2.0, bottom),
        radians(90),
        radians(arc));

    nodes.add(DynamicNode(position: Offset(left, top + leftTopRadius)));

    nodes.arcTo(
        Rect.fromLTRB(
            left, top, left + topLeftRadius * 2.0, top + leftTopRadius * 2.0),
        radians(180),
        radians(arc));

    return DynamicPath(size: rect.size, nodes: nodes);
  }
}
