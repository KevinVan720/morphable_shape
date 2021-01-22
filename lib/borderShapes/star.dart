import 'dart:math';

import 'package:flutter/material.dart';
import '../MorphableShapeBorder.dart';

class StarShape extends Shape {
  final int corners;
  final Length inset;
  final Length cornerRadius;

  StarShape({this.corners=4, this.inset=const Length(0.5, unit: LengthUnit.percent),
  this.cornerRadius=const Length(0),
  }) : assert(corners > 3);

  StarShape.fromJson(Map<String, dynamic> map)
      : corners=map["corners"],
  inset=map['inset'],
  cornerRadius=map["cornerRadius"];

  Shape copyWith() {
    return BubbleShape();
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst={"name": this.runtimeType};
    rst["corners"]=corners;
    rst["inset"]=inset;
    return rst;
  }

  DynamicPath generateDynamicPath(Rect rect) {
    List<DynamicNode> nodes = [];

    double scale = min(rect.width, rect.height);
    double cornerRadius = this.cornerRadius.toPX(constraintSize: scale);

    final height = scale;
    final width = scale;

    final int vertices = corners * 2;
    final double alpha = (2 * pi) / vertices;
    final double radius = min(height, width) / 2.0;
    final double centerX = width / 2;
    final double centerY = height / 2;

    double inset=this.inset.toPX(constraintSize: radius);
    inset=inset.clamp(0, radius);
    double sideLength=getThirdSideLength(radius, radius-inset, alpha);
    double beta=getThirdAngle(sideLength, radius, radius-inset);

    cornerRadius = cornerRadius.clamp(0, sideLength * tan(beta));


    for (int i = 0 ; i <vertices; i++) {
      final double r;
      final double omega = -pi/2 + alpha * i;
      if(i.isEven) {
        if(cornerRadius==0) {
          r = radius;
          nodes.add(DynamicNode(position: Offset((r * cos(omega)) + centerX, (r * sin(omega)) + centerY)));
        }else{
          r=radius-cornerRadius/sin(beta);
          Offset center= Offset((r * cos(omega)) + centerX, (r * sin(omega)) + centerY);
          double sweepAngle=2*(pi/2-beta);
            Offset start = arcToCubicBezier(
                Rect.fromCircle(
                    center: center, radius: cornerRadius),
                omega-sweepAngle/2, sweepAngle)[0];
            nodes.add(DynamicNode(position: start));
          nodes.arcTo(Rect.fromCircle(center: center, radius: cornerRadius), omega-sweepAngle/2, sweepAngle);
        }
      }else{
        if(cornerRadius==0) {
          r=radius-inset;
          nodes.add(DynamicNode(position: Offset((r * cos(omega)) + centerX, (r * sin(omega)) + centerY)));
        }else{
          r=radius-cornerRadius/sin(beta);
          Offset center= Offset((r * cos(omega)) + centerX, (r * sin(omega)) + centerY);
          double sweepAngle=2*(pi/2-beta);
          Offset start = arcToCubicBezier(
              Rect.fromCircle(
                  center: center, radius: cornerRadius),
              omega+sweepAngle/2+pi, -sweepAngle)[0];
          nodes.add(DynamicNode(position: start));
          nodes.arcTo(Rect.fromCircle(center: center, radius: cornerRadius), omega+sweepAngle/2+pi, -sweepAngle);
        }
      }

    }

    return DynamicPath(size: Size(width, height), nodes: nodes)..resize(rect.size);
  }

}
