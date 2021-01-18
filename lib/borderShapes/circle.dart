import 'package:flutter/material.dart';

import '../MorphableShapeBorder.dart';
import 'dart:math';

class CircleShape extends Shape {
  const CircleShape();

  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst={"name": this.runtimeType};
    return rst;
  }

  CircleShape.fromJson(Map<String, dynamic> map);

  DynamicPath generateDynamicPath(Rect rect) {
    final size = rect.size;

    List<DynamicNode> nodes = [];

    addBezier(nodes, arcToCubicBezier(Rect.fromCenter(
      center: Offset(rect.width / 2.0, rect.height / 2.0),
      width: rect.width,
      height: rect.height,
    ), 0, 2.0*pi));

    return DynamicPath(nodes: nodes, size: size);
  }


  Path generatePath({double scale=1, Rect rect= const Rect.fromLTRB(0.0, 0.0, 0.0, 0.0)}) {
    return Path()
      ..addOval(Rect.fromCenter(
        center: Offset(rect.width / 2.0, rect.height / 2.0),
        width: rect.width,
        height: rect.height,
      ));
  }
}

