import 'package:flutter/material.dart';
import '../morphable_shape_border.dart';
import '../path_morph.dart';
import '../dynamic_path_morph.dart';

///this class should only be called by a morphShapeTween
///Use PathMorph to morph between two shapes
class MorphShape extends Shape {
  final Shape startShape;
  final Shape endShape;
  final double t;

  SampledDynamicPathData data;

  MorphShape({required this.startShape, required this.endShape, required this.t, required this.data});

  DynamicPath generateDynamicPath(Rect rect) {
    if(rect.width!=data.boundingBox.width||rect.height!=data.boundingBox.height) {
      DynamicPathMorph.samplePathsFromShape(data, startShape,
          endShape,
          rect);
    }
    //DynamicPathMorph.lerpPath(t, data).forEach((element) {
    //  nodes.add(DynamicNode(position: element));
    //});
    return DynamicPathMorph.lerpPath(t, data)..resize(rect.size);
  }

  Map<String, dynamic> toJson() {
    return {};
  }

  Shape copyWith() {
    return this;
  }

}
