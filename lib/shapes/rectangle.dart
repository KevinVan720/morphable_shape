import 'dart:math';

import 'package:flutter/material.dart';
import 'package:length_unit/dynamic_border_side.dart';

import '../morphable_shape.dart';
import 'package:vector_math/vector_math.dart' hide Colors;
import 'package:bezier/bezier.dart';
import 'package:morphable_shape/dynamic_path_morph.dart';

///Rectangle shape with various corner style and radius for each corner
class RectangleShape extends FilledBorderShape {
  final CornerStyle topLeftStyle;
  final CornerStyle topRightStyle;
  final CornerStyle bottomLeftStyle;
  final CornerStyle bottomRightStyle;

  final DynamicBorderSide leftBorder;
  final DynamicBorderSide rightBorder;
  final DynamicBorderSide topBorder;
  final DynamicBorderSide bottomBorder;

  final DynamicBorderRadius borderRadius;

  const RectangleShape({
    this.borderRadius =
        const DynamicBorderRadius.all(DynamicRadius.circular(Length(0))),
    this.topLeftStyle = CornerStyle.rounded,
    this.topRightStyle = CornerStyle.rounded,
    this.bottomLeftStyle = CornerStyle.rounded,
    this.bottomRightStyle = CornerStyle.rounded,
    this.topBorder = defaultBorder,
    this.bottomBorder = defaultBorder,
    this.leftBorder = defaultBorder,
    this.rightBorder = defaultBorder,
  });

  RectangleShape.fromJson(Map<String, dynamic> map)
      : borderRadius = parseDynamicBorderRadius(map["borderRadius"]) ??
            DynamicBorderRadius.all(DynamicRadius.circular(Length(0))),
        this.topLeftStyle = CornerStyle.rounded,
        this.topRightStyle = CornerStyle.rounded,
        this.bottomLeftStyle = CornerStyle.rounded,
        this.bottomRightStyle = CornerStyle.rounded,
        this.topBorder =
            parseDynamicBorderSide(map["topBorder"]) ?? defaultBorder,
        this.bottomBorder =
            parseDynamicBorderSide(map["bottomBorder"]) ?? defaultBorder,
        this.leftBorder =
            parseDynamicBorderSide(map["leftBorder"]) ?? defaultBorder,
        this.rightBorder =
            parseDynamicBorderSide(map["rightBorder"]) ?? defaultBorder;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst = {"type": "RectangleShape"};
    rst["borderRadius"] = borderRadius.toJson();
    rst["topLeftStyle"] = topLeftStyle.toJson();
    rst["topRightStyle"] = topRightStyle.toJson();
    rst["bottomLeftStyle"] = bottomLeftStyle.toJson();
    rst["bottomRightStyle"] = bottomRightStyle.toJson();
    rst["leftBorder"] = leftBorder.toJson();
    rst["rightBorder"] = rightBorder.toJson();
    rst["topBorder"] = topBorder.toJson();
    rst["bottomBorder"] = bottomBorder.toJson();
    return rst;
  }

  RectangleShape copyWith(
      {CornerStyle? topLeft,
      CornerStyle? topRight,
      CornerStyle? bottomLeft,
      CornerStyle? bottomRight,
      DynamicBorderSide? topBorder,
      DynamicBorderSide? bottomBorder,
      DynamicBorderSide? leftBorder,
      DynamicBorderSide? rightBorder,
      DynamicBorderRadius? borderRadius}) {
    return RectangleShape(
        topBorder: topBorder ?? this.topBorder,
        bottomBorder: bottomBorder ?? this.bottomBorder,
        leftBorder: leftBorder ?? this.leftBorder,
        rightBorder: rightBorder ?? this.rightBorder,
        topLeftStyle: topLeft ?? this.topLeftStyle,
        topRightStyle: topRight ?? this.topRightStyle,
        bottomLeftStyle: bottomLeft ?? this.bottomLeftStyle,
        bottomRightStyle: bottomRight ?? this.bottomRightStyle,
        borderRadius: borderRadius ?? this.borderRadius);
  }

  List<Color> borderFillColors() {
    List<Color> rst = [];
    rst.addAll(List.generate(3, (index) => topBorder.color));
    rst.addAll(List.generate(3, (index) => rightBorder.color));
    rst.addAll(List.generate(3, (index) => bottomBorder.color));
    rst.addAll(List.generate(3, (index) => leftBorder.color));
    return rotateList(rst, 2).cast<Color>();
  }

  DynamicPath generateInnerDynamicPath(Rect rect) {
    Size size = rect.size;

    double leftSideWidth =
        this.leftBorder.width.toPX(constraintSize: size.width);
    double rightSideWidth =
        this.rightBorder.width.toPX(constraintSize: size.width);
    double topSideWidth =
        this.topBorder.width.toPX(constraintSize: size.height);
    double bottomSideWidth =
        this.bottomBorder.width.toPX(constraintSize: size.height);

    if (leftSideWidth + rightSideWidth > size.width) {
      double ratio = leftSideWidth / (leftSideWidth + rightSideWidth);
      leftSideWidth = size.width * ratio;
      rightSideWidth = size.width * (1 - ratio);
    }

    if (topSideWidth + bottomSideWidth > size.height) {
      double ratio = topSideWidth / (topSideWidth + bottomSideWidth);
      topSideWidth = size.height * ratio;
      bottomSideWidth = size.height * (1 - ratio);
    }

    BorderRadius borderRadius = this.borderRadius.toBorderRadius(size: size);

    double topLeftRadius = borderRadius.topLeft.x;
    double topRightRadius = borderRadius.topRight.x;

    double bottomLeftRadius = borderRadius.bottomLeft.x;
    double bottomRightRadius = borderRadius.bottomRight.x;

    double leftTopRadius = borderRadius.topLeft.y;
    double leftBottomRadius = borderRadius.bottomLeft.y;

    double rightTopRadius = borderRadius.topRight.y;
    double rightBottomRadius = borderRadius.bottomRight.y;

    double topTotal =
        max(topLeftRadius, leftSideWidth) + max(topRightRadius, rightSideWidth);
    double bottomTotal = max(bottomLeftRadius, leftSideWidth) +
        max(bottomRightRadius, rightSideWidth);
    double leftTotal = max(leftTopRadius, topSideWidth) +
        max(leftBottomRadius, bottomSideWidth);
    double rightTotal = max(rightTopRadius, topSideWidth) +
        max(rightBottomRadius, bottomSideWidth);

    if (topTotal > size.width || bottomTotal > size.width) {
      double total = max(topTotal, bottomTotal);
      topLeftRadius *= size.width / total;
      topRightRadius *= size.width / total;
      bottomLeftRadius *= size.width / total;
      bottomRightRadius *= size.width / total;
      leftSideWidth *= size.width / total;
      rightSideWidth *= size.width / total;
      //leftSideWidth =
      //    leftSideWidth.clamp(0, max(topLeftRadius, bottomLeftRadius));
      //rightSideWidth =
      //    rightSideWidth.clamp(0, max(topRightRadius, bottomRightRadius));
    }

    if (leftTotal > size.height || rightTotal > size.height) {
      double total = max(leftTotal, rightTotal);
      leftTopRadius *= size.height / total;
      rightTopRadius *= size.height / total;
      leftBottomRadius *= size.height / total;
      rightBottomRadius *= size.height / total;
      topSideWidth *= size.height / total;
      bottomSideWidth *= size.height / total;
      //topSideWidth = topSideWidth.clamp(0, max(leftTopRadius, rightTopRadius));
      //bottomSideWidth =
      //    bottomSideWidth.clamp(0, max(leftBottomRadius, rightBottomRadius));
    }

    final double left = rect.left;
    final double top = rect.top;
    final double bottom = rect.bottom;
    final double right = rect.right;

    List<DynamicNode> nodes = [];

    switch (topRightStyle) {
      case CornerStyle.rounded:
        nodes.add(DynamicNode(
            position: Offset(right - max(topRightRadius, rightSideWidth),
                top + topSideWidth)));
        nodes.arcTo(
            Rect.fromCenter(
                center: Offset(right - max(topRightRadius, rightSideWidth),
                    top + max(rightTopRadius, topSideWidth)),
                width: max(0, 2 * topRightRadius - 2 * rightSideWidth),
                height: max(0, 2 * rightTopRadius - 2 * topSideWidth)),
            -pi / 2,
            pi / 2);
        break;
      case CornerStyle.cutout:
        nodes.add(DynamicNode(
            position: Offset(right - max(topRightRadius, rightSideWidth),
                top + topSideWidth)));
        nodes.add(DynamicNode(
            position: Offset(right - max(topRightRadius, rightSideWidth),
                top + max(rightTopRadius, topSideWidth))));
        nodes.add(DynamicNode(
            position: Offset(right - rightSideWidth,
                top + max(rightTopRadius, topSideWidth))));
        break;
      case CornerStyle.straight:
        Offset start = Offset(
            right - max(rightSideWidth, topRightRadius), top + topSideWidth);
        Offset end = Offset(
            right - rightSideWidth, top + max(topSideWidth, rightTopRadius));
        nodes.add(DynamicNode(position: start));
        nodes.add(DynamicNode(
          position: (start + end) / 2,
        ));
        nodes.add(DynamicNode(position: end));
        break;
      case CornerStyle.concave:
        List<Bezier> beziers = nodes.arcToCubicBezierCurve(
            Rect.fromCenter(
                center: Offset(right, top),
                width: 2 * max(topRightRadius, rightSideWidth),
                height: 2 * max(rightTopRadius, topSideWidth)),
            pi,
            -pi / 2);
        List<double> intersections11 = beziers[0].intersectionsWithLineSegment(
            Offset(left - 10, top + topSideWidth).toVector2(),
            Offset(right + 10, top + topSideWidth).toVector2());

        List<double> intersections12 = beziers[1].intersectionsWithLineSegment(
            Offset(left - 10, top + topSideWidth).toVector2(),
            Offset(right + 10, top + topSideWidth).toVector2());

        List<double> intersections22 = beziers[1].intersectionsWithLineSegment(
            Offset(right - rightSideWidth, top - 10).toVector2(),
            Offset(right - rightSideWidth, bottom + 10).toVector2());

        List<double> intersections21 = beziers[0].intersectionsWithLineSegment(
            Offset(right - rightSideWidth, top - 10).toVector2(),
            Offset(right - rightSideWidth, bottom + 10).toVector2());

        Bezier bezier1 = beziers[0];
        Bezier bezier2 = beziers[1];
        double t1 = 0, t2 = 1;

        if (intersections11.isNotEmpty && intersections22.isNotEmpty) {
          t1 = intersections11.first.clamp(0.0001, 0.9999);
          t2 = intersections22.first.clamp(0.0001, 0.9999);
          bezier1 = beziers[0].rightSubcurveAt(t1);
          bezier2 = beziers[1].leftSubcurveAt(t2);
        }
        if (intersections11.isNotEmpty && intersections21.isNotEmpty) {
          t1 = intersections11.first.clamp(0.0001, 0.9999);
          t2 = intersections21.first.clamp(0.0001, 0.9999);
          if (t2 < t1) {
            double temp = t2;
            t2 = t1;
            t1 = temp;
          }
          bezier1 = beziers[0].subcurveBetween(t1, t2);
          bezier2 = beziers[0].subcurveBetween(t2 - 0.00001, t2);
        }
        if (intersections22.isNotEmpty && intersections12.isNotEmpty) {
          t1 = intersections12.first.clamp(0.0001, 0.9999);
          t2 = intersections22.first.clamp(0.0001, 0.9999);
          if (t2 < t1) {
            double temp = t2;
            t2 = t1;
            t1 = temp;
          }
          bezier1 = beziers[1].subcurveBetween(t1, t1 + 0.00001);
          bezier2 = beziers[1].subcurveBetween(t1, t2);
        }
        if (bezier1.endPoint.toOffset().dx <= right - rightSideWidth &&
                bezier1.endPoint.toOffset().dy >= top + topSideWidth ||
            bezier2.startPoint.toOffset().dx <= right - rightSideWidth &&
                bezier2.startPoint.toOffset().dy >= top + topSideWidth) {
          nodes.add(DynamicNode(
              position: bezier1.startPoint.toOffset(),
              next: bezier1.points[1].toOffset()));
          nodes.add(DynamicNode(
              position: bezier1.endPoint.toOffset(),
              prev: bezier1.points[2].toOffset(),
              next: bezier2.points[1].toOffset()));
          nodes.add(DynamicNode(
              position: bezier2.endPoint.toOffset(),
              prev: bezier2.points[2].toOffset()));
        } else {
          nodes.add(DynamicNode(
              position: Offset(right - rightSideWidth, top + topSideWidth)));
          nodes.add(DynamicNode(
              position: Offset(right - rightSideWidth, top + topSideWidth)));
          nodes.add(DynamicNode(
              position: Offset(right - rightSideWidth, top + topSideWidth)));
        }

        break;
    }

    switch (bottomRightStyle) {
      case CornerStyle.rounded:
        nodes.add(DynamicNode(
            position: Offset(right - rightSideWidth,
                bottom - max(bottomSideWidth, rightBottomRadius))));
        nodes.arcTo(
            Rect.fromCenter(
                center: Offset(right - max(bottomRightRadius, rightSideWidth),
                    bottom - max(rightBottomRadius, bottomSideWidth)),
                width: max(0, 2 * bottomRightRadius - 2 * rightSideWidth),
                height: max(0, 2 * rightBottomRadius - 2 * bottomSideWidth)),
            0,
            pi / 2);

        break;
      case CornerStyle.cutout:
        nodes.add(DynamicNode(
            position: Offset(right - rightSideWidth,
                bottom - max(rightBottomRadius, bottomSideWidth))));
        nodes.add(DynamicNode(
            position: Offset(right - max(bottomRightRadius, rightSideWidth),
                bottom - max(rightBottomRadius, bottomSideWidth))));
        nodes.add(DynamicNode(
            position: Offset(right - max(bottomRightRadius, rightSideWidth),
                bottom - bottomSideWidth)));
        break;
      case CornerStyle.straight:
        Offset start = Offset(right - rightSideWidth,
            bottom - max(bottomSideWidth, rightBottomRadius));
        Offset end = Offset(right - max(rightSideWidth, bottomRightRadius),
            bottom - bottomSideWidth);
        nodes.add(DynamicNode(position: start));
        nodes.add(DynamicNode(
          position: (start + end) / 2,
        ));
        nodes.add(DynamicNode(position: end));
        break;
      case CornerStyle.concave:
        List<Bezier> beziers = nodes.arcToCubicBezierCurve(
            Rect.fromCenter(
                center: Offset(right, bottom),
                width: 2 * max(bottomRightRadius, rightSideWidth),
                height: 2 * max(rightBottomRadius, bottomSideWidth)),
            -pi / 2,
            -pi / 2);
        List<double> intersections11 = beziers[0].intersectionsWithLineSegment(
            Offset(right - rightSideWidth, top - 10).toVector2(),
            Offset(right - rightSideWidth, bottom + 10).toVector2());

        List<double> intersections12 = beziers[1].intersectionsWithLineSegment(
            Offset(right - rightSideWidth, top - 10).toVector2(),
            Offset(right - rightSideWidth, bottom + 10).toVector2());

        List<double> intersections22 = beziers[1].intersectionsWithLineSegment(
            Offset(left - 10, bottom - bottomSideWidth).toVector2(),
            Offset(right + 10, bottom - bottomSideWidth).toVector2());

        List<double> intersections21 = beziers[0].intersectionsWithLineSegment(
            Offset(left - 10, bottom - bottomSideWidth).toVector2(),
            Offset(right + 10, bottom - bottomSideWidth).toVector2());

        Bezier bezier1 = beziers[0];
        Bezier bezier2 = beziers[1];
        double t1 = 0, t2 = 1;

        if (intersections11.isNotEmpty && intersections22.isNotEmpty) {
          t1 = intersections11.first.clamp(0.0001, 0.9999);
          t2 = intersections22.first.clamp(0.0001, 0.9999);
          bezier1 = beziers[0].rightSubcurveAt(t1);
          bezier2 = beziers[1].leftSubcurveAt(t2);
        }
        if (intersections11.isNotEmpty && intersections21.isNotEmpty) {
          t1 = intersections11.first.clamp(0.0001, 0.9999);
          t2 = intersections21.first.clamp(0.0001, 0.9999);
          if (t2 < t1) {
            double temp = t2;
            t2 = t1;
            t1 = temp;
          }
          bezier1 = beziers[0].subcurveBetween(t1, t2);
          bezier2 = beziers[0].subcurveBetween(t2 - 0.00001, t2);
        }
        if (intersections22.isNotEmpty && intersections12.isNotEmpty) {
          t1 = intersections12.first.clamp(0.0001, 0.9999);
          t2 = intersections22.first.clamp(0.0001, 0.9999);
          if (t2 < t1) {
            double temp = t2;
            t2 = t1;
            t1 = temp;
          }
          bezier1 = beziers[1].subcurveBetween(t1, t1 + 0.00001);
          bezier2 = beziers[1].subcurveBetween(t1, t2);
        }
        if (bezier1.endPoint.toOffset().dx <= right - rightSideWidth &&
                bezier1.endPoint.toOffset().dy <= bottom - bottomSideWidth ||
            bezier2.startPoint.toOffset().dx <= right - rightSideWidth &&
                bezier2.startPoint.toOffset().dy <= bottom - bottomSideWidth) {
          nodes.add(DynamicNode(
              position: bezier1.startPoint.toOffset(),
              next: bezier1.points[1].toOffset()));
          nodes.add(DynamicNode(
              position: bezier1.endPoint.toOffset(),
              prev: bezier1.points[2].toOffset(),
              next: bezier2.points[1].toOffset()));
          nodes.add(DynamicNode(
              position: bezier2.endPoint.toOffset(),
              prev: bezier2.points[2].toOffset()));
        } else {
          nodes.add(DynamicNode(
              position:
                  Offset(right - rightSideWidth, bottom - bottomSideWidth)));
          nodes.add(DynamicNode(
              position:
                  Offset(right - rightSideWidth, bottom - bottomSideWidth)));
          nodes.add(DynamicNode(
              position:
                  Offset(right - rightSideWidth, bottom - bottomSideWidth)));
        }

        break;
    }

    switch (bottomLeftStyle) {
      case CornerStyle.rounded:
        nodes.add(DynamicNode(
            position: Offset(left + max(leftSideWidth, bottomLeftRadius),
                bottom - bottomSideWidth)));
        nodes.arcTo(
            Rect.fromCenter(
                center: Offset(left + max(leftSideWidth, bottomLeftRadius),
                    bottom - max(bottomSideWidth, leftBottomRadius)),
                width: max(0, 2 * bottomLeftRadius - 2 * leftSideWidth),
                height: max(0, 2 * leftBottomRadius - 2 * bottomSideWidth)),
            pi / 2,
            pi / 2);
        break;
      case CornerStyle.cutout:
        nodes.add(DynamicNode(
            position: Offset(left + max(bottomLeftRadius, leftSideWidth),
                bottom - bottomSideWidth)));
        nodes.add(DynamicNode(
            position: Offset(left + max(bottomLeftRadius, leftSideWidth),
                bottom - max(leftBottomRadius, bottomSideWidth))));
        nodes.add(DynamicNode(
            position: Offset(left + leftSideWidth,
                bottom - max(leftBottomRadius, bottomSideWidth))));

        break;
      case CornerStyle.straight:
        Offset start = Offset(left + max(leftSideWidth, bottomLeftRadius),
            bottom - bottomSideWidth);
        Offset end = Offset(left + leftSideWidth,
            bottom - max(bottomSideWidth, leftBottomRadius));
        nodes.add(DynamicNode(position: start));
        nodes.add(DynamicNode(
          position: (start + end) / 2,
        ));
        nodes.add(DynamicNode(position: end));
        break;
      case CornerStyle.concave:
        List<Bezier> beziers = nodes.arcToCubicBezierCurve(
            Rect.fromCenter(
                center: Offset(left, bottom),
                width: 2 * max(bottomLeftRadius, leftSideWidth),
                height: 2 * max(leftBottomRadius, bottomSideWidth)),
            0,
            -pi / 2);

        List<double> intersections11 = beziers[0].intersectionsWithLineSegment(
            Offset(left - 10, bottom - bottomSideWidth).toVector2(),
            Offset(right + 10, bottom - bottomSideWidth).toVector2());

        List<double> intersections12 = beziers[1].intersectionsWithLineSegment(
            Offset(left - 10, bottom - bottomSideWidth).toVector2(),
            Offset(right + 10, bottom - bottomSideWidth).toVector2());

        List<double> intersections22 = beziers[1].intersectionsWithLineSegment(
            Offset(left + leftSideWidth, top - 10).toVector2(),
            Offset(left + leftSideWidth, bottom + 10).toVector2());

        List<double> intersections21 = beziers[0].intersectionsWithLineSegment(
            Offset(left + leftSideWidth, top - 10).toVector2(),
            Offset(left + leftSideWidth, bottom + 10).toVector2());

        Bezier bezier1 = beziers[0];
        Bezier bezier2 = beziers[1];
        double t1 = 0, t2 = 1;

        if (intersections11.isNotEmpty && intersections22.isNotEmpty) {
          t1 = intersections11.first.clamp(0.0001, 0.9999);
          t2 = intersections22.first.clamp(0.0001, 0.9999);
          bezier1 = beziers[0].rightSubcurveAt(t1);
          bezier2 = beziers[1].leftSubcurveAt(t2);
        }
        if (intersections11.isNotEmpty && intersections21.isNotEmpty) {
          t1 = intersections11.first.clamp(0.0001, 0.9999);
          t2 = intersections21.first.clamp(0.0001, 0.9999);
          if (t2 < t1) {
            double temp = t2;
            t2 = t1;
            t1 = temp;
          }
          bezier1 = beziers[0].subcurveBetween(t1, t2);
          bezier2 = beziers[0].subcurveBetween(t2 - 0.00001, t2);
        }
        if (intersections22.isNotEmpty && intersections12.isNotEmpty) {
          t1 = intersections12.first.clamp(0.0001, 0.9999);
          t2 = intersections22.first.clamp(0.0001, 0.9999);
          if (t2 < t1) {
            double temp = t2;
            t2 = t1;
            t1 = temp;
          }
          bezier1 = beziers[1].subcurveBetween(t1, t1 + 0.00001);
          bezier2 = beziers[1].subcurveBetween(t1, t2);
        }
        if (bezier1.endPoint.toOffset().dx >= left + leftSideWidth &&
                bezier1.endPoint.toOffset().dy <= bottom - bottomSideWidth ||
            bezier2.startPoint.toOffset().dx >= left + leftSideWidth &&
                bezier2.startPoint.toOffset().dy <= bottom - bottomSideWidth) {
          nodes.add(DynamicNode(
              position: bezier1.startPoint.toOffset(),
              next: bezier1.points[1].toOffset()));
          nodes.add(DynamicNode(
              position: bezier1.endPoint.toOffset(),
              prev: bezier1.points[2].toOffset(),
              next: bezier2.points[1].toOffset()));
          nodes.add(DynamicNode(
              position: bezier2.endPoint.toOffset(),
              prev: bezier2.points[2].toOffset()));
        } else {
          nodes.add(DynamicNode(
              position:
                  Offset(left + leftSideWidth, bottom - bottomSideWidth)));
          nodes.add(DynamicNode(
              position:
                  Offset(left + leftSideWidth, bottom - bottomSideWidth)));
          nodes.add(DynamicNode(
              position:
                  Offset(left + leftSideWidth, bottom - bottomSideWidth)));
        }

        break;
    }

    switch (topLeftStyle) {
      case CornerStyle.rounded:
        nodes.add(DynamicNode(
            position: Offset(
                left + leftSideWidth, top + max(topSideWidth, leftTopRadius))));
        nodes.arcTo(
            Rect.fromCenter(
                center: Offset(left + max(leftSideWidth, topLeftRadius),
                    top + max(topSideWidth, leftTopRadius)),
                width: max(0, 2 * topLeftRadius - 2 * leftSideWidth),
                height: max(0, 2 * leftTopRadius - 2 * topSideWidth)),
            pi,
            pi / 2);

        break;
      case CornerStyle.cutout:
        nodes.add(DynamicNode(
            position: Offset(
                left + leftSideWidth, top + max(leftTopRadius, topSideWidth))));
        nodes.add(DynamicNode(
            position: Offset(left + max(topLeftRadius, leftSideWidth),
                top + max(leftTopRadius, topSideWidth))));
        nodes.add(DynamicNode(
            position: Offset(
                left + max(topLeftRadius, leftSideWidth), top + topSideWidth)));

        break;
      case CornerStyle.straight:
        Offset start = Offset(left + leftSideWidth,
            top + max(topSideWidth, leftTopRadius));
        Offset end = Offset(left + max(leftSideWidth, topLeftRadius),
            top +topSideWidth);
        nodes.add(DynamicNode(position: start));
        nodes.add(DynamicNode(
          position: (start + end) / 2,
        ));
        nodes.add(DynamicNode(position: end));
        break;
      case CornerStyle.concave:
        List<Bezier> beziers = nodes.arcToCubicBezierCurve(
            Rect.fromCenter(
                center: Offset(left, top),
                width: 2 * max(topLeftRadius, leftSideWidth),
                height: 2 * max(leftTopRadius , topSideWidth)),
            pi / 2,
            -pi / 2);
        List<double> intersections11 = beziers[0].intersectionsWithLineSegment(
            Offset(left + leftSideWidth, top-10).toVector2(),
            Offset(left + leftSideWidth, bottom+10).toVector2());

        List<double> intersections12 = beziers[1].intersectionsWithLineSegment(
            Offset(left + leftSideWidth, top-10).toVector2(),
            Offset(left + leftSideWidth, bottom+10).toVector2());

        List<double> intersections22 = beziers[1].intersectionsWithLineSegment(
            Offset(left-10, top + topSideWidth).toVector2(),
            Offset(right+10, top + topSideWidth).toVector2());

        List<double> intersections21 = beziers[0].intersectionsWithLineSegment(
            Offset(left-10, top + topSideWidth).toVector2(),
            Offset(right+10, top + topSideWidth).toVector2());

        Bezier bezier1 = beziers[0];
        Bezier bezier2 = beziers[1];
        double t1 = 0, t2 = 1;

        if (intersections11.isNotEmpty && intersections22.isNotEmpty) {
          t1 = intersections11.first.clamp(0.0001, 0.9999);
          t2 = intersections22.first.clamp(0.0001, 0.9999);
          bezier1 = beziers[0].rightSubcurveAt(t1);
          bezier2 = beziers[1].leftSubcurveAt(t2);
        }
        if (intersections11.isNotEmpty && intersections21.isNotEmpty) {
          t1 = intersections11.first.clamp(0.0001, 0.9999);
          t2 = intersections21.first.clamp(0.0001, 0.9999);
          if (t2 < t1) {
            double temp = t2;
            t2 = t1;
            t1 = temp;
          }
          bezier1 = beziers[0].subcurveBetween(t1, t2);
          bezier2 = beziers[0].subcurveBetween(t2 - 0.00001, t2);
        }
        if (intersections22.isNotEmpty && intersections12.isNotEmpty) {
          t1 = intersections12.first.clamp(0.0001, 0.9999);
          t2 = intersections22.first.clamp(0.0001, 0.9999);
          if (t2 < t1) {
            double temp = t2;
            t2 = t1;
            t1 = temp;
          }
          bezier1 = beziers[1].subcurveBetween(t1, t1 + 0.00001);
          bezier2 = beziers[1].subcurveBetween(t1, t2);
        }
        if (bezier1.endPoint.toOffset() >=
            Offset(left + leftSideWidth, top + topSideWidth)) {
          nodes.add(DynamicNode(
              position: bezier1.startPoint.toOffset(),
              next: bezier1.points[1].toOffset()));
          nodes.add(DynamicNode(
              position: bezier1.endPoint.toOffset(),
              prev: bezier1.points[2].toOffset(),
              next: bezier2.points[1].toOffset()));
          nodes.add(DynamicNode(
              position: bezier2.endPoint.toOffset(),
              prev: bezier2.points[2].toOffset()));
        } else {
          nodes.add(DynamicNode(
              position: Offset(left + leftSideWidth, top + topSideWidth)));
          nodes.add(DynamicNode(
              position: Offset(left + leftSideWidth, top + topSideWidth)));
          nodes.add(DynamicNode(
              position: Offset(left + leftSideWidth, top + topSideWidth)));
        }

        break;
    }

    return DynamicPath(size: rect.size, nodes: nodes);
  }

  DynamicPath generateOuterDynamicPath(Rect rect) {
    Size size = rect.size;
    List<DynamicNode> nodes = [];

    final double left = rect.left;
    final double top = rect.top;
    final double bottom = rect.bottom;
    final double right = rect.right;

    double leftSideWidth =
        this.leftBorder.width.toPX(constraintSize: size.width);
    double rightSideWidth =
        this.rightBorder.width.toPX(constraintSize: size.width);
    double topSideWidth =
        this.topBorder.width.toPX(constraintSize: size.height);
    double bottomSideWidth =
        this.bottomBorder.width.toPX(constraintSize: size.height);

    BorderRadius borderRadius = this.borderRadius.toBorderRadius(size: size);

    double topLeftRadius = borderRadius.topLeft.x;
    double topRightRadius = borderRadius.topRight.x;

    double bottomLeftRadius = borderRadius.bottomLeft.x;
    double bottomRightRadius = borderRadius.bottomRight.x;

    double leftTopRadius = borderRadius.topLeft.y;
    double leftBottomRadius = borderRadius.bottomLeft.y;

    double rightTopRadius = borderRadius.topRight.y;
    double rightBottomRadius = borderRadius.bottomRight.y;

    double topTotal =
        max(topLeftRadius, leftSideWidth) + max(topRightRadius, rightSideWidth);
    double bottomTotal = max(bottomLeftRadius, leftSideWidth) +
        max(bottomRightRadius, rightSideWidth);
    double leftTotal = max(leftTopRadius, topSideWidth) +
        max(leftBottomRadius, bottomSideWidth);
    double rightTotal = max(rightTopRadius, topSideWidth) +
        max(rightBottomRadius, bottomSideWidth);

    if (topTotal > size.width || bottomTotal > size.width) {
      double total = max(topTotal, bottomTotal);
      topLeftRadius *= size.width / total;
      topRightRadius *= size.width / total;
      bottomLeftRadius *= size.width / total;
      bottomRightRadius *= size.width / total;
      leftSideWidth *= size.width / total;
      rightSideWidth *= size.width / total;
      //leftSideWidth =
      //    leftSideWidth.clamp(0, max(topLeftRadius, bottomLeftRadius));
      //rightSideWidth =
      //    rightSideWidth.clamp(0, max(topRightRadius, bottomRightRadius));
    }

    if (leftTotal > size.height || rightTotal > size.height) {
      double total = max(leftTotal, rightTotal);
      leftTopRadius *= size.height / total;
      rightTopRadius *= size.height / total;
      leftBottomRadius *= size.height / total;
      rightBottomRadius *= size.height / total;
      topSideWidth *= size.height / total;
      bottomSideWidth *= size.height / total;
      //topSideWidth = topSideWidth.clamp(0, max(leftTopRadius, rightTopRadius));
      //bottomSideWidth =
      //    bottomSideWidth.clamp(0, max(leftBottomRadius, rightBottomRadius));
    }

    /*
    double topTotal = topLeftRadius + topRightRadius;
    double bottomTotal = bottomLeftRadius + bottomRightRadius;
    double leftTotal = leftTopRadius + leftBottomRadius;
    double rightTotal = rightTopRadius + rightBottomRadius;

    if (topTotal > size.width || bottomTotal > size.width) {
      double total = max(topTotal, bottomTotal);
      topLeftRadius *= size.width / total;
      topRightRadius *= size.width / total;
      bottomLeftRadius *= size.width / total;
      bottomRightRadius *= size.width / total;
      leftSideWidth =
          leftSideWidth.clamp(0, max(topLeftRadius, bottomLeftRadius));
      rightSideWidth =
          rightSideWidth.clamp(0, max(topRightRadius, bottomRightRadius));
    }

    if (leftTotal > size.height || rightTotal > size.height) {
      double total = max(leftTotal, rightTotal);
      leftTopRadius *= size.height / total;
      rightTopRadius *= size.height / total;
      leftBottomRadius *= size.height / total;
      rightBottomRadius *= size.height / total;
      topSideWidth = topSideWidth.clamp(0, max(leftTopRadius, rightTopRadius));
      bottomSideWidth =
          bottomSideWidth.clamp(0, max(leftBottomRadius, rightBottomRadius));
    }

     */

    switch (topRightStyle) {
      case CornerStyle.rounded:
        nodes.add(DynamicNode(position: Offset(right - topRightRadius, top)));
        nodes.arcTo(
            Rect.fromCenter(
                center: Offset(right - topRightRadius, top + rightTopRadius),
                width: 2 * topRightRadius,
                height: 2 * rightTopRadius),
            -pi / 2,
            pi / 2);
        break;
      case CornerStyle.straight:
        double angle = atan(rightTopRadius / max(topRightRadius, 0.00000001));
        Offset start = Offset(
            right - max(0, topRightRadius - topSideWidth * tan(angle / 2)),
            top);
        Offset end = Offset(
            right,
            top +
                max(0,
                    rightTopRadius - rightSideWidth * tan(pi / 4 - angle / 2)));
        nodes.add(DynamicNode(position: start));
        nodes.add(DynamicNode(position: (start + end) / 2));
        nodes.add(DynamicNode(position: end));
        break;
      case CornerStyle.concave:
        nodes.add(DynamicNode(
            position:
                Offset(right - max(0, topRightRadius - rightSideWidth), top)));
        nodes.arcTo(
            Rect.fromCenter(
                center: Offset(right, top),
                width: 2 * max(0, topRightRadius - rightSideWidth),
                height: 2 * max(0, rightTopRadius - topSideWidth)),
            pi,
            -pi / 2);
        break;
      case CornerStyle.cutout:
        nodes.add(DynamicNode(
            position: Offset(right - topRightRadius + rightSideWidth, top)));
        nodes.add(DynamicNode(
            position: Offset(right - topRightRadius + rightSideWidth,
                top + rightTopRadius - topSideWidth)));
        nodes.add(DynamicNode(
            position: Offset(right, top + rightTopRadius - topSideWidth)));
    }

    switch (bottomRightStyle) {
      case CornerStyle.rounded:
        nodes.add(
            DynamicNode(position: Offset(right, bottom - rightBottomRadius)));
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
        double angle =
            atan(rightBottomRadius / max(bottomRightRadius, 0.00000001));
        Offset start = Offset(
            right,
            bottom -
                max(
                    0,
                    rightBottomRadius -
                        rightSideWidth * tan(pi / 4 - angle / 2)));
        Offset end = Offset(
            right -
                max(0, bottomRightRadius - bottomSideWidth * tan(angle / 2)),
            bottom);
        nodes.add(DynamicNode(position: start));
        nodes.add(DynamicNode(position: (start + end) / 2));
        nodes.add(DynamicNode(position: end));
        break;
      case CornerStyle.concave:
        nodes.add(DynamicNode(
            position: Offset(
                right, bottom - max(0, rightBottomRadius - bottomSideWidth))));
        nodes.arcTo(
            Rect.fromCenter(
                center: Offset(right, bottom),
                width: 2 * max(0, bottomRightRadius - rightSideWidth),
                height: 2 * max(0, rightBottomRadius - bottomSideWidth)),
            -pi / 2,
            -pi / 2);
        break;
      case CornerStyle.cutout:
        nodes.add(DynamicNode(
            position:
                Offset(right, bottom - rightBottomRadius + bottomSideWidth)));
        nodes.add(DynamicNode(
            position: Offset(right - bottomRightRadius + rightSideWidth,
                bottom - rightBottomRadius + bottomSideWidth)));
        nodes.add(DynamicNode(
            position:
                Offset(right - bottomRightRadius + rightSideWidth, bottom)));
    }

    switch (bottomLeftStyle) {
      case CornerStyle.rounded:
        nodes.add(
            DynamicNode(position: Offset(left + bottomLeftRadius, bottom)));
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
        double angle =
            atan(leftBottomRadius / max(bottomLeftRadius, 0.00000001));
        Offset start = Offset(
            left + max(0, bottomLeftRadius - bottomSideWidth * tan(angle / 2)),
            bottom);
        Offset end = Offset(
            left,
            bottom -
                max(
                    0,
                    leftBottomRadius -
                        leftSideWidth * tan(pi / 4 - angle / 2)));
        nodes.add(DynamicNode(position: start));
        nodes.add(DynamicNode(position: (start + end) / 2));
        nodes.add(DynamicNode(position: end));
        break;
      case CornerStyle.concave:
        nodes.add(DynamicNode(
            position: Offset(
                left + max(0, bottomLeftRadius - leftSideWidth), bottom)));
        nodes.arcTo(
            Rect.fromCenter(
                center: Offset(left, bottom),
                width: 2 * max(0, bottomLeftRadius - leftSideWidth),
                height: 2 * max(0, leftBottomRadius - bottomSideWidth)),
            0,
            -pi / 2);
        break;
      case CornerStyle.cutout:
        nodes.add(DynamicNode(
            position: Offset(left + bottomLeftRadius - leftSideWidth, bottom)));
        nodes.add(DynamicNode(
            position: Offset(left + bottomLeftRadius - leftSideWidth,
                bottom - leftBottomRadius + bottomSideWidth)));
        nodes.add(DynamicNode(
            position:
                Offset(left, bottom - leftBottomRadius + bottomSideWidth)));
    }


    switch (topLeftStyle) {
      case CornerStyle.rounded:
        nodes.add(DynamicNode(position: Offset(left, top + leftTopRadius)));
        nodes.arcTo(
            Rect.fromCenter(
                center: Offset(left + topLeftRadius, top + leftTopRadius),
                width: 2 * topLeftRadius,
                height: 2 * leftTopRadius),
            pi,
            pi / 2);
        break;
      case CornerStyle.straight:
        double angle =
        atan(leftTopRadius / max(topLeftRadius, 0.00000001));
        Offset start = Offset(
            left,
            top +
                max(
                    0,
                    leftTopRadius -
                        leftSideWidth * tan(pi / 4 - angle / 2)));
        Offset end = Offset(
            left +
                max(0, topLeftRadius - topSideWidth * tan(angle / 2)),
            top);
        nodes.add(DynamicNode(position: start));
        nodes.add(DynamicNode(position: (start + end) / 2));
        nodes.add(DynamicNode(position: end));
        break;
      case CornerStyle.concave:
        nodes.add(DynamicNode(
            position: Offset(
                left, top + max(0, leftTopRadius - topSideWidth))));
        nodes.arcTo(
            Rect.fromCenter(
                center: Offset(left, top),
                width: 2 * max(0, topLeftRadius-leftSideWidth),
                height: 2 * max(0,leftTopRadius-topSideWidth)),
            pi / 2,
            -pi / 2);
        break;
      case CornerStyle.cutout:
        nodes.add(DynamicNode(
            position:
            Offset(left, top + leftTopRadius - topSideWidth)));
        nodes.add(DynamicNode(
            position:
            Offset(left+topLeftRadius-leftSideWidth, top + leftTopRadius - topSideWidth)));
        nodes.add(DynamicNode(
            position:
            Offset(left+topLeftRadius-leftSideWidth, top)));
    }

    return DynamicPath(size: rect.size, nodes: nodes);
  }

  /*
  DynamicPath generateInnerDynamicPath(Rect rect) {
    Size size = rect.size;

    double leftSideWidth =
        this.leftBorder.width.toPX(constraintSize: size.width);
    double rightSideWidth =
        this.rightBorder.width.toPX(constraintSize: size.width);
    double topSideWidth =
        this.topBorder.width.toPX(constraintSize: size.height);
    double bottomSideWidth =
        this.bottomBorder.width.toPX(constraintSize: size.height);

    if (leftSideWidth + rightSideWidth > size.width) {
      double ratio = leftSideWidth / (leftSideWidth + rightSideWidth);
      leftSideWidth = size.width * ratio;
      rightSideWidth = size.width * (1 - ratio);
    }

    if (topSideWidth + bottomSideWidth > size.height) {
      double ratio = topSideWidth / (topSideWidth + bottomSideWidth);
      topSideWidth = size.height * ratio;
      bottomSideWidth = size.height * (1 - ratio);
    }

    BorderRadius borderRadius = this.borderRadius.toBorderRadius(size: size);

    double topLeftRadius = borderRadius.topLeft.x;
    double topRightRadius = borderRadius.topRight.x;

    double bottomLeftRadius = borderRadius.bottomLeft.x;
    double bottomRightRadius = borderRadius.bottomRight.x;

    double leftTopRadius = borderRadius.topLeft.y;
    double leftBottomRadius = borderRadius.bottomLeft.y;

    double rightTopRadius = borderRadius.topRight.y;
    double rightBottomRadius = borderRadius.bottomRight.y;

    double topTotal = topLeftRadius +
        topRightRadius +
        (topLeftStyle != CornerStyle.rounded ? leftSideWidth : max(0, leftSideWidth-topLeftRadius)) +
        (topRightStyle != CornerStyle.rounded ? rightSideWidth : max(0, rightSideWidth-topRightRadius));
    double bottomTotal = bottomLeftRadius +
        bottomRightRadius +
        (bottomLeftStyle != CornerStyle.rounded ? leftSideWidth : max(0, leftSideWidth-bottomLeftRadius)) +
        (bottomRightStyle != CornerStyle.rounded ? rightSideWidth : max(0, rightSideWidth-bottomRightRadius));
    double leftTotal = leftTopRadius +
        leftBottomRadius +
        (topLeftStyle != CornerStyle.rounded ? topSideWidth :  max(0, topSideWidth-leftTopRadius)) +
        (bottomLeftStyle != CornerStyle.rounded ? bottomSideWidth : max(0, bottomSideWidth-leftBottomRadius));
    double rightTotal = rightTopRadius +
        rightBottomRadius +
        (topRightStyle != CornerStyle.rounded ? topSideWidth : max(0, topSideWidth-rightTopRadius)) +
        (bottomRightStyle != CornerStyle.rounded ? bottomSideWidth : max(0, bottomSideWidth-rightBottomRadius));

    if (topTotal > size.width || bottomTotal > size.width) {
      double total = max(topTotal, bottomTotal);
      topLeftRadius *= size.width / total;
      topRightRadius *= size.width / total;
      bottomLeftRadius *= size.width / total;
      bottomRightRadius *= size.width / total;
      leftSideWidth *= size.width / total;
      rightSideWidth *= size.width / total;
    }

    if (leftTotal > size.height || rightTotal > size.height) {
      double total = max(leftTotal, rightTotal);
      leftTopRadius *= size.height / total;
      rightTopRadius *= size.height / total;
      leftBottomRadius *= size.height / total;
      rightBottomRadius *= size.height / total;
      topSideWidth *= size.height / total;
      bottomSideWidth *= size.height / total;
    }

    final double left = rect.left;
    final double top = rect.top;
    final double bottom = rect.bottom;
    final double right = rect.right;

    List<DynamicNode> nodes = [];

    switch (topRightStyle) {
      case CornerStyle.rounded:
        nodes.add(DynamicNode(
            position: Offset(right - max(topRightRadius, rightSideWidth),
                top + topSideWidth)));
        nodes.arcTo(
            Rect.fromCenter(
                center: Offset(right - max(topRightRadius, rightSideWidth),
                    top + max(rightTopRadius, topSideWidth)),
                width: max(0, 2 * topRightRadius - 2 * rightSideWidth),
                height: max(0, 2 * rightTopRadius - 2 * topSideWidth)),
            -pi / 2,
            pi / 2);
        break;
      case CornerStyle.cutout:
        nodes.add(DynamicNode(
            position: Offset(
                right - topRightRadius - rightSideWidth, top + topSideWidth)));
        nodes.add(DynamicNode(
            position: Offset(right - topRightRadius - rightSideWidth,
                top + rightTopRadius + topSideWidth)));
        nodes.add(DynamicNode(
            position: Offset(
                right - rightSideWidth, top + rightTopRadius + topSideWidth)));
        break;
      case CornerStyle.straight:
        double angle = atan(rightTopRadius / max(topRightRadius, 0.00000001));
        Offset start = Offset(
            right -
                max(rightSideWidth,
                    topRightRadius + topSideWidth * tan(angle / 2)),
            top + topSideWidth);
        Offset end = Offset(
            right - rightSideWidth,
            top +
                max(topSideWidth,
                    rightTopRadius + rightSideWidth * tan(pi / 4 - angle / 2)));
        nodes.add(DynamicNode(position: start));
        nodes.add(DynamicNode(
          position: (start + end) / 2,
        ));
        nodes.add(DynamicNode(position: end));
        break;
      case CornerStyle.concave:
        List<Bezier> beziers = nodes.arcToCubicBezierCurve(
            Rect.fromCenter(
                center: Offset(right, top),
                width: 2 * topRightRadius + 2 * rightSideWidth,
                height: 2 * rightTopRadius + 2 * topSideWidth),
            pi,
            -pi / 2);
        List<double> intersections11 = beziers[0].intersectionsWithLineSegment(
            Offset(left, top + topSideWidth).toVector2(),
            Offset(right, top + topSideWidth).toVector2());

        List<double> intersections12 = beziers[1].intersectionsWithLineSegment(
            Offset(left, top + topSideWidth).toVector2(),
            Offset(right, top + topSideWidth).toVector2());

        List<double> intersections22 = beziers[1].intersectionsWithLineSegment(
            Offset(right - rightSideWidth, top).toVector2(),
            Offset(right - rightSideWidth, bottom).toVector2());

        List<double> intersections21 = beziers[0].intersectionsWithLineSegment(
            Offset(right - rightSideWidth, top).toVector2(),
            Offset(right - rightSideWidth, bottom).toVector2());

        Bezier bezier1 = beziers[0];
        Bezier bezier2 = beziers[1];
        double t1 = 0, t2 = 1;

        if (intersections11.isNotEmpty && intersections22.isNotEmpty) {
          t1 = intersections11.first.clamp(0.0001, 0.9999);
          t2 = intersections22.first.clamp(0.0001, 0.9999);
          bezier1 = beziers[0].rightSubcurveAt(t1);
          bezier2 = beziers[1].leftSubcurveAt(t2);
        }
        if (intersections11.isNotEmpty && intersections21.isNotEmpty) {
          t1 = intersections11.first.clamp(0.0001, 0.9999);
          t2 = intersections21.first.clamp(0.0001, 0.9999);
          if (t2 < t1) {
            double temp = t2;
            t2 = t1;
            t1 = temp;
          }
          bezier1 = beziers[0].subcurveBetween(t1, t2);
          bezier2 = beziers[0].subcurveBetween(t2 - 0.00001, t2);
        }
        if (intersections22.isNotEmpty && intersections12.isNotEmpty) {
          t1 = intersections12.first.clamp(0.0001, 0.9999);
          t2 = intersections22.first.clamp(0.0001, 0.9999);
          if (t2 < t1) {
            double temp = t2;
            t2 = t1;
            t1 = temp;
          }
          bezier1 = beziers[1].subcurveBetween(t1, t1 + 0.00001);
          bezier2 = beziers[1].subcurveBetween(t1, t2);
        }
        if (bezier1.endPoint.toOffset().dx <= right - rightSideWidth &&
                bezier1.endPoint.toOffset().dy >= top + topSideWidth ||
            bezier2.startPoint.toOffset().dx <= right - rightSideWidth &&
                bezier2.startPoint.toOffset().dy >= top + topSideWidth) {
          nodes.add(DynamicNode(
              position: bezier1.startPoint.toOffset(),
              next: bezier1.points[1].toOffset()));
          nodes.add(DynamicNode(
              position: bezier1.endPoint.toOffset(),
              prev: bezier1.points[2].toOffset(),
              next: bezier2.points[1].toOffset()));
          nodes.add(DynamicNode(
              position: bezier2.endPoint.toOffset(),
              prev: bezier2.points[2].toOffset()));
        } else {
          nodes.add(DynamicNode(
              position: Offset(right - rightSideWidth, top + topSideWidth)));
          nodes.add(DynamicNode(
              position: Offset(right - rightSideWidth, top + topSideWidth)));
          nodes.add(DynamicNode(
              position: Offset(right - rightSideWidth, top + topSideWidth)));
        }

        break;
    }

    switch (bottomRightStyle) {
      case CornerStyle.rounded:
        nodes.add(DynamicNode(
            position: Offset(right - rightSideWidth,
                bottom - max(bottomSideWidth, rightBottomRadius))));
        nodes.arcTo(
            Rect.fromCenter(
                center: Offset(right - max(bottomRightRadius, rightSideWidth),
                    bottom - max(rightBottomRadius, bottomSideWidth)),
                width: max(0, 2 * bottomRightRadius - 2 * rightSideWidth),
                height: max(0, 2 * rightBottomRadius - 2 * bottomSideWidth)),
            0,
            pi / 2);

        break;
      case CornerStyle.cutout:
        nodes.add(DynamicNode(
            position: Offset(right - rightSideWidth,
                bottom - rightBottomRadius - bottomSideWidth)));
        nodes.add(DynamicNode(
            position: Offset(right - bottomRightRadius - rightSideWidth,
                bottom - rightBottomRadius - bottomSideWidth)));
        nodes.add(DynamicNode(
            position: Offset(right - bottomRightRadius - rightSideWidth,
                bottom - bottomSideWidth)));
        break;
      case CornerStyle.straight:
        double angle =
            atan(rightBottomRadius / max(bottomRightRadius, 0.00000001));
        Offset start = Offset(
            right - rightSideWidth,
            bottom -
                max(
                    bottomSideWidth,
                    rightBottomRadius +
                        rightSideWidth * tan(pi / 4 - angle / 2)));
        Offset end = Offset(
            right -
                max(rightSideWidth,
                    bottomRightRadius + bottomSideWidth * tan(angle / 2)),
            bottom - bottomSideWidth);
        nodes.add(DynamicNode(position: start));
        nodes.add(DynamicNode(
          position: (start + end) / 2,
        ));
        nodes.add(DynamicNode(position: end));
        break;
      case CornerStyle.concave:
        List<Bezier> beziers = nodes.arcToCubicBezierCurve(
            Rect.fromCenter(
                center: Offset(right, bottom),
                width: 2 * bottomRightRadius + 2 * rightSideWidth,
                height: 2 * rightBottomRadius + 2 * bottomSideWidth),
            -pi / 2,
            -pi / 2);
        List<double> intersections11 = beziers[0].intersectionsWithLineSegment(
            Offset(right - rightSideWidth, top).toVector2(),
            Offset(right - rightSideWidth, bottom).toVector2());

        List<double> intersections12 = beziers[1].intersectionsWithLineSegment(
            Offset(right - rightSideWidth, top).toVector2(),
            Offset(right - rightSideWidth, bottom).toVector2());

        List<double> intersections22 = beziers[1].intersectionsWithLineSegment(
            Offset(left, bottom - bottomSideWidth).toVector2(),
            Offset(right, bottom - bottomSideWidth).toVector2());

        List<double> intersections21 = beziers[0].intersectionsWithLineSegment(
            Offset(left, bottom - bottomSideWidth).toVector2(),
            Offset(right, bottom - bottomSideWidth).toVector2());

        Bezier bezier1 = beziers[0];
        Bezier bezier2 = beziers[1];
        double t1 = 0, t2 = 1;

        if (intersections11.isNotEmpty && intersections22.isNotEmpty) {
          t1 = intersections11.first.clamp(0.0001, 0.9999);
          t2 = intersections22.first.clamp(0.0001, 0.9999);
          bezier1 = beziers[0].rightSubcurveAt(t1);
          bezier2 = beziers[1].leftSubcurveAt(t2);
        }
        if (intersections11.isNotEmpty && intersections21.isNotEmpty) {
          t1 = intersections11.first.clamp(0.0001, 0.9999);
          t2 = intersections21.first.clamp(0.0001, 0.9999);
          if (t2 < t1) {
            double temp = t2;
            t2 = t1;
            t1 = temp;
          }
          bezier1 = beziers[0].subcurveBetween(t1, t2);
          bezier2 = beziers[0].subcurveBetween(t2 - 0.00001, t2);
        }
        if (intersections22.isNotEmpty && intersections12.isNotEmpty) {
          t1 = intersections12.first.clamp(0.0001, 0.9999);
          t2 = intersections22.first.clamp(0.0001, 0.9999);
          if (t2 < t1) {
            double temp = t2;
            t2 = t1;
            t1 = temp;
          }
          bezier1 = beziers[1].subcurveBetween(t1, t1 + 0.00001);
          bezier2 = beziers[1].subcurveBetween(t1, t2);
        }
        if (bezier1.endPoint.toOffset().dx <= right - rightSideWidth &&
                bezier1.endPoint.toOffset().dy <= bottom - bottomSideWidth ||
            bezier2.startPoint.toOffset().dx <= right - rightSideWidth &&
                bezier2.startPoint.toOffset().dy <= bottom - bottomSideWidth) {
          nodes.add(DynamicNode(
              position: bezier1.startPoint.toOffset(),
              next: bezier1.points[1].toOffset()));
          nodes.add(DynamicNode(
              position: bezier1.endPoint.toOffset(),
              prev: bezier1.points[2].toOffset(),
              next: bezier2.points[1].toOffset()));
          nodes.add(DynamicNode(
              position: bezier2.endPoint.toOffset(),
              prev: bezier2.points[2].toOffset()));
        } else {
          nodes.add(DynamicNode(
              position:
                  Offset(right - rightSideWidth, bottom - bottomSideWidth)));
          nodes.add(DynamicNode(
              position:
                  Offset(right - rightSideWidth, bottom - bottomSideWidth)));
          nodes.add(DynamicNode(
              position:
                  Offset(right - rightSideWidth, bottom - bottomSideWidth)));
        }

        break;
    }

    switch (bottomLeftStyle) {
      case CornerStyle.rounded:
        nodes.add(DynamicNode(
            position: Offset(left + max(leftSideWidth, bottomLeftRadius),
                bottom - bottomSideWidth)));
        nodes.arcTo(
            Rect.fromCenter(
                center: Offset(left + max(leftSideWidth, bottomLeftRadius),
                    bottom - max(bottomSideWidth, leftBottomRadius)),
                width: max(0, 2 * bottomLeftRadius - 2 * leftSideWidth),
                height: max(0, 2 * leftBottomRadius - 2 * bottomSideWidth)),
            pi / 2,
            pi / 2);
        break;
      case CornerStyle.cutout:
        nodes.add(DynamicNode(
            position: Offset(left + bottomLeftRadius + leftSideWidth,
                bottom - bottomSideWidth)));
        nodes.add(DynamicNode(
            position: Offset(left + bottomLeftRadius + leftSideWidth,
                bottom - leftBottomRadius - bottomSideWidth)));
        nodes.add(DynamicNode(
            position: Offset(left + leftSideWidth,
                bottom - leftBottomRadius - bottomSideWidth)));

        break;
      case CornerStyle.straight:
        double angle = atan(leftBottomRadius / max(bottomLeftRadius, 0.000001));
        Offset start = Offset(
            left +
                max(leftSideWidth,
                    bottomLeftRadius + bottomSideWidth * tan(angle / 2)),
            bottom - bottomSideWidth);
        Offset end = Offset(
            left + leftSideWidth,
            bottom -
                max(
                    bottomSideWidth,
                    leftBottomRadius +
                        leftSideWidth * tan(pi / 4 - angle / 2)));
        nodes.add(DynamicNode(position: start));
        nodes.add(DynamicNode(
          position: (start + end) / 2,
        ));
        nodes.add(DynamicNode(position: end));
        break;
      case CornerStyle.concave:
        List<Bezier> beziers = nodes.arcToCubicBezierCurve(
            Rect.fromCenter(
                center: Offset(left, bottom),
                width: 2 * bottomLeftRadius + 2 * leftSideWidth,
                height: 2 * leftBottomRadius + 2 * bottomSideWidth),
            0,
            -pi / 2);

        List<double> intersections11 = beziers[0].intersectionsWithLineSegment(
            Offset(left, bottom - bottomSideWidth).toVector2(),
            Offset(right, bottom - bottomSideWidth).toVector2());

        List<double> intersections12 = beziers[1].intersectionsWithLineSegment(
            Offset(left, bottom - bottomSideWidth).toVector2(),
            Offset(right, bottom - bottomSideWidth).toVector2());

        List<double> intersections22 = beziers[1].intersectionsWithLineSegment(
            Offset(left + leftSideWidth, top).toVector2(),
            Offset(left + leftSideWidth, bottom).toVector2());

        List<double> intersections21 = beziers[0].intersectionsWithLineSegment(
            Offset(left + leftSideWidth, top).toVector2(),
            Offset(left + leftSideWidth, bottom).toVector2());

        Bezier bezier1 = beziers[0];
        Bezier bezier2 = beziers[1];
        double t1 = 0, t2 = 1;

        if (intersections11.isNotEmpty && intersections22.isNotEmpty) {
          t1 = intersections11.first.clamp(0.0001, 0.9999);
          t2 = intersections22.first.clamp(0.0001, 0.9999);
          bezier1 = beziers[0].rightSubcurveAt(t1);
          bezier2 = beziers[1].leftSubcurveAt(t2);
        }
        if (intersections11.isNotEmpty && intersections21.isNotEmpty) {
          t1 = intersections11.first.clamp(0.0001, 0.9999);
          t2 = intersections21.first.clamp(0.0001, 0.9999);
          if (t2 < t1) {
            double temp = t2;
            t2 = t1;
            t1 = temp;
          }
          bezier1 = beziers[0].subcurveBetween(t1, t2);
          bezier2 = beziers[0].subcurveBetween(t2 - 0.00001, t2);
        }
        if (intersections22.isNotEmpty && intersections12.isNotEmpty) {
          t1 = intersections12.first.clamp(0.0001, 0.9999);
          t2 = intersections22.first.clamp(0.0001, 0.9999);
          if (t2 < t1) {
            double temp = t2;
            t2 = t1;
            t1 = temp;
          }
          bezier1 = beziers[1].subcurveBetween(t1, t1 + 0.00001);
          bezier2 = beziers[1].subcurveBetween(t1, t2);
        }
        if (bezier1.endPoint.toOffset().dx >= left + leftSideWidth &&
                bezier1.endPoint.toOffset().dy <= bottom - bottomSideWidth ||
            bezier2.startPoint.toOffset().dx >= left + leftSideWidth &&
                bezier2.startPoint.toOffset().dy <= bottom - bottomSideWidth) {
          nodes.add(DynamicNode(
              position: bezier1.startPoint.toOffset(),
              next: bezier1.points[1].toOffset()));
          nodes.add(DynamicNode(
              position: bezier1.endPoint.toOffset(),
              prev: bezier1.points[2].toOffset(),
              next: bezier2.points[1].toOffset()));
          nodes.add(DynamicNode(
              position: bezier2.endPoint.toOffset(),
              prev: bezier2.points[2].toOffset()));
        } else {
          nodes.add(DynamicNode(
              position:
                  Offset(left + leftSideWidth, bottom - bottomSideWidth)));
          nodes.add(DynamicNode(
              position:
                  Offset(left + leftSideWidth, bottom - bottomSideWidth)));
          nodes.add(DynamicNode(
              position:
                  Offset(left + leftSideWidth, bottom - bottomSideWidth)));
        }

        break;
    }

    switch (topLeftStyle) {
      case CornerStyle.rounded:
        nodes.add(DynamicNode(
            position: Offset(
                left + leftSideWidth, top + max(topSideWidth, leftTopRadius))));
        nodes.arcTo(
            Rect.fromCenter(
                center: Offset(left + max(leftSideWidth, topLeftRadius),
                    top + max(topSideWidth, leftTopRadius)),
                width: max(0, 2 * topLeftRadius - 2 * leftSideWidth),
                height: max(0, 2 * leftTopRadius - 2 * topSideWidth)),
            pi,
            pi / 2);

        break;
      case CornerStyle.cutout:
        nodes.add(DynamicNode(
            position: Offset(
                left + leftSideWidth, top + leftTopRadius + topSideWidth)));
        nodes.add(DynamicNode(
            position: Offset(left + topLeftRadius + leftSideWidth,
                top + leftTopRadius + topSideWidth)));
        nodes.add(DynamicNode(
            position: Offset(
                left + topLeftRadius + leftSideWidth, top + topSideWidth)));

        break;
      case CornerStyle.straight:
        double angle = atan(leftTopRadius / max(topLeftRadius, 0.0000001));
        Offset start = Offset(
            left + leftSideWidth,
            top +
                max(topSideWidth,
                    leftTopRadius + leftSideWidth * tan(pi / 4 - angle / 2)));
        Offset end = Offset(
            left +
                max(leftSideWidth,
                    topLeftRadius + topSideWidth * tan(angle / 2)),
            top + topSideWidth);
        nodes.add(DynamicNode(position: start));
        nodes.add(DynamicNode(
          position: (start + end) / 2,
        ));
        nodes.add(DynamicNode(position: end));
        break;
      case CornerStyle.concave:
        List<Bezier> beziers = nodes.arcToCubicBezierCurve(
            Rect.fromCenter(
                center: Offset(left, top),
                width: 2 * topLeftRadius + 2 * leftSideWidth,
                height: 2 * leftTopRadius + 2 * topSideWidth),
            pi / 2,
            -pi / 2);
        List<double> intersections11 = beziers[0].intersectionsWithLineSegment(
            Offset(left + leftSideWidth, top).toVector2(),
            Offset(left + leftSideWidth, bottom).toVector2());

        List<double> intersections12 = beziers[1].intersectionsWithLineSegment(
            Offset(left + leftSideWidth, top).toVector2(),
            Offset(left + leftSideWidth, bottom).toVector2());

        List<double> intersections22 = beziers[1].intersectionsWithLineSegment(
            Offset(left, top + topSideWidth).toVector2(),
            Offset(right, top + topSideWidth).toVector2());

        List<double> intersections21 = beziers[0].intersectionsWithLineSegment(
            Offset(left, top + topSideWidth).toVector2(),
            Offset(right, top + topSideWidth).toVector2());

        Bezier bezier1 = beziers[0];
        Bezier bezier2 = beziers[1];
        double t1 = 0, t2 = 1;

        if (intersections11.isNotEmpty && intersections22.isNotEmpty) {
          t1 = intersections11.first.clamp(0.0001, 0.9999);
          t2 = intersections22.first.clamp(0.0001, 0.9999);
          bezier1 = beziers[0].rightSubcurveAt(t1);
          bezier2 = beziers[1].leftSubcurveAt(t2);
        }
        if (intersections11.isNotEmpty && intersections21.isNotEmpty) {
          t1 = intersections11.first.clamp(0.0001, 0.9999);
          t2 = intersections21.first.clamp(0.0001, 0.9999);
          if (t2 < t1) {
            double temp = t2;
            t2 = t1;
            t1 = temp;
          }
          bezier1 = beziers[0].subcurveBetween(t1, t2);
          bezier2 = beziers[0].subcurveBetween(t2 - 0.00001, t2);
        }
        if (intersections22.isNotEmpty && intersections12.isNotEmpty) {
          t1 = intersections12.first.clamp(0.0001, 0.9999);
          t2 = intersections22.first.clamp(0.0001, 0.9999);
          if (t2 < t1) {
            double temp = t2;
            t2 = t1;
            t1 = temp;
          }
          bezier1 = beziers[1].subcurveBetween(t1, t1 + 0.00001);
          bezier2 = beziers[1].subcurveBetween(t1, t2);
        }
        if (bezier1.endPoint.toOffset() >=
            Offset(left + leftSideWidth, top + topSideWidth)) {
          nodes.add(DynamicNode(
              position: bezier1.startPoint.toOffset(),
              next: bezier1.points[1].toOffset()));
          nodes.add(DynamicNode(
              position: bezier1.endPoint.toOffset(),
              prev: bezier1.points[2].toOffset(),
              next: bezier2.points[1].toOffset()));
          nodes.add(DynamicNode(
              position: bezier2.endPoint.toOffset(),
              prev: bezier2.points[2].toOffset()));
        } else {
          nodes.add(DynamicNode(
              position: Offset(left + leftSideWidth, top + topSideWidth)));
          nodes.add(DynamicNode(
              position: Offset(left + leftSideWidth, top + topSideWidth)));
          nodes.add(DynamicNode(
              position: Offset(left + leftSideWidth, top + topSideWidth)));
        }

        break;
    }

    return DynamicPath(size: rect.size, nodes: nodes);
  }

  DynamicPath generateOuterDynamicPath(Rect rect) {
    Size size = rect.size;
    List<DynamicNode> nodes = [];

    final double left = rect.left;
    final double top = rect.top;
    final double bottom = rect.bottom;
    final double right = rect.right;

    double leftSideWidth =
        this.leftBorder.width.toPX(constraintSize: size.width);
    double rightSideWidth =
        this.rightBorder.width.toPX(constraintSize: size.width);
    double topSideWidth =
        this.topBorder.width.toPX(constraintSize: size.height);
    double bottomSideWidth =
        this.bottomBorder.width.toPX(constraintSize: size.height);

    BorderRadius borderRadius = this.borderRadius.toBorderRadius(size: size);

    double topLeftRadius = borderRadius.topLeft.x;
    double topRightRadius = borderRadius.topRight.x;

    double bottomLeftRadius = borderRadius.bottomLeft.x;
    double bottomRightRadius = borderRadius.bottomRight.x;

    double leftTopRadius = borderRadius.topLeft.y;
    double leftBottomRadius = borderRadius.bottomLeft.y;

    double rightTopRadius = borderRadius.topRight.y;
    double rightBottomRadius = borderRadius.bottomRight.y;


    double topTotal = topLeftRadius +
        topRightRadius +
        (topLeftStyle != CornerStyle.rounded ? leftSideWidth : max(0, leftSideWidth-topLeftRadius)) +
        (topRightStyle != CornerStyle.rounded ? rightSideWidth : max(0, rightSideWidth-topRightRadius));
    double bottomTotal = bottomLeftRadius +
        bottomRightRadius +
        (bottomLeftStyle != CornerStyle.rounded ? leftSideWidth : max(0, leftSideWidth-bottomLeftRadius)) +
        (bottomRightStyle != CornerStyle.rounded ? rightSideWidth : max(0, rightSideWidth-bottomRightRadius));
    double leftTotal = leftTopRadius +
        leftBottomRadius +
        (topLeftStyle != CornerStyle.rounded ? topSideWidth :  max(0, topSideWidth-leftTopRadius)) +
        (bottomLeftStyle != CornerStyle.rounded ? bottomSideWidth : max(0, bottomSideWidth-leftBottomRadius));
    double rightTotal = rightTopRadius +
        rightBottomRadius +
        (topRightStyle != CornerStyle.rounded ? topSideWidth : max(0, topSideWidth-rightTopRadius)) +
        (bottomRightStyle != CornerStyle.rounded ? bottomSideWidth : max(0, bottomSideWidth-rightBottomRadius));



    if (topTotal > size.width || bottomTotal > size.width) {
      double total = max(topTotal, bottomTotal);
      topLeftRadius *= size.width / total;
      topRightRadius *= size.width / total;
      bottomLeftRadius *= size.width / total;
      bottomRightRadius *= size.width / total;
      leftSideWidth *= size.width / total;
      rightSideWidth *= size.width / total;
    }

    if (leftTotal > size.height || rightTotal > size.height) {
      double total = max(leftTotal, rightTotal);
      leftTopRadius *= size.height / total;
      rightTopRadius *= size.height / total;
      leftBottomRadius *= size.height / total;
      rightBottomRadius *= size.height / total;
      topSideWidth *= size.height / total;
      bottomSideWidth *= size.height / total;
    }

    nodes.add(DynamicNode(position: Offset(right - topRightRadius, top)));
    switch (topRightStyle) {
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
        nodes.add(DynamicNode(
            position:
                Offset(right - topRightRadius / 2, top + rightTopRadius / 2)));
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
    switch (bottomRightStyle) {
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
        nodes.add(DynamicNode(
            position: Offset(right - bottomRightRadius / 2,
                bottom - rightBottomRadius / 2)));
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
    switch (bottomLeftStyle) {
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
        nodes.add(DynamicNode(
            position: Offset(
                left + bottomLeftRadius / 2, bottom - leftBottomRadius / 2)));
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
    switch (topLeftStyle) {
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
        nodes.add(DynamicNode(
            position:
                Offset(left + topLeftRadius / 2, top + leftTopRadius / 2)));
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

   */
}