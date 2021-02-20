import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart';
import 'package:morphable_shape/morphable_shape.dart';

extension CornerStyleExtension on CornerStyle {
  String toJson() {
    return this.toString().stripFirstDot();
  }

  bool get isConcave {
    return this == CornerStyle.concave || this == CornerStyle.cutout;
  }
}

extension ShapeSideExtension on ShapeSide {
  String toJson() {
    return this.toString().stripFirstDot();
  }

  bool get isHorizontal {
    return this == ShapeSide.top || this == ShapeSide.bottom;
  }

  bool get isVertical {
    return !this.isHorizontal;
  }
}

extension ShapeCornerExtension on ShapeCorner {
  String toJson() {
    return this.toString().stripFirstDot();
  }

  bool get isTop {
    return this == ShapeCorner.topLeft || this == ShapeCorner.topRight;
  }

  bool get isBottom {
    return this == ShapeCorner.bottomLeft || this == ShapeCorner.bottomRight;
  }

  bool get isLeft {
    return this == ShapeCorner.leftTop || this == ShapeCorner.leftBottom;
  }

  bool get isRight {
    return this == ShapeCorner.rightTop || this == ShapeCorner.rightBottom;
  }

  bool get isHorizontal {
    return this.isTop || this.isBottom;
  }

  bool get isVertical {
    return this.isLeft || this.isRight;
  }

  bool get isHorizontalLeft {
    return this == ShapeCorner.topLeft || this == ShapeCorner.bottomLeft;
  }

  bool get isHorizontalRight {
    return this == ShapeCorner.topRight || this == ShapeCorner.bottomRight;
  }

  bool get isVerticalTop {
    return this == ShapeCorner.leftTop || this == ShapeCorner.rightTop;
  }

  bool get isVerticalBottom {
    return this == ShapeCorner.leftBottom || this == ShapeCorner.rightBottom;
  }
}

extension OffsetExtension on Offset {
  Offset clamp(Offset lower, Offset upper) {
    return Offset(
        this.dx.clamp(lower.dx, upper.dx), this.dy.clamp(lower.dy, upper.dy));
  }

  Offset rotateAround({Offset pivot = Offset.zero, double angle = 0.0}) {
    double distance = (this - pivot).distance;
    double direction = (this - pivot).direction;
    return pivot + Offset.fromDirection(direction + angle, distance);
  }

  Offset roundWithPrecision(int N) {
    return Offset(this.dx.roundWithPrecision(N), this.dy.roundWithPrecision(N));
  }

  Vector2 toVector2() {
    return Vector2(this.dx, this.dy);
  }
}

extension IndexedIterable<E> on Iterable<E> {
  Iterable<T> mapIndexed<T>(T Function(E e, int i) f) {
    var i = 0;
    return map((e) => f(e, i++));
  }
}

///Every arc will be converted to cubic Bezier path(s) in this package
extension addDynamicNodeExtension on List<DynamicNode> {
  void cubicTo(Offset x1, Offset x2, Offset x3) {
    if (this.isEmpty) {
      return;
    }
    this.last.next = x1;
    DynamicNode newNode = DynamicNode(position: x3, prev: x2);
    this.add(newNode);
  }

  void addArc(Rect rect, double startAngle, double sweepAngle,
      {int? splitTimes}) {
    ///configure the minSplitTimes to let some FilledColorShape have symmetric split at the rounded corners
    List<Offset> points =
        arcToCubicBezier(rect, startAngle, sweepAngle, splitTimes: splitTimes);
    this.add(DynamicNode(position: points[0]));
    for (int i = 0; i < points.length; i += 4) {
      this.cubicTo(points[i + 1], points[i + 2], points[i + 3]);
    }
  }

  ///has to assume it is a circle, not an eclipse
  void addStyledCorner(
      Offset center, double radius, double startAngle, double sweepAngle,
      {CornerStyle style = CornerStyle.rounded, int? splitTimes}) {
    ///configure the minSplitTimes to let some FilledColorShape have symmetric split at the rounded corners
    List<Offset> points = arcToCubicBezier(
        Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle,
        splitTimes: splitTimes);
    if (style == CornerStyle.rounded) {
      for (int i = 0; i < points.length; i += 4) {
        this.cubicTo(points[i + 1], points[i + 2], points[i + 3]);
      }
    }
    if (style == CornerStyle.straight) {
      this.add(DynamicNode(position: points.first));
      this.add(DynamicNode(position: (points.first + points.last) / 2));
      this.add(DynamicNode(position: points.last));
    }
    if (style == CornerStyle.concave) {
      Offset newCenter = center +
          Offset.fromDirection((startAngle + sweepAngle / 2).clampAngle(),
              radius / cos(sweepAngle / 2));
      double newSweep = (-(pi - sweepAngle)).clampAngle();
      double newStart =
          -(pi - (startAngle + sweepAngle / 2) + newSweep / 2).clampAngle();
      this.addArc(
          Rect.fromCircle(
              center: newCenter, radius: radius * tan(sweepAngle / 2)),
          newStart,
          newSweep,
          splitTimes: splitTimes);
    }
    if (style == CornerStyle.cutout) {
      this.add(DynamicNode(position: points.first));
      this.add(DynamicNode(position: center));
      this.add(DynamicNode(position: points.last));
    }
  }
}

extension Vector2ToOffset on Vector2 {
  Offset toOffset() {
    return Offset(this.x, this.y);
  }
}

extension extendColorListExtension on List<Color> {
  List<Color> extendColorsToLength(int length) {
    if (this.length >= length) {
      return this.sublist(0, length);
    } else {
      List<Color> rst = [];
      for (int i = 0; i < length; i++) {
        rst.add(this[i % this.length]);
      }
      return rst;
    }
  }
}

extension angleDoubleExtension on double {
  double toRadian() {
    return this / 180 * pi;
  }

  double toDegree() {
    return this / pi * 180;
  }

  double clampAngle() {
    if (this > pi) return this - 2 * pi;
    if (this < -pi) return this + 2 * pi;
    return this;
  }
}
