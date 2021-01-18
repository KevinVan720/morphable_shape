
import 'package:flutter/material.dart';

import '../MorphableShapeBorder.dart';

class DiamondShape extends Shape {

  const DiamondShape();

  DiamondShape.fromJson(Map<String, dynamic> map);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst={"name": this.runtimeType};
    return rst;
  }

  DynamicPath generateDynamicPath(Rect rect) {
    final size = rect.size;

    List<DynamicNode> nodes = [];

    final width = rect.width;
    final height = rect.height;

    nodes.add(DynamicNode(position: Offset(width/2, 0)));
    nodes.add(DynamicNode(position: Offset(width, height/2)));
    nodes.add(DynamicNode(position: Offset(width/2, height)));
    nodes.add(DynamicNode(position: Offset(0, height/2)));

    return DynamicPath(nodes: nodes, size: size);
  }

  Path generatePath({double scale=1, Rect rect= const Rect.fromLTRB(0.0, 0.0, 0.0, 0.0)}) {

    Size size=rect.size;

    final Path path = new Path();
    path.moveTo(size.width/2, 0);
    path.lineTo(size.width, size.height/2);
    path.lineTo(size.width/2, size.height);
    path.lineTo(0, size.height/2);
    path.close();

    return path;
  }
}
