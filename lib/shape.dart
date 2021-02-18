import 'package:flutter/material.dart';
import 'morphable_shape.dart';

///The base class for various shapes implemented in this package
///should be serializable/deserializable
///generate a DynamicPath instance with all the control points, then convert to a Path
abstract class Shape {
  final Gradient? borderGradient;

  const Shape(
      {this.borderGradient});

  Map<String, dynamic> toJson() {
    return {"borderGradient": borderGradient?.toJson()};
  }

  Shape copyWith();

  DynamicPath generateOuterDynamicPath(Rect rect);

  DynamicPath generateInnerDynamicPath(Rect rect);

  Path generateOuterPath({required Rect rect}) {
    DynamicPath path = generateOuterDynamicPath(rect);
    path.removeOverlappingNodes();
    return path.getPath(rect.size);
  }

  Path generateInnerPath({required Rect rect}) {
    DynamicPath path = generateInnerDynamicPath(rect);
    path.removeOverlappingNodes();
    return path.getPath(rect.size);
  }

  void drawBorder(Canvas canvas, Rect rect);
}

///Shape with a single border color and width, use PaintingStyle.stroke
///to paint the border
abstract class OutlinedShape extends Shape {
  final DynamicBorderSide border;

  const OutlinedShape({this.border = DynamicBorderSide.none});

  Map<String, dynamic> toJson() {
    return {"border": border.toJson()}..addAll(super.toJson());
  }

  DynamicPath generateInnerDynamicPath(Rect rect) {
    return generateOuterDynamicPath(rect);
  }

  void drawBorder(Canvas canvas, Rect rect) {
    Paint borderPaint = Paint();

    borderPaint.isAntiAlias = true;
    borderPaint.style = PaintingStyle.stroke;
    borderPaint.color = border.color;
    borderPaint.strokeWidth =
        2 * border.width.toPX(constraintSize: rect.shortestSide);
    borderPaint.shader = borderGradient?.createShader(rect);
    canvas.drawPath(generateOuterPath(rect: rect), borderPaint);
  }
}

///Shape with multiple border color and width, use PaintingStyle.fill
///to paint the border
abstract class FilledBorderShape extends Shape {
  const FilledBorderShape();

  List<Color> borderFillColors();

  void drawBorder(Canvas canvas, Rect rect) {
    Paint borderPaint = Paint();

    DynamicPath outer = generateOuterDynamicPath(rect);
    DynamicPath inner = generateInnerDynamicPath(rect);
    List<Color> borderColors = borderFillColors();

    BorderPaths borderPaths =
        BorderPaths(outer: outer, inner: inner, fillColors: borderColors);

    borderPaths.removeOverlappingPaths();

    List<Path> paths = borderPaths.generateBorderPaths(rect);
    int shift = 0;
    for (int i = shift; i < paths.length + shift; i++) {
      borderPaint.isAntiAlias = true;
      borderPaint.style = PaintingStyle.fill;
      borderPaint.color = borderPaths.fillColors[i % borderColors.length];
      borderPaint.strokeWidth = 1;
      borderPaint.shader = borderGradient?.createShader(rect);
      canvas.drawPath(paths[i], borderPaint);
    }
  }
}
