import 'package:flutter/material.dart';
import 'package:flutter_class_parser/parseJson.dart';
import 'package:flutter_class_parser/toJson.dart';
import 'dart:math';
import 'PathMorph.dart';
import 'package:morphable_shape/borderShapes/roundrect.dart';
import 'package:morphable_shape/borderShapes/morph.dart';
import 'package:tuple/tuple.dart';
import 'dart:core';

export 'package:flutter_class_parser/parseJson.dart';
export 'package:flutter_class_parser/toJson.dart';

export 'parseJson.dart';
export 'borderShapes/arc.dart';
export 'borderShapes/bubble.dart';
export 'borderShapes/circle.dart';
export 'borderShapes/custom.dart';
export 'borderShapes/cutcorner.dart';
export 'borderShapes/diagonal.dart';
export 'borderShapes/polygon.dart';
export 'borderShapes/roundrect.dart';
export 'borderShapes/star.dart';
export 'borderShapes/triangle.dart';
export 'borderShapes/morph.dart';
export 'borderShapes/diamond.dart';
export 'borderShapes/trapezoid.dart';
export 'borderShapes/path.dart';

//enum ShapePosition { bottom, top, left, right }

extension clampOffset on Offset {
  Offset clamp(Offset lower, Offset upper) {
    return Offset(
        this.dx.clamp(lower.dx, upper.dx), this.dy.clamp(lower.dy, upper.dy));
  }
}

extension IndexedIterable<E> on Iterable<E> {
  Iterable<T> mapIndexed<T>(T Function(E e, int i) f) {
    var i = 0;
    return map((e) => f(e, i++));
  }
}

List<Offset> arcToCubicBezier(Rect rect, double startAngle, double sweepAngle,
    {double limit = pi / 2}) {
  if (sweepAngle > limit) {
    List<Offset> rst = arcToCubicBezier(rect, startAngle, sweepAngle / 2);
    rst
      ..addAll(
          arcToCubicBezier(rect, startAngle + sweepAngle / 2, sweepAngle / 2));
    return rst;
  }

  double xc = rect.center.dx, yc = rect.center.dy, radius = rect.width / 2;

  List<Offset> rst = [];
  double x1, y1, x2, y2, x3, y3, x4, y4, ax, ay, bx, by, q1, q2, k2;
  x1 = xc + radius * cos(startAngle);
  y1 = yc + radius * sin(startAngle);
  x4 = xc + radius * cos(startAngle + sweepAngle);
  y4 = yc + radius * sin(startAngle + sweepAngle);
  ax = x1 - xc;
  ay = y1 - yc;
  bx = x4 - xc;
  by = y4 - yc;
  q1 = ax * ax + ay * ay;
  q2 = q1 + ax * bx + ay * by;
  k2 = 4.0 / 3.0 * (sqrt(2.0 * q1 * q2) - q2) / (ax * by - ay * bx);
  x2 = xc + ax - k2 * ay;
  y2 = yc + ay + k2 * ax;
  x3 = xc + bx + k2 * by;
  y3 = yc + by - k2 * bx;

  rst.add(Offset(x1, y1));
  rst.add(Offset(x2, y2));
  rst.add(Offset(x3, y3));
  rst.add(Offset(x4, y4));

  return rst;
}

class DynamicNode {
  Offset position;
  Offset? prevControlPoints;
  Offset? nextControlPoints;

  DynamicNode(
      {required this.position, this.prevControlPoints, this.nextControlPoints});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst = {};
    rst["position"] = position.toJson();
    rst.updateNotNull("prevControlPoints", prevControlPoints?.toJson());
    rst.updateNotNull("nextControlPoints", nextControlPoints?.toJson());
    return rst;
  }
}

class DynamicPath {
  Size size;
  List<DynamicNode> nodes;

  DynamicPath({required this.size, required this.nodes}) {

    ///max 10 times trial, 1% tolerance
    double tolerance=min(size.width, size.height)/100;
    Rect bound = Rect.fromLTRB(-tolerance, -tolerance, size.width+tolerance, size.height+tolerance);
    int outlierIndex=getOutlierIndex(bound: bound);
    int iteration=0;

    while (outlierIndex!=-1 && iteration<10) {

      int splitIndex=outlierIndex;
      if(!bound.contains(nodes[outlierIndex].prevControlPoints ?? Offset.zero)) {
        splitIndex=(outlierIndex-1)%nodes.length;
      }
      print(nodes[outlierIndex].prevControlPoints);
      print(nodes[outlierIndex].nextControlPoints);
      int nextIndex=(splitIndex+1)%nodes.length;
      List<Offset> controlPoints = getControlPointsAt(splitIndex);

      List<Offset> splittedControlPoints;
      splittedControlPoints = splitCubicAt(0.5, controlPoints);
      nodes[splitIndex].nextControlPoints = splittedControlPoints[1];
      nodes[nextIndex].prevControlPoints =
      splittedControlPoints[5];
      nodes.insert(
          nextIndex,
          DynamicNode(
              position: splittedControlPoints[3],
              prevControlPoints: splittedControlPoints[2],
              nextControlPoints: splittedControlPoints[4]));
      outlierIndex=getOutlierIndex(bound: bound);
      iteration++;
    }


    for (int index = 0; index < nodes.length; index++) {
      updateNode(index, Offset.zero);
    }
    purgeOverlappingNodes();

  }

  void purgeOverlappingNodes() {
    List<DynamicNode> newNodes=[nodes[0]];
    for (int i=0; i<nodes.length; i++) {
      if((nodes[i].position-newNodes.last.position).distance<0.01*min(size.width, size.height)) {
        newNodes.last.nextControlPoints=nodes[i].nextControlPoints;
      }
      else {
        newNodes.add(nodes[i]);
      }
    }
    nodes=newNodes;
  }


  int getOutlierIndex({required Rect bound}) {
    int outlierIndex = -1;
    for (int index = 0; index < nodes.length; index++) {
      if (!bound.contains(nodes[index].position) ||
          !bound.contains(nodes[index].prevControlPoints ?? Offset.zero) ||
          !bound.contains(nodes[index].nextControlPoints ?? Offset.zero)) {
        outlierIndex = index;
        break;
      }
    }
    return outlierIndex;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst = {};
    rst["size"] = size.toJson();
    rst["nodes"] = nodes.map((e) => e.toJson()).toList();
    return rst;
  }

  void resize(Size newSize) {
    nodes.forEach((element) {
      element.position = element.position
          .scale(newSize.width / size.width, newSize.height / size.height);
      element.prevControlPoints = element.prevControlPoints
          ?.scale(newSize.width / size.width, newSize.height / size.height);
      element.nextControlPoints = element.nextControlPoints
          ?.scale(newSize.width / size.width, newSize.height / size.height);
    });
    size = newSize;
  }

  DynamicNode getNodeWithControlPoints(int index) {
    DynamicNode newNode = DynamicNode(
        position: nodes[index].position,
        prevControlPoints: nodes[index].prevControlPoints,
        nextControlPoints: nodes[index].nextControlPoints);

    if (newNode.prevControlPoints == null) {
      int prevIndex = (index - 1) % nodes.length;
      newNode.prevControlPoints =
          newNode.position + (nodes[prevIndex].position - newNode.position) / 3;
    }
    if (newNode.nextControlPoints == null) {
      int nextIndex = (index + 1) % nodes.length;
      newNode.nextControlPoints =
          newNode.position + (nodes[nextIndex].position - newNode.position) / 3;
    }

    return newNode;
  }

  void updateNode(int index, Offset offset) {
    DynamicNode node = nodes[index];
    node.position += offset;
    node.position =
        node.position.clamp(Offset.zero, Offset(size.width, size.height));
    if (node.prevControlPoints != null) {
      node.prevControlPoints = node.prevControlPoints! + offset;
      node.prevControlPoints = node.prevControlPoints!
          .clamp(Offset.zero, Offset(size.width, size.height));
    }
    if (node.nextControlPoints != null) {
      node.nextControlPoints = node.nextControlPoints! + offset;
      node.nextControlPoints = node.nextControlPoints!
          .clamp(Offset.zero, Offset(size.width, size.height));
    }
  }

  void updateNodeControl(int index, bool prev, Offset offset) {
    DynamicNode node = nodes[index];
    if (prev) {
      node.prevControlPoints = offset;
      node.prevControlPoints = node.prevControlPoints!
          .clamp(Offset.zero, Offset(size.width, size.height));
    } else {
      node.nextControlPoints = offset;
      node.nextControlPoints = node.nextControlPoints!
          .clamp(Offset.zero, Offset(size.width, size.height));
    }
  }

  List<Offset> getControlPointsAt(int index) {
    List<Offset> rst = [];
    int nextIndex = (index + 1) % nodes.length;
    Offset? control1 = nodes[index].nextControlPoints;
    Offset? control2 = nodes[nextIndex].prevControlPoints;
    if (control1 != null && control2 != null) {
      rst.add(nodes[index].position);
      rst.add(control1);
      rst.add(control2);
      rst.add(nodes[nextIndex].position);
    } else if (control1 != null && control2 == null) {
      Offset tempControl2 = nodes[nextIndex].position +
          (nodes[index].position - nodes[nextIndex].position) / 3;
      rst.add(nodes[index].position);
      rst.add(control1);
      rst.add(tempControl2);
      rst.add(nodes[nextIndex].position);
    } else if (control1 == null && control2 != null) {
      Offset tempControl1 = nodes[index].position +
          (nodes[nextIndex].position - nodes[index].position) / 3;
      rst.add(nodes[index].position);
      rst.add(tempControl1);
      rst.add(control2);
      rst.add(nodes[nextIndex].position);
    } else {
      rst.add(nodes[index].position);
      rst.add(nodes[nextIndex].position);
    }
    return rst;
  }

  static List<Offset> splitCubicAt(double t, List<Offset> controlPoints) {
    Offset x1 = controlPoints[0];
    Offset x2 = controlPoints[1];
    Offset x3 = controlPoints[2];
    Offset x4 = controlPoints[3];
    Offset x12, x23, x34, x123, x234, x1234;
    x12 = (x2 - x1) * t + x1;
    x23 = (x3 - x2) * t + x2;
    x34 = (x4 - x3) * t + x3;
    x123 = (x23 - x12) * t + x12;
    x234 = (x34 - x23) * t + x23;
    x1234 = (x234 - x123) * t + x123;
    return [x1, x12, x123, x1234, x234, x34, x4];
  }

  Path getPath(Size newSize) {
    Path path = Path()..moveTo(nodes[0].position.dx, nodes[0].position.dy);
    for (int i = 0; i < nodes.length; i++) {
      List<Offset> controlPoints = getControlPointsAt(i);
      if (controlPoints.length == 4) {
        path
          ..cubicTo(
              controlPoints[1].dx,
              controlPoints[1].dy,
              controlPoints[2].dx,
              controlPoints[2].dy,
              controlPoints[3].dx,
              controlPoints[3].dy);
      } else {
        path..lineTo(controlPoints[1].dx, controlPoints[1].dy);
      }
    }

    final Matrix4 matrix4 = Matrix4.identity();
    matrix4.scale(newSize.width / size.width, newSize.height / size.height);
    return path.transform(matrix4.storage);
  }
}

abstract class Shape {
  //final scale;

  const Shape();

  Shape.fromJson(Map<String, dynamic> map);

  Map<String, dynamic> toJson();

  DynamicPath generateDynamicPath(Rect rect);

  Path generatePath({required Rect rect});

  void addBezier(List<DynamicNode> nodes, List<Offset> points) {
    if(nodes.isEmpty) {
      nodes.add(DynamicNode(position: points[0]));
    }
    for (int i=0; i<points.length; i+=4) {
      nodes.last.nextControlPoints=points[i+1];
      DynamicNode newNode=DynamicNode(position: points[i+3], prevControlPoints: points[i+2]);
      nodes.add(newNode);
    }
  }


  void drawBorder(
      Canvas canvas, Rect rect, Color borderColor, double borderWidth) {
    if (borderWidth > 0) {
      Paint borderPaint = Paint();
      borderPaint.isAntiAlias = true;
      borderPaint.style = PaintingStyle.stroke;
      borderPaint.color = borderColor;
      borderPaint.strokeWidth = borderWidth;
      canvas.drawPath(generatePath(rect: rect), borderPaint);
    }
  }
}

class MorphableShapeBorder extends ShapeBorder {
  final Shape shape;
  final Color borderColor;
  final double borderWidth;

  const MorphableShapeBorder(
      {required this.shape,
      this.borderColor = Colors.black,
      this.borderWidth = 1});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst = {};
    rst["shape"] = shape.toJson();
    rst["borderColor"] = borderColor.toJson();
    rst["borderWidth"] = borderWidth;
    return rst;
  }

  @override
  EdgeInsetsGeometry get dimensions {
    return EdgeInsets.all(0);
  }

  @override
  ShapeBorder scale(double t) {
    return this;
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return shape.generatePath(rect: rect);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return shape.generatePath(rect: rect);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    shape.drawBorder(canvas, rect, borderColor, borderWidth);
  }

  @override
  bool operator ==(dynamic other) {
    if (runtimeType != other.runtimeType) return false;
    final MorphableShapeBorder typedOther = other;
    return shape == typedOther.shape &&
        borderWidth == typedOther.borderWidth &&
        borderColor == typedOther.borderColor;
  }

  @override
  int get hashCode =>
      (shape.hashCode + borderWidth.hashCode * 3 + borderColor.hashCode * 5);

  @override
  String toString() {
    return '$runtimeType(shape: $shape, borderColor: $borderColor, borderWidth: $borderWidth)';
  }
}

///Why is there no shapeTween?
///Because to morph shape we need to know the rect at every time step,
/// which can only be retrieved from a shapeBorder
class MorphableShapeBorderTween extends Tween<MorphableShapeBorder> {
  late SampledPathData data;
  MorphableShapeBorderTween(
      {MorphableShapeBorder begin = const MorphableShapeBorder(
          shape: RoundRectShape(borderRadius: BorderRadius.all(Radius.zero))),
      MorphableShapeBorder end = const MorphableShapeBorder(
          shape: RoundRectShape(borderRadius: BorderRadius.all(Radius.zero)))})
      : super(begin: begin, end: end) {
    Rect originalRect = Rect.fromLTRB(0, 0, 100, 100);
    data = SampledPathData(
        points1: [],
        points2: [],
        shiftedPoints: [],
        endIndices: [],
        boundingBox: Rect.zero);
    PathMorph.samplePathsFromShape(data, begin.shape, end.shape, originalRect);
  }

  @override
  MorphableShapeBorder lerp(double t) {
    if (t < 0.01) return begin!;
    if (t > 0.99) return end!;
    return MorphableShapeBorder(
        shape: MorphShape(
            startShape: begin!.shape, endShape: end!.shape, t: t, data: data),
        borderColor:
            ColorTween(begin: begin!.borderColor, end: end!.borderColor)
                    .transform(t) ??
                Colors.transparent,
        borderWidth: Tween(begin: begin!.borderWidth, end: end!.borderWidth)
            .transform(t));
  }
}
