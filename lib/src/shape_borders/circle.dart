import 'package:morphable_shape/src/common_includes.dart';

///Circle shape
class CircleShapeBorder extends OutlinedShapeBorder {
  const CircleShapeBorder({
    super.border = DynamicBorderSide.none,
  });

  CircleShapeBorder.fromJson(Map<String, dynamic> map)
      : super(
            border: parseDynamicBorderSide(map["border"]) ??
                DynamicBorderSide.none);

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst = {"type": "Circle"};
    rst.addAll(super.toJson());
    return rst;
  }

  @override
  CircleShapeBorder copyWith({
    DynamicBorderSide? border,
  }) {
    return CircleShapeBorder(
      border: border ?? this.border,
    );
  }

  @override
  bool isSameMorphGeometry(MorphableShapeBorder shape) {
    return shape is CircleShapeBorder ||
        shape is RectangleShapeBorder ||
        shape is RoundedRectangleShapeBorder;
  }

  @override
  DynamicPath generateOuterDynamicPath(Rect rect) {
    final size = rect.size;

    List<DynamicNode> nodes = [];

    nodes.addArc(
        Rect.fromCenter(
          center: Offset(rect.width / 2.0, rect.height / 2.0),
          width: rect.width,
          height: rect.height,
        ),
        -pi / 2,
        pi / 2,
        splitTimes: 1);
    nodes.addArc(
        Rect.fromCenter(
          center: Offset(rect.width / 2.0, rect.height / 2.0),
          width: rect.width,
          height: rect.height,
        ),
        0,
        pi / 2,
        splitTimes: 1);
    nodes.addArc(
        Rect.fromCenter(
          center: Offset(rect.width / 2.0, rect.height / 2.0),
          width: rect.width,
          height: rect.height,
        ),
        pi / 2,
        pi / 2,
        splitTimes: 1);
    nodes.addArc(
        Rect.fromCenter(
          center: Offset(rect.width / 2.0, rect.height / 2.0),
          width: rect.width,
          height: rect.height,
        ),
        pi,
        pi / 2,
        splitTimes: 1);

    return DynamicPath(nodes: nodes, size: size);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is CircleShapeBorder && other.border == border;
  }

  @override
  int get hashCode => border.hashCode;
}
