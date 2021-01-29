import 'dart:math';

import 'package:flutter/material.dart';
import '../morphable_shape_border.dart';

class StarShape extends Shape {
  final int corners;
  final Length inset;
  final Length cornerRadius;
  final Length insetRadius;

  const StarShape({
    this.corners = 4,
    this.inset = const Length(50, unit: LengthUnit.percent),
    this.cornerRadius = const Length(0),
    this.insetRadius = const Length(0),
  }) : assert(corners > 3);

  StarShape.fromJson(Map<String, dynamic> map)
      : corners = map["corners"],
        inset = Length.fromJson(map['inset'])??Length(0.5, unit: LengthUnit.percent),
        cornerRadius = Length.fromJson(map["cornerRadius"])??Length(0),
        insetRadius = Length.fromJson(map["insetRadius"])??Length(0);

  StarShape copyWith({
    int? corners,
    Length? inset,
    Length? cornerRadius,
    Length? insetRadius,
  }) {
    return StarShape(
      corners: corners ?? this.corners,
      inset: inset ?? this.inset,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      insetRadius: insetRadius ?? this.insetRadius,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst = {"name": this.runtimeType.toString()};
    rst["corners"] = corners;
    rst["inset"] = inset.toJson();
    rst["cornerRadius"]=cornerRadius.toJson();
    rst["insetRadius"]=insetRadius.toJson();
    return rst;
  }

  DynamicPath generateDynamicPath(Rect rect) {
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
    inset = inset.clamp(5.0, radius);
    double sideLength = getThirdSideLength(radius, radius - inset, alpha);
    double beta = getThirdAngle(sideLength, radius, radius - inset);
    double gamma = alpha + beta;

    cornerRadius = cornerRadius.clamp(0, sideLength * tan(beta));

    double avalSideLength = max(sideLength - cornerRadius / tan(beta),0.0);
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
              sweepAngle)[0];
          nodes.add(DynamicNode(position: start));
          nodes.arcTo(Rect.fromCircle(center: center, radius: cornerRadius),
              omega - sweepAngle / 2, sweepAngle);
        }
      } else {
        if (cornerRadius == 0) {
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
                -sweepAngle)[0];
            nodes.add(DynamicNode(position: start));
            nodes.arcTo(Rect.fromCircle(center: center, radius: insetRadius),
                omega + sweepAngle / 2 + pi, -sweepAngle);
          } else {
            sweepAngle = -sweepAngle;
            r = radius - inset - insetRadius / sin(gamma);
            Offset center =
                Offset((r * cos(omega)) + centerX, (r * sin(omega)) + centerY);
            Offset start = arcToCubicBezier(
                Rect.fromCircle(center: center, radius: insetRadius),
                omega - sweepAngle / 2,
                sweepAngle)[0];
            nodes.add(DynamicNode(position: start));
            nodes.arcTo(Rect.fromCircle(center: center, radius: insetRadius),
                omega - sweepAngle / 2, sweepAngle);
          }
        }
      }
    }

    return DynamicPath(size: Size(width, height), nodes: nodes)
      ..resize(rect.size);
  }
}
