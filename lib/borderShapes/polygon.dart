import 'dart:math';

import 'package:flutter/material.dart';

import '../morphable_shape_border.dart';

class PolygonShape extends Shape {
  final int sides;
  //final double startAngle;
  final Length cornerRadius;
  final CornerStyle cornerStyle;

  const PolygonShape({this.sides = 5,
    this.cornerStyle = CornerStyle.rounded,
    this.cornerRadius = const Length(0)})
      : assert(sides >= 3);

  PolygonShape.fromJson(Map<String, dynamic> map)
      :
        cornerStyle = parseCornerStyle(map["cornerStyle"])??CornerStyle.rounded,
        cornerRadius = Length.fromJson(map["cornerRadius"])??Length(0),
        sides = map["sides"]??5;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst = {"name": this.runtimeType.toString()};
    rst["sides"] = sides;
    rst["cornerRadius"]= cornerRadius.toJson();
    rst["cornerStyle"]=cornerStyle.toJson();
    return rst;
  }

  PolygonShape copyWith({
    CornerStyle? cornerStyle,
  Length? cornerRadius,
    int? sides,
}) {
    return PolygonShape(
      cornerStyle: cornerStyle ?? this.cornerStyle,
      sides: sides?? this.sides,
      cornerRadius: cornerRadius??this.cornerRadius,
    );
  }

  DynamicPath generateDynamicPath(Rect rect) {
    List<DynamicNode> nodes = [];

    double scale = min(rect.width, rect.height);
    double cornerRadius = this.cornerRadius.toPX(constraintSize: scale);

    final height = scale;
    final width = scale;

    final double section = (2.0 * pi / sides);
    final double polygonSize = min(width, height);
    final double radius = polygonSize / 2;
    final double centerX = width / 2;
    final double centerY = height / 2;

    cornerRadius = cornerRadius.clamp(0, radius * cos(section / 2));

    double arcCenterRadius = radius - cornerRadius / sin(pi / 2 - section / 2);

    double startAngle=-pi/2;

    for (int i = 0; i < sides; i++) {
      double cornerAngle = startAngle + section * i;
      if (cornerRadius == 0) {
        nodes.add(DynamicNode(
            position: Offset((centerX + radius * cos(cornerAngle)),
                (centerY + radius * sin(cornerAngle)))));
      } else {
        double arcCenterX = (centerX + arcCenterRadius * cos(cornerAngle));
        double arcCenterY = (centerY + arcCenterRadius * sin(cornerAngle));
        //if (i == 0) {
          Offset start = arcToCubicBezier(
              Rect.fromCircle(
                  center: Offset(arcCenterX, arcCenterY), radius: cornerRadius),
              cornerAngle - section / 2,
              section).first;
        Offset end = arcToCubicBezier(
            Rect.fromCircle(
                center: Offset(arcCenterX, arcCenterY), radius: cornerRadius),
            cornerAngle - section / 2,
            section).last;
          nodes.add(DynamicNode(position: start));
        //}
        switch(cornerStyle) {
          case CornerStyle.rounded:
            nodes.arcTo(
                Rect.fromCircle(
                    center: Offset(arcCenterX, arcCenterY), radius: cornerRadius),
                cornerAngle - section / 2,
                section);
            break;
          case CornerStyle.concave:
            nodes.arcTo(
                Rect.fromCircle(
                    center: Offset(arcCenterX, arcCenterY), radius: cornerRadius),
                cornerAngle - section / 2,
                -(2*pi-section));
            break;
          case CornerStyle.straight:
            nodes.add(DynamicNode(position: end));
            break;
          case CornerStyle.cutout:
            nodes.add(DynamicNode(position: Offset(arcCenterX, arcCenterY)));
            nodes.add(DynamicNode(position: end));
            break;
        }

      }
    }

    return DynamicPath(size: Size(width, height), nodes: nodes)
      ..resize(rect.size);
  }
}
