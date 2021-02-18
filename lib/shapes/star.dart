import 'dart:math';

import 'package:flutter/material.dart';
import '../morphable_shape.dart';

class StarShape extends FilledBorderShape {
  final int corners;
  final Length inset;
  final Length cornerRadius;
  final Length insetRadius;
  final CornerStyle cornerStyle;
  final CornerStyle insetStyle;
  final DynamicBorderSides border;

  const StarShape({
    this.corners = 4,
    this.inset = const Length(50, unit: LengthUnit.percent),
    this.cornerRadius = const Length(0),
    this.insetRadius = const Length(0),
    this.cornerStyle = CornerStyle.rounded,
    this.insetStyle = CornerStyle.rounded,
    this.border = const DynamicBorderSides(
        width: Length(20, unit: LengthUnit.percent),
        colors: [
          Colors.red,
          Colors.blue,
          Colors.green,
          Colors.teal,
          Colors.yellow
        ])
  })  : assert(corners >= 3);

  StarShape.fromJson(Map<String, dynamic> map)
      : cornerStyle =
            parseCornerStyle(map["cornerStyle"]) ?? CornerStyle.rounded,
        insetStyle = parseCornerStyle(map["insetStyle"]) ?? CornerStyle.rounded,
        corners = map["corners"] ?? 4,
        inset = Length.fromJson(map['inset']) ??
            Length(50, unit: LengthUnit.percent),
        cornerRadius = Length.fromJson(map["cornerRadius"]) ?? Length(0),
        insetRadius = Length.fromJson(map["insetRadius"]) ?? Length(0),
        this.border = const DynamicBorderSides(
            width: Length(20, unit: LengthUnit.percent),
            colors: [Colors.red, Colors.blue, Colors.green]);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst = {"type": "StarShape"};
    rst.addAll(super.toJson());
    rst["corners"] = corners;
    rst["inset"] = inset.toJson();
    rst["cornerRadius"] = cornerRadius.toJson();
    rst["insetRadius"] = insetRadius.toJson();
    rst["cornerStyle"] = cornerStyle.toJson();
    rst["insetStyle"] = insetStyle.toJson();
    rst["border"] = border.toJson();
    return rst;
  }

  StarShape copyWith({
    int? corners,
    Length? inset,
    Length? cornerRadius,
    Length? insetRadius,
    CornerStyle? cornerStyle,
    CornerStyle? insetStyle,
    DynamicBorderSides? border,
  }) {
    return StarShape(
      corners: corners ?? this.corners,
      inset: inset ?? this.inset,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      insetRadius: insetRadius ?? this.insetRadius,
      cornerStyle: cornerStyle ?? this.cornerStyle,
      insetStyle: insetStyle ?? this.insetStyle,
      border: border ?? this.border,
    );
  }

  @override
  List<Color> borderFillColors() {
    int degeneracy = 1;
    List<Color> colors = border.colors.extendColorsToLength(corners);
    List<Color> rst = [];
    for (int i = 0; i < colors.length; i++) {
      rst.addAll(List.generate(2 * degeneracy + 1, (index) => colors[i]));
    }

    return rotateList(rst, -degeneracy).cast<Color>();
  }

  DynamicPath generateInnerDynamicPath(Rect rect) {
    List<DynamicNode> nodes = [];

    double scale = min(rect.width, rect.height);
    double cornerRadius = this.cornerRadius.toPX(constraintSize: scale);
    double insetRadius = this.insetRadius.toPX(constraintSize: scale);

    final height = scale;
    final width = scale;

    final int vertices = corners * 2;
    final double alpha = (2 * pi) / vertices;
    final double radius = scale / 2;
    final double centerX = width / 2;
    final double centerY = height / 2;

    double inset = this.inset.toPX(constraintSize: radius);
    inset = inset.clamp(0.01 * scale, radius);
    double sideLength = getThirdSideLength(radius, radius - inset, alpha);
    double beta = getThirdAngle(sideLength, radius, radius - inset);
    double gamma = alpha + beta;

    cornerRadius = cornerRadius.clamp(0, sideLength * tan(beta));

    double avalSideLength = max(sideLength - cornerRadius / tan(beta), 0.0);
    if (gamma <= pi / 2) {
      insetRadius = insetRadius.clamp(0, avalSideLength * tan(gamma));
    } else {
      insetRadius = insetRadius.clamp(0, avalSideLength * tan(pi - gamma));
    }

    for (int i = 0; i < vertices; i++) {
      final double r;
      final double omega = -pi / 2 + alpha * i;
      if (i.isEven) {
        if (cornerRadius == 0) {
          r = radius;
          nodes.add(DynamicNode(
              position: Offset(
                  (r * cos(omega)) + centerX, (r * sin(omega)) + centerY)));
        } else {
          r = radius - cornerRadius / sin(beta);
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
                  omega - sweepAngle / 2, sweepAngle);
              break;
            case CornerStyle.concave:
              nodes.addArc(Rect.fromCircle(center: center, radius: cornerRadius),
                  omega - sweepAngle / 2, sweepAngle - 2 * pi);
              break;
            case CornerStyle.straight:
              nodes.add(DynamicNode(position: start));
              nodes.add(DynamicNode(position: end));
              break;
            case CornerStyle.cutout:
              nodes.add(DynamicNode(position: start));
              nodes.add(DynamicNode(position: center));
              nodes.add(DynamicNode(position: end));
              break;
          }
        }
      } else {
        if (insetRadius == 0) {
          r = radius - inset;
          nodes.add(DynamicNode(
              position: Offset(
                  (r * cos(omega)) + centerX, (r * sin(omega)) + centerY)));
        } else {
          double sweepAngle = pi - 2 * gamma;
          if (gamma <= pi / 2) {
            r = radius - inset + insetRadius / sin(gamma);
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
                nodes.addArc(
                    Rect.fromCircle(center: center, radius: insetRadius),
                    omega + sweepAngle / 2 + pi,
                    -sweepAngle);
                break;
              case CornerStyle.concave:
                nodes.addArc(
                    Rect.fromCircle(center: center, radius: insetRadius),
                    omega + sweepAngle / 2 + pi,
                    -sweepAngle - 2 * pi);
                break;
              case CornerStyle.straight:
                nodes.add(DynamicNode(position: start));
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
            r = radius - inset - insetRadius / sin(gamma);
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
                nodes.addArc(
                    Rect.fromCircle(center: center, radius: insetRadius),
                    omega - sweepAngle / 2,
                    sweepAngle);
                break;
              case CornerStyle.concave:
                nodes.addArc(
                    Rect.fromCircle(center: center, radius: insetRadius),
                    omega - sweepAngle / 2,
                    sweepAngle - 2 * pi);
                break;
              case CornerStyle.straight:
                nodes.add(DynamicNode(position: start));
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
    }

    return DynamicPath(size: Size(width, height), nodes: nodes)
      ..resize(rect.size);
  }

  DynamicPath generateOuterDynamicPath(Rect rect) {
    List<DynamicNode> nodes = [];

    double scale = min(rect.width, rect.height);
    double cornerRadius = this.cornerRadius.toPX(constraintSize: scale);
    double insetRadius = this.insetRadius.toPX(constraintSize: scale);

    final height = scale;
    final width = scale;

    final int vertices = corners * 2;
    final double alpha = (2 * pi) / vertices;
    final double radius = scale / 2;
    final double centerX = width / 2;
    final double centerY = height / 2;

    double inset = this.inset.toPX(constraintSize: radius);
    inset = inset.clamp(0.01 * scale, radius);
    double sideLength = getThirdSideLength(radius, radius - inset, alpha);
    double beta = getThirdAngle(sideLength, radius, radius - inset);
    double gamma = alpha + beta;

    cornerRadius = cornerRadius.clamp(0, sideLength * tan(beta));

    double avalSideLength = max(sideLength - cornerRadius / tan(beta), 0.0);
    if (gamma <= pi / 2) {
      insetRadius = insetRadius.clamp(0, avalSideLength * tan(gamma));
    } else {
      insetRadius = insetRadius.clamp(0, avalSideLength * tan(pi - gamma));
    }

    for (int i = 0; i < vertices; i++) {
      final double r;
      final double omega = -pi / 2 + alpha * i;
      if (i.isEven) {
        if (cornerRadius == 0) {
          r = radius;
          nodes.add(DynamicNode(
              position: Offset(
                  (r * cos(omega)) + centerX, (r * sin(omega)) + centerY)));
        } else {
          r = radius - cornerRadius / sin(beta);
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
                  omega - sweepAngle / 2, sweepAngle);
              break;
            case CornerStyle.concave:
              nodes.addArc(Rect.fromCircle(center: center, radius: cornerRadius),
                  omega - sweepAngle / 2, sweepAngle - 2 * pi);
              break;
            case CornerStyle.straight:
              nodes.add(DynamicNode(position: start));
              nodes.add(DynamicNode(position: end));
              break;
            case CornerStyle.cutout:
              nodes.add(DynamicNode(position: start));
              nodes.add(DynamicNode(position: center));
              nodes.add(DynamicNode(position: end));
              break;
          }
        }
      } else {
        if (insetRadius == 0) {
          r = radius - inset;
          nodes.add(DynamicNode(
              position: Offset(
                  (r * cos(omega)) + centerX, (r * sin(omega)) + centerY)));
        } else {
          double sweepAngle = pi - 2 * gamma;
          if (gamma <= pi / 2) {
            r = radius - inset + insetRadius / sin(gamma);
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
                nodes.addArc(
                    Rect.fromCircle(center: center, radius: insetRadius),
                    omega + sweepAngle / 2 + pi,
                    -sweepAngle);
                break;
              case CornerStyle.concave:
                nodes.addArc(
                    Rect.fromCircle(center: center, radius: insetRadius),
                    omega + sweepAngle / 2 + pi,
                    -sweepAngle - 2 * pi);
                break;
              case CornerStyle.straight:
                nodes.add(DynamicNode(position: start));
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
            r = radius - inset - insetRadius / sin(gamma);
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
                nodes.addArc(
                    Rect.fromCircle(center: center, radius: insetRadius),
                    omega - sweepAngle / 2,
                    sweepAngle);
                break;
              case CornerStyle.concave:
                nodes.addArc(
                    Rect.fromCircle(center: center, radius: insetRadius),
                    omega - sweepAngle / 2,
                    sweepAngle - 2 * pi);
                break;
              case CornerStyle.straight:
                nodes.add(DynamicNode(position: start));
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
    }

    return DynamicPath(size: Size(width, height), nodes: nodes)
      ..resize(rect.size);
  }
}
