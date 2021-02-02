import 'morphable_shape_border.dart';
import 'package:flutter/material.dart';
import 'dart:math';

enum ShapeSide { bottom, top, left, right }

enum ShapeCorner {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  leftTop,
  leftBottom,
  rightTop,
  rightBottom
}

enum CornerStyle{
  rounded,
  concave,
  straight,
  cutout,
}

extension CornerStyleExtension on CornerStyle {
  String toJson() {
    return this.toString().stripFirstDot();
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
  Offset roundWithPrecision(int N) {
    return Offset(
        this.dx.roundWithPrecision(N), this.dy.roundWithPrecision(N));
  }
}

extension IndexedIterable<E> on Iterable<E> {
  Iterable<T> mapIndexed<T>(T Function(E e, int i) f) {
    var i = 0;
    return map((e) => f(e, i++));
  }
}

double getThirdSideLength(double a, double b, double angle) {
  double c2 = a * a + b * b - 2 * a * b * cos(angle);
  return sqrt(c2);
}

double getThirdAngle(double a, double b, double c) {
  double cosA = (a * a + b * b - c * c) / (2 * a * b);
  return acos(cosA);
}

Offset getPointOnArc(Rect rect, double t) {
  double xc = rect.center.dx,
      yc = rect.center.dy,
      rx = rect.width / 2,
      ry = rect.height / 2;
  return Offset(xc + rx * cos(t), yc + ry * sin(t));
}

Offset getDerivativeOnArc(Rect rect, double t) {
  double rx = rect.width / 2, ry = rect.height / 2;
  return Offset(-rx * sin(t), ry * cos(t));
}

List<Offset> arcToCubicBezier(Rect rect, double startAngle, double sweepAngle,
    {double limit = pi / 4}) {
  if (sweepAngle.abs() > limit) {
    List<Offset> rst = arcToCubicBezier(rect, startAngle, sweepAngle / 2);
    rst
      ..addAll(
          arcToCubicBezier(rect, startAngle + sweepAngle / 2, sweepAngle / 2));
    return rst;
  }

  double alpha = sin(sweepAngle) *
      (sqrt(4 + 3 * tan(sweepAngle / 2) * tan(sweepAngle / 2)) - 1) /
      3;

  List<Offset> rst = [];
  Offset p1, p2, p3, p4;
  p1 = getPointOnArc(rect, startAngle);
  p4 = getPointOnArc(rect, startAngle + sweepAngle);
  p2 = p1 + getDerivativeOnArc(rect, startAngle) * alpha;
  p3 = p4 - getDerivativeOnArc(rect, startAngle + sweepAngle) * alpha;
  rst.add(p1);
  rst.add(p2);
  rst.add(p3);
  rst.add(p4);

  return rst;
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

  void arcTo(Rect rect, double startAngle, double sweepAngle) {
    List<Offset> points = arcToCubicBezier(rect, startAngle, sweepAngle);
    for (int i = 0; i < points.length; i += 4) {
      this.cubicTo(points[i + 1], points[i + 2], points[i + 3]);
    }
  }
}
