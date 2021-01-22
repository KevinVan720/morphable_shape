
import 'package:flutter/material.dart';

import '../MorphableShapeBorder.dart';

class DiamondShape extends Shape {

  DiamondShape();

  DiamondShape.fromJson(Map<String, dynamic> map);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst={"name": this.runtimeType};
    return rst;
  }
  Shape copyWith() {
    return BubbleShape();
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

}
