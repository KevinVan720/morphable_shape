import 'package:flutter/material.dart';

import '../morphable_shape_border.dart';

///A Shape made from a path with straight or cubic Bezier lines
///possible for future implementation of freeform lines or import shapes from SVG
class PathShape extends OutlinedShape {
  final DynamicPath path;

  const PathShape(
      {DynamicBorderSide border = DynamicBorderSide.none, required this.path})
      : super(border: border);

  PathShape.fromJson(Map<String, dynamic> map)
      : path = parseDynamicPath(map["path"]) ??
            DynamicPath(size: Size.zero, nodes: []);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst = {"type": "PathShape"};
    rst["path"] = path.toJson();
    return rst;
  }

  PathShape copyWith({
    DynamicPath? path,
    DynamicBorderSide? border,
  }) {
    return PathShape(path: path ?? this.path, border: border ?? this.border);
  }

  DynamicPath generateOuterDynamicPath(Rect rect) {
    return path;
  }
}
