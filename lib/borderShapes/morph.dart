import 'package:flutter/material.dart';
import '../morphable_shape_border.dart';
import '../path_morph.dart';

///this class should only be called by a morphShapeTween
class MorphShape extends Shape {
  final Shape startShape;
  final Shape endShape;
  final double t;

  SampledPathData data;

  MorphShape({required this.startShape, required this.endShape, required this.t, required this.data});

  DynamicPath generateDynamicPath(Rect rect) {
    List<DynamicNode> nodes=[];
    if(rect.width!=data.boundingBox.width||rect.height!=data.boundingBox.height) {
      PathMorph.samplePathsFromShape(data, startShape,
          endShape,
          rect);
    }
    PathMorph.lerpPoints(t, data).forEach((element) {
      nodes.add(DynamicNode(position: element));
    });
    return DynamicPath(size: rect.size, nodes: nodes)..resize(rect.size);
  }

  Map<String, dynamic> toJson() {
    return {};
  }

  Shape copyWith() {
    return this;
  }

}
