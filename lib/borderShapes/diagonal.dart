
import 'package:flutter/material.dart';

import '../MorphableShapeBorder.dart';


class DiagonalShape extends Shape {
  final AxisDirection position;
  final double inset;
  final bool insetClockwise;

  DiagonalShape({
    this.position = AxisDirection.down,
    this.inset = 10,
    this.insetClockwise = true,
  });

  Shape copyWith() {
    return BubbleShape();
  }


  DiagonalShape.fromJson(Map<String, dynamic> map)
      : position = parseAxisDirection(map["position"]) ?? AxisDirection.down,
        inset = map["inset"],
        insetClockwise = map["insetClockwise"];

  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst = {"name": this.runtimeType};
    rst["position"] = position.toJson();
    rst["inset"] = inset;
    rst["insetClockwise"] = insetClockwise;
    return rst;
  }

  DynamicPath generateDynamicPath(Rect rect) {
    final size = rect.size;

    List<DynamicNode> nodes = [];

    final width = rect.width;
    final height = rect.height;

    switch (this.position) {
      case AxisDirection.down:
        nodes.add(DynamicNode(position: Offset(0,0)));
        nodes.add(DynamicNode(position: Offset(width, 0)));
        nodes.add(DynamicNode(position: Offset(width, height - (insetClockwise ? inset : 0))));
        nodes.add(DynamicNode(position: Offset(0, height - (insetClockwise ? 0 : inset))));
        break;
      case AxisDirection.up:
        nodes.add(DynamicNode(position: Offset(0, (insetClockwise ? inset : 0))));
        nodes.add(DynamicNode(position: Offset(0, height - (insetClockwise ? 0 : inset))));
        nodes.add(DynamicNode(position: Offset(width, height)));
        nodes.add(DynamicNode(position: Offset(0, height)));
        break;
      case AxisDirection.left:
        nodes.add(DynamicNode(position: Offset((insetClockwise ? 0 : inset), 0)));
        nodes.add(DynamicNode(position: Offset(width, 0)));
        nodes.add(DynamicNode(position: Offset(width, height)));
        nodes.add(DynamicNode(position: Offset((insetClockwise ? inset : 0), height)));
        break;
      case AxisDirection.right:
        nodes.add(DynamicNode(position: Offset((insetClockwise ? inset : 0), 0)));
        nodes.add(DynamicNode(position: Offset((insetClockwise ? 0 : inset), height)));
        nodes.add(DynamicNode(position: Offset(0, height)));
        nodes.add(DynamicNode(position: Offset(0,0)));
        break;
    }

    return DynamicPath(nodes: nodes, size: size);
  }

}
