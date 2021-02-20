import 'dart:math';

import 'package:flutter/material.dart';

import 'package:morphable_shape/morphable_shape.dart';
import 'package:bezier/bezier.dart';

///Rectangle shape with various corner style and radius for each corner
class RectangleShape extends FilledBorderShape {
  final RectangleCornerStyles cornerStyles;
  final RectangleBorders borders;

  final DynamicBorderRadius borderRadius;

  const RectangleShape({
    this.borderRadius =
        const DynamicBorderRadius.all(DynamicRadius.circular(Length(0))),
    this.cornerStyles = const RectangleCornerStyles.all(CornerStyle.rounded),
    this.borders = const RectangleBorders.all(DynamicBorderSide.none),
  });

  RectangleShape.fromJson(Map<String, dynamic> map)
      : borderRadius = parseDynamicBorderRadius(map["borderRadius"]) ??
            DynamicBorderRadius.all(DynamicRadius.circular(Length(0))),
        this.borders = parseRectangleBorderSide(map["borders"]) ??
            RectangleBorders.all(DynamicBorderSide.none),
        this.cornerStyles = parseRectangleCornerStyle(map["cornerStyles"]) ??
            RectangleCornerStyles.all(CornerStyle.rounded);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst = {"type": "RectangleShape"};
    rst["borderRadius"] = borderRadius.toJson();
    rst["borders"] = borders.toJson();
    rst["cornerStyles"] = cornerStyles.toJson();
    return rst;
  }

  RectangleShape copyWith(
      {RectangleCornerStyles? cornerStyles,
      RectangleBorders? borders,
      DynamicBorderRadius? borderRadius}) {
    return RectangleShape(
        cornerStyles: cornerStyles ?? this.cornerStyles,
        borders: borders ?? this.borders,
        borderRadius: borderRadius ?? this.borderRadius);
  }

  List<Color> borderFillColors() {
    List<Color> rst = [];
    rst.addAll(List.generate(3, (index) => borders.top.color));
    rst.addAll(List.generate(3, (index) => borders.right.color));
    rst.addAll(List.generate(3, (index) => borders.bottom.color));
    rst.addAll(List.generate(3, (index) => borders.left.color));
    return rotateList(rst, 2).cast<Color>();
  }

  @override
  List<Gradient?> borderFillGradients() {
    List<Gradient?> rst = [];
    rst.addAll(List.generate(3, (index) => borders.top.gradient));
    rst.addAll(List.generate(3, (index) => borders.right.gradient));
    rst.addAll(List.generate(3, (index) => borders.bottom.gradient));
    rst.addAll(List.generate(3, (index) => borders.left.gradient));
    return rotateList(rst, 2).cast<Gradient?>();
  }

  DynamicPath generateInnerDynamicPath(Rect rect) {
    Size size = rect.size;

    double leftSideWidth =
        this.borders.left.width.toPX(constraintSize: size.width);
    double rightSideWidth =
        this.borders.right.width.toPX(constraintSize: size.width);
    double topSideWidth =
        this.borders.top.width.toPX(constraintSize: size.height);
    double bottomSideWidth =
        this.borders.bottom.width.toPX(constraintSize: size.height);

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

    ///Another solution for handling the case when either the border with or
    ///corner radius is too big: Fit the corner radius first, then shrink the
    ///border width
    /*
    double topTotal =
        topLeftRadius + topRightRadius;
    double bottomTotal = bottomLeftRadius +
        bottomRightRadius;
    double leftTotal = leftTopRadius +
        leftBottomRadius;
    double rightTotal = rightTopRadius +
        rightBottomRadius;

    if (topTotal > size.width || bottomTotal > size.width) {
      double total = max(topTotal, bottomTotal);
      topLeftRadius *= size.width / total;
      topRightRadius *= size.width / total;
      bottomLeftRadius *= size.width / total;
      bottomRightRadius *= size.width / total;
      //leftSideWidth *= size.width / total;
      //rightSideWidth *= size.width / total;

    }
    leftSideWidth =
        leftSideWidth.clamp(0, size.width-max(topRightRadius, bottomRightRadius));
    rightSideWidth =
        rightSideWidth.clamp(0, size.width-max(topLeftRadius, bottomLeftRadius));

    if (leftTotal > size.height || rightTotal > size.height) {
      double total = max(leftTotal, rightTotal);
      leftTopRadius *= size.height / total;
      rightTopRadius *= size.height / total;
      leftBottomRadius *= size.height / total;
      rightBottomRadius *= size.height / total;

      //topSideWidth *= size.height / total;
      //bottomSideWidth *= size.height / total;
      //topSideWidth = topSideWidth.clamp(0, max(leftTopRadius, rightTopRadius));
      //bottomSideWidth =
      //    bottomSideWidth.clamp(0, max(leftBottomRadius, rightBottomRadius));
    }
    topSideWidth =
        topSideWidth.clamp(0, size.height-max(leftBottomRadius, rightBottomRadius));
    bottomSideWidth =
        bottomSideWidth.clamp(0, size.height-max(leftTopRadius, rightTopRadius));


     */

    ///Handling the case when either the border with or
    ///corner radius is too big
    double topTotal =
        max(topLeftRadius, leftSideWidth) + max(topRightRadius, rightSideWidth);
    double bottomTotal = max(bottomLeftRadius, leftSideWidth) +
        max(bottomRightRadius, rightSideWidth);
    double leftTotal = max(leftTopRadius, topSideWidth) +
        max(leftBottomRadius, bottomSideWidth);
    double rightTotal = max(rightTopRadius, topSideWidth) +
        max(rightBottomRadius, bottomSideWidth);

    if (max(topTotal, bottomTotal) > size.width ||
        max(leftTotal, rightTotal) > size.height) {
      double resizeRatio = min(size.width / max(topTotal, bottomTotal),
          size.height / max(leftTotal, rightTotal));

      topLeftRadius *= resizeRatio;
      topRightRadius *= resizeRatio;
      bottomLeftRadius *= resizeRatio;
      bottomRightRadius *= resizeRatio;
      leftSideWidth *= resizeRatio;
      rightSideWidth *= resizeRatio;

      leftTopRadius *= resizeRatio;
      rightTopRadius *= resizeRatio;
      leftBottomRadius *= resizeRatio;
      rightBottomRadius *= resizeRatio;
      topSideWidth *= resizeRatio;
      bottomSideWidth *= resizeRatio;
    }

    final double left = rect.left;
    final double top = rect.top;
    final double bottom = rect.bottom;
    final double right = rect.right;

    List<DynamicNode> nodes = [];

    switch (cornerStyles.topRight) {
      case CornerStyle.rounded:
        nodes.addArc(
            Rect.fromCenter(
                center: Offset(right - max(topRightRadius, rightSideWidth),
                    top + max(rightTopRadius, topSideWidth)),
                width: max(0, 2 * topRightRadius - 2 * rightSideWidth),
                height: max(0, 2 * rightTopRadius - 2 * topSideWidth)),
            -pi / 2,
            pi / 2,
            splitTimes: 1);
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
        List<Bezier> beziers = arcToCubicBezierCurves(
            Rect.fromCenter(
                center: Offset(right, top),
                width: 2 * max(topRightRadius, rightSideWidth),
                height: 2 * max(rightTopRadius, topSideWidth)),
            pi,
            -pi / 2,
            splitTimes: 1);
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

    switch (cornerStyles.bottomRight) {
      case CornerStyle.rounded:
        nodes.addArc(
            Rect.fromCenter(
                center: Offset(right - max(bottomRightRadius, rightSideWidth),
                    bottom - max(rightBottomRadius, bottomSideWidth)),
                width: max(0, 2 * bottomRightRadius - 2 * rightSideWidth),
                height: max(0, 2 * rightBottomRadius - 2 * bottomSideWidth)),
            0,
            pi / 2,
            splitTimes: 1);

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
        List<Bezier> beziers = arcToCubicBezierCurves(
            Rect.fromCenter(
                center: Offset(right, bottom),
                width: 2 * max(bottomRightRadius, rightSideWidth),
                height: 2 * max(rightBottomRadius, bottomSideWidth)),
            -pi / 2,
            -pi / 2,
            splitTimes: 1);
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

    switch (cornerStyles.bottomLeft) {
      case CornerStyle.rounded:
        nodes.addArc(
            Rect.fromCenter(
                center: Offset(left + max(leftSideWidth, bottomLeftRadius),
                    bottom - max(bottomSideWidth, leftBottomRadius)),
                width: max(0, 2 * bottomLeftRadius - 2 * leftSideWidth),
                height: max(0, 2 * leftBottomRadius - 2 * bottomSideWidth)),
            pi / 2,
            pi / 2,
            splitTimes: 1);
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
        List<Bezier> beziers = arcToCubicBezierCurves(
            Rect.fromCenter(
                center: Offset(left, bottom),
                width: 2 * max(bottomLeftRadius, leftSideWidth),
                height: 2 * max(leftBottomRadius, bottomSideWidth)),
            0,
            -pi / 2,
            splitTimes: 1);

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

    switch (cornerStyles.topLeft) {
      case CornerStyle.rounded:
        nodes.addArc(
            Rect.fromCenter(
                center: Offset(left + max(leftSideWidth, topLeftRadius),
                    top + max(topSideWidth, leftTopRadius)),
                width: max(0, 2 * topLeftRadius - 2 * leftSideWidth),
                height: max(0, 2 * leftTopRadius - 2 * topSideWidth)),
            pi,
            pi / 2,
            splitTimes: 1);

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
        Offset start = Offset(
            left + leftSideWidth, top + max(topSideWidth, leftTopRadius));
        Offset end = Offset(
            left + max(leftSideWidth, topLeftRadius), top + topSideWidth);
        nodes.add(DynamicNode(position: start));
        nodes.add(DynamicNode(
          position: (start + end) / 2,
        ));
        nodes.add(DynamicNode(position: end));
        break;
      case CornerStyle.concave:
        List<Bezier> beziers = arcToCubicBezierCurves(
            Rect.fromCenter(
                center: Offset(left, top),
                width: 2 * max(topLeftRadius, leftSideWidth),
                height: 2 * max(leftTopRadius, topSideWidth)),
            pi / 2,
            -pi / 2,
            splitTimes: 1);
        List<double> intersections11 = beziers[0].intersectionsWithLineSegment(
            Offset(left + leftSideWidth, top - 10).toVector2(),
            Offset(left + leftSideWidth, bottom + 10).toVector2());

        List<double> intersections12 = beziers[1].intersectionsWithLineSegment(
            Offset(left + leftSideWidth, top - 10).toVector2(),
            Offset(left + leftSideWidth, bottom + 10).toVector2());

        List<double> intersections22 = beziers[1].intersectionsWithLineSegment(
            Offset(left - 10, top + topSideWidth).toVector2(),
            Offset(right + 10, top + topSideWidth).toVector2());

        List<double> intersections21 = beziers[0].intersectionsWithLineSegment(
            Offset(left - 10, top + topSideWidth).toVector2(),
            Offset(right + 10, top + topSideWidth).toVector2());

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
        this.borders.left.width.toPX(constraintSize: size.width);
    double rightSideWidth =
        this.borders.right.width.toPX(constraintSize: size.width);
    double topSideWidth =
        this.borders.top.width.toPX(constraintSize: size.height);
    double bottomSideWidth =
        this.borders.bottom.width.toPX(constraintSize: size.height);

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

    if (max(topTotal, bottomTotal) > size.width ||
        max(leftTotal, rightTotal) > size.height) {
      double resizeRatio = min(size.width / max(topTotal, bottomTotal),
          size.height / max(leftTotal, rightTotal));

      topLeftRadius *= resizeRatio;
      topRightRadius *= resizeRatio;
      bottomLeftRadius *= resizeRatio;
      bottomRightRadius *= resizeRatio;
      leftSideWidth *= resizeRatio;
      rightSideWidth *= resizeRatio;

      leftTopRadius *= resizeRatio;
      rightTopRadius *= resizeRatio;
      leftBottomRadius *= resizeRatio;
      rightBottomRadius *= resizeRatio;
      topSideWidth *= resizeRatio;
      bottomSideWidth *= resizeRatio;
    }

    /*
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

     */

    switch (cornerStyles.topRight) {
      case CornerStyle.rounded:
        nodes.addArc(
            Rect.fromCenter(
                center: Offset(right - topRightRadius, top + rightTopRadius),
                width: 2 * topRightRadius,
                height: 2 * rightTopRadius),
            -pi / 2,
            pi / 2,
            splitTimes: 1);
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
        nodes.addArc(
            Rect.fromCenter(
                center: Offset(right, top),
                width: 2 * max(0, topRightRadius - rightSideWidth),
                height: 2 * max(0, rightTopRadius - topSideWidth)),
            pi,
            -pi / 2,
            splitTimes: 1);
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

    switch (cornerStyles.bottomRight) {
      case CornerStyle.rounded:
        nodes.addArc(
            Rect.fromCenter(
                center: Offset(
                    right - bottomRightRadius, bottom - rightBottomRadius),
                width: 2 * bottomRightRadius,
                height: 2 * rightBottomRadius),
            0,
            pi / 2,
            splitTimes: 1);
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
        nodes.addArc(
            Rect.fromCenter(
                center: Offset(right, bottom),
                width: 2 * max(0, bottomRightRadius - rightSideWidth),
                height: 2 * max(0, rightBottomRadius - bottomSideWidth)),
            -pi / 2,
            -pi / 2,
            splitTimes: 1);
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

    switch (cornerStyles.bottomLeft) {
      case CornerStyle.rounded:
        nodes.addArc(
            Rect.fromCenter(
                center:
                    Offset(left + bottomLeftRadius, bottom - leftBottomRadius),
                width: 2 * bottomLeftRadius,
                height: 2 * leftBottomRadius),
            pi / 2,
            pi / 2,
            splitTimes: 1);
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
        nodes.addArc(
            Rect.fromCenter(
                center: Offset(left, bottom),
                width: 2 * max(0, bottomLeftRadius - leftSideWidth),
                height: 2 * max(0, leftBottomRadius - bottomSideWidth)),
            0,
            -pi / 2,
            splitTimes: 1);
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

    switch (cornerStyles.topLeft) {
      case CornerStyle.rounded:
        nodes.addArc(
            Rect.fromCenter(
                center: Offset(left + topLeftRadius, top + leftTopRadius),
                width: 2 * topLeftRadius,
                height: 2 * leftTopRadius),
            pi,
            pi / 2,
            splitTimes: 1);
        break;
      case CornerStyle.straight:
        double angle = atan(leftTopRadius / max(topLeftRadius, 0.00000001));
        Offset start = Offset(
            left,
            top +
                max(0,
                    leftTopRadius - leftSideWidth * tan(pi / 4 - angle / 2)));
        Offset end = Offset(
            left + max(0, topLeftRadius - topSideWidth * tan(angle / 2)), top);
        nodes.add(DynamicNode(position: start));
        nodes.add(DynamicNode(position: (start + end) / 2));
        nodes.add(DynamicNode(position: end));
        break;
      case CornerStyle.concave:
        nodes.addArc(
            Rect.fromCenter(
                center: Offset(left, top),
                width: 2 * max(0, topLeftRadius - leftSideWidth),
                height: 2 * max(0, leftTopRadius - topSideWidth)),
            pi / 2,
            -pi / 2,
            splitTimes: 1);
        break;
      case CornerStyle.cutout:
        nodes.add(DynamicNode(
            position: Offset(left, top + leftTopRadius - topSideWidth)));
        nodes.add(DynamicNode(
            position: Offset(left + topLeftRadius - leftSideWidth,
                top + leftTopRadius - topSideWidth)));
        nodes.add(DynamicNode(
            position: Offset(left + topLeftRadius - leftSideWidth, top)));
    }

    return DynamicPath(size: rect.size, nodes: nodes);
  }
}
