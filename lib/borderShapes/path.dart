
import 'package:flutter/material.dart';

import '../MorphableShapeBorder.dart';

///possible for future implementation of freeform shape or import shape from SVG
class PathShape extends Shape {
  final DynamicPath path;

  const PathShape({required this.path});

  ///not implemented for now
  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst={"name": this.runtimeType};
    return rst;
  }

  DynamicPath generateDynamicPath(Rect rect) {
    return DynamicPath(size: rect.size, nodes: []);
  }

  Path generatePath({Rect rect= const Rect.fromLTRB(0.0, 0.0, 0.0, 0.0)}) {

    final Path path =this.path.getPath(rect.size);

    return path;
  }
}