import 'package:morphable_shape/src/common_includes.dart';
import 'package:morphable_shape/src/ui_data_classes/dynamic_rectangle_styles.dart';

///Rectangle shape with various border radius and width for each corner
///This class is similar to what CSS box does, you can configure different border
///radius and border width
class RoundedRectangleShapeBorder extends FilledBorderShapeBorder {
  final RectangleBorderSides borderSides;
  final DynamicBorderRadius borderRadius;

  const RoundedRectangleShapeBorder({
    this.borderRadius =
        const DynamicBorderRadius.all(DynamicRadius.circular(Length(0))),
    this.borderSides = const RectangleBorderSides.all(DynamicBorderSide.none),
  });

  RoundedRectangleShapeBorder.fromJson(Map<String, dynamic> map)
      : borderRadius = parseDynamicBorderRadius(map["borderRadius"]) ??
            DynamicBorderRadius.all(DynamicRadius.circular(Length(0))),
        this.borderSides = parseRectangleBorderSide(map["borderSides"]) ??
            RectangleBorderSides.all(DynamicBorderSide.none);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst = {"type": "RoundedRectangle"};
    rst["borderRadius"] = borderRadius.toJson();
    rst["borderSides"] = borderSides.toJson();
    return rst;
  }

  RoundedRectangleShapeBorder copyWith(
      {RectangleBorderSides? borders, DynamicBorderRadius? borderRadius}) {
    return RoundedRectangleShapeBorder(
        borderSides: borders ?? this.borderSides,
        borderRadius: borderRadius ?? this.borderRadius);
  }

  bool isSameMorphGeometry(MorphableShapeBorder shape) {
    return shape is RectangleShapeBorder ||
        shape is RoundedRectangleShapeBorder;
  }

  EdgeInsetsGeometry get dimensions => EdgeInsets.only(
      top: borderSides.top.width,
      bottom: borderSides.bottom.width,
      left: borderSides.left.width,
      right: borderSides.right.width);

  List<Color> borderFillColors() {
    List<Color> rst = [];
    rst.addAll(List.generate(3, (index) => borderSides.top.color));
    rst.addAll(List.generate(3, (index) => borderSides.right.color));
    rst.addAll(List.generate(3, (index) => borderSides.bottom.color));
    rst.addAll(List.generate(3, (index) => borderSides.left.color));
    return rotateList(rst, 2).cast<Color>();
  }

  @override
  List<Gradient?> borderFillGradients() {
    List<Gradient?> rst = [];
    rst.addAll(List.generate(3, (index) => borderSides.top.gradient));
    rst.addAll(List.generate(3, (index) => borderSides.right.gradient));
    rst.addAll(List.generate(3, (index) => borderSides.bottom.gradient));
    rst.addAll(List.generate(3, (index) => borderSides.left.gradient));
    return rotateList(rst, 2).cast<Gradient?>();
  }

  static double epsilon = 0.0000001;

  DynamicPath generateInnerDynamicPath(Rect rect) {
    Size size = rect.size;

    double leftSideWidth = this.borderSides.left.width;
    double rightSideWidth = this.borderSides.right.width;
    double topSideWidth = this.borderSides.top.width;
    double bottomSideWidth = this.borderSides.bottom.width;

    BorderRadius borderRadius = this.borderRadius.toBorderRadius(size: size);

    double topLeftRadius = borderRadius.topLeft.x;
    double topRightRadius = borderRadius.topRight.x;

    double bottomLeftRadius = borderRadius.bottomLeft.x;
    double bottomRightRadius = borderRadius.bottomRight.x;

    double leftTopRadius = borderRadius.topLeft.y;
    double leftBottomRadius = borderRadius.bottomLeft.y;

    double rightTopRadius = borderRadius.topRight.y;
    double rightBottomRadius = borderRadius.bottomRight.y;

    ///Handling the case when either the border with or
    ///corner radius is too big
    double topTotal =
        max(topLeftRadius, leftSideWidth) + max(topRightRadius, rightSideWidth);
    double bottomTotal = max(bottomLeftRadius, leftSideWidth) +
        max(bottomRightRadius, rightSideWidth);
    double leftTotal = max(leftTopRadius, topSideWidth) +
        max(leftBottomRadius, bottomSideWidth);
    double rightTotal = max(rightTopRadius, topSideWidth) +
        max(rightBottomRadius, bottomSideWidth);

    if (max(topTotal, bottomTotal) > size.width ||
        max(leftTotal, rightTotal) > size.height) {
      double resizeRatio = min(size.width / max(topTotal, bottomTotal),
          size.height / max(leftTotal, rightTotal));

      topLeftRadius *= resizeRatio;
      topRightRadius *= resizeRatio;
      bottomLeftRadius *= resizeRatio;
      bottomRightRadius *= resizeRatio;
      leftSideWidth *= resizeRatio;
      rightSideWidth *= resizeRatio;

      leftTopRadius *= resizeRatio;
      rightTopRadius *= resizeRatio;
      leftBottomRadius *= resizeRatio;
      rightBottomRadius *= resizeRatio;
      topSideWidth *= resizeRatio;
      bottomSideWidth *= resizeRatio;
    }

    final double left = rect.left;
    final double top = rect.top;
    final double bottom = rect.bottom;
    final double right = rect.right;

    List<DynamicNode> nodes = [];

    double r1, r2, sweep1;
    var centerRect;

    r1 = max(epsilon, 2 * topRightRadius - 2 * rightSideWidth);
    r2 = max(epsilon, 2 * rightTopRadius - 2 * topSideWidth);
    centerRect = Rect.fromCenter(
        center: Offset(right - max(topRightRadius, rightSideWidth),
            top + max(rightTopRadius, topSideWidth)),
        width: r1,
        height: r2);
    sweep1 = r1 / (r1 + r2) * pi / 2;
    nodes.addArc(centerRect, -pi / 2, sweep1, splitTimes: 0);
    List<Offset> points = arcToCubicBezier(
        centerRect, -pi / 2 + sweep1, pi / 2 - sweep1,
        splitTimes: 0);
    for (int i = 0; i < points.length; i += 4) {
      nodes.cubicTo(points[i + 1], points[i + 2], points[i + 3]);
    }

    r1 = max(epsilon, 2 * bottomRightRadius - 2 * rightSideWidth);
    r2 = max(epsilon, 2 * rightBottomRadius - 2 * bottomSideWidth);
    centerRect = Rect.fromCenter(
        center: Offset(right - max(bottomRightRadius, rightSideWidth),
            bottom - max(rightBottomRadius, bottomSideWidth)),
        width: r1,
        height: r2);
    sweep1 = r2 / (r1 + r2) * pi / 2;
    nodes.addArc(centerRect, 0, sweep1, splitTimes: 0);
    points = arcToCubicBezier(centerRect, 0 + sweep1, pi / 2 - sweep1,
        splitTimes: 0);
    for (int i = 0; i < points.length; i += 4) {
      nodes.cubicTo(points[i + 1], points[i + 2], points[i + 3]);
    }

    r1 = max(epsilon, 2 * bottomLeftRadius - 2 * leftSideWidth);
    r2 = max(epsilon, 2 * leftBottomRadius - 2 * bottomSideWidth);
    centerRect = Rect.fromCenter(
        center: Offset(left + max(leftSideWidth, bottomLeftRadius),
            bottom - max(bottomSideWidth, leftBottomRadius)),
        width: r1,
        height: r2);
    sweep1 = r1 / (r1 + r2) * pi / 2;
    nodes.addArc(centerRect, pi / 2, sweep1, splitTimes: 0);
    points = arcToCubicBezier(centerRect, pi / 2 + sweep1, pi / 2 - sweep1,
        splitTimes: 0);
    for (int i = 0; i < points.length; i += 4) {
      nodes.cubicTo(points[i + 1], points[i + 2], points[i + 3]);
    }

    r1 = max(epsilon, 2 * topLeftRadius - 2 * leftSideWidth);
    r2 = max(epsilon, 2 * leftTopRadius - 2 * topSideWidth);
    centerRect = Rect.fromCenter(
        center: Offset(left + max(leftSideWidth, topLeftRadius),
            top + max(topSideWidth, leftTopRadius)),
        width: r1,
        height: r2);
    sweep1 = r2 / (r1 + r2) * pi / 2;
    nodes.addArc(centerRect, pi, sweep1, splitTimes: 0);
    points = arcToCubicBezier(centerRect, pi + sweep1, pi / 2 - sweep1,
        splitTimes: 0);
    for (int i = 0; i < points.length; i += 4) {
      nodes.cubicTo(points[i + 1], points[i + 2], points[i + 3]);
    }

    return DynamicPath(size: rect.size, nodes: nodes);
  }

  DynamicPath generateOuterDynamicPath(Rect rect) {
    Size size = rect.size;
    List<DynamicNode> nodes = [];

    final double left = rect.left;
    final double top = rect.top;
    final double bottom = rect.bottom;
    final double right = rect.right;

    double leftSideWidth = this.borderSides.left.width;
    double rightSideWidth = this.borderSides.right.width;
    double topSideWidth = this.borderSides.top.width;
    double bottomSideWidth = this.borderSides.bottom.width;

    BorderRadius borderRadius = this.borderRadius.toBorderRadius(size: size);

    double topLeftRadius = borderRadius.topLeft.x;
    double topRightRadius = borderRadius.topRight.x;

    double bottomLeftRadius = borderRadius.bottomLeft.x;
    double bottomRightRadius = borderRadius.bottomRight.x;

    double leftTopRadius = borderRadius.topLeft.y;
    double leftBottomRadius = borderRadius.bottomLeft.y;

    double rightTopRadius = borderRadius.topRight.y;
    double rightBottomRadius = borderRadius.bottomRight.y;

    ///Handling the case when either the border with or
    ///corner radius is too big
    double topTotal =
        max(topLeftRadius, leftSideWidth) + max(topRightRadius, rightSideWidth);
    double bottomTotal = max(bottomLeftRadius, leftSideWidth) +
        max(bottomRightRadius, rightSideWidth);
    double leftTotal = max(leftTopRadius, topSideWidth) +
        max(leftBottomRadius, bottomSideWidth);
    double rightTotal = max(rightTopRadius, topSideWidth) +
        max(rightBottomRadius, bottomSideWidth);

    if (max(topTotal, bottomTotal) > size.width ||
        max(leftTotal, rightTotal) > size.height) {
      double resizeRatio = min(size.width / max(topTotal, bottomTotal),
          size.height / max(leftTotal, rightTotal));

      topLeftRadius *= resizeRatio;
      topRightRadius *= resizeRatio;
      bottomLeftRadius *= resizeRatio;
      bottomRightRadius *= resizeRatio;
      leftSideWidth *= resizeRatio;
      rightSideWidth *= resizeRatio;

      leftTopRadius *= resizeRatio;
      rightTopRadius *= resizeRatio;
      leftBottomRadius *= resizeRatio;
      rightBottomRadius *= resizeRatio;
      topSideWidth *= resizeRatio;
      bottomSideWidth *= resizeRatio;
    }

    double r1, r2, sweep1;
    var centerRect;

    r1 = 2 * topRightRadius;
    r2 = 2 * rightTopRadius;
    centerRect = Rect.fromCenter(
        center: Offset(right - topRightRadius, top + rightTopRadius),
        width: r1,
        height: r2);
    sweep1 = r1 / (r1 + r2 + epsilon) * pi / 2;
    nodes.addArc(centerRect, -pi / 2, sweep1, splitTimes: 0);
    List<Offset> points = arcToCubicBezier(
        centerRect, -pi / 2 + sweep1, pi / 2 - sweep1,
        splitTimes: 0);
    for (int i = 0; i < points.length; i += 4) {
      nodes.cubicTo(points[i + 1], points[i + 2], points[i + 3]);
    }

    r1 = 2 * bottomRightRadius;
    r2 = 2 * rightBottomRadius;
    centerRect = Rect.fromCenter(
        center: Offset(right - bottomRightRadius, bottom - rightBottomRadius),
        width: r1,
        height: r2);
    sweep1 = r2 / (r1 + r2 + epsilon) * pi / 2;
    nodes.addArc(centerRect, 0, sweep1, splitTimes: 0);
    points = arcToCubicBezier(centerRect, 0 + sweep1, pi / 2 - sweep1,
        splitTimes: 0);
    for (int i = 0; i < points.length; i += 4) {
      nodes.cubicTo(points[i + 1], points[i + 2], points[i + 3]);
    }

    r1 = 2 * bottomLeftRadius;
    r2 = 2 * leftBottomRadius;
    centerRect = Rect.fromCenter(
        center: Offset(left + bottomLeftRadius, bottom - leftBottomRadius),
        width: r1,
        height: r2);
    sweep1 = r1 / (r1 + r2 + epsilon) * pi / 2;
    nodes.addArc(centerRect, pi / 2, sweep1, splitTimes: 0);
    points = arcToCubicBezier(centerRect, pi / 2 + sweep1, pi / 2 - sweep1,
        splitTimes: 0);
    for (int i = 0; i < points.length; i += 4) {
      nodes.cubicTo(points[i + 1], points[i + 2], points[i + 3]);
    }

    r1 = 2 * topLeftRadius;
    r2 = 2 * leftTopRadius;
    centerRect = Rect.fromCenter(
        center: Offset(left + topLeftRadius, top + leftTopRadius),
        width: r1,
        height: r2);
    sweep1 = r2 / (r1 + r2 + epsilon) * pi / 2;
    nodes.addArc(centerRect, pi, sweep1, splitTimes: 0);
    points = arcToCubicBezier(centerRect, pi + sweep1, pi / 2 - sweep1,
        splitTimes: 0);
    for (int i = 0; i < points.length; i += 4) {
      nodes.cubicTo(points[i + 1], points[i + 2], points[i + 3]);
    }

    return DynamicPath(size: rect.size, nodes: nodes);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is RoundedRectangleShapeBorder &&
        other.borderSides == borderSides &&
        other.borderRadius == borderRadius;
  }

  @override
  int get hashCode => Object.hash(borderSides, borderRadius);
}
