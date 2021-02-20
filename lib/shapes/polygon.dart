import 'dart:math';

import 'package:flutter/material.dart';
import 'package:morphable_shape/morphable_shape.dart';

class PolygonShape extends OutlinedShape {
  final int sides;
  final Length cornerRadius;
  final CornerStyle cornerStyle;
  //final DynamicBorderSides border;

  const PolygonShape(
      {this.sides = 5,
      this.cornerStyle = CornerStyle.rounded,
      this.cornerRadius = const Length(0),
      border = DynamicBorderSide.none})
      : assert(sides >= 3),
        super(border: border);

  PolygonShape.fromJson(Map<String, dynamic> map)
      : cornerStyle =
            parseCornerStyle(map["cornerStyle"]) ?? CornerStyle.rounded,
        cornerRadius = Length.fromJson(map["cornerRadius"]) ?? Length(0),
        sides = map["sides"] ?? 5,
        super(border: parseDynamicBorderSide(map["border"]) ?? defaultBorder);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst = {"type": "PolygonShape"};
    rst.addAll(super.toJson());
    rst["sides"] = sides;
    rst["cornerRadius"] = cornerRadius.toJson();
    rst["cornerStyle"] = cornerStyle.toJson();
    //rst["border"] = border.toJson();
    return rst;
  }

  PolygonShape copyWith({
    CornerStyle? cornerStyle,
    Length? cornerRadius,
    int? sides,
    DynamicBorderSide? border,
  }) {
    return PolygonShape(
      border: border ?? this.border,
      cornerStyle: cornerStyle ?? this.cornerStyle,
      sides: sides ?? this.sides,
      cornerRadius: cornerRadius ?? this.cornerRadius,
    );
  }

  DynamicPath generateOuterDynamicPath(Rect rect) {
    List<DynamicNode> nodes = [];

    final double alpha = (2.0 * pi / sides) / 2;
    double scale = min(rect.width, rect.height) / 2;
    final double centerX = scale;
    final double centerY = scale;
    double cornerRadius = this.cornerRadius.toPX(constraintSize: scale);
    double borderWidth = 0.0;

    borderWidth = borderWidth.clamp(0, scale * cos(alpha));
    cornerRadius = cornerRadius.clamp(0, scale * cos(alpha));

    double arcCenterRadius = 0;

    switch (cornerStyle) {
      case CornerStyle.rounded:
        arcCenterRadius = scale - cornerRadius / sin(pi / 2 - alpha);
        break;
      case CornerStyle.concave:
      case CornerStyle.cutout:
        arcCenterRadius = scale -
            cornerRadius / sin(pi / 2 - alpha) +
            borderWidth / sin(alpha);
        arcCenterRadius = arcCenterRadius.clamp(0.0, scale);
        cornerRadius -= borderWidth / tan(alpha);
        cornerRadius = cornerRadius.clamp(0.0, scale);
        break;

      case CornerStyle.straight:
        cornerRadius -=
            borderWidth * (1 - cos(alpha)) / sin(alpha) / tan(alpha);
        cornerRadius = cornerRadius.clamp(0.0, scale);
        arcCenterRadius = scale - cornerRadius / sin(pi / 2 - alpha);
        arcCenterRadius = arcCenterRadius.clamp(0.0, scale);
        break;
    }

    double startAngle = -pi / 2;

    for (int i = 0; i < sides; i++) {
      double cornerAngle = startAngle + 2 * alpha * i;
      double arcCenterX = (centerX + arcCenterRadius * cos(cornerAngle));
      double arcCenterY = (centerY + arcCenterRadius * sin(cornerAngle));
      Offset start = arcToCubicBezier(
              Rect.fromCircle(
                  center: Offset(arcCenterX, arcCenterY), radius: cornerRadius),
              cornerAngle - alpha,
              2 * alpha,
              splitTimes: 1)
          .first;
      Offset end = arcToCubicBezier(
              Rect.fromCircle(
                  center: Offset(arcCenterX, arcCenterY), radius: cornerRadius),
              cornerAngle - alpha,
              2 * alpha,
              splitTimes: 1)
          .last;

      switch (cornerStyle) {
        case CornerStyle.concave:
          nodes.addStyledCorner(Offset(arcCenterX, arcCenterY), cornerRadius,
              cornerAngle - alpha, 2 * alpha,
              style: CornerStyle.concave, splitTimes: 1);
          break;
        case CornerStyle.rounded:
          nodes.addArc(
              Rect.fromCircle(
                  center: Offset(arcCenterX, arcCenterY), radius: cornerRadius),
              cornerAngle - alpha,
              2 * alpha,
              splitTimes: 1);
          break;

        case CornerStyle.straight:
          nodes.add(DynamicNode(position: start));
          nodes.add(DynamicNode(position: (start + end) / 2));
          nodes.add(DynamicNode(position: end));
          break;
        case CornerStyle.cutout:
          nodes.add(DynamicNode(position: start));
          nodes.add(DynamicNode(position: Offset(arcCenterX, arcCenterY)));
          nodes.add(DynamicNode(position: end));
          break;
      }
      //}
    }

    return DynamicPath(size: Size(2 * scale, 2 * scale), nodes: nodes)
      ..resize(rect.size);
  }

  ///used for implementing filled color polygon, works for a rectangle box but
  ///streches with rectangular boxes, revert back to border line polygon for now...
  /*
  @override
  List<Color> borderFillColors() {
    int degeneracy = 1;
    List<Color> colors = border.colors.extendColorsToLength(sides);
    List<Color> rst = [];
    for (int i = 0; i < colors.length; i++) {
      rst.addAll(List.generate(2 * degeneracy + 1, (index) => colors[i]));
    }

    return rotateList(rst, -degeneracy).cast<Color>();
  }


  @override
  List<Gradient?> borderFillGradients() {

    return List.generate(3*sides, (index) => null);
  }

  DynamicPath generateInnerDynamicPath(Rect rect) {
    List<DynamicNode> nodes = [];

    final double alpha = (2.0 * pi / sides) / 2;
    double scale = min(rect.width, rect.height) / 2;
    final double centerX = scale;
    final double centerY = scale;
    double cornerRadius = this.cornerRadius.toPX(constraintSize: scale);
    double borderWidth = this.border.width.toPX(constraintSize: scale);

    borderWidth = borderWidth.clamp(0, scale * cos(alpha));
    cornerRadius = cornerRadius.clamp(0, scale * cos(alpha));

    double arcCenterRadius =
        scale - max(cornerRadius, borderWidth) / sin(pi / 2 - alpha);
    cornerRadius = (cornerRadius - borderWidth).clamp(0, double.infinity);

    double startAngle = -pi / 2;

    for (int i = 0; i < sides; i++) {
      double cornerAngle = startAngle + 2 * alpha * i;
      double arcCenterX = (centerX + arcCenterRadius * cos(cornerAngle));
      double arcCenterY = (centerY + arcCenterRadius * sin(cornerAngle));
      Offset start = arcToCubicBezier(
              Rect.fromCircle(
                  center: Offset(arcCenterX, arcCenterY), radius: cornerRadius),
              cornerAngle - alpha,
              2 * alpha)
          .first;
      Offset end = arcToCubicBezier(
              Rect.fromCircle(
                  center: Offset(arcCenterX, arcCenterY), radius: cornerRadius),
              cornerAngle - alpha,
              2 * alpha)
          .last;

      switch (cornerStyle) {
        case CornerStyle.concave:
          Offset center = Offset(arcCenterX, arcCenterY);
          double radius = cornerRadius + borderWidth;
          double startAngle = cornerAngle - alpha;
          double sweepAngle = 2 * alpha;
          Offset newCenter = center +
              Offset.fromDirection((startAngle + sweepAngle / 2).clampAngle(),
                  radius / cos(sweepAngle / 2));
          double newSweep = (-(pi - sweepAngle)).clampAngle();
          double newStart =
              -(pi - (startAngle + sweepAngle / 2) + newSweep / 2).clampAngle();
          double newRadius = (cornerRadius + borderWidth) * tan(alpha);
          double delta = -asin((borderWidth / newRadius).clamp(0, 1))
              .clamp(0.0, -newSweep / 2);

          nodes.addArc(Rect.fromCircle(center: newCenter, radius: newRadius),
              newStart + delta, min(-0.0000001, newSweep - 2 * delta),
              splitTimes: 1);
          break;
        case CornerStyle.rounded:
          nodes.addArc(
              Rect.fromCircle(
                  center: Offset(arcCenterX, arcCenterY), radius: cornerRadius),
              cornerAngle - alpha,
              2 * alpha,
              splitTimes: 1);
          break;

        case CornerStyle.straight:
          nodes.add(DynamicNode(position: start));
          nodes.add(DynamicNode(position: (start + end) / 2));
          nodes.add(DynamicNode(position: end));
          break;
        case CornerStyle.cutout:
          nodes.add(DynamicNode(position: start));
          nodes.add(DynamicNode(position: Offset(arcCenterX, arcCenterY)));
          nodes.add(DynamicNode(position: end));
          break;
      }
    }

    return DynamicPath(size: Size(2 * scale, 2 * scale), nodes: nodes)..resize(rect.size);
  }
  */

}
