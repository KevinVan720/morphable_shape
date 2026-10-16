import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morphable_shape/morphable_shape.dart';

const Color red = Color(0xFFFF0000);
const Color green = Color(0xFF00FF00);
const Color blue = Color(0xFF0000FF);
const Color translucent = Color(0x80123456);

const LinearGradient linearGradient = LinearGradient(colors: [red, blue]);
const RadialGradient radialGradient = RadialGradient(colors: [green, red]);
const SweepGradient sweepGradient = SweepGradient(colors: [blue, green]);

const DynamicBorderSide solidBorder = DynamicBorderSide(width: 4, color: red);
const DynamicBorderSide gradientBorder =
    DynamicBorderSide(width: 6, gradient: linearGradient);
const DynamicBorderSide partialBorder = DynamicBorderSide(
  width: 3,
  color: blue,
  begin: Length(10, unit: LengthUnit.percent),
  end: Length(60, unit: LengthUnit.percent),
  shift: Length(20, unit: LengthUnit.percent),
  strokeCap: StrokeCap.round,
  strokeJoin: StrokeJoin.round,
);

/// The sizes every shape gets checked with.
const List<Size> sampleSizes = [Size(100, 100), Size(240, 80), Size(60, 150)];

DynamicPath samplePath() => DynamicPath(size: const Size(100, 100), nodes: [
      DynamicNode(position: const Offset(0, 0)),
      DynamicNode(position: const Offset(100, 0), next: const Offset(100, 50)),
      DynamicNode(position: const Offset(50, 100), prev: const Offset(90, 100)),
    ]);

/// One representative of every shape border type with its default values.
Map<String, MorphableShapeBorder> defaultShapes() => {
      'Rectangle': const RectangleShapeBorder(),
      'RoundedRectangle': const RoundedRectangleShapeBorder(),
      'Circle': const CircleShapeBorder(),
      'Polygon': const PolygonShapeBorder(),
      'Star': const StarShapeBorder(),
      'Arc': const ArcShapeBorder(),
      'Arrow': const ArrowShapeBorder(),
      'Bubble': const BubbleShapeBorder(),
      'Trapezoid': const TrapezoidShapeBorder(),
      'Triangle': const TriangleShapeBorder(),
      'Path': PathShapeBorder(path: samplePath()),
    };

/// A wide selection of configured shapes (every type, side, corner style and
/// a few border variations).
Map<String, MorphableShapeBorder> sampleShapes() {
  final shapes = <String, MorphableShapeBorder>{...defaultShapes()};
  for (final style in CornerStyle.values) {
    shapes['Rectangle.${style.name}'] = RectangleShapeBorder(
      borderRadius: const DynamicBorderRadius.all(
          DynamicRadius.circular(Length(20, unit: LengthUnit.percent))),
      cornerStyles: RectangleCornerStyles.all(style),
      border: solidBorder,
    );
    shapes['Polygon.${style.name}'] = PolygonShapeBorder(
      sides: 6,
      cornerStyle: style,
      cornerRadius: const Length(30, unit: LengthUnit.percent),
      border: gradientBorder,
    );
    shapes['Star.${style.name}'] = StarShapeBorder(
      corners: 5,
      cornerStyle: style,
      insetStyle: style,
      cornerRadius: const Length(20, unit: LengthUnit.percent),
      insetRadius: const Length(20, unit: LengthUnit.percent),
      border: partialBorder,
    );
  }
  for (final side in ShapeSide.values) {
    shapes['Arc.${side.name}.out'] =
        ArcShapeBorder(side: side, border: solidBorder);
    shapes['Arc.${side.name}.in'] = ArcShapeBorder(
        side: side,
        isOutward: false,
        arcHeight: const Length(30, unit: LengthUnit.percent));
    shapes['Arrow.${side.name}'] =
        ArrowShapeBorder(side: side, border: gradientBorder);
    shapes['Bubble.${side.name}'] =
        BubbleShapeBorder(side: side, border: partialBorder);
    shapes['Trapezoid.${side.name}'] =
        TrapezoidShapeBorder(side: side, border: solidBorder);
  }
  shapes['RoundedRectangle.borders'] = const RoundedRectangleShapeBorder(
    borderRadius: DynamicBorderRadius.only(
      topLeft: DynamicRadius.circular(Length(30, unit: LengthUnit.percent)),
      bottomRight: DynamicRadius.elliptical(
          Length(60), Length(10, unit: LengthUnit.percent)),
    ),
    borderSides: RectangleBorderSides.only(
      top: DynamicBorderSide(width: 5, color: red),
      right: DynamicBorderSide(width: 10, gradient: radialGradient),
      bottom: DynamicBorderSide(width: 2, color: translucent),
      left: DynamicBorderSide(width: 8, gradient: sweepGradient),
    ),
  );
  shapes['RoundedRectangle.circular100'] = const RoundedRectangleShapeBorder(
    borderRadius: DynamicBorderRadius.all(DynamicRadius.circular(Length(100))),
    borderSides: RectangleBorderSides.all(solidBorder),
  );
  shapes['RoundedRectangle.hugeBorder'] = const RoundedRectangleShapeBorder(
    borderSides: RectangleBorderSides.symmetric(
        horizontal: DynamicBorderSide(width: 200, color: red),
        vertical: DynamicBorderSide(width: 30, color: blue)),
  );
  shapes['Circle.border'] = const CircleShapeBorder(border: gradientBorder);
  shapes['Triangle.custom'] = const TriangleShapeBorder(
    point1: DynamicOffset(Length(10), Length(0, unit: LengthUnit.percent)),
    point2: DynamicOffset(Length(100, unit: LengthUnit.percent),
        Length(50, unit: LengthUnit.percent)),
    point3: DynamicOffset(Length(0), Length(100, unit: LengthUnit.percent)),
    border: partialBorder,
  );
  shapes['Path.border'] =
      PathShapeBorder(path: samplePath(), border: solidBorder);
  return shapes;
}

/// Paints [shape] into a throw-away picture, surfacing any exception or
/// failed assertion.
void paintShape(ShapeBorder shape, Rect rect) {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  shape.paint(canvas, rect);
  recorder.endRecording().dispose();
}

bool isFiniteOffset(Offset offset) => offset.dx.isFinite && offset.dy.isFinite;

/// Every node and control point of [path] is finite and within [rect]
/// (allowing for a small numerical tolerance).
void expectNodesWithin(DynamicPath path, Rect rect, {double tolerance = 0.01}) {
  final bounds = rect.inflate(tolerance);
  for (final node in path.nodes) {
    for (final point in [node.position, node.prev, node.next]) {
      if (point == null) continue;
      expect(isFiniteOffset(point), isTrue, reason: 'non finite point $point');
      expect(
        point.dx >= bounds.left &&
            point.dx <= bounds.right &&
            point.dy >= bounds.top &&
            point.dy <= bounds.bottom,
        isTrue,
        reason: '$point is outside of $rect',
      );
    }
  }
}

/// Matches a [Rect] whose edges are all within [epsilon] of [expected].
Matcher rectCloseTo(Rect expected, {double epsilon = 0.5}) =>
    _RectCloseTo(expected, epsilon);

class _RectCloseTo extends Matcher {
  const _RectCloseTo(this.expected, this.epsilon);

  final Rect expected;
  final double epsilon;

  @override
  bool matches(Object? item, Map<dynamic, dynamic> matchState) {
    if (item is! Rect) return false;
    return (item.left - expected.left).abs() <= epsilon &&
        (item.top - expected.top).abs() <= epsilon &&
        (item.right - expected.right).abs() <= epsilon &&
        (item.bottom - expected.bottom).abs() <= epsilon;
  }

  @override
  Description describe(Description description) =>
      description.add('a Rect within $epsilon of $expected');
}

/// Pumps [child] centered in a large surface so that the painted rect does not
/// start at the origin of the canvas.
Future<void> pumpCentered(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Align(
        alignment: const Alignment(0.3, 0.2),
        child: child,
      ),
    ),
  );
}
