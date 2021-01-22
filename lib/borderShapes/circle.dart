import 'package:flutter/material.dart';

import '../MorphableShapeBorder.dart';
import 'dart:math';

class CircleShape extends Shape {
  const CircleShape();

  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst={"name": this.runtimeType};
    return rst;
  }

  CircleShape copyWith() {
    return CircleShape();
  }


  CircleShape.fromJson(Map<String, dynamic> map);

  DynamicPath generateDynamicPath(Rect rect) {
    final size = rect.size;

    List<DynamicNode> nodes = [];

    nodes.add(DynamicNode(position: Offset(size.width, size.height/2)));
    nodes.arcTo(Rect.fromCenter(
      center: Offset(rect.width / 2.0, rect.height / 2.0),
      width: rect.width,
      height: rect.height,
    ), 0, 2.0*pi);

    return DynamicPath(nodes: nodes, size: size);
  }

}

