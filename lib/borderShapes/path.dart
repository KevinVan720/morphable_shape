import 'package:flutter/material.dart';

import '../MorphableShapeBorder.dart';

///possible for future implementation of freeform shape or import shape from SVG
class PathShape extends Shape {
  final DynamicPath path;

  const PathShape({required this.path});

  ///not implemented for now
  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst = {"name": this.runtimeType};
    return rst;
  }

  PathShape copyWith({
    DynamicPath? path,
  }) {
    return PathShape(path: path ?? this.path);
  }

  DynamicPath generateDynamicPath(Rect rect) {

    return path;
  }
}
