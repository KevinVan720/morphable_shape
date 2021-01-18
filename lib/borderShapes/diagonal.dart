
import 'package:flutter/material.dart';

import '../MorphableShapeBorder.dart';


class DiagonalShape extends Shape {
  final AxisDirection position;
  final double inset;
  final bool insetClockwise;

  const DiagonalShape({
    this.position = AxisDirection.down,
    this.inset = 10,
    this.insetClockwise = true,
  });

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

  Path generatePath(
      {double scale = 1, Rect rect = const Rect.fromLTRB(0.0, 0.0, 0.0, 0.0)}) {
    final Path path = Path();

    final width = rect.width;
    final height = rect.height;

    switch (this.position) {
      case AxisDirection.down:
        path.lineTo(width, 0);
        path.lineTo(width, height - (insetClockwise ? inset : 0));
        path.lineTo(0, height - (insetClockwise ? 0 : inset));
        path.close();
        break;
      case AxisDirection.up:
        path.moveTo(0, (insetClockwise ? inset : 0));
        path.lineTo(0, height - (insetClockwise ? 0 : inset));
        path.lineTo(width, height);
        path.lineTo(0, height);
        path.close();
        break;
      case AxisDirection.left:
        path.moveTo((insetClockwise ? 0 : inset), 0);
        path.lineTo(width, 0);
        path.lineTo(width, height);
        path.lineTo((insetClockwise ? inset : 0), height);
        path.close();
        break;
      case AxisDirection.right:
        path.lineTo((insetClockwise ? inset : 0), 0);
        path.lineTo((insetClockwise ? 0 : inset), height);
        path.lineTo(0, height);
        path.close();
        break;
    }
    return path;
  }
}
