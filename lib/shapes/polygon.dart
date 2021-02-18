import 'dart:math';

import 'package:flutter/material.dart';
import 'package:bezier/bezier.dart';
import '../morphable_shape.dart';

class PolygonShape extends FilledBorderShape {
  final int sides;
  final Length cornerRadius;
  final CornerStyle cornerStyle;
  final DynamicBorderSides border;

  const PolygonShape(
      {this.sides = 5,
      this.cornerStyle = CornerStyle.rounded,
      this.cornerRadius = const Length(0),
      this.border = const DynamicBorderSides(
          width: Length(20, unit: LengthUnit.percent),
          colors: [
            Colors.red,
            Colors.blue,
            Colors.green,
            Colors.teal,
            Colors.yellow
          ])})
      : assert(sides >= 3);

  PolygonShape.fromJson(Map<String, dynamic> map)
      : cornerStyle =
            parseCornerStyle(map["cornerStyle"]) ?? CornerStyle.rounded,
        cornerRadius = Length.fromJson(map["cornerRadius"]) ?? Length(0),
        sides = map["sides"] ?? 5,
        this.border = const DynamicBorderSides(
            width: Length(20, unit: LengthUnit.percent),
            colors: [Colors.red, Colors.blue, Colors.green]);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst = {"type": "PolygonShape"};
    rst.addAll(super.toJson());
    rst["sides"] = sides;
    rst["cornerRadius"] = cornerRadius.toJson();
    rst["cornerStyle"] = cornerStyle.toJson();
    rst["border"] = border.toJson();
    return rst;
  }

  PolygonShape copyWith({
    CornerStyle? cornerStyle,
    Length? cornerRadius,
    int? sides,
    DynamicBorderSides? border,
  }) {
    return PolygonShape(
      border: border ?? this.border,
      cornerStyle: cornerStyle ?? this.cornerStyle,
      sides: sides ?? this.sides,
      cornerRadius: cornerRadius ?? this.cornerRadius,
    );
  }

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

  DynamicPath generateInnerDynamicPath(Rect rect) {
    List<DynamicNode> nodes = [];

    final double section = (2.0 * pi / sides);
    double scale = min(rect.width, rect.height);
    final height = scale;
    final width = scale;
    final double centerX = width / 2;
    final double centerY = height / 2;
    double cornerRadius = this.cornerRadius.toPX(constraintSize: scale);
    double borderWidth = this.border.width.toPX(constraintSize: scale);

    borderWidth = borderWidth.clamp(0, scale / 2 * cos(section / 2));
    cornerRadius = cornerRadius.clamp(0, scale / 2 * cos(section / 2));

    double arcCenterRadius =
        scale / 2 - max(cornerRadius, borderWidth) / sin(pi / 2 - section / 2);
    cornerRadius = (cornerRadius - borderWidth).clamp(0, double.infinity);

    double startAngle = -pi / 2;

    for (int i = 0; i < sides; i++) {
      double cornerAngle = startAngle + section * i;
      double arcCenterX = (centerX + arcCenterRadius * cos(cornerAngle));
      double arcCenterY = (centerY + arcCenterRadius * sin(cornerAngle));
      Offset start = arcToCubicBezier(
              Rect.fromCircle(
                  center: Offset(arcCenterX, arcCenterY), radius: cornerRadius),
              cornerAngle - section / 2,
              section)
          .first;
      Offset end = arcToCubicBezier(
              Rect.fromCircle(
                  center: Offset(arcCenterX, arcCenterY), radius: cornerRadius),
              cornerAngle - section / 2,
              section)
          .last;


      //print(start.toJson().toString()+"< "+end.toJson().toString());


      switch (cornerStyle) {
        case CornerStyle.concave:
          Offset center=Offset(arcCenterX, arcCenterY);
          double radius=cornerRadius+borderWidth;
          double startAngle=cornerAngle - section / 2;
          double sweepAngle=section;
          Offset newCenter = center +
              Offset.fromDirection((startAngle + sweepAngle / 2).clampAngle(),
                  radius / cos(sweepAngle / 2));
          double newSweep = (-(pi - sweepAngle)).clampAngle();
          double newStart =
          -(pi - (startAngle + sweepAngle / 2) + newSweep / 2).clampAngle();
          double newRadius=(cornerRadius+borderWidth) * tan(section / 2);
          double delta=-asin((borderWidth/newRadius).clamp(0, 1)).clamp(0.0, -newSweep/2);

        nodes.addArc(
              Rect.fromCircle(
                  center: newCenter, radius: newRadius),
              newStart+delta,
            min(-0.0000001, newSweep-2*delta),
              splitTimes: 1);
        break;
        case CornerStyle.rounded:
          nodes.addArc(
              Rect.fromCircle(
                  center: Offset(arcCenterX, arcCenterY), radius: cornerRadius),
              cornerAngle - section / 2,
              section, splitTimes: 1);
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

    return DynamicPath(size: Size(width, height), nodes: nodes)
      ..resize(rect.size);
  }

  DynamicPath generateOuterDynamicPath(Rect rect) {
    List<DynamicNode> nodes = [];

    final double section = (2.0 * pi / sides);
    double scale = min(rect.width, rect.height);
    final height = scale;
    final width = scale;
    final double centerX = width / 2;
    final double centerY = height / 2;
    double cornerRadius = this.cornerRadius.toPX(constraintSize: scale);
    double borderWidth = this.border.width.toPX(constraintSize: scale);

    borderWidth = borderWidth.clamp(0, scale / 2 * cos(section / 2));
    cornerRadius = cornerRadius.clamp(0, scale / 2 * cos(section / 2));

    double arcCenterRadius = 0;

    switch (cornerStyle) {

      case CornerStyle.rounded:
        arcCenterRadius = scale / 2 - cornerRadius / sin(pi / 2 - section / 2);
        break;
      case CornerStyle.concave:
      case CornerStyle.cutout:
        arcCenterRadius = scale / 2 -
            cornerRadius / sin(pi / 2 - section / 2) +
            borderWidth / sin(section / 2);
        arcCenterRadius = arcCenterRadius.clamp(0.0, scale / 2);
        cornerRadius -= borderWidth / tan(section / 2);
        cornerRadius = cornerRadius.clamp(0.0, scale / 2);
        break;

      case CornerStyle.straight:
        cornerRadius -= borderWidth *
            (1 - cos(section / 2)) /
            sin(section / 2) /
            tan(section / 2);
        cornerRadius = cornerRadius.clamp(0.0, scale / 2);
        arcCenterRadius = scale / 2 - cornerRadius / sin(pi / 2 - section / 2);
        arcCenterRadius = arcCenterRadius.clamp(0.0, scale / 2);
        break;
    }

    double startAngle = -pi / 2;

    for (int i = 0; i < sides; i++) {
      double cornerAngle = startAngle + section * i;
      double arcCenterX = (centerX + arcCenterRadius * cos(cornerAngle));
      double arcCenterY = (centerY + arcCenterRadius * sin(cornerAngle));
      Offset start = arcToCubicBezier(
              Rect.fromCircle(
                  center: Offset(arcCenterX, arcCenterY), radius: cornerRadius),
              cornerAngle - section / 2,
              section,splitTimes: 1)
          .first;
      Offset end = arcToCubicBezier(
              Rect.fromCircle(
                  center: Offset(arcCenterX, arcCenterY), radius: cornerRadius),
              cornerAngle - section / 2,
              section,splitTimes: 1)
          .last;

      //print(Offset(arcCenterX, arcCenterY).toJson().toString());
      //print(cornerRadius.toString()+","+cornerAngle.toDegree().toString()+","+section.toDegree().toString());
      //print(start.toJson().toString()+"< "+end.toJson().toString());

      switch (cornerStyle) {
        case CornerStyle.concave:
        nodes.addStyledCorner(Offset(arcCenterX, arcCenterY), cornerRadius,
           cornerAngle - section / 2, section,
            style: CornerStyle.concave,splitTimes: 1);
        break;
        case CornerStyle.rounded:
          nodes.addArc(
              Rect.fromCircle(
                  center: Offset(arcCenterX, arcCenterY), radius: cornerRadius),
              cornerAngle - section / 2,
              section,splitTimes: 1);
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

    return DynamicPath(size: Size(width, height), nodes: nodes)
      ..resize(rect.size);
  }
}
