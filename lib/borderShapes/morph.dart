import 'package:flutter/material.dart';
import '../morphable_shape_border.dart';

import '../dynamic_path_morph.dart';

///this class should only be called by a morphShapeTween
///Use PathMorph to morph between two shapes
class MorphShape extends Shape {
  final double t;
  final SampledDynamicPathData data;

  MorphShape({this.t, this.data});

  DynamicPath generateDynamicPath(Rect rect) {
    if (rect.width != data.boundingBox.width ||
        rect.height != data.boundingBox.height) {
      data.boundingBox = rect;
      DynamicPathMorph.samplePathsFromShape(data);
    }
    return DynamicPathMorph.lerpPath(t, data)..resize(rect.size);
  }

  Map<String, dynamic> toJson() {
    return {};
  }

  Shape copyWith() {
    return this;
  }
}
