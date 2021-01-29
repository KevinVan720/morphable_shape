import 'package:flutter/material.dart';

import '../morphable_shape_border.dart';

class CutCornerShape extends Shape {
  final DynamicBorderRadius borderRadius;

  const CutCornerShape(
      {this.borderRadius = const DynamicBorderRadius.all(DynamicRadius.circular(Length(10, unit: LengthUnit.percent)))});

  CutCornerShape copyWith({DynamicBorderRadius? borderRadius}) {
    return CutCornerShape(borderRadius: borderRadius ?? this.borderRadius);
  }

  CutCornerShape.fromJson(Map<String, dynamic> map)
      : borderRadius = parseDynamicBorderRadius(map["borderRadius"])??DynamicBorderRadius.all(DynamicRadius.zero);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst = {"name": this.runtimeType.toString()};
    rst["borderRadius"]=borderRadius.toJson();
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

    return DynamicPath(nodes: nodes, size: size);
  }
}
