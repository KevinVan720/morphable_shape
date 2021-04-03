import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:morphable_shape/morphable_shape.dart';

///triangle shape defined by the three vertices
class TriangleShapeBorder extends OutlinedShapeBorder {
  final DynamicOffset point1;
  final DynamicOffset point2;
  final DynamicOffset point3;

  const TriangleShapeBorder(
      {this.point1 = const DynamicOffset(
          const Length(0, unit: LengthUnit.percent),
          const Length(0, unit: LengthUnit.percent)),
      this.point2 = const DynamicOffset(
          const Length(100, unit: LengthUnit.percent),
          const Length(0, unit: LengthUnit.percent)),
      this.point3 = const DynamicOffset(
          const Length(50, unit: LengthUnit.percent),
          const Length(100, unit: LengthUnit.percent)),
      DynamicBorderSide border = DynamicBorderSide.none})
      : super(border: border);

  TriangleShapeBorder.fromJson(Map<String, dynamic> map)
      : point1 = parseDynamicOffset(map["point1"]) ??
            DynamicOffset(const Length(0, unit: LengthUnit.percent),
                const Length(0, unit: LengthUnit.percent)),
        point2 = parseDynamicOffset(map["point2"]) ??
            DynamicOffset(const Length(100, unit: LengthUnit.percent),
                const Length(0, unit: LengthUnit.percent)),
        point3 = parseDynamicOffset(map["point3"]) ??
            DynamicOffset(const Length(50, unit: LengthUnit.percent),
                const Length(100, unit: LengthUnit.percent)),
        super(
            border: parseDynamicBorderSide(map["border"]) ??
                DynamicBorderSide.none);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst = {"type": "Triangle"};
    rst.addAll(super.toJson());
    rst["point1"] = point1.toJson();
    rst["point2"] = point2.toJson();
    rst["point3"] = point3.toJson();
    return rst;
  }

  TriangleShapeBorder copyWith({
    DynamicOffset? point1,
    DynamicOffset? point2,
    DynamicOffset? point3,
    DynamicBorderSide? border,
  }) {
    return TriangleShapeBorder(
      point1: point1 ?? this.point1,
      point2: point2 ?? this.point2,
      point3: point3 ?? this.point3,
      border: border ?? this.border,
    );
  }

  bool isSameMorphGeometry(MorphableShapeBorder shape) {
    return shape is TriangleShapeBorder;
  }

  DynamicPath generateOuterDynamicPath(Rect rect) {
    List<DynamicNode> nodes = [];

    Size size = rect.size;
    final width = rect.width;
    final height = rect.height;

    Offset point3 = this
        .point3
        .toOffset(size: size)
        .clamp(Offset.zero, Offset(width, height));
    Offset point2 = this
        .point2
        .toOffset(size: size)
        .clamp(Offset.zero, Offset(width, height));
    Offset point1 = this
        .point1
        .toOffset(size: size)
        .clamp(Offset.zero, Offset(width, height));

    Offset center = (point1 + point2 + point3) / 3;

    List<Offset> points = [
      point1,
      point2,
      point3
    ]..sort((a, b) => (a - center).direction.compareTo((b - center).direction));

    points.forEach((element) {
      nodes.add(DynamicNode(position: element));
    });

    return DynamicPath(size: rect.size, nodes: nodes);
  }
}
