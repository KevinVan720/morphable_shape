import 'dart:math';

import 'package:flutter/material.dart';
import 'package:morphable_shape/morphable_shape.dart';

///Star shape, with different corner radius & style, inset radius & style.
class StarShapeBorder extends OutlinedShapeBorder {
  final int corners;
  final Dimension inset;
  final Dimension cornerRadius;
  final Dimension insetRadius;
  final CornerStyle cornerStyle;
  final CornerStyle insetStyle;

  const StarShapeBorder({
    this.corners = 4,
    this.inset = const Length(50, unit: LengthUnit.percent),
    this.cornerRadius = const Length(0),
    this.insetRadius = const Length(0),
    this.cornerStyle = CornerStyle.rounded,
    this.insetStyle = CornerStyle.rounded,
    border = DynamicBorderSide.none,
  })  : assert(corners >= 3),
        super(border: border);

  StarShapeBorder.fromJson(Map<String, dynamic> map)
      : cornerStyle =
            parseCornerStyle(map["cornerStyle"]) ?? CornerStyle.rounded,
        insetStyle = parseCornerStyle(map["insetStyle"]) ?? CornerStyle.rounded,
        corners = map["corners"] ?? 4,
        inset = parseDimension(map['inset']) ??
            Length(50, unit: LengthUnit.percent),
        cornerRadius = parseDimension(map["cornerRadius"]) ?? Length(0),
        insetRadius = parseDimension(map["insetRadius"]) ?? Length(0),
        super(
            border: parseDynamicBorderSide(map["border"]) ??
                DynamicBorderSide.none);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst = {"type": "Star"};
    rst.addAll(super.toJson());
    rst["corners"] = corners;
    rst["inset"] = inset.toJson();
    rst["cornerRadius"] = cornerRadius.toJson();
    rst["insetRadius"] = insetRadius.toJson();
    rst["cornerStyle"] = cornerStyle.toJson();
    rst["insetStyle"] = insetStyle.toJson();
    return rst;
  }

  StarShapeBorder copyWith({
    int? corners,
    Dimension? inset,
    Dimension? cornerRadius,
    Dimension? insetRadius,
    CornerStyle? cornerStyle,
    CornerStyle? insetStyle,
    DynamicBorderSide? border,
  }) {
    return StarShapeBorder(
      corners: corners ?? this.corners,
      inset: inset ?? this.inset,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      insetRadius: insetRadius ?? this.insetRadius,
      cornerStyle: cornerStyle ?? this.cornerStyle,
      insetStyle: insetStyle ?? this.insetStyle,
      border: border ?? this.border,
    );
  }

  bool isSameMorphGeometry(MorphableShapeBorder shape) {
    return shape is StarShapeBorder && shape.corners == this.corners;
  }

  DynamicPath generateOuterDynamicPath(Rect rect) {
    List<DynamicNode> nodes = [];

    double scale = min(rect.width, rect.height) / 2;
    double cornerRadius = this.cornerRadius.toPX(constraint: scale / 2);
    double insetRadius = this.insetRadius.toPX(constraint: scale / 2);

    final int vertices = corners * 2;
    final double alpha = (2 * pi) / vertices;

    final double centerX = scale;
    final double centerY = scale;

    double inset = this.inset.toPX(constraint: scale);
    inset = inset.clamp(0.0, scale * 0.999);
    double sideLength = getThirdSideLength(scale, scale - inset, alpha);
    double beta = getThirdAngle(sideLength, scale, scale - inset);
    double gamma = alpha + beta;

    cornerRadius = cornerRadius.clamp(0, sideLength * tan(beta));

    double avalSideLength = max(sideLength - cornerRadius / tan(beta), 0.0);
    if (gamma <= pi / 2) {
      insetRadius = insetRadius.clamp(0, avalSideLength * tan(gamma));
    } else {
      insetRadius = insetRadius.clamp(0, avalSideLength * tan(pi - gamma));
    }

    for (int i = 0; i < vertices; i++) {
      double r;
      double omega = -pi / 2 + alpha * i;
      if (i.isEven) {
        r = scale - cornerRadius / sin(beta);
        Offset center =
            Offset((r * cos(omega)) + centerX, (r * sin(omega)) + centerY);
        double sweepAngle = 2 * (pi / 2 - beta);
        Offset start = arcToCubicBezier(
                Rect.fromCircle(center: center, radius: cornerRadius),
                omega - sweepAngle / 2,
                sweepAngle)
            .first;
        Offset end = arcToCubicBezier(
                Rect.fromCircle(center: center, radius: cornerRadius),
                omega - sweepAngle / 2,
                sweepAngle)
            .last;

        switch (cornerStyle) {
          case CornerStyle.rounded:
            nodes.addArc(Rect.fromCircle(center: center, radius: cornerRadius),
                omega - sweepAngle / 2, sweepAngle,
                splitTimes: 1);
            break;
          case CornerStyle.concave:
            nodes.addStyledCorner(
                center, cornerRadius, omega - sweepAngle / 2, sweepAngle,
                splitTimes: 1, style: CornerStyle.concave);
            break;
          case CornerStyle.straight:
            nodes.add(DynamicNode(position: start));
            nodes.add(DynamicNode(position: (start + end) / 2));
            nodes.add(DynamicNode(position: end));
            break;
          case CornerStyle.cutout:
            nodes.add(DynamicNode(position: start));
            nodes.add(DynamicNode(position: center));
            nodes.add(DynamicNode(position: end));
            break;
        }
      } else {
        double sweepAngle = pi - 2 * gamma;
        if (gamma <= pi / 2) {
          r = scale - inset + insetRadius / sin(gamma);
          Offset center =
              Offset((r * cos(omega)) + centerX, (r * sin(omega)) + centerY);
          Offset start = arcToCubicBezier(
                  Rect.fromCircle(center: center, radius: insetRadius),
                  omega + sweepAngle / 2 + pi,
                  -sweepAngle)
              .first;
          Offset end = arcToCubicBezier(
                  Rect.fromCircle(center: center, radius: insetRadius),
                  omega + sweepAngle / 2 + pi,
                  -sweepAngle)
              .last;

          switch (insetStyle) {
            case CornerStyle.rounded:
              nodes.addArc(Rect.fromCircle(center: center, radius: insetRadius),
                  omega + sweepAngle / 2 + pi, -sweepAngle,
                  splitTimes: 1);
              break;
            case CornerStyle.concave:
              r = scale - inset;
              Offset center = Offset(
                  (r * cos(omega)) + centerX, (r * sin(omega)) + centerY);
              double newSweep = ((pi - sweepAngle)).clampAngleWithin();
              double newStart =
                  ((omega + sweepAngle / 2 + pi + sweepAngle / 2) +
                          newSweep / 2)
                      .clampAngleWithin();
              nodes.addArc(
                  Rect.fromCircle(
                      center: center,
                      radius: insetRadius * tan(sweepAngle / 2)),
                  newStart,
                  newSweep,
                  splitTimes: 1);
              break;
            case CornerStyle.straight:
              nodes.add(DynamicNode(position: start));
              nodes.add(DynamicNode(position: (start + end) / 2));
              nodes.add(DynamicNode(position: end));
              break;
            case CornerStyle.cutout:
              nodes.add(DynamicNode(position: start));
              nodes.add(DynamicNode(position: center));
              nodes.add(DynamicNode(position: end));
              break;
          }
        } else {
          sweepAngle = -sweepAngle;
          r = scale - inset - insetRadius / sin(gamma);
          Offset center =
              Offset((r * cos(omega)) + centerX, (r * sin(omega)) + centerY);
          Offset start = arcToCubicBezier(
                  Rect.fromCircle(center: center, radius: insetRadius),
                  omega - sweepAngle / 2,
                  sweepAngle)
              .first;
          Offset end = arcToCubicBezier(
                  Rect.fromCircle(center: center, radius: insetRadius),
                  omega - sweepAngle / 2,
                  sweepAngle)
              .last;

          switch (insetStyle) {
            case CornerStyle.rounded:
              nodes.addArc(Rect.fromCircle(center: center, radius: insetRadius),
                  omega - sweepAngle / 2, sweepAngle,
                  splitTimes: 1);
              break;
            case CornerStyle.concave:
              nodes.addStyledCorner(
                  center, insetRadius, omega - sweepAngle / 2, sweepAngle,
                  splitTimes: 1, style: CornerStyle.concave);

              break;
            case CornerStyle.straight:
              nodes.add(DynamicNode(position: start));
              nodes.add(DynamicNode(position: (start + end) / 2));
              nodes.add(DynamicNode(position: end));
              break;
            case CornerStyle.cutout:
              nodes.add(DynamicNode(position: start));
              nodes.add(DynamicNode(position: center));
              nodes.add(DynamicNode(position: end));
              break;
          }
        }
      }
    }

    return DynamicPath(size: Size(2 * scale, 2 * scale), nodes: nodes)
      ..resize(rect.size);
  }
}
