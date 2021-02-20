import 'dart:math';

import 'package:flutter/material.dart';

import 'package:morphable_shape/morphable_shape.dart';

///Rectangle shape with various corner style and radius for each corner
class RoundedRectangleShape extends FilledBorderShape {
  final RectangleBorders borders;

  final DynamicBorderRadius borderRadius;

  const RoundedRectangleShape({
    this.borderRadius =
        const DynamicBorderRadius.all(DynamicRadius.circular(Length(0))),
    this.borders = const RectangleBorders.all(DynamicBorderSide.none),
  });

  RoundedRectangleShape.fromJson(Map<String, dynamic> map)
      : borderRadius = parseDynamicBorderRadius(map["borderRadius"]) ??
            DynamicBorderRadius.all(DynamicRadius.circular(Length(0))),
        this.borders = parseRectangleBorderSide(map["borders"]) ??
            RectangleBorders.all(DynamicBorderSide.none);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst = {"type": "RoundedRectangleShape"};
    rst["borderRadius"] = borderRadius.toJson();
    rst["borders"] = borders.toJson();
    return rst;
  }

  RoundedRectangleShape copyWith(
      {RectangleBorders? borders, DynamicBorderRadius? borderRadius}) {
    return RoundedRectangleShape(
        borders: borders ?? this.borders,
        borderRadius: borderRadius ?? this.borderRadius);
  }

  List<Color> borderFillColors() {
    List<Color> rst = [];
    rst.addAll(List.generate(3, (index) => borders.top.color));
    rst.addAll(List.generate(3, (index) => borders.right.color));
    rst.addAll(List.generate(3, (index) => borders.bottom.color));
    rst.addAll(List.generate(3, (index) => borders.left.color));
    return rotateList(rst, 2).cast<Color>();
  }

  @override
  List<Gradient?> borderFillGradients() {
    List<Gradient?> rst = [];
    rst.addAll(List.generate(3, (index) => borders.top.gradient));
    rst.addAll(List.generate(3, (index) => borders.right.gradient));
    rst.addAll(List.generate(3, (index) => borders.bottom.gradient));
    rst.addAll(List.generate(3, (index) => borders.left.gradient));
    return rotateList(rst, 2).cast<Gradient?>();
  }

  DynamicPath generateInnerDynamicPath(Rect rect) {
    Size size = rect.size;

    double leftSideWidth =
        this.borders.left.width.toPX(constraintSize: size.width);
    double rightSideWidth =
        this.borders.right.width.toPX(constraintSize: size.width);
    double topSideWidth =
        this.borders.top.width.toPX(constraintSize: size.height);
    double bottomSideWidth =
        this.borders.bottom.width.toPX(constraintSize: size.height);

    if (leftSideWidth + rightSideWidth > size.width) {
      double ratio = leftSideWidth / (leftSideWidth + rightSideWidth);
      leftSideWidth = size.width * ratio;
      rightSideWidth = size.width * (1 - ratio);
    }

    if (topSideWidth + bottomSideWidth > size.height) {
      double ratio = topSideWidth / (topSideWidth + bottomSideWidth);
      topSideWidth = size.height * ratio;
      bottomSideWidth = size.height * (1 - ratio);
    }

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

    nodes.addArc(
        Rect.fromCenter(
            center: Offset(right - max(topRightRadius, rightSideWidth),
                top + max(rightTopRadius, topSideWidth)),
            width: max(0, 2 * topRightRadius - 2 * rightSideWidth),
            height: max(0, 2 * rightTopRadius - 2 * topSideWidth)),
        -pi / 2,
        pi / 2,
        splitTimes: 1);

    nodes.addArc(
        Rect.fromCenter(
            center: Offset(right - max(bottomRightRadius, rightSideWidth),
                bottom - max(rightBottomRadius, bottomSideWidth)),
            width: max(0, 2 * bottomRightRadius - 2 * rightSideWidth),
            height: max(0, 2 * rightBottomRadius - 2 * bottomSideWidth)),
        0,
        pi / 2,
        splitTimes: 1);

    nodes.addArc(
        Rect.fromCenter(
            center: Offset(left + max(leftSideWidth, bottomLeftRadius),
                bottom - max(bottomSideWidth, leftBottomRadius)),
            width: max(0, 2 * bottomLeftRadius - 2 * leftSideWidth),
            height: max(0, 2 * leftBottomRadius - 2 * bottomSideWidth)),
        pi / 2,
        pi / 2,
        splitTimes: 1);

    nodes.addArc(
        Rect.fromCenter(
            center: Offset(left + max(leftSideWidth, topLeftRadius),
                top + max(topSideWidth, leftTopRadius)),
            width: max(0, 2 * topLeftRadius - 2 * leftSideWidth),
            height: max(0, 2 * leftTopRadius - 2 * topSideWidth)),
        pi,
        pi / 2,
        splitTimes: 1);

    return DynamicPath(size: rect.size, nodes: nodes);
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

    nodes.addArc(
        Rect.fromCenter(
            center: Offset(right - topRightRadius, top + rightTopRadius),
            width: 2 * topRightRadius,
            height: 2 * rightTopRadius),
        -pi / 2,
        pi / 2,
        splitTimes: 1);

    nodes.addArc(
        Rect.fromCenter(
            center:
                Offset(right - bottomRightRadius, bottom - rightBottomRadius),
            width: 2 * bottomRightRadius,
            height: 2 * rightBottomRadius),
        0,
        pi / 2,
        splitTimes: 1);

    nodes.addArc(
        Rect.fromCenter(
            center: Offset(left + bottomLeftRadius, bottom - leftBottomRadius),
            width: 2 * bottomLeftRadius,
            height: 2 * leftBottomRadius),
        pi / 2,
        pi / 2,
        splitTimes: 1);

    nodes.addArc(
        Rect.fromCenter(
            center: Offset(left + topLeftRadius, top + leftTopRadius),
            width: 2 * topLeftRadius,
            height: 2 * leftTopRadius),
        pi,
        pi / 2,
        splitTimes: 1);

    return DynamicPath(size: rect.size, nodes: nodes);
  }
}
