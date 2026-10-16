import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morphable_shape/morphable_shape.dart';

import 'test_utils.dart';

const List<ShapeShadow> shadows = [
  ShapeShadow(color: red, offset: Offset(3, 4), blurRadius: 5),
  ShapeShadow(
      gradient: linearGradient, spreadRadius: 6, blurStyle: BlurStyle.solid),
];

const List<ShapeShadow> insetShadows = [
  ShapeShadow(color: blue, offset: Offset(-2, 2), blurRadius: 8),
  ShapeShadow(color: green, spreadRadius: 1000),
];

void main() {
  group('paint on a canvas', () {
    for (final entry in sampleShapes().entries) {
      test(entry.key, () {
        for (final size in sampleSizes) {
          paintShape(entry.value, Offset.zero & size);
          paintShape(entry.value, const Offset(40, 70) & size);
          paintShape(entry.value, const Offset(-10.5, 3.25) & size);
        }
        paintShape(entry.value, Rect.zero);
        paintShape(entry.value, const Rect.fromLTWH(5, 5, 300, 0));
        paintShape(entry.value, const Rect.fromLTWH(5, 5, 0, 300));
        paintShape(entry.value, const Rect.fromLTWH(5, 5, 0.5, 0.5));
      });
    }
  });

  group('issue #16: ShapeDecoration with a RoundedRectangleShapeBorder', () {
    testWidgets('default shape in a Container', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Center(
            child: Container(
              width: 120,
              height: 80,
              decoration: const ShapeDecoration(
                  color: red, shape: RoundedRectangleShapeBorder()),
            ),
          ),
        ),
      ));
      expect(tester.takeException(), isNull);
    });

    testWidgets('circular radius and no border sides', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              const SizedBox(height: 33),
              Container(
                decoration: const ShapeDecoration(
                  color: blue,
                  shape: RoundedRectangleShapeBorder(
                    borderRadius: DynamicBorderRadius.all(
                        DynamicRadius.circular(Length(100))),
                    borderSides:
                        RectangleBorderSides.all(DynamicBorderSide.none),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(17),
                child: Container(
                  height: 50,
                  decoration: const ShapeDecoration(
                    color: blue,
                    shape: RoundedRectangleShapeBorder(
                      borderRadius: DynamicBorderRadius.all(
                          DynamicRadius.circular(Length(100))),
                      borderSides:
                          RectangleBorderSides.all(DynamicBorderSide.none),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ));
      expect(tester.takeException(), isNull);
    });

    test('the border is painted where the box is', () {
      const decoration = ShapeDecoration(
        shape: RoundedRectangleShapeBorder(
          borderRadius:
              DynamicBorderRadius.all(DynamicRadius.circular(Length(20))),
          borderSides: RectangleBorderSides.only(
            top: DynamicBorderSide(width: 10, color: red),
            right: DynamicBorderSide(width: 10, color: green),
            bottom: DynamicBorderSide(width: 10, color: red),
            left: DynamicBorderSide(width: 10, color: blue),
          ),
        ),
      );
      final painter = decoration.createBoxPainter(() {});
      final paths = <Path>[];
      expect(
        (Canvas canvas) => painter.paint(canvas, const Offset(100, 50),
            const ImageConfiguration(size: Size(200, 100))),
        paints
          ..everything((method, arguments) {
            if (method == #drawPath) paths.add(arguments[0] as Path);
            return true;
          }),
      );
      // The border is drawn as filled paths, all of them in the box.
      expect(paths, isNotEmpty);
      final bounds = paths
          .map((path) => path.getBounds())
          .reduce((a, b) => a.expandToInclude(b));
      expect(bounds, rectCloseTo(const Rect.fromLTWH(100, 50, 200, 100)));
      bool painted(Offset point) => paths.any((path) => path.contains(point));
      expect(painted(const Offset(105, 100)), isTrue); // left side
      expect(painted(const Offset(295, 100)), isTrue); // right side
      expect(painted(const Offset(200, 55)), isTrue); // top side
      expect(painted(const Offset(200, 145)), isTrue); // bottom side
      expect(painted(const Offset(200, 100)), isFalse); // inside
      expect(painted(const Offset(5, 5)), isFalse); // outside
    });
  });

  group('widgets', () {
    for (final entry in sampleShapes().entries) {
      testWidgets('DecoratedShadowedShape with ${entry.key}', (tester) async {
        for (final size in const [Size(120, 90), Size(30, 200), Size.zero]) {
          await pumpCentered(
            tester,
            DecoratedShadowedShape(
              shape: entry.value,
              shadows: shadows,
              insetShadows: insetShadows,
              decoration: const BoxDecoration(gradient: radialGradient),
              child: SizedBox.fromSize(size: size),
            ),
          );
          expect(tester.takeException(), isNull);
        }
      });

      testWidgets('ShapeDecoration with ${entry.key}', (tester) async {
        for (final decoration in [
          ShapeDecoration(shape: entry.value, color: green),
          ShapeDecoration(
            shape: entry.value,
            gradient: sweepGradient,
            shadows: const [BoxShadow(blurRadius: 4, spreadRadius: 2)],
          ),
        ]) {
          await pumpCentered(
            tester,
            Container(width: 150, height: 110, decoration: decoration),
          );
          expect(tester.takeException(), isNull);
        }
      });
    }

    testWidgets('DecoratedShadowedShape without anything', (tester) async {
      await pumpCentered(tester, DecoratedShadowedShape());
      expect(tester.takeException(), isNull);
      await pumpCentered(tester,
          DecoratedShadowedShape(child: const SizedBox(width: 10, height: 10)));
      expect(tester.takeException(), isNull);
    });

    testWidgets('DecoratedShadowedShape clips its child to the shape',
        (tester) async {
      await pumpCentered(
        tester,
        DecoratedShadowedShape(
          shape: const CircleShapeBorder(),
          decoration: const BoxDecoration(color: red),
          child: const SizedBox(width: 100, height: 100),
        ),
      );
      final clipPath =
          tester.renderObject<RenderClipPath>(find.byType(ClipPath).first);
      final clip = clipPath.clipper!.getClip(const Size(100, 100));
      expect(clip.contains(const Offset(50, 50)), isTrue);
      expect(clip.contains(const Offset(2, 2)), isFalse);
    });

    testWidgets('Material and ClipPath accept the shapes', (tester) async {
      for (final shape in sampleShapes().values) {
        await tester.pumpWidget(MaterialApp(
          home: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Material(
                  shape: shape,
                  color: red,
                  elevation: 4,
                  clipBehavior: Clip.antiAlias,
                  child: const SizedBox(width: 80, height: 60),
                ),
                ClipPath(
                  clipper: ShapeBorderClipper(shape: shape),
                  child: const SizedBox(width: 80, height: 60),
                ),
              ],
            ),
          ),
        ));
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('right to left', (tester) async {
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.rtl,
        child: Center(
          child: DecoratedShadowedShape(
            shape: sampleShapes()['RoundedRectangle.borders'],
            shadows: shadows,
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      ));
      expect(tester.takeException(), isNull);
    });
  });

  group('CustomShapeBorderClipper', () {
    test('clips to the outer path', () {
      const clipper = CustomShapeBorderClipper(shape: CircleShapeBorder());
      final clip = clipper.getClip(const Size(50, 50));
      expect(clip.getBounds(), rectCloseTo(const Rect.fromLTWH(0, 0, 50, 50)));
      expect(clipper.shouldReclip(clipper), isTrue);
    });
  });
}
