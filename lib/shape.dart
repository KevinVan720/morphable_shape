import 'package:flutter/material.dart';
import 'package:morphable_shape/morphable_shape.dart';

///The base class for various shapes implemented in this package
///should be serializable/deserializable
///generate a DynamicPath instance with all the control points, then convert to a Path
abstract class Shape {
  const Shape();

  Map<String, dynamic> toJson();

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

    borderPaint.isAntiAlias = true;
    borderPaint.style = PaintingStyle.stroke;
    borderPaint.color = border.color;
    borderPaint.strokeWidth =
        2 * border.width.toPX(constraintSize: rect.shortestSide);
    borderPaint.shader = border.gradient?.createShader(rect);
    canvas.drawPath(generateOuterPath(rect: rect), borderPaint);
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
        /*} else if (i == paths.length - 1 &&
          borderGradients[i] == borderGradients[0] &&
          borderColors[i] == borderColors[0]) {
        finalPaths.first =
            Path.combine(PathOperation.union, finalPaths.first, paths[i]);*/
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
}
