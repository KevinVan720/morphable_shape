import 'package:flutter/material.dart';
import 'package:morphable_shape/morphable_shape.dart';

///A Shape made from a path with straight or cubic Bezier lines
///possible for future implementation of freeform lines or import shapes from SVG
class PathShapeBorder extends OutlinedShapeBorder {
  final DynamicPath path;

  const PathShapeBorder(
      {DynamicBorderSide border = DynamicBorderSide.none, required this.path})
      : super(border: border);

  PathShapeBorder.fromJson(Map<String, dynamic> map)
      : path = parseDynamicPath(map["path"]) ??
            DynamicPath(size: Size.zero, nodes: []),
        super(
            border: parseDynamicBorderSide(map["border"]) ??
                DynamicBorderSide.none);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst = {"type": "Path"};
    rst.addAll(super.toJson());
    rst["path"] = path.toJson();
    return rst;
  }

  PathShapeBorder copyWith({
    DynamicPath? path,
    DynamicBorderSide? border,
  }) {
    return PathShapeBorder(
        path: path ?? this.path, border: border ?? this.border);
  }

  bool isSameMorphGeometry(MorphableShapeBorder shape) {
    return shape is PathShapeBorder && this.path == shape.path;
  }

  DynamicPath generateOuterDynamicPath(Rect rect) {
    return path..resize(rect.size);
  }
}
