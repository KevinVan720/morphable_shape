import 'package:flutter/material.dart';
import '../morphable_shape.dart';

import '../dynamic_path_morph.dart';

///this class should only be called by a morphShapeTween
///Use PathMorph to morph between two shapes
class MorphShape extends Shape {
  final double t;
  final MorphShapeData data;

  MorphShape({required this.t, required this.data});

  DynamicPath generateOuterDynamicPath(Rect rect) {
    if (rect.width != data.boundingBox.width ||
        rect.height != data.boundingBox.height) {
      data.boundingBox = rect;
      DynamicPathMorph.sampleBorderPathsFromShape(data);
    }
    return DynamicPathMorph.lerpPaths(t, data.beginOuterPath, data.endOuterPath)
      ..resize(rect.size);
  }

  DynamicPath generateInnerDynamicPath(Rect rect) {

    if (rect.width != data.boundingBox.width ||
        rect.height != data.boundingBox.height) {
      data.boundingBox = rect;
      DynamicPathMorph.sampleBorderPathsFromShape(data);
    }
    if (data.begin is FilledBorderShape) {
      if (data.end is FilledBorderShape) {
        return DynamicPathMorph.lerpPaths(
            t, data.beginPaths!.inner, data.endPaths!.inner)
          ..resize(rect.size);
      } else {
        return DynamicPathMorph.lerpPaths(
            t, data.beginPaths!.inner, data.endOuterPath)
          ..resize(rect.size);
      }
    } else {
      if (data.end is FilledBorderShape) {
        return DynamicPathMorph.lerpPaths(
            t, data.beginOuterPath, data.endPaths!.inner)
          ..resize(rect.size);
      } else {
        return DynamicPathMorph.lerpPaths(
            t, data.beginOuterPath, data.endOuterPath)
          ..resize(rect.size);
      }
    }
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

    if(t==0 || t==1) {
      print(outer.nodes.length.toString()+", "+inner.nodes.length.toString());
      print("outer-----------------");
      outer.nodes.forEach((element) {print(element.position.toString());});
      print("inner-----------------");
      inner.nodes.forEach((element) {print(element.position.toString());});
    }


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
    Paint borderPaint = Paint();
    if (data.begin is FilledBorderShape) {
      if (data.end is FilledBorderShape) {

        List<Color> beginBorderColors = data.beginPaths!.fillColors;
        List<Color> endBorderColors = data.endPaths!.fillColors;
        List<Color> borderColors = beginBorderColors
            .mapIndexed((e, i) =>
                ColorTween(
                        begin: e,
                        end: endBorderColors[i])
                    .lerp(t) ??
                Colors.black)
            .toList();

        List<Path> paths = generateBorderPaths(rect);
        int shift = 0;
        for (int i = shift; i < paths.length + shift; i++) {
          borderPaint.isAntiAlias = true;
          borderPaint.style = PaintingStyle.fill;
          borderPaint.color = borderColors[i];
          borderPaint.strokeWidth = 1;
          canvas.drawPath(paths[i], borderPaint);
        }
      } else {

        borderPaint.style = PaintingStyle.stroke;
        borderPaint.color = (data.end as OutlinedShape).border.color;
        borderPaint.strokeWidth = 2*Tween(
            begin: 0.0,
            end: (data.end as OutlinedShape)
                .border
                .width
                .toPX(constraintSize: rect.shortestSide))
            .lerp(t);
        canvas.drawPath(generateOuterPath(rect: rect), borderPaint);

        List<Color> beginBorderColors = data.beginPaths!.fillColors;
        List<Color> borderColors = beginBorderColors
            .mapIndexed((e, i) =>
        ColorTween(
            begin: e,
            end: (data.end as OutlinedShape).border.color)
            .lerp(t) ??
            Colors.black)
            .toList();

        List<Path> paths = generateBorderPaths(rect);
        int shift = 0;
        for (int i = shift; i < paths.length + shift; i++) {
          borderPaint.isAntiAlias = true;
          borderPaint.style = PaintingStyle.fill;
          borderPaint.color = borderColors[i];
          borderPaint.strokeWidth = 1;
          canvas.drawPath(paths[i], borderPaint);
        }


      }
    } else {
      if (data.end is FilledBorderShape) {

        Paint borderPaint = Paint();

        List<Color> endBorderColors = data.endPaths!.fillColors;
        List<Color> borderColors = endBorderColors
            .mapIndexed((e, i) =>
        ColorTween(
            begin: (data.begin as OutlinedShape).border.color,
            end: e).lerp(t) ??
            Colors.black,)
            .toList();

        List<Path> paths = generateBorderPaths(rect);
        int shift = 0;
        for (int i = shift; i < paths.length + shift; i++) {
          borderPaint.isAntiAlias = true;
          borderPaint.style = PaintingStyle.fill;
          borderPaint.color = borderColors[i];
          borderPaint.strokeWidth = 1;
          canvas.drawPath(paths[i], borderPaint);
        }

        borderPaint.style = PaintingStyle.stroke;
        borderPaint.color = (data.begin as OutlinedShape).border.color;
        borderPaint.strokeWidth = 2*Tween(
            begin: (data.begin as OutlinedShape)
                .border
                .width
                .toPX(constraintSize: rect.shortestSide),
            end: 0.0)
            .lerp(t);
        canvas.drawPath(generateOuterPath(rect: rect), borderPaint);

      } else {
        Paint borderPaint = Paint();
        borderPaint.isAntiAlias = true;
        borderPaint.style = PaintingStyle.stroke;
        borderPaint.color = ColorTween(
                    begin: (data.begin as OutlinedShape).border.color,
                    end: (data.end as OutlinedShape).border.color)
                .lerp(t) ??
            Colors.black;
        borderPaint.strokeWidth = 2*Tween(
                begin: (data.begin as OutlinedShape)
                    .border
                    .width
                    .toPX(constraintSize: rect.shortestSide),
                end: (data.end as OutlinedShape)
                    .border
                    .width
                    .toPX(constraintSize: rect.shortestSide))
            .lerp(t);
        canvas.drawPath(generateOuterPath(rect: rect), borderPaint);
      }
    }
  }
}
