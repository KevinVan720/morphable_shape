import 'dart:math';

import 'package:flutter/material.dart';

import '../morphable_shape_border.dart';

///Rectangle shape with various corner style and radius for each corner
class RectangleShape extends Shape {
  final CornerStyle topLeft;
  final CornerStyle topRight;
  final CornerStyle bottomLeft;
  final CornerStyle bottomRight;
  final DynamicBorderRadius borderRadius;

  const RectangleShape({
    this.borderRadius =
        const DynamicBorderRadius.all(DynamicRadius.circular(Length(0))),
    this.topLeft = CornerStyle.rounded,
    this.topRight = CornerStyle.rounded,
    this.bottomLeft = CornerStyle.rounded,
    this.bottomRight = CornerStyle.rounded,
  });

  RectangleShape copyWith(
      {CornerStyle? topLeft,
      CornerStyle? topRight,
      CornerStyle? bottomLeft,
      CornerStyle? bottomRight,
      DynamicBorderRadius? borderRadius}) {
    return RectangleShape(
        topLeft: topLeft ?? this.topLeft,
        topRight: topRight ?? this.topRight,
        bottomLeft: bottomLeft ?? this.bottomLeft,
        bottomRight: bottomRight ?? this.bottomRight,
        borderRadius: borderRadius ?? this.borderRadius);
  }

  RectangleShape.fromJson(Map<String, dynamic> map)
      : borderRadius = parseDynamicBorderRadius(map["borderRadius"]) ??
            DynamicBorderRadius.all(DynamicRadius.circular(Length(0))),
        this.topLeft = CornerStyle.rounded,
        this.topRight = CornerStyle.rounded,
        this.bottomLeft = CornerStyle.rounded,
        this.bottomRight = CornerStyle.rounded;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst = {"name": "RectangleShape"};
    rst["borderRadius"] = borderRadius.toJson();
    return rst;
  }

  DynamicPath generateDynamicPath(Rect rect) {
    Size size = rect.size;
    List<DynamicNode> nodes = [];

    final double left = rect.left;
    final double top = rect.top;
    final double bottom = rect.bottom;
    final double right = rect.right;

    BorderRadius borderRadius = this.borderRadius.toBorderRadius(size: size);

    double topLeftRadius = borderRadius.topLeft.x;
    double topRightRadius = borderRadius.topRight.x;

    if (topLeftRadius + topRightRadius > size.width) {
      double ratio = (topLeftRadius) / (topLeftRadius + topRightRadius);
      topLeftRadius = size.width * ratio;
      topRightRadius = size.width * (1 - ratio);
    }

    double bottomLeftRadius = borderRadius.bottomLeft.x;
    double bottomRightRadius = borderRadius.bottomRight.x;

    if (bottomLeftRadius + bottomRightRadius > size.width) {
      double ratio =
          (bottomLeftRadius) / (bottomLeftRadius + bottomRightRadius);
      bottomLeftRadius = size.width * ratio;
      bottomRightRadius = size.width * (1 - ratio);
    }

    double leftTopRadius = borderRadius.topLeft.y;
    double leftBottomRadius = borderRadius.bottomLeft.y;

    if (leftTopRadius + leftBottomRadius > size.height) {
      double ratio = (leftTopRadius) / (leftTopRadius + leftBottomRadius);
      leftTopRadius = size.height * ratio;
      leftBottomRadius = size.height * (1 - ratio);
    }

    double rightTopRadius = borderRadius.topRight.y;
    double rightBottomRadius = borderRadius.bottomRight.y;

    if (rightTopRadius + rightBottomRadius > size.height) {
      double ratio = (rightTopRadius) / (rightTopRadius + rightBottomRadius);
      rightTopRadius = size.height * ratio;
      rightBottomRadius = size.height * (1 - ratio);
    }

    nodes.add(DynamicNode(position: Offset(right - topRightRadius, top)));

    switch (topRight) {
      case CornerStyle.rounded:
        nodes.arcTo(
            Rect.fromCenter(
                center: Offset(right - topRightRadius, top + rightTopRadius),
                width: 2 * topRightRadius,
                height: 2 * rightTopRadius),
            -pi / 2,
            pi / 2);
        break;
      case CornerStyle.straight:
        nodes.add(DynamicNode(position: Offset(right, top + rightTopRadius)));
        break;
      case CornerStyle.concave:
        nodes.arcTo(
            Rect.fromCenter(
                center: Offset(right, top),
                width: 2 * topRightRadius,
                height: 2 * rightTopRadius),
            pi,
            -pi / 2);
        break;
      case CornerStyle.cutout:
        nodes.add(DynamicNode(
            position: Offset(right - topRightRadius, top + rightTopRadius)));
        nodes.add(DynamicNode(position: Offset(right, top + rightTopRadius)));
    }

    nodes.add(DynamicNode(position: Offset(right, bottom - rightBottomRadius)));

    switch (bottomRight) {
      case CornerStyle.rounded:
        nodes.arcTo(
            Rect.fromCenter(
                center: Offset(
                    right - bottomRightRadius, bottom - rightBottomRadius),
                width: 2 * bottomRightRadius,
                height: 2 * rightBottomRadius),
            0,
            pi / 2);
        break;
      case CornerStyle.straight:
        nodes.add(
            DynamicNode(position: Offset(right - bottomRightRadius, bottom)));
        break;
      case CornerStyle.concave:
        nodes.arcTo(
            Rect.fromCenter(
                center: Offset(right, bottom),
                width: 2 * bottomRightRadius,
                height: 2 * rightBottomRadius),
            -pi / 2,
            -pi / 2);
        break;
      case CornerStyle.cutout:
        nodes.add(DynamicNode(
            position:
                Offset(right - bottomRightRadius, bottom - rightBottomRadius)));
        nodes.add(
            DynamicNode(position: Offset(right - bottomRightRadius, bottom)));
    }

    nodes.add(DynamicNode(position: Offset(left + bottomLeftRadius, bottom)));

    switch (bottomLeft) {
      case CornerStyle.rounded:
        nodes.arcTo(
            Rect.fromCenter(
                center:
                    Offset(left + bottomLeftRadius, bottom - leftBottomRadius),
                width: 2 * bottomLeftRadius,
                height: 2 * leftBottomRadius),
            pi / 2,
            pi / 2);
        break;
      case CornerStyle.straight:
        nodes.add(
            DynamicNode(position: Offset(left, bottom - leftBottomRadius)));
        break;
      case CornerStyle.concave:
        nodes.arcTo(
            Rect.fromCenter(
                center: Offset(left, bottom),
                width: 2 * bottomLeftRadius,
                height: 2 * leftBottomRadius),
            0,
            -pi / 2);
        break;
      case CornerStyle.cutout:
        nodes.add(DynamicNode(
            position:
                Offset(left + bottomLeftRadius, bottom - leftBottomRadius)));
        nodes.add(
            DynamicNode(position: Offset(left, bottom - leftBottomRadius)));
    }

    nodes.add(DynamicNode(position: Offset(left, top + leftTopRadius)));

    switch (topLeft) {
      case CornerStyle.rounded:
        nodes.arcTo(
            Rect.fromCenter(
                center: Offset(left + topLeftRadius, top + leftTopRadius),
                width: 2 * topLeftRadius,
                height: 2 * leftTopRadius),
            pi,
            pi / 2);
        break;
      case CornerStyle.straight:
        nodes.add(DynamicNode(position: Offset(left + topLeftRadius, top)));
        break;
      case CornerStyle.concave:
        nodes.arcTo(
            Rect.fromCenter(
                center: Offset(left, top),
                width: 2 * topLeftRadius,
                height: 2 * leftTopRadius),
            pi / 2,
            -pi / 2);
        break;
      case CornerStyle.cutout:
        nodes.add(DynamicNode(
            position: Offset(left + topLeftRadius, top + leftTopRadius)));
        nodes.add(DynamicNode(position: Offset(left + topLeftRadius, top)));
    }

    return DynamicPath(size: rect.size, nodes: nodes);
  }
}
