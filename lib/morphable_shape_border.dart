import 'package:flutter/material.dart';
import 'package:morphable_shape/borderShapes/rectangle.dart';
import 'package:morphable_shape/borderShapes/morph.dart';

import 'package:morphable_shape/morphable_shape.dart';
import 'dynamic_path.dart';
import 'dynamic_path_morph.dart';

export 'shape_utils.dart';
export 'package:flutter_class_parser/parse_json.dart';
export 'package:flutter_class_parser/to_json.dart';
export 'shadowed_shape.dart';
export 'animated_shadowd_shape.dart';

export 'package:length_unit/length_unit.dart';
export 'dynamic_path.dart';
export 'parse_json.dart';
export 'borderShapes/arc.dart';
export 'borderShapes/bubble.dart';
export 'borderShapes/arrow.dart';
export 'borderShapes/circle.dart';
export 'borderShapes/polygon.dart';
export 'borderShapes/rectangle.dart';
export 'borderShapes/star.dart';
export 'borderShapes/triangle.dart';
export 'borderShapes/morph.dart';
export 'borderShapes/trapezoid.dart';
export 'borderShapes/path.dart';

///The base class for various shapes implemented in this package
///should be serializable/deserializable
///generate a DynamicPath instance with all the control points, then convert to a Path
abstract class Shape {
  const Shape();

  Map<String, dynamic> toJson();

  Shape copyWith();

  DynamicPath generateOuterDynamicPath(Rect rect);

  DynamicPath generateInnerDynamicPath(Rect rect);

  Path generateOuterPath({required Rect rect}) {
    DynamicPath path=generateOuterDynamicPath(rect);
    path.removeOverlappingNodes();
    return path.getPath(rect.size);
  }

  Path generateInnerPath({required Rect rect}) {
    DynamicPath path=generateInnerDynamicPath(rect);
    path.removeOverlappingNodes();
    return path.getPath(rect.size);
  }

  void drawBorder(Canvas canvas, Rect rect);
}

abstract class OutlinedShape extends Shape {
  final DynamicBorderSide border;

  const OutlinedShape({this.border = DynamicBorderSide.none});

  DynamicPath generateInnerDynamicPath(Rect rect) {
    return generateOuterDynamicPath(rect);
  }

  void drawBorder(Canvas canvas, Rect rect) {
    Paint borderPaint = Paint();

    borderPaint.isAntiAlias = true;
    borderPaint.style = PaintingStyle.stroke;
    borderPaint.color = border.color;
    borderPaint.strokeWidth =
        2 * border.width.toPX(constraintSize: rect.shortestSide);
    canvas.drawPath(generateOuterPath(rect: rect), borderPaint);
  }
}

class BorderPaths {
  static double tolerance=0.1;

  DynamicPath outer;
  DynamicPath inner;
  List<Color> fillColors;

  BorderPaths({required this.outer, required this.inner, required this.fillColors});

  void removeOverlappingPaths() {
    assert(outer.nodes.length==inner.nodes.length);
    if (outer.nodes.isNotEmpty) {
      List<DynamicNode> outerNodes = [outer.nodes[0]];
      List<DynamicNode> innerNodes = [inner.nodes[0]];
      List<Color> newColors=[fillColors[0]];
      for (int i = 0; i < outer.nodes.length; i++) {
        if ((outer.nodes[i].position - outerNodes.last.position).distance <
            tolerance && (inner.nodes[i].position - innerNodes.last.position).distance <
    tolerance) {
          outerNodes.last.next = outer.nodes[i].next;
          innerNodes.last.next = inner.nodes[i].next;
        } else if (i == outer.nodes.length - 1 &&
            (outer.nodes[i].position - outerNodes.first.position).distance <
                tolerance && (inner.nodes[i].position - innerNodes.first.position).distance <
            tolerance) {
          outerNodes.first.prev = outer.nodes[i].prev;
          innerNodes.first.prev = inner.nodes[i].prev;
        } else {
          outerNodes.add(outer.nodes[i]);
          innerNodes.add(inner.nodes[i]);
          newColors.add(fillColors[i]);
        }
      }
      outer.nodes=outerNodes;
      inner.nodes=innerNodes;
      fillColors=newColors;
    }
  }

  List<Path> generateBorderPaths(Rect rect) {
    int pathLength=outer.nodes.length;
    List<Path> rst = [];

    for (int i = 0; i < pathLength; i++) {
      DynamicNode nextNode = outer.nodes[(i + 1) % pathLength];
      DynamicPath borderPath = DynamicPath(size: rect.size, nodes: []);
      borderPath.nodes.add(DynamicNode(
          position: outer.nodes[i].position, next: outer.nodes[i].next));
      borderPath.nodes
          .add(DynamicNode(position: nextNode.position, prev: nextNode.prev));
      DynamicNode nextInnerNode = inner.nodes[(i + 1) % pathLength];
      borderPath.nodes.add(DynamicNode(
          position: nextInnerNode.position, next: nextInnerNode.prev));
      borderPath.nodes.add(DynamicNode(
          position: inner.nodes[i % pathLength].position,
          prev: inner.nodes[i % pathLength].next));
      rst.add(borderPath.getPath(rect.size));
    }

    return rst;
  }

}

abstract class FilledBorderShape extends Shape {
  const FilledBorderShape();

  List<Color> borderFillColors();

  /*
  List<Path> generateBorderPaths(Rect rect) {
    DynamicPath outer = generateOuterDynamicPath(rect);
    DynamicPath inner = generateInnerDynamicPath(rect);
    int pathLength = outer.nodes.length;
    int pathLength2 = inner.nodes.length;

    assert(outer.nodes.length == inner.nodes.length);

    List<Path> rst = [];

    for (int i = 0; i < pathLength; i++) {
      DynamicNode nextNode = outer.nodes[(i + 1) % pathLength];
      DynamicPath borderPath = DynamicPath(size: rect.size, nodes: []);
      borderPath.nodes.add(DynamicNode(
          position: outer.nodes[i].position, next: outer.nodes[i].next));
      borderPath.nodes
          .add(DynamicNode(position: nextNode.position, prev: nextNode.prev));
      DynamicNode nextInnerNode = inner.nodes[(i + 1) % pathLength2];
      borderPath.nodes.add(DynamicNode(
          position: nextInnerNode.position, next: nextInnerNode.prev));
      borderPath.nodes.add(DynamicNode(
          position: inner.nodes[i % pathLength2].position,
          prev: inner.nodes[i % pathLength2].next));
      rst.add(borderPath.getPath(rect.size));
    }

    return rst;
  }

   */

  void drawBorder(Canvas canvas, Rect rect) {
    Paint borderPaint = Paint();

    DynamicPath outer = generateOuterDynamicPath(rect);
    DynamicPath inner = generateInnerDynamicPath(rect);
    List<Color> borderColors = borderFillColors();

    BorderPaths borderPaths=BorderPaths(outer: outer, inner: inner, fillColors: borderColors);

    borderPaths.removeOverlappingPaths();

    List<Path> paths = borderPaths.generateBorderPaths(rect);
    int shift = 0;
    for (int i = shift; i < paths.length + shift; i++) {
      borderPaint.isAntiAlias = true;
      borderPaint.style = PaintingStyle.fill;
      borderPaint.color = borderPaths.fillColors[i%borderColors.length];
      borderPaint.strokeWidth = 1;
      canvas.drawPath(paths[i], borderPaint);
    }
  }
}

///ShapeBorder with various customizable shapes
///can tween smoothly between arbitrary two instances of this class
class MorphableShapeBorder extends ShapeBorder {
  final Shape shape;

  const MorphableShapeBorder({
    required this.shape,
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst = {};
    rst["shape"] = shape.toJson();
    return rst;
  }

  @override
  EdgeInsetsGeometry get dimensions {
    return EdgeInsets.all(0);
  }

  ///TODO: IMPLEMENT THIS
  @override
  ShapeBorder scale(double t) {
    return this;
  }

  ///Inner path is currently regarded the same as the outer path
  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return shape.generateInnerPath(rect: rect);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return shape.generateOuterPath(rect: rect);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    shape.drawBorder(canvas, rect);
  }

  @override
  bool operator ==(dynamic other) {
    if (runtimeType != other.runtimeType) return false;
    final MorphableShapeBorder typedOther = other;

    return shape == typedOther.shape;
  }

  @override
  //int get hashCode => hashValues(shape, borderColor, borderWidth);
  int get hashCode => shape.hashCode;

  @override
  String toString() {
    return '$runtimeType(shape: $shape)';
    //return '$runtimeType(shape: $shape, borderColor: $borderColor, borderWidth: $borderWidth)';
  }
}

///Why is there no shapeTween?
///Because to morph shape we need to know the rect at every time step,
/// which can only be retrieved from a shapeBorder
class MorphableShapeBorderTween extends Tween<MorphableShapeBorder?> {
  SampledDynamicPathData? data;
  MorphMethod method;
  MorphableShapeBorderTween(
      {MorphableShapeBorder? begin,
      MorphableShapeBorder? end,
      this.method = MorphMethod.auto})
      : super(begin: begin, end: end) ;

  @override
  MorphableShapeBorder? lerp(double t) {
    if (begin == null && end == null) {
      return null;
    }
    if (begin == null) {
      if (data == null || end!.shape != data!.end) {
        data = SampledDynamicPathData(
            begin: RectangleShape(),
            end: end!.shape,
            boundingBox: Rect.fromLTRB(0, 0, 100, 100),
            method: method);
        DynamicPathMorph.sampleOuterPathsFromShape(data!);
      }
      return MorphableShapeBorder(
        shape: MorphShape(t: t, data: data!),
      );
    }
    if (end == null) {
      if (data == null) {
        data = SampledDynamicPathData(
            begin: begin!.shape,
            end: RectangleShape(),
            boundingBox: Rect.fromLTRB(0, 0, 100, 100),
            method: method);
        DynamicPathMorph.sampleOuterPathsFromShape(data!);
      }
      return MorphableShapeBorder(
        shape: MorphShape(t: t, data: data!),
        //borderColor: ColorTween(begin: begin!.borderColor).transform(t) ??
        //    Colors.transparent,
        //borderWidth: Tween(begin: begin!.borderWidth, end: 0.0).transform(t)
      );
    }
    if (data == null ||
        begin!.shape != data!.begin ||
        end!.shape != data!.end) {
      data = SampledDynamicPathData(
          begin: begin!.shape,
          end: end!.shape,
          boundingBox: Rect.fromLTRB(0, 0, 100, 100),
          method: method);
      DynamicPathMorph.sampleOuterPathsFromShape(data!);
    }
    return MorphableShapeBorder(
      shape: MorphShape(t: t, data: data!),
    );
  }
}
