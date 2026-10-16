import 'package:morphable_shape/src/common_includes.dart';

///this class should only be called by a morphShapeTween
///Use PathMorph to morph between two shapes
class MorphShapeBorder extends MorphableShapeBorder {
  final double t;
  final MorphShapeData morphData;

  const MorphShapeBorder({required this.t, required this.morphData});

  @override
  Map<String, dynamic> toJson() {
    return {};
  }

  @override
  MorphableShapeBorder copyWith() {
    return this;
  }

  @override
  bool isSameMorphGeometry(MorphableShapeBorder shape) {
    return false;
  }

  @override
  EdgeInsetsGeometry get dimensions =>
      EdgeInsetsGeometry.lerp(
          morphData.begin.dimensions, morphData.end.dimensions, t) ??
      EdgeInsets.zero;

  ///Sample the morph data if this has not been done yet or if the size of the
  ///rect changed. The data is always sampled in the local coordinate space of
  ///the shape (a rect at the origin). An empty rect keeps the current data,
  ///the paths are just scaled down to it.
  void _updateMorphData(Rect rect) {
    bool isSampled = morphData.supplyCounts1 != null;
    bool sizeChanged = rect.width != morphData.boundingBox.width ||
        rect.height != morphData.boundingBox.height;
    if (!rect.isEmpty && sizeChanged) {
      morphData.boundingBox = Offset.zero & rect.size;
      DynamicPathMorph.sampleBorderPathsFromShape(morphData);
    } else if (!isSampled) {
      DynamicPathMorph.sampleBorderPathsFromShape(morphData);
    }
  }

  @override
  DynamicPath generateOuterDynamicPath(Rect rect) {
    _updateMorphData(rect);
    return DynamicPathMorph.lerpPaths(
        t, morphData.beginOuterPath, morphData.endOuterPath)
      ..resize(rect.size);
  }

  @override
  DynamicPath generateInnerDynamicPath(Rect rect) {
    _updateMorphData(rect);
    if (morphData.begin is FilledBorderShapeBorder) {
      if (morphData.end is FilledBorderShapeBorder) {
        return DynamicPathMorph.lerpPaths(
            t, morphData.beginPaths!.inner, morphData.endPaths!.inner)
          ..resize(rect.size);
      } else {
        return DynamicPathMorph.lerpPaths(
            t, morphData.beginPaths!.inner, morphData.endOuterPath)
          ..resize(rect.size);
      }
    } else {
      if (morphData.end is FilledBorderShapeBorder) {
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

  ///The paths between each pair of outer and inner nodes, in the local
  ///coordinate space of the shape (relative to the top left of [rect]).
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

  ///Fill the border paths with the (already interpolated) colors and gradients
  void _paintFilledBorder(Canvas canvas, Rect rect, List<Color> borderColors,
      List<Gradient?> borderGradients) {
    List<Path> paths = generateBorderPaths(rect);
    if (paths.isEmpty) return;
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
    Paint borderPaint = Paint();
    for (int i = 0; i < finalPaths.length; i++) {
      borderPaint.style = PaintingStyle.fill;
      borderPaint.color = finalColors[i];
      borderPaint.shader = finalGradients[i]?.createShader(rect);
      borderPaint.strokeWidth = 1;
      canvas.drawPath(finalPaths[i].shift(rect.topLeft), borderPaint);
    }
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    _updateMorphData(rect);
    if (morphData.begin is FilledBorderShapeBorder) {
      List<Color> beginBorderColors = morphData.beginPaths!.fillColors;
      List<Gradient?> beginBorderGradients =
          morphData.beginPaths!.fillGradients;
      if (morphData.end is FilledBorderShapeBorder) {
        List<Color> endBorderColors = morphData.endPaths!.fillColors;
        List<Gradient?> endBorderGradients = morphData.endPaths!.fillGradients;
        List<Color> borderColors = beginBorderColors
            .mapIndexed((e, i) =>
                ColorTween(begin: e, end: endBorderColors[i]).lerp(t) ??
                const Color(0x00000000))
            .toList();

        List<Gradient?> borderGradients = beginBorderGradients
            .mapIndexed((e, i) => lerpGradient(t, e, endBorderGradients[i],
                beginBorderColors[i], endBorderColors[i]))
            .toList();

        _paintFilledBorder(canvas, rect, borderColors, borderGradients);
      } else {
        assert(morphData.end is OutlinedShapeBorder);
        DynamicBorderSide border =
            (morphData.end as OutlinedShapeBorder).border;
        if (border.style != BorderStyle.none) {
          Paint borderPaint = Paint()
            ..style = PaintingStyle.stroke
            ..color = border.color
            ..shader = border.gradient?.createShader(rect)
            ..strokeWidth = Tween(begin: 0.0, end: border.width).transform(t)
            ..strokeCap = border.strokeCap
            ..strokeJoin = border.strokeJoin;
          Path path = getOuterPath(rect);
          OutlinedShapeBorder.drawBorderPath(
              canvas, rect, borderPaint, path, border);
        }

        List<Color> borderColors = beginBorderColors
            .mapIndexed((e, i) =>
                ColorTween(begin: e, end: border.color).lerp(t) ??
                const Color(0xFF000000))
            .toList();

        List<Gradient?> borderGradients = beginBorderGradients
            .mapIndexed((e, i) => lerpGradient(
                t, e, border.gradient, beginBorderColors[i], border.color))
            .toList();

        _paintFilledBorder(canvas, rect, borderColors, borderGradients);
      }
    } else {
      assert(morphData.begin is OutlinedShapeBorder);
      DynamicBorderSide beginBorder =
          (morphData.begin as OutlinedShapeBorder).border;
      if (morphData.end is FilledBorderShapeBorder) {
        if (beginBorder.style != BorderStyle.none) {
          Paint borderPaint = Paint()
            ..style = PaintingStyle.stroke
            ..color = beginBorder.color
            ..shader = beginBorder.gradient?.createShader(rect)
            ..strokeWidth =
                Tween(begin: beginBorder.width, end: 0.0).transform(t)
            ..strokeCap = beginBorder.strokeCap
            ..strokeJoin = beginBorder.strokeJoin;
          Path path = getOuterPath(rect);
          OutlinedShapeBorder.drawBorderPath(
              canvas, rect, borderPaint, path, beginBorder);
        }
        List<Color> endBorderColors = morphData.endPaths!.fillColors;
        List<Gradient?> endBorderGradients = morphData.endPaths!.fillGradients;
        List<Color> borderColors = endBorderColors
            .mapIndexed(
              (e, i) =>
                  ColorTween(begin: beginBorder.color, end: e).lerp(t) ??
                  const Color(0xFF000000),
            )
            .toList();

        List<Gradient?> borderGradients = endBorderGradients
            .mapIndexed((e, i) => lerpGradient(t, beginBorder.gradient, e,
                beginBorder.color, endBorderColors[i]))
            .toList();

        _paintFilledBorder(canvas, rect, borderColors, borderGradients);
      } else {
        assert(morphData.end is OutlinedShapeBorder);
        DynamicBorderSide endBorder =
            (morphData.end as OutlinedShapeBorder).border;
        DynamicBorderSide morphBorder =
            DynamicBorderSide.lerp(beginBorder, endBorder, t);

        if (morphBorder.style != BorderStyle.none) {
          Paint borderPaint = Paint()
            ..isAntiAlias = true
            ..style = PaintingStyle.stroke
            ..color = morphBorder.color
            ..shader = lerpGradient(t, beginBorder.gradient, endBorder.gradient,
                    beginBorder.color, endBorder.color)
                ?.createShader(rect)
            ..strokeWidth = morphBorder.width
            ..strokeCap = morphBorder.strokeCap
            ..strokeJoin = morphBorder.strokeJoin;
          Path path = getOuterPath(rect);
          OutlinedShapeBorder.drawBorderPath(
              canvas, rect, borderPaint, path, morphBorder);
        }
      }
    }
  }

  ///Adds the ability to lerp from a color to a gradient and vice versa
  Gradient? lerpGradient(double t, Gradient? beginGradient,
      Gradient? endGradient, Color beginColor, Color endColor) {
    if (beginGradient == null) {
      if (endGradient == null) {
        return null;
      } else {
        if (endGradient is LinearGradient) {
          return Gradient.lerp(
              LinearGradient(colors: [beginColor, beginColor]), endGradient, t);
        }
        if (endGradient is RadialGradient) {
          return Gradient.lerp(
              RadialGradient(colors: [beginColor, beginColor]), endGradient, t);
        }
        if (endGradient is SweepGradient) {
          return Gradient.lerp(
              SweepGradient(colors: [beginColor, beginColor]), endGradient, t);
        }
      }
    } else {
      if (endGradient == null) {
        if (beginGradient is LinearGradient) {
          return Gradient.lerp(
              beginGradient, LinearGradient(colors: [endColor, endColor]), t);
        }
        if (beginGradient is RadialGradient) {
          return Gradient.lerp(
              beginGradient, RadialGradient(colors: [endColor, endColor]), t);
        }
        if (beginGradient is SweepGradient) {
          return Gradient.lerp(
              beginGradient, SweepGradient(colors: [endColor, endColor]), t);
        }
      } else {
        return Gradient.lerp(beginGradient, endGradient, t);
      }
    }

    ///Other gradient types cannot be built from a single color, let them
    ///fade in or out instead of disappearing.
    return Gradient.lerp(beginGradient, endGradient, t);
  }
}
