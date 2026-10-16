import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morphable_shape/morphable_shape.dart';

import 'test_utils.dart';

void main() {
  group('outer path of every shape', () {
    for (final entry in sampleShapes().entries) {
      final name = entry.key;
      final shape = entry.value;

      for (final size in sampleSizes) {
        test('$name in $size stays within its rect', () {
          final rect = Offset.zero & size;
          final dynamicPath = shape.generateOuterDynamicPath(rect);
          expect(dynamicPath.nodes.length, greaterThanOrEqualTo(3));
          expectNodesWithin(dynamicPath, rect);

          final path = shape.getOuterPath(rect);
          final bounds = path.getBounds();
          expect(rect.inflate(0.01).contains(bounds.topLeft), isTrue);
          expect(rect.inflate(0.01).contains(bounds.bottomRight), isTrue);
          expect(bounds.width, greaterThan(size.width * 0.5));
          expect(bounds.height, greaterThan(size.height * 0.5));
          expect(path.contains(rect.center), isTrue);
          expect(path.contains(rect.topLeft - const Offset(1, 1)), isFalse);
          expect(path.contains(rect.bottomRight + const Offset(1, 1)), isFalse);
        });
      }

      test('$name outer path follows the rect offset', () {
        const size = Size(120, 90);
        const offset = Offset(37, -12);
        final atOrigin = shape.getOuterPath(Offset.zero & size).getBounds();
        final shifted = shape.getOuterPath(offset & size).getBounds();
        expect(shifted, rectCloseTo(atOrigin.shift(offset), epsilon: 1e-3));

        final innerAtOrigin =
            shape.getInnerPath(Offset.zero & size).getBounds();
        final innerShifted = shape.getInnerPath(offset & size).getBounds();
        expect(innerShifted,
            rectCloseTo(innerAtOrigin.shift(offset), epsilon: 1e-3));
      });

      test('$name generates the same path when asked twice', () {
        const rect = Rect.fromLTWH(0, 0, 150, 100);
        final first = shape.getOuterPath(rect).getBounds();
        shape.getOuterPath(const Rect.fromLTWH(0, 0, 30, 300));
        final second = shape.getOuterPath(rect).getBounds();
        expect(second, rectCloseTo(first, epsilon: 1e-3));
      });

      for (final size in const [Size.zero, Size(100, 0), Size(0, 100)]) {
        test('$name handles the degenerate size $size', () {
          final rect = const Offset(10, 20) & size;
          final path = shape.getOuterPath(rect);
          final bounds = path.getBounds();
          expect(bounds.left.isFinite && bounds.top.isFinite, isTrue);
          expect(bounds.right.isFinite && bounds.bottom.isFinite, isTrue);
          expect(rect.inflate(0.01).contains(bounds.topLeft), isTrue);
          shape.getInnerPath(rect);
          paintShape(shape, rect);
        });
      }
    }
  });

  group('node counts (characterization)', () {
    // These document the number of control points every shape uses, which is
    // what the morphing algorithm relies on.
    const expected = {
      'Rectangle': [12, 12, 12],
      'RoundedRectangle': [12, 12, 12],
      'Circle': [12, 12, 12],
      'Polygon': [15, 15, 15],
      'Star': [24, 24, 24],
      'Arc': [5, 5, 7],
      'Arrow': [7, 7, 7],
      'Bubble': [15, 15, 15],
      'Trapezoid': [4, 4, 4],
      'Triangle': [3, 3, 3],
      'Path': [3, 3, 3],
    };
    final shapes = defaultShapes();
    for (final entry in expected.entries) {
      test(entry.key, () {
        final counts = [
          for (final size in sampleSizes)
            shapes[entry.key]!
                .generateOuterDynamicPath(Offset.zero & size)
                .nodes
                .length
        ];
        expect(counts, entry.value);
      });
    }

    test('polygon and star scale with sides and corners', () {
      for (final sides in [3, 4, 7, 12]) {
        for (final style in CornerStyle.values) {
          final polygon = PolygonShapeBorder(sides: sides, cornerStyle: style);
          expect(
              polygon
                  .generateOuterDynamicPath(const Rect.fromLTWH(0, 0, 100, 100))
                  .nodes
                  .length,
              3 * sides);
        }
        final star = StarShapeBorder(corners: sides);
        expect(
            star
                .generateOuterDynamicPath(const Rect.fromLTWH(0, 0, 100, 100))
                .nodes
                .length,
            6 * sides);
      }
    });
  });

  group('specific geometry', () {
    const rect = Rect.fromLTWH(0, 0, 200, 100);

    test('default rectangle is the rect', () {
      final path = const RectangleShapeBorder().getOuterPath(rect);
      expect(path.getBounds(), rectCloseTo(rect, epsilon: 1e-6));
      expect(path.contains(const Offset(1, 1)), isTrue);
      expect(path.contains(const Offset(199, 99)), isTrue);
    });

    test('rounded corners cut the corner', () {
      const shape = RectangleShapeBorder(
          borderRadius:
              DynamicBorderRadius.all(DynamicRadius.circular(Length(40))));
      final path = shape.getOuterPath(rect);
      expect(path.contains(const Offset(2, 2)), isFalse);
      expect(path.contains(const Offset(40, 2)), isTrue);
      expect(path.contains(const Offset(100, 50)), isTrue);
    });

    test('corner radii are scaled down like CSS when too large', () {
      const shape = RoundedRectangleShapeBorder(
          borderRadius:
              DynamicBorderRadius.all(DynamicRadius.circular(Length(1000))));
      final path = shape.getOuterPath(rect);
      expect(path.getBounds(), rectCloseTo(rect, epsilon: 1e-3));
      // a stadium: both short sides are half circles of radius 50
      expect(path.contains(const Offset(100, 1)), isTrue);
      expect(path.contains(const Offset(3, 3)), isFalse);
      expect(path.contains(const Offset(1, 50)), isTrue);
    });

    test('rounded rectangle inner path is deflated by the border widths', () {
      const shape = RoundedRectangleShapeBorder(
          borderSides: RectangleBorderSides.only(
        top: DynamicBorderSide(width: 5),
        right: DynamicBorderSide(width: 10),
        bottom: DynamicBorderSide(width: 15),
        left: DynamicBorderSide(width: 20),
      ));
      final inner = shape.getInnerPath(rect).getBounds();
      expect(inner, rectCloseTo(const Rect.fromLTRB(20, 5, 190, 85)));
    });

    test('outlined shapes use the outer path as inner path', () {
      const shape = CircleShapeBorder(border: DynamicBorderSide(width: 10));
      expect(shape.getInnerPath(rect).getBounds(),
          rectCloseTo(shape.getOuterPath(rect).getBounds(), epsilon: 1e-6));
    });

    test('circle is an ellipse filling the rect', () {
      final path = const CircleShapeBorder().getOuterPath(rect);
      expect(path.getBounds(), rectCloseTo(rect, epsilon: 0.1));
      expect(path.contains(const Offset(3, 3)), isFalse);
      expect(path.contains(const Offset(100, 50)), isTrue);
      expect(path.contains(const Offset(2, 50)), isTrue);
    });

    test('triangle with its default vertices', () {
      final path = const TriangleShapeBorder().getOuterPath(rect);
      expect(path.contains(const Offset(100, 90)), isTrue);
      expect(path.contains(const Offset(10, 90)), isFalse);
      expect(path.contains(const Offset(190, 90)), isFalse);
    });

    test('trapezoid insets the requested side', () {
      final path = const TrapezoidShapeBorder(
              side: ShapeSide.top, inset: Length(25, unit: LengthUnit.percent))
          .getOuterPath(rect);
      expect(path.contains(const Offset(10, 2)), isFalse);
      expect(path.contains(const Offset(10, 98)), isTrue);
    });

    test('arrow points to its side', () {
      final path =
          const ArrowShapeBorder(side: ShapeSide.right).getOuterPath(rect);
      expect(path.contains(const Offset(198, 50)), isTrue);
      expect(path.contains(const Offset(198, 5)), isFalse);
      expect(path.contains(const Offset(2, 50)), isTrue);
      expect(path.contains(const Offset(2, 5)), isFalse);
    });

    test('bubble leaves room for its arrow', () {
      final path =
          const BubbleShapeBorder(side: ShapeSide.bottom).getOuterPath(rect);
      expect(path.contains(const Offset(100, 98)), isTrue);
      expect(path.contains(const Offset(20, 90)), isFalse);
      expect(path.contains(const Offset(20, 70)), isTrue);
    });

    test('arc bulges outwards or inwards', () {
      final outward = const ArcShapeBorder(
              side: ShapeSide.bottom,
              arcHeight: Length(20, unit: LengthUnit.percent))
          .getOuterPath(rect);
      expect(outward.contains(const Offset(100, 98)), isTrue);
      expect(outward.contains(const Offset(3, 98)), isFalse);
      final inward = const ArcShapeBorder(
              side: ShapeSide.bottom,
              isOutward: false,
              arcHeight: Length(20, unit: LengthUnit.percent))
          .getOuterPath(rect);
      expect(inward.contains(const Offset(100, 95)), isFalse);
      expect(inward.contains(const Offset(3, 95)), isTrue);
    });

    test('arc with zero height is a rectangle', () {
      final path = const ArcShapeBorder(arcHeight: Length(0))
          .generateOuterDynamicPath(rect);
      expect(path.nodes.map((e) => e.position).toList(), const [
        Offset(0, 0),
        Offset(200, 0),
        Offset(200, 100),
        Offset(0, 100),
      ]);
    });

    test('star with a straight inset is a polygon-like star', () {
      final path = const StarShapeBorder(
              corners: 5, inset: Length(0, unit: LengthUnit.percent))
          .getOuterPath(const Rect.fromLTWH(0, 0, 100, 100));
      expect(path.contains(const Offset(50, 50)), isTrue);
      expect(path.contains(const Offset(50, 2)), isTrue);
    });

    test('path shape scales its path to the rect', () {
      final shape = PathShapeBorder(path: samplePath());
      final bounds = shape.getOuterPath(rect).getBounds();
      expect(bounds, rectCloseTo(rect, epsilon: 0.5));
    });

    test('painting or measuring a path shape does not modify its path', () {
      final path = DynamicPath(size: const Size(100, 100), nodes: [
        DynamicNode(position: const Offset(0, 0)),
        DynamicNode(position: const Offset(0.01, 0.01)),
        DynamicNode(position: const Offset(100, 0)),
        DynamicNode(position: const Offset(100, 100)),
      ]);
      final shape = PathShapeBorder(path: path, border: solidBorder);
      final json = shape.toJson();
      shape.getOuterPath(rect);
      shape.getInnerPath(rect);
      paintShape(shape, rect);
      expect(path.size, const Size(100, 100));
      expect(path.nodes.length, 4);
      expect(shape.toJson(), json);
    });
  });

  group('dimensions', () {
    test('outlined shapes use the border width on every side', () {
      for (final shape in [
        const RectangleShapeBorder(border: solidBorder),
        const CircleShapeBorder(border: solidBorder),
        const PolygonShapeBorder(border: solidBorder),
        const StarShapeBorder(border: solidBorder),
        const ArcShapeBorder(border: solidBorder),
        const ArrowShapeBorder(border: solidBorder),
        const BubbleShapeBorder(border: solidBorder),
        const TrapezoidShapeBorder(border: solidBorder),
        const TriangleShapeBorder(border: solidBorder),
        PathShapeBorder(path: samplePath(), border: solidBorder),
      ]) {
        expect(shape.dimensions, const EdgeInsets.all(4), reason: '$shape');
      }
      expect(const CircleShapeBorder().dimensions, EdgeInsets.zero);
    });

    test('rounded rectangle uses each side width', () {
      const shape = RoundedRectangleShapeBorder(
          borderSides: RectangleBorderSides.only(
        top: DynamicBorderSide(width: 1),
        right: DynamicBorderSide(width: 2),
        bottom: DynamicBorderSide(width: 3),
        left: DynamicBorderSide(width: 4),
      ));
      expect(shape.dimensions,
          const EdgeInsets.only(top: 1, right: 2, bottom: 3, left: 4));
    });
  });

  group('scale', () {
    test('returns the shape unchanged', () {
      for (final shape in sampleShapes().values) {
        expect(identical(shape.scale(0.5), shape), isTrue);
        expect(identical(shape.scale(2), shape), isTrue);
      }
    });
  });
}
