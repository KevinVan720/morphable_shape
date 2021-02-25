import 'package:flutter/material.dart';
import 'package:morphable_shape/morphable_shape.dart';

///An arrow shape with a head and a tail

class ArrowShape extends OutlinedShape {
  final ShapeSide side;
  final Length arrowHeight;
  final Length tailWidth;

  const ArrowShape(
      {this.side = ShapeSide.right,
      this.arrowHeight = const Length(25, unit: LengthUnit.percent),
      this.tailWidth = const Length(40, unit: LengthUnit.percent),
      DynamicBorderSide border = DynamicBorderSide.none})
      : super(border: border);

  ArrowShape.fromJson(Map<String, dynamic> map)
      : side = parseShapeSide(map["side"]) ?? ShapeSide.bottom,
        arrowHeight = Length.fromJson(map['arrowHeight']) ??
            Length(25, unit: LengthUnit.percent),
        tailWidth = Length.fromJson(map['tailWidth']) ??
            Length(40, unit: LengthUnit.percent),
        super(
            border: parseDynamicBorderSide(map["border"]) ??
                DynamicBorderSide.none);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst = {"type": "ArrowShape"};
    rst.addAll(super.toJson());
    rst["side"] = side.toJson();
    rst["arrowHeight"] = arrowHeight.toJson();
    rst["tailWidth"] = tailWidth.toJson();
    return rst;
  }

  ArrowShape copyWith({
    ShapeSide? side,
    Length? arrowHeight,
    Length? tailWidth,
    DynamicBorderSide? border,
  }) {
    return ArrowShape(
        side: side ?? this.side,
        arrowHeight: arrowHeight ?? this.arrowHeight,
        tailWidth: tailWidth ?? this.tailWidth,
        border: border ?? this.border);
  }

  DynamicPath generateOuterDynamicPath(Rect rect) {
    List<DynamicNode> nodes = [];

    Size size = rect.size;

    double tailWidth, arrowHeight;
    if (side.isHorizontal) {
      arrowHeight = this
          .arrowHeight
          .toPX(constraint: size.height)
          .clamp(0, size.height);
      tailWidth =
          this.tailWidth.toPX(constraint: size.width).clamp(0, size.width);
    } else {
      arrowHeight = this
          .arrowHeight
          .toPX(constraint: size.width)
          .clamp(0, size.width);
      tailWidth = this
          .tailWidth
          .toPX(constraint: size.height)
          .clamp(0, size.height);
    }

    switch (side) {
      case ShapeSide.top:
        {
          nodes.add(DynamicNode(position: Offset(size.width / 2, 0)));
          nodes.add(DynamicNode(position: Offset(size.width, arrowHeight)));
          nodes.add(DynamicNode(
              position: Offset(size.width / 2 + tailWidth / 2, arrowHeight)));
          nodes.add(DynamicNode(
              position: Offset(size.width / 2 + tailWidth / 2, size.height)));
          nodes.add(DynamicNode(
              position: Offset(size.width / 2 - tailWidth / 2, size.height)));
          nodes.add(DynamicNode(
              position: Offset(size.width / 2 - tailWidth / 2, arrowHeight)));
          nodes.add(DynamicNode(position: Offset(0, arrowHeight)));
        }
        break;
      case ShapeSide.bottom:
        {
          nodes.add(DynamicNode(position: Offset(size.width / 2, size.height)));
          nodes
              .add(DynamicNode(position: Offset(0, size.height - arrowHeight)));
          nodes.add(DynamicNode(
              position: Offset(
                  size.width / 2 - tailWidth / 2, size.height - arrowHeight)));
          nodes.add(
              DynamicNode(position: Offset(size.width / 2 - tailWidth / 2, 0)));
          nodes.add(
              DynamicNode(position: Offset(size.width / 2 + tailWidth / 2, 0)));
          nodes.add(DynamicNode(
              position: Offset(
                  size.width / 2 + tailWidth / 2, size.height - arrowHeight)));
          nodes.add(DynamicNode(
              position: Offset(size.width, size.height - arrowHeight)));
        }
        break;
      case ShapeSide.left:
        {
          nodes.add(DynamicNode(position: Offset(0, size.height / 2)));
          nodes.add(DynamicNode(position: Offset(arrowHeight, 0)));
          nodes.add(DynamicNode(
              position: Offset(arrowHeight, size.height / 2 - tailWidth / 2)));
          nodes.add(DynamicNode(
              position: Offset(size.width, size.height / 2 - tailWidth / 2)));
          nodes.add(DynamicNode(
              position: Offset(size.width, size.height / 2 + tailWidth / 2)));
          nodes.add(DynamicNode(
              position: Offset(arrowHeight, size.height / 2 + tailWidth / 2)));
          nodes.add(DynamicNode(position: Offset(arrowHeight, size.height)));
        }
        break;
      case ShapeSide.right:
        {
          nodes.add(DynamicNode(position: Offset(size.width, size.height / 2)));
          nodes.add(DynamicNode(
              position: Offset(size.width - arrowHeight, size.height)));
          nodes.add(DynamicNode(
              position: Offset(
                  size.width - arrowHeight, size.height / 2 + tailWidth / 2)));
          nodes.add(DynamicNode(
              position: Offset(0, size.height / 2 + tailWidth / 2)));
          nodes.add(DynamicNode(
              position: Offset(0, size.height / 2 - tailWidth / 2)));
          nodes.add(DynamicNode(
              position: Offset(
                  size.width - arrowHeight, size.height / 2 - tailWidth / 2)));
          nodes.add(DynamicNode(position: Offset(size.width - arrowHeight, 0)));
        }

        break;
    }

    return DynamicPath(size: rect.size, nodes: nodes);
  }
}
