import 'dart:math';
import 'package:flutter/material.dart';

///represent a shape feature at one of the four side of a rectangle
enum ShapeSide { bottom, top, left, right }

///represent a shape feature at one of the four side of a rectangle
///plus one of the four corners of the rectangle
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

enum CornerStyle {
  rounded,
  concave,
  straight,
  cutout,
}

int lcm(int a, int b) => (a * b) ~/ gcd(a, b);

int gcd(int a, int b) {
  while (b != 0) {
    var t = b;
    b = a % t;
    a = t;
  }
  return a;
}

///get third angle or side length in a triangle
double getThirdSideLength(double a, double b, double angle) {
  double c2 = a * a + b * b - 2 * a * b * cos(angle);
  return sqrt(c2);
}

double getThirdAngle(double a, double b, double c) {
  double cosA = (a * a + b * b - c * c) / (2 * a * b);
  return acos(cosA);
}

///get point coordinate/first derivative at parameter t on an arc
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

///recursively split an arc into multiple cubic Bezier
List<Offset> arcToCubicBezier(Rect rect, double startAngle, double sweepAngle,
    {double limit = pi / 4, int? splitTimes}) {
  if (splitTimes != null) {
    limit = sweepAngle.abs() / pow(2, splitTimes);
  }
  if (sweepAngle.abs() > limit) {
    List<Offset> rst =
        arcToCubicBezier(rect, startAngle, sweepAngle / 2.0, limit: limit);
    rst
      ..addAll(arcToCubicBezier(
          rect, startAngle + sweepAngle / 2.0, sweepAngle / 2.0,
          limit: limit));
    return rst;
  }

  double alpha = sin(sweepAngle) *
      (sqrt(4.0 + 3.0 * tan(sweepAngle / 2.0) * tan(sweepAngle / 2.0)) - 1.0) /
      3.0;

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

num total(List<num> list) {
  num total = 0;
  list.forEach((element) {
    total += element;
  });
  return total;
}

List<dynamic> rotateList(List<dynamic> list, int v) {
  if (list.isEmpty) return list;
  var i = v % list.length;
  return list.sublist(i)..addAll(list.sublist(0, i));
}

int randomChoose(List<num> list) {
  int index = 0;
  num totalWeight = total(list);
  var rng = new Random();
  double randomDraw = rng.nextDouble() * totalWeight;
  double currentSum = 0;
  for (int i = 0; i < list.length; i++) {
    currentSum += list[i];
    if (randomDraw <= currentSum) return i;
  }
  return index;
}

int estimateCombinationsOf(int n, int k, {int maximum = 10000000}) {
  if (k > n) {
    return 0;
  }
  int r = 1;
  for (int d = 1; d <= k; ++d) {
    if (r > maximum) break;
    r *= n--;
    r = r ~/ d;
  }
  return r;
}
