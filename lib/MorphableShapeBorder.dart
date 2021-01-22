import 'package:flutter/material.dart';
import 'PathMorph.dart';
import 'package:morphable_shape/borderShapes/roundrect.dart';
import 'package:morphable_shape/borderShapes/morph.dart';
import 'DynamicPath.dart';

export 'ShapeUtils.dart';
export 'package:flutter_class_parser/parseJson.dart';
export 'package:flutter_class_parser/toJson.dart';

export 'package:length_unit/length_unit.dart';
export 'DynamicShape.dart';
export 'DynamicPath.dart';
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

abstract class Shape {
  //final scale;

  const Shape();

  DynamicPath generateDynamicPath(Rect rect);

  Shape copyWith();

  Path generatePath({required Rect rect}) {

    return generateDynamicPath(rect).getPath(rect.size);
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

  /*
  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst = {};
    rst["shape"] = shape.toJson();
    rst["borderColor"] = borderColor.toJson();
    rst["borderWidth"] = borderWidth;
    return rst;
  }
  */

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
      {MorphableShapeBorder? begin,
      MorphableShapeBorder? end})
      : super(begin: begin, end: end) {
    Rect originalRect = Rect.fromLTRB(0, 0, 100, 100);
    data = SampledPathData(
        points1: [],
        points2: [],
        shiftedPoints: [],
        endIndices: [],
        boundingBox: Rect.zero);
    begin=begin??MorphableShapeBorder(
        shape: RoundRectShape(borderRadius: BorderRadius.all(Radius.zero)));
    end=end??MorphableShapeBorder(
        shape: RoundRectShape(borderRadius: BorderRadius.all(Radius.zero)));
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
