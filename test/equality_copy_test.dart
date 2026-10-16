// Shapes are deliberately created without `const` so that equality is checked
// on distinct instances instead of canonicalized constants.
// ignore_for_file: prefer_const_constructors

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morphable_shape/morphable_shape.dart';

import 'test_utils.dart';

/// Builds two distinct but equal instances and a list of variations that must
/// all differ from them.
class EqualityCase {
  EqualityCase(this.build, this.variations);

  final Object Function() build;
  final List<Object> Function(Object value) variations;
}

void expectValueSemantics(EqualityCase c) {
  final a = c.build();
  final b = c.build();
  expect(identical(a, b), isFalse);
  expect(a, equals(b));
  expect(a.hashCode, b.hashCode);
  // ignore: unrelated_type_equality_checks
  expect(a == 'not a shape', isFalse);
  for (final variation in c.variations(a)) {
    expect(variation, isNot(equals(a)), reason: '$variation');
  }
}

void main() {
  group('data classes', () {
    test('DynamicRadius', () {
      expectValueSemantics(EqualityCase(
        () => DynamicRadius.elliptical(
            Length(10), Length(5, unit: LengthUnit.percent)),
        (v) => [
          (v as DynamicRadius).copyWith(x: Length(11)),
          v.copyWith(y: Length(5)),
          DynamicRadius.zero,
        ],
      ));
      final radius = DynamicRadius.circular(Length(3));
      expect(radius.x, Length(3));
      expect(radius.y, Length(3));
      expect(radius.copyWith(), radius);
      expect(
          radius.toRadius(size: const Size(10, 10)), const Radius.circular(3));
      expect(
          DynamicRadius.elliptical(Length(50, unit: LengthUnit.percent),
                  Length(10, unit: LengthUnit.percent))
              .toRadius(size: const Size(200, 100)),
          const Radius.elliptical(100, 10));
    });

    test('DynamicBorderRadius', () {
      expectValueSemantics(EqualityCase(
        () => DynamicBorderRadius.only(
            topLeft: DynamicRadius.circular(Length(1)),
            bottomRight: DynamicRadius.circular(Length(2))),
        (v) => [
          (v as DynamicBorderRadius)
              .copyWith(topLeft: DynamicRadius.circular(Length(3))),
          v.copyWith(topRight: DynamicRadius.circular(Length(3))),
          v.copyWith(bottomLeft: DynamicRadius.circular(Length(3))),
          v.copyWith(bottomRight: DynamicRadius.circular(Length(3))),
        ],
      ));
      final radius = DynamicBorderRadius.all(DynamicRadius.circular(Length(4)));
      expect(radius.copyWith(), radius);
      expect(radius.toBorderRadius(size: const Size(10, 10)),
          BorderRadius.circular(4));
    });

    test('DynamicOffset', () {
      expectValueSemantics(EqualityCase(
        () => DynamicOffset(Length(1), Length(2, unit: LengthUnit.percent)),
        (v) => [
          (v as DynamicOffset).copyWith(dx: Length(2)),
          v.copyWith(dy: Length(2)),
          DynamicOffset.zero,
        ],
      ));
      expect(
          DynamicOffset(Length(1), Length(50, unit: LengthUnit.percent))
              .toOffset(size: const Size(10, 30)),
          const Offset(1, 15));
    });

    test('DynamicBorderSide', () {
      expectValueSemantics(EqualityCase(
        () => DynamicBorderSide(
          color: red,
          width: 3,
          gradient: LinearGradient(colors: [red, blue]),
          begin: Length(1),
          end: Length(2),
          shift: Length(3),
          strokeCap: StrokeCap.round,
          strokeJoin: StrokeJoin.bevel,
        ),
        (v) => [
          (v as DynamicBorderSide).copyWith(color: blue),
          v.copyWith(width: 4),
          v.copyWith(gradient: LinearGradient(colors: [blue, red])),
          v.copyWith(style: BorderStyle.none),
          v.copyWith(begin: Length(5)),
          v.copyWith(end: Length(5)),
          v.copyWith(shift: Length(5)),
          v.copyWith(strokeCap: StrokeCap.square),
          v.copyWith(strokeJoin: StrokeJoin.miter),
        ],
      ));
      expect(solidBorder.copyWith(), solidBorder);
    });

    test('RectangleCornerStyles', () {
      expectValueSemantics(EqualityCase(
        () => RectangleCornerStyles.only(
            topLeft: CornerStyle.concave, bottomRight: CornerStyle.cutout),
        (v) => [
          (v as RectangleCornerStyles).copyWith(topLeft: CornerStyle.rounded),
          v.copyWith(topRight: CornerStyle.straight),
          v.copyWith(bottomLeft: CornerStyle.straight),
          v.copyWith(bottomRight: CornerStyle.rounded),
        ],
      ));
      expect(RectangleCornerStyles.all(CornerStyle.rounded),
          RectangleCornerStyles.only());
    });

    test('RectangleBorderSides', () {
      expectValueSemantics(EqualityCase(
        () => RectangleBorderSides.only(
            top: DynamicBorderSide(width: 1),
            left: DynamicBorderSide(width: 2)),
        (v) => [
          (v as RectangleBorderSides).copyWith(top: DynamicBorderSide.none),
          v.copyWith(bottom: DynamicBorderSide(width: 3)),
          v.copyWith(left: DynamicBorderSide.none),
          v.copyWith(right: DynamicBorderSide(width: 3)),
        ],
      ));
      expect(RectangleBorderSides.all(DynamicBorderSide.none),
          RectangleBorderSides.only());
      expect(
          RectangleBorderSides.symmetric(
              horizontal: solidBorder, vertical: gradientBorder),
          RectangleBorderSides.only(
              top: solidBorder,
              bottom: solidBorder,
              left: gradientBorder,
              right: gradientBorder));
    });

    test('ShapeShadow', () {
      expectValueSemantics(EqualityCase(
        () => ShapeShadow(
            color: red,
            offset: Offset(1, 2),
            blurRadius: 3,
            spreadRadius: 4,
            gradient: LinearGradient(colors: [red, blue])),
        (v) => [
          ShapeShadow(color: red, offset: Offset(1, 2), blurRadius: 3),
          ShapeShadow(
              color: red,
              offset: Offset(1, 2),
              blurRadius: 3,
              spreadRadius: 4,
              gradient: LinearGradient(colors: [red, blue]),
              blurStyle: BlurStyle.outer),
        ],
      ));
    });
  });

  group('shape borders', () {
    final cases = <String, EqualityCase>{
      'Rectangle': EqualityCase(
        () => RectangleShapeBorder(
          borderRadius:
              DynamicBorderRadius.all(DynamicRadius.circular(Length(10))),
          cornerStyles: RectangleCornerStyles.all(CornerStyle.concave),
          border: DynamicBorderSide(width: 2, color: red),
        ),
        (v) => [
          (v as RectangleShapeBorder).copyWith(
              borderRadius:
                  DynamicBorderRadius.all(DynamicRadius.circular(Length(11)))),
          v.copyWith(
              cornerStyles: RectangleCornerStyles.all(CornerStyle.cutout)),
          v.copyWith(border: DynamicBorderSide.none),
          RoundedRectangleShapeBorder(),
        ],
      ),
      'RoundedRectangle': EqualityCase(
        () => RoundedRectangleShapeBorder(
          borderRadius:
              DynamicBorderRadius.all(DynamicRadius.circular(Length(10))),
          borderSides:
              RectangleBorderSides.only(top: DynamicBorderSide(width: 2)),
        ),
        (v) => [
          (v as RoundedRectangleShapeBorder).copyWith(
              borderRadius:
                  DynamicBorderRadius.all(DynamicRadius.circular(Length(11)))),
          v.copyWith(
              borders:
                  RectangleBorderSides.only(left: DynamicBorderSide(width: 2))),
          RectangleShapeBorder(),
        ],
      ),
      'Circle': EqualityCase(
        () => CircleShapeBorder(border: DynamicBorderSide(width: 2)),
        (v) => [
          (v as CircleShapeBorder)
              .copyWith(border: DynamicBorderSide(width: 3)),
          CircleShapeBorder(),
        ],
      ),
      'Polygon': EqualityCase(
        () => PolygonShapeBorder(
            sides: 6,
            cornerRadius: Length(5),
            cornerStyle: CornerStyle.straight,
            border: DynamicBorderSide(width: 2)),
        (v) => [
          (v as PolygonShapeBorder).copyWith(sides: 7),
          v.copyWith(cornerRadius: Length(6)),
          v.copyWith(cornerStyle: CornerStyle.rounded),
          v.copyWith(border: DynamicBorderSide.none),
        ],
      ),
      'Star': EqualityCase(
        () => StarShapeBorder(
            corners: 6,
            inset: Length(30, unit: LengthUnit.percent),
            cornerRadius: Length(5),
            insetRadius: Length(4),
            cornerStyle: CornerStyle.concave,
            insetStyle: CornerStyle.straight,
            border: DynamicBorderSide(width: 2)),
        (v) => [
          (v as StarShapeBorder).copyWith(corners: 7),
          v.copyWith(inset: Length(31, unit: LengthUnit.percent)),
          v.copyWith(cornerRadius: Length(6)),
          v.copyWith(insetRadius: Length(6)),
          v.copyWith(cornerStyle: CornerStyle.rounded),
          v.copyWith(insetStyle: CornerStyle.rounded),
          v.copyWith(border: DynamicBorderSide.none),
        ],
      ),
      'Arc': EqualityCase(
        () => ArcShapeBorder(
            side: ShapeSide.left,
            isOutward: false,
            arcHeight: Length(12),
            border: DynamicBorderSide(width: 2)),
        (v) => [
          (v as ArcShapeBorder).copyWith(side: ShapeSide.right),
          v.copyWith(isOutward: true),
          v.copyWith(arcHeight: Length(13)),
          v.copyWith(border: DynamicBorderSide.none),
        ],
      ),
      'Arrow': EqualityCase(
        () => ArrowShapeBorder(
            side: ShapeSide.top,
            arrowHeight: Length(10),
            tailWidth: Length(20),
            border: DynamicBorderSide(width: 2)),
        (v) => [
          (v as ArrowShapeBorder).copyWith(side: ShapeSide.bottom),
          v.copyWith(arrowHeight: Length(11)),
          v.copyWith(tailWidth: Length(21)),
          v.copyWith(border: DynamicBorderSide.none),
        ],
      ),
      'Bubble': EqualityCase(
        () => BubbleShapeBorder(
            side: ShapeSide.left,
            borderRadius: Length(3),
            arrowHeight: Length(4),
            arrowWidth: Length(5),
            arrowCenterPosition: Length(6),
            arrowHeadPosition: Length(7),
            border: DynamicBorderSide(width: 2)),
        (v) => [
          (v as BubbleShapeBorder).copyWith(side: ShapeSide.top),
          v.copyWith(borderRadius: Length(1)),
          v.copyWith(arrowHeight: Length(1)),
          v.copyWith(arrowWidth: Length(1)),
          v.copyWith(arrowCenterPosition: Length(1)),
          v.copyWith(arrowHeadPosition: Length(1)),
          v.copyWith(border: DynamicBorderSide.none),
        ],
      ),
      'Trapezoid': EqualityCase(
        () => TrapezoidShapeBorder(
            side: ShapeSide.right,
            inset: Length(9),
            border: DynamicBorderSide(width: 2)),
        (v) => [
          (v as TrapezoidShapeBorder).copyWith(side: ShapeSide.left),
          v.copyWith(inset: Length(10)),
          v.copyWith(border: DynamicBorderSide.none),
        ],
      ),
      'Triangle': EqualityCase(
        () => TriangleShapeBorder(
            point1: DynamicOffset(Length(1), Length(2)),
            point2: DynamicOffset(Length(3), Length(4)),
            point3: DynamicOffset(Length(5), Length(6)),
            border: DynamicBorderSide(width: 2)),
        (v) => [
          (v as TriangleShapeBorder)
              .copyWith(point1: DynamicOffset(Length(0), Length(0))),
          v.copyWith(point2: DynamicOffset(Length(0), Length(0))),
          v.copyWith(point3: DynamicOffset(Length(0), Length(0))),
          v.copyWith(border: DynamicBorderSide.none),
        ],
      ),
    };

    for (final entry in cases.entries) {
      test('${entry.key} has value equality', () {
        expectValueSemantics(entry.value);
      });

      test('${entry.key}.copyWith() without arguments keeps every value', () {
        final shape = entry.value.build() as MorphableShapeBorder;
        final copy = shape.copyWith();
        expect(identical(copy, shape), isFalse);
        expect(copy, shape);
        expect(copy.toJson(), shape.toJson());
      });
    }

    test('different shape types are never equal', () {
      final shapes = defaultShapes().values.toList();
      for (var i = 0; i < shapes.length; i++) {
        for (var j = 0; j < shapes.length; j++) {
          if (i != j) expect(shapes[i] == shapes[j], isFalse);
        }
      }
    });

    test('Path shapes compare their path by identity', () {
      // DynamicPath is mutable (the shape editor edits it in place), so path
      // shapes keep identity semantics for their path.
      final path = samplePath();
      final shape = PathShapeBorder(path: path);
      expect(shape.copyWith().path, same(path));
      expect(shape.copyWith().toJson(), shape.toJson());
      expect(shape.copyWith(border: solidBorder).border, solidBorder);
      final otherPath = samplePath();
      expect(shape.copyWith(path: otherPath).path, same(otherPath));
      expect(shape.isSameMorphGeometry(shape.copyWith()), isTrue);
      expect(
          shape.isSameMorphGeometry(PathShapeBorder(path: otherPath)), isFalse);
    });
  });

  group('isSameMorphGeometry', () {
    test('matches shapes that share their control point layout', () {
      expect(
          RectangleShapeBorder()
              .isSameMorphGeometry(RoundedRectangleShapeBorder()),
          isTrue);
      expect(
          RoundedRectangleShapeBorder()
              .isSameMorphGeometry(RectangleShapeBorder()),
          isTrue);
      expect(CircleShapeBorder().isSameMorphGeometry(RectangleShapeBorder()),
          isTrue);
      expect(RectangleShapeBorder().isSameMorphGeometry(CircleShapeBorder()),
          isFalse);
      expect(
          PolygonShapeBorder(sides: 5)
              .isSameMorphGeometry(PolygonShapeBorder(sides: 5)),
          isTrue);
      expect(
          PolygonShapeBorder(sides: 5)
              .isSameMorphGeometry(PolygonShapeBorder(sides: 6)),
          isFalse);
      expect(
          StarShapeBorder(corners: 5)
              .isSameMorphGeometry(StarShapeBorder(corners: 5)),
          isTrue);
      expect(
          StarShapeBorder(corners: 5)
              .isSameMorphGeometry(StarShapeBorder(corners: 6)),
          isFalse);
      expect(
          ArcShapeBorder()
              .isSameMorphGeometry(ArcShapeBorder(isOutward: false)),
          isTrue);
      expect(
          ArcShapeBorder()
              .isSameMorphGeometry(ArcShapeBorder(side: ShapeSide.top)),
          isFalse);
      expect(
          ArrowShapeBorder()
              .isSameMorphGeometry(ArrowShapeBorder(side: ShapeSide.left)),
          isFalse);
      expect(
          BubbleShapeBorder().isSameMorphGeometry(BubbleShapeBorder()), isTrue);
      expect(
          TrapezoidShapeBorder()
              .isSameMorphGeometry(TrapezoidShapeBorder(side: ShapeSide.left)),
          isTrue);
      expect(TriangleShapeBorder().isSameMorphGeometry(TriangleShapeBorder()),
          isTrue);
      expect(TriangleShapeBorder().isSameMorphGeometry(TrapezoidShapeBorder()),
          isFalse);
    });
  });
}
