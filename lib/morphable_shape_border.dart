import 'package:flutter/material.dart';
import 'package:morphable_shape/shapes/rectangle.dart';
import 'package:morphable_shape/shapes/morph.dart';

import 'package:morphable_shape/morphable_shape.dart';
import 'package:morphable_shape/dynamic_path_morph.dart';

///ShapeBorder with various customizable shapes
///can smoothly tween between any two instances of this class
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

  ///for complex/responsive shapes, there is no way to determine the dimensions of the shape
  ///without knowing the constraints
  @override
  EdgeInsetsGeometry get dimensions {
    return this.shape.dimensions;
  }

  ///TODO: implement this,
  ///not a top priority as there is no use case I can think of...
  @override
  ShapeBorder scale(double t) {
    return this;
  }

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
  int get hashCode => shape.hashCode;

  @override
  String toString() {
    return '$runtimeType(shape: $shape)';
  }
}

///Why is there no shapeTween?
///Because to morph shape we need to know the rect at every time step,
/// which can only be retrieved from a shapeBorder
class MorphableShapeBorderTween extends Tween<MorphableShapeBorder?> {
  MorphShapeData? data;
  MorphMethod method;
  MorphableShapeBorderTween(
      {MorphableShapeBorder? begin,
      MorphableShapeBorder? end,
      this.method = MorphMethod.auto})
      : super(begin: begin, end: end);

  @override
  MorphableShapeBorder? lerp(double t) {
    if (begin == null && end == null) {
      return null;
    }
    if (begin == null) {
      if (data == null || end!.shape != data!.end) {
        data = MorphShapeData(
            begin: RectangleShape(),
            end: end!.shape,
            boundingBox: Rect.fromLTRB(0, 0, 100, 100),
            method: method);
        DynamicPathMorph.sampleBorderPathsFromShape(data!);
      }
      return MorphableShapeBorder(
        shape: MorphShape(t: t, morphData: data!),
      );
    }
    if (end == null) {
      if (data == null) {
        data = MorphShapeData(
            begin: begin!.shape,
            end: RectangleShape(),
            boundingBox: Rect.fromLTRB(0, 0, 100, 100),
            method: method);
        DynamicPathMorph.sampleBorderPathsFromShape(data!);
      }
      return MorphableShapeBorder(
        shape: MorphShape(t: t, morphData: data!),
      );
    }
    if (data == null ||
        begin!.shape != data!.begin ||
        end!.shape != data!.end) {
      data = MorphShapeData(
          begin: begin!.shape,
          end: end!.shape,
          boundingBox: Rect.fromLTRB(0, 0, 100, 100),
          method: method);
      DynamicPathMorph.sampleBorderPathsFromShape(data!);
    }
    return MorphableShapeBorder(
      shape: MorphShape(t: t, morphData: data!),
    );
  }
}
