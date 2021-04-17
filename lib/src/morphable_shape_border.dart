import 'dart:ui';

import 'package:morphable_shape/src/common_includes.dart';
import 'package:morphable_shape/src/dynamic_path/border_paths.dart';

///The base class for various shape borders implemented in this package
///should be serializable/deserializable
///generate a DynamicPath instance with all the control points, then convert to a Path
abstract class MorphableShapeBorder extends ShapeBorder {
  const MorphableShapeBorder();

  Map<String, dynamic> toJson();

  MorphableShapeBorder copyWith();

  EdgeInsetsGeometry get dimensions;

  ///TODO: implement this,
  ///not a top priority as there is no use case I can think of...
  @override
  ShapeBorder scale(double t) {
    return this;
  }

  bool isSameMorphGeometry(MorphableShapeBorder shape);

  DynamicPath generateOuterDynamicPath(Rect rect);

  DynamicPath generateInnerDynamicPath(Rect rect);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    DynamicPath path = generateOuterDynamicPath(Offset.zero & rect.size);
    path.removeOverlappingNodes();
    return path.getPath(rect.size).shift(rect.topLeft);
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    DynamicPath path = generateInnerDynamicPath(Offset.zero & rect.size);
    path.removeOverlappingNodes();
    return path.getPath(rect.size).shift(rect.topLeft);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection});
}

///Shape with a single border color and width, use PaintingStyle.stroke
///to paint the border
abstract class OutlinedShapeBorder extends MorphableShapeBorder {
  final DynamicBorderSide border;

  const OutlinedShapeBorder({this.border = DynamicBorderSide.none});

  EdgeInsetsGeometry get dimensions => EdgeInsets.all(border.width);

  Map<String, dynamic> toJson() {
    return {"border": border.toJson()};
  }

  OutlinedShapeBorder copyWith({
    DynamicBorderSide? border,
  }) {
    return this.copyWith(border: border);
  }

  DynamicPath generateInnerDynamicPath(Rect rect) {
    return generateOuterDynamicPath(rect);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    Paint borderPaint = Paint();

    if (border.style != BorderStyle.none) {
      borderPaint.isAntiAlias = true;
      borderPaint.style = PaintingStyle.stroke;
      borderPaint.color = border.color;
      borderPaint.strokeWidth = border.width;
      borderPaint.shader = border.gradient?.createShader(rect);
      borderPaint.strokeCap = border.strokeCap;
      borderPaint.strokeJoin = border.strokeJoin;
      drawBorderPath(canvas, rect, borderPaint, getOuterPath(rect), border);
    }
  }

  ///draw the border with a optional begin, end, and offset
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

      path = extractPartialPath(
        metric,
        beginPX + shiftPX,
        endPX + shiftPX,
      );
      if (beginPX + shiftPX < metric.length) {
        canvas.drawPath(path, borderPaint);
        if (endPX + shiftPX > metric.length) {
          path = extractPartialPath(
            metric,
            0.0,
            endPX + shiftPX - metric.length,
          );
          canvas.drawPath(path, borderPaint);
        }
      } else {
        path = extractPartialPath(
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

  static Path extractPartialPath(PathMetric metric, double begin, double end) {
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
abstract class FilledBorderShapeBorder extends MorphableShapeBorder {
  const FilledBorderShapeBorder();

  List<Color> borderFillColors();

  List<Gradient?> borderFillGradients();

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
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
