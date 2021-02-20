import 'package:flutter/material.dart';
import 'package:morphable_shape/morphable_shape.dart';

import 'package:morphable_shape/dynamic_path_morph.dart';

///this class should only be called by a morphShapeTween
///Use PathMorph to morph between two shapes
class MorphShape extends Shape {
  final double t;
  final MorphShapeData morphData;

  MorphShape({required this.t, required this.morphData});

  Map<String, dynamic> toJson() {
    return {};
  }

  Shape copyWith() {
    return this;
  }

  DynamicPath generateOuterDynamicPath(Rect rect) {
    if (rect.width != morphData.boundingBox.width ||
        rect.height != morphData.boundingBox.height) {
      morphData.boundingBox = rect;
      DynamicPathMorph.sampleBorderPathsFromShape(morphData);
    }
    return DynamicPathMorph.lerpPaths(
        t, morphData.beginOuterPath, morphData.endOuterPath)
      ..resize(rect.size);
  }

  DynamicPath generateInnerDynamicPath(Rect rect) {
    if (rect.width != morphData.boundingBox.width ||
        rect.height != morphData.boundingBox.height) {
      morphData.boundingBox = rect;
      DynamicPathMorph.sampleBorderPathsFromShape(morphData);
    }
    if (morphData.begin is FilledBorderShape) {
      if (morphData.end is FilledBorderShape) {
        return DynamicPathMorph.lerpPaths(
            t, morphData.beginPaths!.inner, morphData.endPaths!.inner)
          ..resize(rect.size);
      } else {
        return DynamicPathMorph.lerpPaths(
            t, morphData.beginPaths!.inner, morphData.endOuterPath)
          ..resize(rect.size);
      }
    } else {
      if (morphData.end is FilledBorderShape) {
        return DynamicPathMorph.lerpPaths(
            t, morphData.beginOuterPath, morphData.endPaths!.inner)
          ..resize(rect.size);
      } else {
        return DynamicPathMorph.lerpPaths(
            t, morphData.beginOuterPath, morphData.endOuterPath)
          ..resize(rect.size);
      }
    }
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
    Paint borderPaint = Paint();
    if (morphData.begin is FilledBorderShape) {
      if (morphData.end is FilledBorderShape) {
        List<Color> beginBorderColors = morphData.beginPaths!.fillColors;
        List<Color> endBorderColors = morphData.endPaths!.fillColors;
        List<Gradient?> beginBorderGradients =
            morphData.beginPaths!.fillGradients;
        List<Gradient?> endBorderGradients = morphData.endPaths!.fillGradients;
        List<Color> borderColors = beginBorderColors
            .mapIndexed((e, i) =>
                ColorTween(begin: e, end: endBorderColors[i]).lerp(t) ??
                Colors.black)
            .toList();

        List<Gradient?> borderGradients = beginBorderGradients
            .mapIndexed((e, i) => lerpGradient(t, e, endBorderGradients[i],
                beginBorderColors[i], endBorderColors[i]))
            .toList();

        List<Path> paths = generateBorderPaths(rect);
        List<Path> finalPaths = [paths[0]];
        List<Color> finalColors = [borderColors[0]];
        List<Gradient?> finalGradients = [borderGradients[0]];
        for (int i = 1; i < paths.length; i++) {
          if (borderGradients[i] == borderGradients[i - 1] &&
              borderColors[i] == borderColors[i - 1]) {
            finalPaths.last =
                Path.combine(PathOperation.union, finalPaths.last, paths[i]);
          } else if (i == paths.length - 1 &&
              borderGradients[i] == borderGradients[0] &&
              borderColors[i] == borderColors[0]) {
            finalPaths.first =
                Path.combine(PathOperation.union, finalPaths.first, paths[i]);
          } else {
            finalPaths.add(paths[i]);
            finalColors.add(borderColors[i]);
            finalGradients.add(borderGradients[i]);
          }
        }
        for (int i = 0; i < finalPaths.length; i++) {
          borderPaint.isAntiAlias = true;
          borderPaint.style = PaintingStyle.fill;
          borderPaint.color = finalColors[i];
          borderPaint.shader = finalGradients[i]?.createShader(rect);
          borderPaint.strokeWidth = 2;
          canvas.drawPath(finalPaths[i], borderPaint);
        }
      } else {
        assert(morphData.end is OutlinedShape);
        borderPaint.style = PaintingStyle.stroke;
        borderPaint.color = (morphData.end as OutlinedShape).border.color;
        borderPaint.shader = (morphData.end as OutlinedShape)
            .border
            .gradient
            ?.createShader(rect);
        borderPaint.strokeWidth = 2 *
            Tween(
                    begin: 0.0,
                    end: (morphData.end as OutlinedShape)
                        .border
                        .width
                        .toPX(constraintSize: rect.shortestSide))
                .lerp(t);
        canvas.drawPath(generateOuterPath(rect: rect), borderPaint);

        List<Color> beginBorderColors = morphData.beginPaths!.fillColors;
        List<Gradient?> beginBorderGradients =
            morphData.beginPaths!.fillGradients;
        List<Color> borderColors = beginBorderColors
            .mapIndexed((e, i) =>
                ColorTween(
                        begin: e,
                        end: (morphData.end as OutlinedShape).border.color)
                    .lerp(t) ??
                Colors.black)
            .toList();

        List<Gradient?> borderGradients = beginBorderGradients
            .mapIndexed((e, i) => lerpGradient(
                t,
                e,
                (morphData.end as OutlinedShape).border.gradient,
                beginBorderColors[i],
                (morphData.end as OutlinedShape).border.color))
            .toList();

        List<Path> paths = generateBorderPaths(rect);

        List<Path> finalPaths = [paths[0]];
        List<Color> finalColors = [borderColors[0]];
        List<Gradient?> finalGradients = [borderGradients[0]];
        for (int i = 1; i < paths.length; i++) {
          if (borderGradients[i] == borderGradients[i - 1] &&
              borderColors[i] == borderColors[i - 1]) {
            finalPaths.last =
                Path.combine(PathOperation.union, finalPaths.last, paths[i]);
          } else if (i == paths.length - 1 &&
              borderGradients[i] == borderGradients[0] &&
              borderColors[i] == borderColors[0]) {
            finalPaths.first =
                Path.combine(PathOperation.union, finalPaths.first, paths[i]);
          } else {
            finalPaths.add(paths[i]);
            finalColors.add(borderColors[i]);
            finalGradients.add(borderGradients[i]);
          }
        }
        for (int i = 0; i < finalPaths.length; i++) {
          borderPaint.isAntiAlias = true;
          borderPaint.style = PaintingStyle.fill;
          borderPaint.color = finalColors[i];
          borderPaint.shader = finalGradients[i]?.createShader(rect);
          borderPaint.strokeWidth = 2;
          canvas.drawPath(finalPaths[i], borderPaint);
        }
      }
    } else {
      assert(morphData.begin is OutlinedShape);
      if (morphData.end is FilledBorderShape) {
        Paint borderPaint = Paint();

        borderPaint.style = PaintingStyle.stroke;
        borderPaint.color = (morphData.begin as OutlinedShape).border.color;
        borderPaint.shader = (morphData.begin as OutlinedShape)
            .border
            .gradient
            ?.createShader(rect);

        borderPaint.strokeWidth = 2 *
            Tween(
                    begin: (morphData.begin as OutlinedShape)
                        .border
                        .width
                        .toPX(constraintSize: rect.shortestSide),
                    end: 0.0)
                .lerp(t);
        canvas.drawPath(generateOuterPath(rect: rect), borderPaint);

        List<Color> endBorderColors = morphData.endPaths!.fillColors;
        List<Gradient?> endBorderGradients = morphData.endPaths!.fillGradients;
        List<Color> borderColors = endBorderColors
            .mapIndexed(
              (e, i) =>
                  ColorTween(
                          begin:
                              (morphData.begin as OutlinedShape).border.color,
                          end: e)
                      .lerp(t) ??
                  Colors.black,
            )
            .toList();

        List<Gradient?> borderGradients = endBorderGradients
            .mapIndexed((e, i) => lerpGradient(
                t,
                (morphData.begin as OutlinedShape).border.gradient,
                e,
                (morphData.begin as OutlinedShape).border.color,
                endBorderColors[i]))
            .toList();

        List<Path> paths = generateBorderPaths(rect);
        List<Path> finalPaths = [paths[0]];
        List<Color> finalColors = [borderColors[0]];
        List<Gradient?> finalGradients = [borderGradients[0]];
        for (int i = 1; i < paths.length; i++) {
          if (borderGradients[i] == borderGradients[i - 1] &&
              borderColors[i] == borderColors[i - 1]) {
            finalPaths.last =
                Path.combine(PathOperation.union, finalPaths.last, paths[i]);
          } else if (i == paths.length - 1 &&
              borderGradients[i] == borderGradients[0] &&
              borderColors[i] == borderColors[0]) {
            finalPaths.first =
                Path.combine(PathOperation.union, finalPaths.first, paths[i]);
          } else {
            finalPaths.add(paths[i]);
            finalColors.add(borderColors[i]);
            finalGradients.add(borderGradients[i]);
          }
        }
        for (int i = 0; i < finalPaths.length; i++) {
          borderPaint.isAntiAlias = true;
          borderPaint.style = PaintingStyle.fill;
          borderPaint.color = finalColors[i];
          borderPaint.shader = finalGradients[i]?.createShader(rect);
          borderPaint.strokeWidth = 2;
          canvas.drawPath(finalPaths[i], borderPaint);
        }
      } else {
        assert(morphData.end is OutlinedShape);
        Paint borderPaint = Paint();
        borderPaint.isAntiAlias = true;
        borderPaint.style = PaintingStyle.stroke;

        borderPaint.color = ColorTween(
                    begin: (morphData.begin as OutlinedShape).border.color,
                    end: (morphData.end as OutlinedShape).border.color)
                .lerp(t) ??
            Colors.black;
        borderPaint.shader = lerpGradient(
                t,
                (morphData.begin as OutlinedShape).border.gradient,
                (morphData.end as OutlinedShape).border.gradient,
                (morphData.begin as OutlinedShape).border.color,
                (morphData.end as OutlinedShape).border.color)
            ?.createShader(rect);
        borderPaint.strokeWidth = 2 *
            Tween(
                    begin: (morphData.begin as OutlinedShape)
                        .border
                        .width
                        .toPX(constraintSize: rect.shortestSide),
                    end: (morphData.end as OutlinedShape)
                        .border
                        .width
                        .toPX(constraintSize: rect.shortestSide))
                .lerp(t);
        canvas.drawPath(generateOuterPath(rect: rect), borderPaint);
      }
    }
  }

  Gradient? lerpGradient(double t, Gradient? beginGradient,
      Gradient? endGradient, Color beginColor, Color endColor) {
    if (beginGradient == null) {
      if (endGradient == null) {
        return null;
      } else {
        return Gradient.lerp(
            LinearGradient(colors: [beginColor, beginColor]), endGradient, t);
      }
    } else {
      if (endGradient == null) {
        return Gradient.lerp(
            beginGradient, LinearGradient(colors: [endColor, endColor]), t);
      } else {
        return Gradient.lerp(beginGradient, endGradient, t);
      }
    }
  }
}
