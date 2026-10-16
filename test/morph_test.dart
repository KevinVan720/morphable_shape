import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morphable_shape/morphable_shape.dart';

import 'test_utils.dart';

Map<String, List<MorphableShapeBorder>> morphPairs() {
  final shapes = sampleShapes();
  return {
    'rectangle -> circle': [
      const RectangleShapeBorder(),
      const CircleShapeBorder(),
    ],
    'rounded rectangle with borders -> star': [
      shapes['RoundedRectangle.borders']!,
      shapes['Star.concave']!,
    ],
    'circle with border -> rounded rectangle with borders': [
      shapes['Circle.border']!,
      shapes['RoundedRectangle.borders']!,
    ],
    'rounded rectangle -> rounded rectangle': [
      shapes['RoundedRectangle.borders']!,
      shapes['RoundedRectangle.circular100']!,
    ],
    'rectangle -> rounded rectangle': [
      shapes['Rectangle.straight']!,
      shapes['RoundedRectangle.hugeBorder']!,
    ],
    'polygon -> star': [
      const PolygonShapeBorder(sides: 5),
      shapes['Star.rounded']!,
    ],
    'polygon -> polygon': [
      shapes['Polygon.cutout']!,
      shapes['Polygon.rounded']!,
    ],
    'arc -> arrow': [shapes['Arc.top.in']!, shapes['Arrow.left']!],
    'bubble -> triangle': [shapes['Bubble.right']!, shapes['Triangle.custom']!],
    'trapezoid -> path': [shapes['Trapezoid.top']!, shapes['Path.border']!],
    'star (many points) -> rectangle': [
      const StarShapeBorder(corners: 12, insetStyle: CornerStyle.concave),
      const RectangleShapeBorder(),
    ],
    'star -> star': [
      const StarShapeBorder(corners: 5),
      const StarShapeBorder(corners: 5, cornerStyle: CornerStyle.cutout),
    ],
  };
}

Rect boundsOf(ShapeBorder shape, Rect rect) =>
    shape.getOuterPath(rect).getBounds();

void main() {
  group('MorphableShapeBorderTween', () {
    for (final pair in morphPairs().entries) {
      for (final method in MorphMethod.values) {
        test('${pair.key} (${method.name})', () {
          final begin = pair.value[0];
          final end = pair.value[1];
          final tween =
              MorphableShapeBorderTween(begin: begin, end: end, method: method);

          for (final size in sampleSizes) {
            final rect = Offset.zero & size;
            for (final t in const [0.0, 0.25, 0.5, 1.0]) {
              final shape = tween.lerp(t)!;
              expect(shape, isA<MorphShapeBorder>());
              final outer = shape.generateOuterDynamicPath(rect);
              final inner = shape.generateInnerDynamicPath(rect);
              expect(outer.nodes.length, inner.nodes.length);
              expectNodesWithin(outer, rect, tolerance: 0.5);
              expectNodesWithin(inner, rect, tolerance: 0.5);

              final bounds = boundsOf(shape, rect);
              expect(rect.inflate(0.5).contains(bounds.topLeft), isTrue);
              expect(rect.inflate(0.5).contains(bounds.bottomRight), isTrue);

              paintShape(shape, rect);
              paintShape(shape, rect.shift(const Offset(31, 17)));
              expect(
                  boundsOf(shape, rect.shift(const Offset(31, 17))),
                  rectCloseTo(bounds.shift(const Offset(31, 17)),
                      epsilon: 1e-3));
            }

            expect(boundsOf(tween.lerp(0)!, rect),
                rectCloseTo(boundsOf(begin, rect), epsilon: 1));
            expect(boundsOf(tween.lerp(1)!, rect),
                rectCloseTo(boundsOf(end, rect), epsilon: 1));
          }

          // empty rects must not break the morph data either
          final shape = tween.lerp(0.5)!;
          for (final rect in const [
            Rect.zero,
            Rect.fromLTWH(3, 4, 100, 0),
            Rect.fromLTWH(3, 4, 0, 100),
          ]) {
            shape.getOuterPath(rect);
            shape.getInnerPath(rect);
            paintShape(shape, rect);
          }
          final rect = const Offset(0, 0) & sampleSizes.first;
          expect(boundsOf(tween.lerp(0)!, rect),
              rectCloseTo(boundsOf(begin, rect), epsilon: 1));
        });
      }
    }

    test('lerps the dimensions', () {
      final tween = MorphableShapeBorderTween(
        begin: const CircleShapeBorder(border: DynamicBorderSide(width: 10)),
        end: const RoundedRectangleShapeBorder(
            borderSides:
                RectangleBorderSides.only(top: DynamicBorderSide(width: 20))),
      );
      expect(tween.lerp(0)!.dimensions, const EdgeInsets.all(10));
      expect(tween.lerp(0.5)!.dimensions,
          const EdgeInsets.only(left: 5, top: 15, right: 5, bottom: 5));
      expect(tween.lerp(1)!.dimensions, const EdgeInsets.only(top: 20));
    });

    test('null ends morph from and to a rectangle', () {
      expect(MorphableShapeBorderTween().lerp(0.5), isNull);
      const rect = Rect.fromLTWH(0, 0, 100, 100);

      final fromNull =
          MorphableShapeBorderTween(end: const CircleShapeBorder());
      expect(boundsOf(fromNull.lerp(0)!, rect), rectCloseTo(rect));
      expect(fromNull.lerp(1)!.getOuterPath(rect).contains(const Offset(3, 3)),
          isFalse);
      expect(fromNull.lerp(0)!.getOuterPath(rect).contains(const Offset(3, 3)),
          isTrue);

      final toNull =
          MorphableShapeBorderTween(begin: const CircleShapeBorder());
      expect(toNull.lerp(0)!.getOuterPath(rect).contains(const Offset(3, 3)),
          isFalse);
      expect(toNull.lerp(1)!.getOuterPath(rect).contains(const Offset(3, 3)),
          isTrue);
    });

    test('reuses the morph data while begin and end are unchanged', () {
      final tween = MorphableShapeBorderTween(
          begin: const StarShapeBorder(), end: const CircleShapeBorder());
      final first = tween.lerp(0.1) as MorphShapeBorder;
      final second = tween.lerp(0.9) as MorphShapeBorder;
      expect(second.morphData, same(first.morphData));

      // equal (but not identical) shapes keep the data too
      final corners = int.parse('4');
      tween.begin = StarShapeBorder(corners: corners);
      final third = tween.lerp(0.5) as MorphShapeBorder;
      expect(third.morphData, same(first.morphData));

      tween.end = const PolygonShapeBorder();
      final fourth = tween.lerp(0.5) as MorphShapeBorder;
      expect(fourth.morphData, isNot(same(first.morphData)));
      expect(fourth.morphData.end, const PolygonShapeBorder());
    });

    test('morphs from an intermediate morph shape', () {
      final first = MorphableShapeBorderTween(
          begin: const StarShapeBorder(), end: const CircleShapeBorder());
      final intermediate = first.lerp(0.5)!;
      final second = MorphableShapeBorderTween(
          begin: intermediate, end: const RectangleShapeBorder());
      final shape = second.lerp(0.5) as MorphShapeBorder;
      expect(shape.morphData.begin, const StarShapeBorder());
      expect(shape.morphData.end, const RectangleShapeBorder());
      paintShape(shape, const Rect.fromLTWH(0, 0, 100, 100));
    });

    test('morphing a shape into itself keeps the shape', () {
      for (final shape in sampleShapes().values) {
        final tween = MorphableShapeBorderTween(begin: shape, end: shape);
        const rect = Rect.fromLTWH(0, 0, 120, 80);
        expect(boundsOf(tween.lerp(0.5)!, rect),
            rectCloseTo(boundsOf(shape, rect), epsilon: 0.5));
      }
    });
  });

  group('MorphShapeBorder', () {
    test('can be used without a tween', () {
      final shape = MorphShapeBorder(
        t: 0.5,
        morphData: MorphShapeData(
          begin: const RectangleShapeBorder(),
          end: const StarShapeBorder(),
          boundingBox: const Rect.fromLTWH(0, 0, 100, 100),
        ),
      );
      const rect = Rect.fromLTWH(0, 0, 100, 100);
      expect(rect.inflate(0.5).contains(boundsOf(shape, rect).topLeft), isTrue);
      paintShape(shape, rect);
    });

    test('is not serializable and does not copy', () {
      final shape = MorphableShapeBorderTween(
              begin: const RectangleShapeBorder(),
              end: const CircleShapeBorder())
          .lerp(0.5)!;
      expect(shape.toJson(), isEmpty);
      expect(parseMorphableShapeBorder(shape.toJson()), isNull);
      expect(shape.copyWith(), same(shape));
      expect(shape.scale(2), same(shape));
      expect(shape.isSameMorphGeometry(shape), isFalse);
    });

    test('lerps border colors and gradients', () {
      const begin = RoundedRectangleShapeBorder(
          borderSides: RectangleBorderSides.all(
              DynamicBorderSide(width: 10, color: red)));
      const end = RoundedRectangleShapeBorder(
          borderSides: RectangleBorderSides.all(
              DynamicBorderSide(width: 10, gradient: linearGradient)));
      final tween = MorphableShapeBorderTween(begin: begin, end: end);
      for (final t in const [0.0, 0.3, 0.7, 1.0]) {
        paintShape(tween.lerp(t)!, const Rect.fromLTWH(10, 10, 100, 100));
      }
      final outlined = MorphableShapeBorderTween(
        begin: const CircleShapeBorder(
            border: DynamicBorderSide(width: 4, gradient: radialGradient)),
        end: const StarShapeBorder(
            border: DynamicBorderSide(width: 2, gradient: sweepGradient)),
      );
      for (final t in const [0.0, 0.3, 0.7, 1.0]) {
        paintShape(outlined.lerp(t)!, const Rect.fromLTWH(10, 10, 100, 100));
      }
    });

    test('lerpGradient', () {
      final shape = MorphableShapeBorderTween(
              begin: const RectangleShapeBorder(),
              end: const CircleShapeBorder())
          .lerp(0.5) as MorphShapeBorder;
      expect(shape.lerpGradient(0.5, null, null, red, blue), isNull);
      expect(shape.lerpGradient(0.5, linearGradient, null, red, blue),
          isA<LinearGradient>());
      expect(shape.lerpGradient(0.5, null, radialGradient, red, blue),
          isA<RadialGradient>());
      expect(shape.lerpGradient(0.5, sweepGradient, null, red, blue),
          isA<SweepGradient>());
      expect(shape.lerpGradient(1, null, linearGradient, red, blue)!.colors,
          linearGradient.colors);
      expect(shape.lerpGradient(0, linearGradient, radialGradient, red, blue),
          linearGradient);
      expect(
          shape.lerpGradient(
              0.5, const _CustomGradient(colors: [red, blue]), null, red, blue),
          isNotNull);
    });
  });

  group('DynamicPathMorph helpers', () {
    test('lcm and gcd', () {
      expect(gcd(12, 18), 6);
      expect(gcd(7, 5), 1);
      expect(lcm(4, 6), 12);
      expect(lcm(12, 12), 12);
    });

    test('generateAllSupplyCounts', () {
      final counts = DynamicPathMorph.generateAllSupplyCounts(2, 3);
      expect(counts.length, 6);
      for (final c in counts) {
        expect(c.length, 3);
        expect(c.reduce((a, b) => a + b), 2);
      }
      expect(DynamicPathMorph.generateAllSupplyCounts(3, 0), isEmpty);
      expect(DynamicPathMorph.generateAllSupplyCounts(3, 1), [
        [3]
      ]);
    });

    test('estimateCombinationsOf', () {
      expect(DynamicPathMorph.estimateCombinationsOf(5, 2), 10);
      expect(DynamicPathMorph.estimateCombinationsOf(2, 5), 0);
      expect(DynamicPathMorph.estimateCombinationsOf(10, 0), 1);
    });

    test('supplyPoints adds points on lines and curves', () {
      final path = samplePath();
      final supplied = DynamicPathMorph.supplyPoints(path, [1, 2, 0]);
      expect(supplied.nodes.length, 6);
      expect(supplied.nodes[1].position, const Offset(50, 0));
      expectNodesWithin(supplied, const Rect.fromLTWH(0, 0, 100, 100));
      expect(DynamicPathMorph.supplyList([1, 2, 3], [0, 2, 1]),
          [1, 2, 2, 2, 3, 3]);
    });

    test('sampleSupplyCounts distributes the missing points', () {
      final path = samplePath();
      for (final weightBased in [true, false]) {
        final counts = DynamicPathMorph.sampleSupplyCounts(path, 10,
            weightBased: weightBased);
        expect(counts.length, 3);
        expect(counts.reduce((a, b) => a + b), 7);
      }
      expect(DynamicPathMorph.sampleSupplyCounts(path, 3), [0, 0, 0]);

      // a degenerate path has no length to weight with
      final point = DynamicPath(
          size: const Size(10, 10),
          nodes: List.generate(3, (_) => DynamicNode(position: Offset.zero)));
      final counts = DynamicPathMorph.sampleSupplyCounts(point, 9);
      expect(counts.reduce((a, b) => a + b), 6);
    });

    test('computeMinimumOffsetIndex finds the best rotation', () {
      const points = [
        Offset(0, 0),
        Offset(10, 0),
        Offset(10, 10),
        Offset(0, 10)
      ];
      final rotated = [points[2], points[3], points[0], points[1]];
      final shift = DynamicPathMorph.computeMinimumOffsetIndex(rotated, points);
      expect(DynamicPathMorph.computeTotalOffset(rotated, points, shift: shift),
          0);
    });

    test('lerpPaths', () {
      final begin = DynamicPath(size: const Size(10, 10), nodes: [
        DynamicNode(position: const Offset(0, 0)),
        DynamicNode(position: const Offset(10, 0)),
        DynamicNode(position: const Offset(10, 10)),
      ]);
      final end = DynamicPath(size: const Size(10, 10), nodes: [
        DynamicNode(position: const Offset(0, 10)),
        DynamicNode(position: const Offset(10, 10)),
        DynamicNode(position: const Offset(0, 0)),
      ]);
      final middle = DynamicPathMorph.lerpPaths(0.5, begin, end);
      expect(middle.nodes.map((e) => e.position).toList(),
          const [Offset(0, 5), Offset(10, 5), Offset(5, 5)]);
    });
  });
}

/// A gradient type the morph does not know about.
class _CustomGradient extends Gradient {
  const _CustomGradient({required super.colors});

  @override
  Shader createShader(Rect rect, {TextDirection? textDirection}) =>
      LinearGradient(colors: colors).createShader(rect);

  @override
  Gradient scale(double factor) => this;

  @override
  Gradient withOpacity(double opacity) => this;
}
