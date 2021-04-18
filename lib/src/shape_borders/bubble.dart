import 'package:morphable_shape/src/common_includes.dart';

///Bubble shape, with a triangular tip and equal radius rounded corner
///The corner parameter is where the tip calculates its positions
class BubbleShapeBorder extends OutlinedShapeBorder {
  final ShapeSide side;

  final Dimension borderRadius;
  final Dimension arrowHeight;
  final Dimension arrowWidth;

  ///arrow position is calculated from the left (if at top or bottom)
  ///or from the top (if at left or right)
  ///if you want to calculate from the other side, you can use for example
  ///100.toPercentLength-10.toPXLength
  final Dimension arrowCenterPosition;
  final Dimension arrowHeadPosition;

  const BubbleShapeBorder({
    DynamicBorderSide border = DynamicBorderSide.none,
    this.side = ShapeSide.bottom,
    this.borderRadius = const Length(6),
    this.arrowHeight = const Length(20, unit: LengthUnit.percent),
    this.arrowWidth = const Length(30, unit: LengthUnit.percent),
    this.arrowCenterPosition = const Length(50, unit: LengthUnit.percent),
    this.arrowHeadPosition = const Length(50, unit: LengthUnit.percent),
  }) : super(border: border);

  BubbleShapeBorder.fromJson(Map<String, dynamic> map)
      : side = parseShapeSide(map["side"]) ?? ShapeSide.bottom,
        borderRadius = parseDimension(map["borderRadius"]) ?? Length(6),
        arrowHeight =
            parseDimension(map["arrowHeight"]) ?? 20.0.toPercentLength,
        arrowWidth = parseDimension(map["arrowWidth"]) ?? 30.0.toPercentLength,
        arrowCenterPosition =
            parseDimension(map["arrowCenterPosition"]) ?? 50.0.toPercentLength,
        arrowHeadPosition =
            parseDimension(map["arrowHeadPosition"]) ?? 50.0.toPercentLength,
        super(
            border: parseDynamicBorderSide(map["border"]) ??
                DynamicBorderSide.none);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst = {"type": "Bubble"};
    rst.addAll(super.toJson());
    rst["side"] = side.toJson();
    rst["borderRadius"] = borderRadius.toJson();
    rst["arrowHeight"] = arrowHeight.toJson();
    rst["arrowWidth"] = arrowWidth.toJson();
    rst["arrowCenterPosition"] = arrowCenterPosition.toJson();
    rst["arrowHeadPosition"] = arrowHeadPosition.toJson();

    return rst;
  }

  BubbleShapeBorder copyWith({
    ShapeSide? side,
    Dimension? borderRadius,
    Dimension? arrowHeight,
    Dimension? arrowWidth,
    Dimension? arrowCenterPosition,
    Dimension? arrowHeadPosition,
    DynamicBorderSide? border,
  }) {
    return BubbleShapeBorder(
      border: border ?? this.border,
      side: side ?? this.side,
      borderRadius: borderRadius ?? this.borderRadius,
      arrowHeight: arrowHeight ?? this.arrowHeight,
      arrowWidth: arrowWidth ?? this.arrowWidth,
      arrowCenterPosition: arrowCenterPosition ?? this.arrowCenterPosition,
      arrowHeadPosition: arrowHeadPosition ?? this.arrowHeadPosition,
    );
  }

  bool isSameMorphGeometry(MorphableShapeBorder shape) {
    return shape is BubbleShapeBorder && this.side == shape.side;
  }

  DynamicPath generateOuterDynamicPath(Rect rect) {
    final size = rect.size;

    double borderRadius;
    double arrowHeight;
    double arrowWidth;
    double arrowCenterPosition;
    double arrowHeadPosition;
    borderRadius =
        this.borderRadius.toPX(constraint: min(size.height, size.width));
    if (side.isHorizontal) {
      arrowHeight = this.arrowHeight.toPX(constraint: size.height);
      arrowWidth = this.arrowWidth.toPX(constraint: size.width);
      arrowCenterPosition =
          this.arrowCenterPosition.toPX(constraint: size.width);
      arrowHeadPosition = this.arrowHeadPosition.toPX(constraint: size.width);
    } else {
      arrowHeight = this.arrowHeight.toPX(constraint: size.width);
      arrowWidth = this.arrowWidth.toPX(constraint: size.height);
      arrowCenterPosition =
          this.arrowCenterPosition.toPX(constraint: size.height);
      arrowHeadPosition = this.arrowHeadPosition.toPX(constraint: size.height);
    }

    List<DynamicNode> nodes = [];

    final double spacingLeft = this.side == ShapeSide.left ? arrowHeight : 0;
    final double spacingTop = this.side == ShapeSide.top ? arrowHeight : 0;
    final double spacingRight = this.side == ShapeSide.right ? arrowHeight : 0;
    final double spacingBottom =
        this.side == ShapeSide.bottom ? arrowHeight : 0;

    final double left = spacingLeft + rect.left;
    final double top = spacingTop + rect.top;
    final double right = rect.right - spacingRight;
    final double bottom = rect.bottom - spacingBottom;

    double radiusBound = 0;

    if (this.side.isHorizontal) {
      arrowCenterPosition = arrowCenterPosition.clamp(0, size.width);
      arrowHeadPosition = arrowHeadPosition.clamp(0, size.width);
      arrowWidth = arrowWidth.clamp(
          0, 2 * min(arrowCenterPosition, size.width - arrowCenterPosition));
      radiusBound = min(
          min(right - arrowCenterPosition - arrowWidth / 2,
              arrowCenterPosition - arrowWidth / 2 - left),
          (bottom - top) / 2);
      borderRadius =
          borderRadius.clamp(0.0, radiusBound >= 0 ? radiusBound : 0);
    } else {
      arrowCenterPosition = arrowCenterPosition.clamp(0, size.height);
      arrowHeadPosition = arrowHeadPosition.clamp(0, size.height);
      arrowWidth = arrowWidth.clamp(
          0, 2 * min(arrowCenterPosition, size.height - arrowCenterPosition));
      radiusBound = min(
          min(bottom - arrowCenterPosition - arrowWidth / 2,
              arrowCenterPosition - arrowWidth / 2 - top),
          (right - left) / 2);
      borderRadius = borderRadius.clamp(
        0.0,
        radiusBound >= 0 ? radiusBound : 0,
      );
    }

    if (this.side == ShapeSide.top) {
      nodes.add(DynamicNode(
          position: Offset(arrowCenterPosition - arrowWidth / 2, top)));
      nodes.add(DynamicNode(position: Offset(arrowHeadPosition, rect.top)));
      nodes.add(DynamicNode(
          position: Offset(arrowCenterPosition + arrowWidth / 2, top)));
    }
    nodes.addArc(
        Rect.fromLTRB(
            right - 2 * borderRadius, top, right, top + 2 * borderRadius),
        3 * pi / 2,
        pi / 2);

    if (this.side == ShapeSide.right) {
      nodes.add(DynamicNode(
          position: Offset(right, arrowCenterPosition - arrowWidth / 2)));
      nodes.add(DynamicNode(position: Offset(rect.right, arrowHeadPosition)));
      nodes.add(DynamicNode(
          position: Offset(right, arrowCenterPosition + arrowWidth / 2)));
    }
    nodes.addArc(
        Rect.fromLTRB(
            right - borderRadius * 2, bottom - borderRadius * 2, right, bottom),
        0,
        pi / 2);

    if (this.side == ShapeSide.bottom) {
      nodes.add(DynamicNode(
          position: Offset(arrowCenterPosition + arrowWidth / 2, bottom)));
      nodes.add(DynamicNode(position: Offset(arrowHeadPosition, rect.bottom)));
      nodes.add(DynamicNode(
          position: Offset(arrowCenterPosition - arrowWidth / 2, bottom)));
    }
    nodes.addArc(
        Rect.fromLTRB(
            left, bottom - borderRadius * 2, left + borderRadius * 2, bottom),
        pi / 2,
        pi / 2);

    if (this.side == ShapeSide.left) {
      nodes.add(DynamicNode(
          position: Offset(left, arrowCenterPosition + arrowWidth / 2)));
      nodes.add(DynamicNode(position: Offset(rect.left, arrowHeadPosition)));
      nodes.add(DynamicNode(
          position: Offset(left, arrowCenterPosition - arrowWidth / 2)));
    }
    nodes.addArc(
        Rect.fromLTRB(
            left, top, left + borderRadius * 2, top + borderRadius * 2),
        pi,
        pi / 2);

    return DynamicPath(nodes: nodes, size: size);
  }
}
