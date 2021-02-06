import 'package:flutter/material.dart';

import '../morphable_shape_border.dart';

///A trapezoid shape, can be achieved from a rectangle
///may remove in the future
class TrapezoidShape extends Shape {
  final ShapeSide side;
  final Length inset;

  const TrapezoidShape(
      {this.side = ShapeSide.bottom,
      this.inset = const Length(20, unit: LengthUnit.percent)});

  Shape copyWith({
    ShapeSide? side,
    Length? inset,
  }) {
    return TrapezoidShape(
      side: side ?? this.side,
      inset: inset ?? this.inset,
    );
  }

  TrapezoidShape.fromJson(Map<String, dynamic> map)
      : side = parseShapeSide(map["side"]) ?? ShapeSide.bottom,
        inset = Length.fromJson(map['inset']) ??
            Length(20, unit: LengthUnit.percent);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst = {"name": "TrapezoidShape"};
    rst["inset"] = inset.toJson();
    rst["side"] = side.toJson();
    return rst;
  }

  DynamicPath generateDynamicPath(Rect rect) {
    List<DynamicNode> nodes = [];

    Size size = rect.size;

    double inset;
    if (side.isHorizontal) {
      inset =
          this.inset.toPX(constraintSize: size.width).clamp(0, size.width / 2);
    } else {
      inset = this
          .inset
          .toPX(constraintSize: size.height)
          .clamp(0, size.height / 2);
    }

    switch (side) {
      case ShapeSide.top:
        {
          nodes.add(DynamicNode(position: Offset(0, 0)));
          nodes.add(DynamicNode(position: Offset(size.width, 0)));
          nodes.add(DynamicNode(
              position: Offset(size.width * (1 - inset / 2), size.height)));
          nodes.add(DynamicNode(
              position: Offset(size.width * (inset / 2), size.height)));
        }
        break;
      case ShapeSide.bottom:
        {
          nodes.add(DynamicNode(position: Offset(0, 0)));
          nodes.add(DynamicNode(position: Offset(size.width, 0)));
          nodes.add(
              DynamicNode(position: Offset(size.width - inset, size.height)));
          nodes.add(DynamicNode(position: Offset(inset, size.height)));
        }
        break;
      case ShapeSide.left:
        {
          nodes.add(DynamicNode(position: Offset(0, inset)));
          nodes.add(DynamicNode(position: Offset(size.width, 0)));
          nodes.add(DynamicNode(position: Offset(size.width, size.height)));
          nodes.add(DynamicNode(position: Offset(0, size.height - inset)));
        }
        break;
      case ShapeSide.right:
        {
          nodes.add(DynamicNode(position: Offset(0, 0)));
          nodes.add(DynamicNode(position: Offset(size.width, inset)));
          nodes.add(
              DynamicNode(position: Offset(size.width, size.height - inset)));
          nodes.add(DynamicNode(position: Offset(0, size.height)));
        }
        break;
    }

    return DynamicPath(size: size, nodes: nodes);
  }
}
