import 'package:flutter/material.dart';

import '../morphable_shape_border.dart';

///possible for future implementation of freeform shape or import shape from SVG
class PathShape extends Shape {
  final DynamicPath path;

  const PathShape({required this.path});

  PathShape.fromJson(Map<String, dynamic> map)
      : path = parseDynamicPath(map["path"]) ??
            DynamicPath(size: Size.zero, nodes: []);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst = {"name": this.runtimeType.toString()};
    rst["path"] = path.toJson();
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
