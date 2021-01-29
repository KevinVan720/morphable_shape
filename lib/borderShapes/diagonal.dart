import 'package:flutter/material.dart';
import 'package:morphable_shape/shape_utils.dart';

import '../morphable_shape_border.dart';

class DiagonalShape extends Shape {
  final ShapeCorner corner;
  final Length inset;

  const DiagonalShape({
    this.corner=ShapeCorner.bottomRight,
    this.inset = const Length(10, unit: LengthUnit.percent),
  });

  DiagonalShape copyWith({
  ShapeCorner? corner,
    Length? inset,
}) {
    return DiagonalShape(
      corner: corner?? this.corner,
      inset: inset??this.inset,
    );
  }


  DiagonalShape.fromJson(Map<String, dynamic> map)
      : corner=parseShapeCorner(map["corner"])??ShapeCorner.bottomRight,
        inset = Length.fromJson(map["inset"])??Length(10);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst = {"name": this.runtimeType.toString()};
    rst["inset"] = inset.toJson();
    rst["corner"] = corner.toJson();
    return rst;
  }

  DynamicPath generateDynamicPath(Rect rect) {
    final size = rect.size;

    List<DynamicNode> nodes = [];

    final width = rect.width;
    final height = rect.height;

    double inset;
    if(corner.isHorizontal) {
      inset=this.inset.toPX(constraintSize: height).clamp(0, height);
    }else{
      inset=this.inset.toPX(constraintSize: width).clamp(0, width);
    }

    switch (this.corner) {
      case ShapeCorner.bottomRight:
        nodes.add(DynamicNode(position: Offset(0,0)));
        nodes.add(DynamicNode(position: Offset(width, 0)));
        nodes.add(DynamicNode(position: Offset(width, height - inset)));
        nodes.add(DynamicNode(position: Offset(0, height)));
        break;
      case ShapeCorner.bottomLeft:
        nodes.add(DynamicNode(position: Offset(0,0)));
        nodes.add(DynamicNode(position: Offset(width, 0)));
        nodes.add(DynamicNode(position: Offset(width, height)));
        nodes.add(DynamicNode(position: Offset(0, height-inset)));
        break;
      case ShapeCorner.topLeft:
        nodes.add(DynamicNode(position: Offset(0, inset)));
        nodes.add(DynamicNode(position: Offset(width, 0)));
        nodes.add(DynamicNode(position: Offset(width, height)));
        nodes.add(DynamicNode(position: Offset(0, height)));
        break;
      case ShapeCorner.topRight:
        nodes.add(DynamicNode(position: Offset(0, 0)));
        nodes.add(DynamicNode(position: Offset(width, inset)));
        nodes.add(DynamicNode(position: Offset(width, height)));
        nodes.add(DynamicNode(position: Offset(0, height)));
        break;
      case ShapeCorner.leftTop:
        nodes.add(DynamicNode(position: Offset( inset, 0)));
        nodes.add(DynamicNode(position: Offset(width, 0)));
        nodes.add(DynamicNode(position: Offset(width, height)));
        nodes.add(DynamicNode(position: Offset(0, height)));
        break;
      case ShapeCorner.leftBottom:
        nodes.add(DynamicNode(position: Offset(0, 0)));
        nodes.add(DynamicNode(position: Offset(width, 0)));
        nodes.add(DynamicNode(position: Offset(width, height)));
        nodes.add(DynamicNode(position: Offset(inset, height)));
        break;
      case ShapeCorner.rightTop:
        nodes.add(DynamicNode(position: Offset(0, 0)));
        nodes.add(DynamicNode(position: Offset(width-inset, 0)));
        nodes.add(DynamicNode(position: Offset(width, height)));
        nodes.add(DynamicNode(position: Offset(0, height)));
        break;
      case ShapeCorner.rightBottom:
        nodes.add(DynamicNode(position: Offset(0, 0)));
        nodes.add(DynamicNode(position: Offset(width, 0)));
        nodes.add(DynamicNode(position: Offset(width-inset, height)));
        nodes.add(DynamicNode(position: Offset(inset, height)));
        break;
    }

    return DynamicPath(nodes: nodes, size: size);
  }

  @override
  int get hashCode =>
      hashValues(corner, inset);

  @override
  bool operator ==(dynamic other) {
    if (runtimeType != other.runtimeType) return false;
    final DiagonalShape otherShape = other;
    return corner == otherShape.corner &&
        inset == otherShape.inset;
  }


}
