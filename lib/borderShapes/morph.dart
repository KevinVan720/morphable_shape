import 'package:flutter/material.dart';
import '../morphable_shape_border.dart';

import '../dynamic_path_morph.dart';

///this class should only be called by a morphShapeTween
///Use PathMorph to morph between two shapes
class MorphShape extends Shape {
  final double t;
  final SampledDynamicPathData data;

  MorphShape({required this.t, required this.data});

  DynamicPath generateOuterDynamicPath(Rect rect) {
    if (rect.width != data.boundingBox.width ||
        rect.height != data.boundingBox.height) {
      data.boundingBox = rect;
      DynamicPathMorph.sampleOuterPathsFromShape(data);
      DynamicPathMorph.sampleInnerPathsFromShape(data);
    }
    return DynamicPathMorph.lerpOuterPath(t, data)..resize(rect.size);
  }

  DynamicPath generateInnerDynamicPath(Rect rect) {
    if (rect.width != data.boundingBox.width ||
        rect.height != data.boundingBox.height) {
      data.boundingBox = rect;
      DynamicPathMorph.sampleOuterPathsFromShape(data);
      DynamicPathMorph.sampleInnerPathsFromShape(data);
    }
    return DynamicPathMorph.lerpInnerPath(t, data)..resize(rect.size);
  }

  Map<String, dynamic> toJson() {
    return {};
  }

  Shape copyWith() {
    return this;
  }

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

  @override
  void drawBorder(Canvas canvas, Rect rect) {
    if (data.begin is FilledBorderShape && data.end is FilledBorderShape) {
      Paint borderPaint = Paint();

      List<Color> beginBorderColors =
          (data.begin as FilledBorderShape).borderFillColors();
      List<Color> endBorderColors =
          (data.end as FilledBorderShape).borderFillColors();
      List<Color> borderColors = beginBorderColors
          .mapIndexed(
              (e, i) => ColorTween(begin: e, end: endBorderColors[i%endBorderColors.length]).lerp(t)??Colors.black)
          .toList();

      List<Path> paths = generateBorderPaths(rect);
      int shift = 0;
      for (int i = shift; i < paths.length + shift; i++) {
        borderPaint.isAntiAlias = true;
        borderPaint.style = PaintingStyle.fill;
        borderPaint.color = borderColors[i % borderColors.length];
        borderPaint.strokeWidth = 1;
        canvas.drawPath(paths[i], borderPaint);
      }
    } else {
      Paint borderPaint = Paint();
      borderPaint.isAntiAlias = true;
      borderPaint.style = PaintingStyle.stroke;
      borderPaint.color = Colors.black;
      borderPaint.strokeWidth = 2;
      canvas.drawPath(generateOuterPath(rect: rect), borderPaint);
    }
  }
}
