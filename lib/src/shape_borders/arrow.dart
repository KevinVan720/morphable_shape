import 'package:morphable_shape/src/common_includes.dart';

///An arrow shape with a head and a tail
class ArrowShapeBorder extends OutlinedShapeBorder {
  final ShapeSide side;
  final Dimension arrowHeight;
  final Dimension tailWidth;

  const ArrowShapeBorder(
      {this.side = ShapeSide.right,
      this.arrowHeight = const Length(25, unit: LengthUnit.percent),
      this.tailWidth = const Length(40, unit: LengthUnit.percent),
      super.border = DynamicBorderSide.none});

  ArrowShapeBorder.fromJson(Map<String, dynamic> map)
      : side = parseShapeSide(map["side"]) ?? ShapeSide.bottom,
        arrowHeight = parseDimension(map['arrowHeight']) ??
            const Length(25, unit: LengthUnit.percent),
        tailWidth = parseDimension(map['tailWidth']) ??
            const Length(40, unit: LengthUnit.percent),
        super(
            border: parseDynamicBorderSide(map["border"]) ??
                DynamicBorderSide.none);

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst = {"type": "Arrow"};
    rst.addAll(super.toJson());
    rst["side"] = side.toJson();
    rst["arrowHeight"] = arrowHeight.toJson();
    rst["tailWidth"] = tailWidth.toJson();
    return rst;
  }

  @override
  ArrowShapeBorder copyWith({
    ShapeSide? side,
    Dimension? arrowHeight,
    Dimension? tailWidth,
    DynamicBorderSide? border,
  }) {
    return ArrowShapeBorder(
        side: side ?? this.side,
        arrowHeight: arrowHeight ?? this.arrowHeight,
        tailWidth: tailWidth ?? this.tailWidth,
        border: border ?? this.border);
  }

  @override
  bool isSameMorphGeometry(MorphableShapeBorder shape) {
    return shape is ArrowShapeBorder && shape.side == side;
  }

  @override
  DynamicPath generateOuterDynamicPath(Rect rect) {
    List<DynamicNode> nodes = [];

    Size size = rect.size;

    double tailWidth, arrowHeight;
    if (side.isHorizontal) {
      arrowHeight =
          this.arrowHeight.toPX(constraint: size.height).clamp(0, size.height);
      tailWidth =
          this.tailWidth.toPX(constraint: size.width).clamp(0, size.width);
    } else {
      arrowHeight =
          this.arrowHeight.toPX(constraint: size.width).clamp(0, size.width);
      tailWidth =
          this.tailWidth.toPX(constraint: size.height).clamp(0, size.height);
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is ArrowShapeBorder &&
        other.border == border &&
        other.side == side &&
        other.arrowHeight == arrowHeight &&
        other.tailWidth == tailWidth;
  }

  @override
  int get hashCode => Object.hash(border, side, arrowHeight, tailWidth);
}
