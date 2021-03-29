import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:morphable_shape/morphable_shape.dart';

///The base class for various shapes implemented in this package
///should be serializable/deserializable
///generate a DynamicPath instance with all the control points, then convert to a Path
abstract class Shape {
  const Shape();

  Map<String, dynamic> toJson();

  Shape copyWith();

  EdgeInsetsGeometry get dimensions;

  bool isSameMorphGeometry(Shape shape);

  DynamicPath generateOuterDynamicPath(Rect rect);

  DynamicPath generateInnerDynamicPath(Rect rect);

  Path generateOuterPath({required Rect rect}) {
    DynamicPath path = generateOuterDynamicPath(Offset.zero & rect.size);
    path.removeOverlappingNodes();
    return path.getPath(rect.size).shift(rect.topLeft);
  }

  Path generateInnerPath({required Rect rect}) {
    DynamicPath path = generateInnerDynamicPath(Offset.zero & rect.size);
    path.removeOverlappingNodes();
    return path.getPath(rect.size).shift(rect.topLeft);
  }

  void drawBorder(Canvas canvas, Rect rect);
}

///Shape with a single border color and width, use PaintingStyle.stroke
///to paint the border
abstract class OutlinedShape extends Shape {
  final DynamicBorderSide border;

  const OutlinedShape({this.border = DynamicBorderSide.none});

  EdgeInsetsGeometry get dimensions => EdgeInsets.all(border.width);

  Map<String, dynamic> toJson() {
    return {"border": border.toJson()};
  }

  OutlinedShape copyWith({
    DynamicBorderSide? border,
  }) {
    return this.copyWith(border: border);
  }

  DynamicPath generateInnerDynamicPath(Rect rect) {
    return generateOuterDynamicPath(rect);
  }

  void drawBorder(Canvas canvas, Rect rect) {
    Paint borderPaint = Paint();

    if (border.style != BorderStyle.none) {
      borderPaint.isAntiAlias = true;
      borderPaint.style = PaintingStyle.stroke;
      borderPaint.color = border.color;
      borderPaint.strokeWidth = border.width;
      borderPaint.shader = border.gradient?.createShader(rect);
      borderPaint.strokeCap = border.strokeCap;
      borderPaint.strokeJoin = border.strokeJoin;
      drawBorderPath(
          canvas, rect, borderPaint, generateOuterPath(rect: rect), border);
    }
  }

  static void drawBorderPath(Canvas canvas, Rect rect, Paint borderPaint,
      Path path, DynamicBorderSide border) {
    if (border.begin != null || border.end != null) {
      PathMetric metric = path.computeMetrics().first;

      double beginPX = border.begin?.toPX(constraint: metric.length) ?? 0.0;
      double endPX =
          border.end?.toPX(constraint: metric.length) ?? metric.length;
      double shiftPX = border.shift?.toPX(constraint: metric.length) ?? 0.0;
      double temp = beginPX;
      beginPX = beginPX > endPX ? endPX : beginPX;
      endPX = beginPX == endPX ? temp : endPX;
      beginPX = beginPX.clamp(0, metric.length);
      endPX = endPX.clamp(0, metric.length);
      shiftPX = shiftPX.clamp(0, metric.length);

      path = extractPath(
        metric,
        beginPX + shiftPX,
        endPX + shiftPX,
      );
      if (beginPX + shiftPX < metric.length) {
        canvas.drawPath(path, borderPaint);
        if (endPX + shiftPX > metric.length) {
          path = extractPath(
            metric,
            0.0,
            endPX + shiftPX - metric.length,
          );
          canvas.drawPath(path, borderPaint);
        }
      } else {
        path = extractPath(
          metric,
          beginPX + shiftPX - metric.length,
          endPX + shiftPX - metric.length,
        );
        canvas.drawPath(path, borderPaint);
      }
    } else {
      canvas.drawPath(path, borderPaint);
    }
  }

  static Path extractPath(PathMetric metric, double begin, double end) {
    if (begin <= 0.0 && end >= metric.length) {
      return metric.extractPath(
        begin,
        end,
      )..close();
    }
    return metric.extractPath(
      begin,
      end,
    );
  }
}

///Shape with multiple border color and width, use PaintingStyle.fill
///to paint the border
abstract class FilledBorderShape extends Shape {
  const FilledBorderShape();

  List<Color> borderFillColors();

  List<Gradient?> borderFillGradients();

  void drawBorder(Canvas canvas, Rect rect) {
    Paint borderPaint = Paint();

    DynamicPath outer = generateOuterDynamicPath(rect);
    DynamicPath inner = generateInnerDynamicPath(rect);
    List<Color> borderColors = borderFillColors();
    List<Gradient?> borderGradients = borderFillGradients();

    BorderPaths borderPaths = BorderPaths(
        outer: outer,
        inner: inner,
        fillColors: borderColors,
        fillGradients: borderGradients);

    borderPaths.removeOverlappingPaths();

    List<Path> paths = borderPaths.generateBorderPaths(rect);
    borderColors = borderPaths.fillColors;
    borderGradients = borderPaths.fillGradients;
    List<Path> finalPaths = [paths[0]];
    List<Color> finalColors = [borderColors[0]];
    List<Gradient?> finalGradients = [borderGradients[0]];
    for (int i = 1; i < paths.length; i++) {
      if (i < paths.length - 1 &&
          borderGradients[i] == borderGradients[i - 1] &&
          borderColors[i] == borderColors[i - 1]) {
        finalPaths.last =
            Path.combine(PathOperation.union, finalPaths.last, paths[i]);
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
      borderPaint.strokeWidth = 1;
      borderPaint.strokeMiterLimit = 0.0;
      canvas.drawPath(finalPaths[i], borderPaint);
    }
  }
}
