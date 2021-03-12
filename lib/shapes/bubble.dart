import 'dart:math';

import 'package:flutter/material.dart';
import 'package:morphable_shape/morphable_shape.dart';

///Bubble shape, with a triangular tip and equal radius rounded corner
class BubbleShape extends OutlinedShape {
  final ShapeCorner corner;

  final Length borderRadius;
  final Length arrowHeight;
  final Length arrowWidth;

  final Length arrowCenterPosition;
  final Length arrowHeadPosition;

  const BubbleShape({
    DynamicBorderSide border = DynamicBorderSide.none,
    this.corner = ShapeCorner.bottomRight,
    this.borderRadius = const Length(6),
    this.arrowHeight = const Length(20, unit: LengthUnit.percent),
    this.arrowWidth = const Length(30, unit: LengthUnit.percent),
    this.arrowCenterPosition = const Length(50, unit: LengthUnit.percent),
    this.arrowHeadPosition = const Length(50, unit: LengthUnit.percent),
  }) : super(border: border);

  BubbleShape.fromJson(Map<String, dynamic> map)
      : corner = parseShapeCorner(map["corner"]) ?? ShapeCorner.bottomRight,
        borderRadius = Length.fromJson(map["borderRadius"]) ?? Length(6),
        arrowHeight =
            Length.fromJson(map["arrowHeight"]) ?? 20.0.toPercentLength,
        arrowWidth = Length.fromJson(map["arrowWidth"]) ?? 30.0.toPercentLength,
        arrowCenterPosition =
            Length.fromJson(map["arrowCenterPosition"]) ?? 50.0.toPercentLength,
        arrowHeadPosition =
            Length.fromJson(map["arrowHeadPosition"]) ?? 50.0.toPercentLength,
        super(
            border: parseDynamicBorderSide(map["border"]) ??
                DynamicBorderSide.none);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst = {"type": "BubbleShape"};
    rst.addAll(super.toJson());
    rst["corner"] = corner.toJson();
    rst["borderRadius"] = borderRadius.toJson();
    rst["arrowHeight"] = arrowHeight.toJson();
    rst["arrowWidth"] = arrowWidth.toJson();
    rst["arrowCenterPosition"] = arrowCenterPosition.toJson();
    rst["arrowHeadPosition"] = arrowHeadPosition.toJson();

    return rst;
  }

  BubbleShape copyWith({
    ShapeCorner? corner,
    Length? borderRadius,
    Length? arrowHeight,
    Length? arrowWidth,
    Length? arrowCenterPosition,
    Length? arrowHeadPosition,
    DynamicBorderSide? border,
  }) {
    return BubbleShape(
      border: border ?? this.border,
      corner: corner ?? this.corner,
      borderRadius: borderRadius ?? this.borderRadius,
      arrowHeight: arrowHeight ?? this.arrowHeight,
      arrowWidth: arrowWidth ?? this.arrowWidth,
      arrowCenterPosition: arrowCenterPosition ?? this.arrowCenterPosition,
      arrowHeadPosition: arrowHeadPosition ?? this.arrowHeadPosition,
    );
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
    if (corner.isHorizontal) {
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

    if (this.corner.isHorizontalRight) {
      arrowCenterPosition = size.width - arrowCenterPosition;
      arrowHeadPosition = size.width - arrowHeadPosition;
    }
    if (this.corner.isVerticalBottom) {
      arrowCenterPosition = size.height - arrowCenterPosition;
      arrowHeadPosition = size.height - arrowHeadPosition;
    }

    final double spacingLeft = this.corner.isLeft ? arrowHeight : 0;
    final double spacingTop = this.corner.isTop ? arrowHeight : 0;
    final double spacingRight = this.corner.isRight ? arrowHeight : 0;
    final double spacingBottom = this.corner.isBottom ? arrowHeight : 0;

    final double left = spacingLeft + rect.left;
    final double top = spacingTop + rect.top;
    final double right = rect.right - spacingRight;
    final double bottom = rect.bottom - spacingBottom;

    double radiusBound = 0;

    if (this.corner.isHorizontal) {
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

    if (this.corner.isTop) {
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

    if (this.corner.isRight) {
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

    if (this.corner.isBottom) {
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

    if (this.corner.isLeft) {
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
