import 'package:flutter/material.dart';
import '../MorphableShapeBorder.dart';
import '../PathMorph.dart';

class MorphShape extends Shape {
  final Shape startShape;
  final Shape endShape;
  final double t;

  SampledPathData data;

  ///should not be called
  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst={"name": this.runtimeType};
    return rst;
  }



  MorphShape({required this.startShape, required this.endShape, required this.t, required this.data});

  DynamicPath generateDynamicPath(Rect rect) {
    return DynamicPath(size: rect.size, nodes: []);
  }

  Path generatePath({double scale=1, Rect rect= const Rect.fromLTRB(0.0, 0.0, 0.0, 0.0)}) {
    if(rect.width!=data.boundingBox.width||rect.height!=data.boundingBox.height) {
      PathMorph.samplePathsFromShape(data, startShape,
          endShape,
          rect);
      return PathMorph.lerpPath(t, data);
    }
    else {
      Path path=PathMorph.lerpPath(t, data);
      final Matrix4 matrix4 = Matrix4.identity();
      matrix4.scale(rect.width / data.boundingBox.width, rect.height / data.boundingBox.height);
      return path.transform(matrix4.storage);
    }
  }
}
