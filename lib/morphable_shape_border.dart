import 'package:flutter/material.dart';
import 'path_morph.dart';
import 'package:morphable_shape/borderShapes/rectangle.dart';
import 'package:morphable_shape/borderShapes/morph.dart';
import 'dynamic_path.dart';
import 'package:flutter_class_parser/flutter_class_parser.dart';


export 'shape_utils.dart';
export 'package:flutter_class_parser/parse_json.dart';
export 'package:flutter_class_parser/to_json.dart';
export 'dynamic_material.dart';

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

abstract class Shape {

  const Shape();

  Map<String, dynamic> toJson();

  Shape copyWith();

  DynamicPath generateDynamicPath(Rect rect);

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
      ///Possible different borderColor and style in the future?
      /*
      List<Path> paths=generateDynamicPath(rect).getPaths(rect.size);
      paths.forEach((element) {
        borderPaint.color=Colors.black;
        canvas.drawPath(element, borderPaint);
      });
       */
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

  ///Not possible for some shapes to define such a scale, ignore it altogether for now
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
      hashValues(shape, borderColor, borderWidth);

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
        shape: RectangleShape());
    end=end??MorphableShapeBorder(
        shape: RectangleShape());
    PathMorph.samplePathsFromShape(data, begin.shape, end.shape, originalRect);
  }

  @override
  MorphableShapeBorder lerp(double t) {
    ///due to the finite sampling accuracy of the morphing,
    ///let the start and end time shape be the original ones
    if (t < 0.005) return begin!;
    if (t > 0.995) return end!;
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
