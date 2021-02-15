import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart';
import 'package:bezier/bezier.dart';
import 'morphable_shape.dart';

extension CornerStyleExtension on CornerStyle {
  String toJson() {
    return this.toString().stripFirstDot();
  }

  bool get isConcave {
    return this==CornerStyle.concave || this==CornerStyle.cutout;
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

  Offset rotateAround({Offset pivot=Offset.zero, double angle=0.0}) {
    double distance=(this-pivot).distance;
    double direction=(this-pivot).direction;
    return pivot+Offset.fromDirection(direction+angle, distance);
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

  void arcTo(Rect rect, double startAngle, double sweepAngle) {
    List<Offset> points = arcToCubicBezier(rect, startAngle, sweepAngle);
    for (int i = 0; i < points.length; i += 4) {
      this.cubicTo(points[i + 1], points[i + 2], points[i + 3]);
    }
  }

  List<CubicBezier> arcToCubicBezierCurve(Rect rect, double startAngle, double sweepAngle) {
    List<Offset> points = arcToCubicBezier(rect, startAngle, sweepAngle);
    List<CubicBezier> rst=[];
    for (int i = 0; i < points.length; i += 4) {
      rst.add(CubicBezier([points[i].toVector2(), points[i + 1].toVector2(), points[i + 2].toVector2(), points[i + 3].toVector2()]));
    }
    return rst;
  }
}


extension Vector2ToOffset on Vector2{
  Offset toOffset() {
    return Offset(this.x, this.y);
  }
}

extension doubleExtension on double {
  double snapWithNumber(double number) {
    return (this * number).round() / number;
  }
}

extension extendColorListExtension on List<Color> {
  List<Color> extendColors(int length) {
    if (this.length>=length) {
      return this.sublist(0, length);
    }else{
      List<Color> rst=[];
      for(int i=0; i<length; i++) {
        rst.add(this[i%this.length]);
      }
      return rst;
    }

  }
}
