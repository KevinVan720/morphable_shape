import 'package:morphable_shape/src/common_includes.dart';

///A Shape made from a path with straight or cubic Bezier lines
///possible for future implementation of freeform lines or import shapes from SVG
class PathShapeBorder extends OutlinedShapeBorder {
  final DynamicPath path;

  const PathShapeBorder(
      {super.border = DynamicBorderSide.none, required this.path});

  PathShapeBorder.fromJson(Map<String, dynamic> map)
      : path = parseDynamicPath(map["path"]) ??
            DynamicPath(size: Size.zero, nodes: []),
        super(
            border: parseDynamicBorderSide(map["border"]) ??
                DynamicBorderSide.none);

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst = {"type": "Path"};
    rst.addAll(super.toJson());
    rst["path"] = path.toJson();
    return rst;
  }

  @override
  PathShapeBorder copyWith({
    DynamicPath? path,
    DynamicBorderSide? border,
  }) {
    return PathShapeBorder(
        path: path ?? this.path, border: border ?? this.border);
  }

  @override
  bool isSameMorphGeometry(MorphableShapeBorder shape) {
    return shape is PathShapeBorder && path == shape.path;
  }

  @override
  DynamicPath generateOuterDynamicPath(Rect rect) {
    ///Work on a copy: measuring or painting the shape must not modify (resize
    ///or merge the nodes of) the path this shape was created with.
    DynamicPath copy = DynamicPath(size: path.size, nodes: [])
      ..nodes = [
        for (final DynamicNode node in path.nodes)
          DynamicNode(position: node.position, prev: node.prev, next: node.next)
      ];
    return copy..resize(rect.size);
  }
}
