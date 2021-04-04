import 'package:morphable_shape/src/common_includes.dart';
import 'package:morphable_shape/src/ui_data_classes/dynamic_rectangle_styles.dart';

///Rectangle shape with various corner style and radius for each corner
class RectangleShapeBorder extends OutlinedShapeBorder {
  final RectangleCornerStyles cornerStyles;

  final DynamicBorderRadius borderRadius;

  const RectangleShapeBorder({
    this.borderRadius =
        const DynamicBorderRadius.all(DynamicRadius.circular(Length(0))),
    this.cornerStyles = const RectangleCornerStyles.all(CornerStyle.rounded),
    border = DynamicBorderSide.none,
  }) : super(border: border);

  RectangleShapeBorder.fromJson(Map<String, dynamic> map)
      : borderRadius = parseDynamicBorderRadius(map["borderRadius"]) ??
            DynamicBorderRadius.all(DynamicRadius.circular(Length(0))),
        this.cornerStyles = parseRectangleCornerStyle(map["cornerStyles"]) ??
            RectangleCornerStyles.all(CornerStyle.rounded),
        super(
            border: parseDynamicBorderSide(map["border"]) ??
                DynamicBorderSide.none);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst = {"type": "Rectangle"};
    rst.addAll(super.toJson());
    rst["borderRadius"] = borderRadius.toJson();
    rst["cornerStyles"] = cornerStyles.toJson();
    return rst;
  }

  RectangleShapeBorder copyWith(
      {RectangleCornerStyles? cornerStyles,
      DynamicBorderSide? border,
      DynamicBorderRadius? borderRadius}) {
    return RectangleShapeBorder(
        cornerStyles: cornerStyles ?? this.cornerStyles,
        border: border ?? this.border,
        borderRadius: borderRadius ?? this.borderRadius);
  }

  bool isSameMorphGeometry(MorphableShapeBorder shape) {
    return shape is RectangleShapeBorder ||
        shape is RoundedRectangleShapeBorder;
  }

  DynamicPath generateOuterDynamicPath(Rect rect) {
    Size size = rect.size;
    List<DynamicNode> nodes = [];

    final double left = rect.left;
    final double top = rect.top;
    final double bottom = rect.bottom;
    final double right = rect.right;

    BorderRadius borderRadius = this.borderRadius.toBorderRadius(size: size);

    double topLeftRadius = borderRadius.topLeft.x;
    double topRightRadius = borderRadius.topRight.x;

    double bottomLeftRadius = borderRadius.bottomLeft.x;
    double bottomRightRadius = borderRadius.bottomRight.x;

    double leftTopRadius = borderRadius.topLeft.y;
    double leftBottomRadius = borderRadius.bottomLeft.y;

    double rightTopRadius = borderRadius.topRight.y;
    double rightBottomRadius = borderRadius.bottomRight.y;

    double topTotal = topLeftRadius + topRightRadius;
    double bottomTotal = bottomLeftRadius + bottomRightRadius;
    double leftTotal = leftTopRadius + leftBottomRadius;
    double rightTotal = rightTopRadius + rightBottomRadius;

    if (max(topTotal, bottomTotal) > size.width ||
        max(leftTotal, rightTotal) > size.height) {
      double resizeRatio = min(size.width / max(topTotal, bottomTotal),
          size.height / max(leftTotal, rightTotal));

      topLeftRadius *= resizeRatio;
      topRightRadius *= resizeRatio;
      bottomLeftRadius *= resizeRatio;
      bottomRightRadius *= resizeRatio;

      leftTopRadius *= resizeRatio;
      rightTopRadius *= resizeRatio;
      leftBottomRadius *= resizeRatio;
      rightBottomRadius *= resizeRatio;
    }

    switch (cornerStyles.topRight) {
      case CornerStyle.rounded:
        nodes.addArc(
            Rect.fromCenter(
                center: Offset(right - topRightRadius, top + rightTopRadius),
                width: 2 * topRightRadius,
                height: 2 * rightTopRadius),
            -pi / 2,
            pi / 2,
            splitTimes: 1);
        break;
      case CornerStyle.straight:
        Offset start = Offset(right - topRightRadius, top);
        Offset end = Offset(right, top + rightTopRadius);
        nodes.add(DynamicNode(position: start));
        nodes.add(DynamicNode(position: (start + end) / 2));
        nodes.add(DynamicNode(position: end));
        break;
      case CornerStyle.concave:
        nodes.addArc(
            Rect.fromCenter(
                center: Offset(right, top),
                width: 2 * topRightRadius,
                height: 2 * rightTopRadius),
            pi,
            -pi / 2,
            splitTimes: 1);
        break;
      case CornerStyle.cutout:
        nodes.add(DynamicNode(position: Offset(right - topRightRadius, top)));
        nodes.add(DynamicNode(
            position: Offset(right - topRightRadius, top + rightTopRadius)));
        nodes.add(DynamicNode(position: Offset(right, top + rightTopRadius)));
    }

    switch (cornerStyles.bottomRight) {
      case CornerStyle.rounded:
        nodes.addArc(
            Rect.fromCenter(
                center: Offset(
                    right - bottomRightRadius, bottom - rightBottomRadius),
                width: 2 * bottomRightRadius,
                height: 2 * rightBottomRadius),
            0,
            pi / 2,
            splitTimes: 1);
        break;
      case CornerStyle.straight:
        Offset start = Offset(right, bottom - rightBottomRadius);
        Offset end = Offset(right - bottomRightRadius, bottom);
        nodes.add(DynamicNode(position: start));
        nodes.add(DynamicNode(position: (start + end) / 2));
        nodes.add(DynamicNode(position: end));
        break;
      case CornerStyle.concave:
        nodes.addArc(
            Rect.fromCenter(
                center: Offset(right, bottom),
                width: 2 * bottomRightRadius,
                height: 2 * rightBottomRadius),
            -pi / 2,
            -pi / 2,
            splitTimes: 1);
        break;
      case CornerStyle.cutout:
        nodes.add(
            DynamicNode(position: Offset(right, bottom - rightBottomRadius)));
        nodes.add(DynamicNode(
            position:
                Offset(right - bottomRightRadius, bottom - rightBottomRadius)));
        nodes.add(
            DynamicNode(position: Offset(right - bottomRightRadius, bottom)));
    }

    switch (cornerStyles.bottomLeft) {
      case CornerStyle.rounded:
        nodes.addArc(
            Rect.fromCenter(
                center:
                    Offset(left + bottomLeftRadius, bottom - leftBottomRadius),
                width: 2 * bottomLeftRadius,
                height: 2 * leftBottomRadius),
            pi / 2,
            pi / 2,
            splitTimes: 1);
        break;
      case CornerStyle.straight:
        Offset start = Offset(left + bottomLeftRadius, bottom);
        Offset end = Offset(left, bottom - leftBottomRadius);
        nodes.add(DynamicNode(position: start));
        nodes.add(DynamicNode(position: (start + end) / 2));
        nodes.add(DynamicNode(position: end));
        break;
      case CornerStyle.concave:
        nodes.addArc(
            Rect.fromCenter(
                center: Offset(left, bottom),
                width: 2 * bottomLeftRadius,
                height: 2 * leftBottomRadius),
            0,
            -pi / 2,
            splitTimes: 1);
        break;
      case CornerStyle.cutout:
        nodes.add(
            DynamicNode(position: Offset(left + bottomLeftRadius, bottom)));
        nodes.add(DynamicNode(
            position:
                Offset(left + bottomLeftRadius, bottom - leftBottomRadius)));
        nodes.add(
            DynamicNode(position: Offset(left, bottom - leftBottomRadius)));
    }

    switch (cornerStyles.topLeft) {
      case CornerStyle.rounded:
        nodes.addArc(
            Rect.fromCenter(
                center: Offset(left + topLeftRadius, top + leftTopRadius),
                width: 2 * topLeftRadius,
                height: 2 * leftTopRadius),
            pi,
            pi / 2,
            splitTimes: 1);
        break;
      case CornerStyle.straight:
        Offset start = Offset(left, top + leftTopRadius);
        Offset end = Offset(left + topLeftRadius, top);
        nodes.add(DynamicNode(position: start));
        nodes.add(DynamicNode(position: (start + end) / 2));
        nodes.add(DynamicNode(position: end));
        break;
      case CornerStyle.concave:
        nodes.addArc(
            Rect.fromCenter(
                center: Offset(left, top),
                width: 2 * topLeftRadius,
                height: 2 * leftTopRadius),
            pi / 2,
            -pi / 2,
            splitTimes: 1);
        break;
      case CornerStyle.cutout:
        nodes.add(DynamicNode(position: Offset(left, top + leftTopRadius)));
        nodes.add(DynamicNode(
            position: Offset(left + topLeftRadius, top + leftTopRadius)));
        nodes.add(DynamicNode(position: Offset(left + topLeftRadius, top)));
    }

    return DynamicPath(size: rect.size, nodes: nodes);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is RectangleShapeBorder &&
        other.border == border &&
        other.cornerStyles == cornerStyles &&
        other.borderRadius == borderRadius;
  }

  @override
  int get hashCode => hashValues(border, cornerStyles, borderRadius);
}
