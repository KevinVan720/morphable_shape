import 'dart:math';

import 'package:flutter/material.dart';

import '../morphable_shape.dart';

class PolygonShape extends OutlinedShape {
  final int sides;
  final Length cornerRadius;
  final CornerStyle cornerStyle;

  const PolygonShape(
      {this.sides = 5,
      this.cornerStyle = CornerStyle.rounded,
      this.cornerRadius = const Length(0),
      border = defaultBorder})
      : assert(sides >= 3),
        super(border: border);

  PolygonShape.fromJson(Map<String, dynamic> map)
      : cornerStyle =
            parseCornerStyle(map["cornerStyle"]) ?? CornerStyle.rounded,
        cornerRadius = Length.fromJson(map["cornerRadius"]) ?? Length(0),
        sides = map["sides"] ?? 5,
        super(
            border: parseDynamicBorderSide(map["border"]) ??
                defaultBorder);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst = {"type": "PolygonShape"};
    rst.addAll(super.toJson());
    rst["sides"] = sides;
    rst["cornerRadius"] = cornerRadius.toJson();
    rst["cornerStyle"] = cornerStyle.toJson();
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

  /*
  List<Color> borderFillColors() {
    //int totalLength =
    //    generateOuterDynamicPath(Rect.fromLTRB(0, 0, 100, 100)).nodes.length;
    int eachSide=3;
    List<Color> colors = borderSides.colors.extendColors(sides);
    List<Color> rst = [];
    colors.forEach((element) {
      rst.addAll(List.generate(eachSide, (index) => element));
    });
    return rotateList(rst, -((eachSide - 1) / 2).round()).cast<Color>();
  }

  DynamicPath generateInnerDynamicPath(Rect rect) {
    double scale = min(rect.width, rect.height);
    final height = scale;
    final width = scale;
    final double section = (2.0 * pi / sides);
    final double alpha=pi/2-section/2;

    double borderWidth = borderSides.width.toPX(constraintSize: scale).clamp(0.0, scale/2 * cos(section / 2));
    double radius = scale / 2 - borderWidth / sin(alpha);
    final double centerX = width / 2;
    final double centerY = height / 2;

    List<DynamicNode> nodes = [];

    double cornerRadius=this.cornerRadius.toPX(constraintSize: scale);
    if(cornerStyle==CornerStyle.rounded) {
      cornerRadius=cornerRadius - borderWidth;
    }else if(cornerStyle==CornerStyle.cutout){
      cornerRadius=cornerRadius + borderWidth/tan(section);
    }else{
      cornerRadius=cornerRadius*(scale/2-cornerRadius/tan(alpha)*cos(alpha)-borderWidth)/(scale/2-cornerRadius/tan(alpha)*cos(alpha));
    }


    radius = radius.clamp(0.0, scale / 2);
    cornerRadius = cornerRadius.clamp(0.0, radius * cos(section / 2));

    double arcCenterRadius = radius - cornerRadius / sin(alpha);

    double startAngle = -pi / 2;

    for (int i = 0; i < sides; i++) {
      double cornerAngle = startAngle + section * i;
      //if (cornerRadius == 0) {
      //  nodes.add(DynamicNode(
      //      position: Offset((centerX + radius * cos(cornerAngle)),
      //          (centerY + radius * sin(cornerAngle)))));
      //} else {
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
      nodes.add(DynamicNode(position: start));
      //}
      switch (cornerStyle) {
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
              -(2 * pi - section));
          break;
        case CornerStyle.straight:
          nodes.add(DynamicNode(position: (start+end)/2));
          nodes.add(DynamicNode(position: end));
          break;
        case CornerStyle.cutout:
          nodes.add(DynamicNode(position: Offset(arcCenterX, arcCenterY)));
          nodes.add(DynamicNode(position: end));
          break;
      }
    }
    //}

    return DynamicPath(size: Size(width, height), nodes: nodes)
      ..resize(rect.size);
  }

   */

  DynamicPath generateOuterDynamicPath(Rect rect) {
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

    double startAngle = -pi / 2;

    for (int i = 0; i < sides; i++) {
      double cornerAngle = startAngle + section * i;
      //if (cornerRadius == 0) {
      //   nodes.add(DynamicNode(
      //     position: Offset((centerX + radius * cos(cornerAngle)),
      //          (centerY + radius * sin(cornerAngle)))));
      // } else {
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
      nodes.add(DynamicNode(position: start));
      //}
      switch (cornerStyle) {
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
              -(2 * pi - section));
          break;
        case CornerStyle.straight:
          nodes.add(DynamicNode(position: (start + end) / 2));
          nodes.add(DynamicNode(position: end));
          break;
        case CornerStyle.cutout:
          nodes.add(DynamicNode(position: Offset(arcCenterX, arcCenterY)));
          nodes.add(DynamicNode(position: end));
          break;
      }
      // }
    }

    return DynamicPath(size: Size(width, height), nodes: nodes)
      ..resize(rect.size);
  }
}
