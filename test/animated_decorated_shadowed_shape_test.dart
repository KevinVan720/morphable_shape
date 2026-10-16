import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morphable_shape/morphable_shape.dart';

import 'test_utils.dart';

Widget animated({
  ShapeBorder? shape,
  Decoration? decoration,
  List<ShapeShadow>? shadows,
  List<ShapeShadow>? insetShadows,
  MorphMethod? method,
  VoidCallback? onEnd,
  Size size = const Size(120, 90),
}) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: Center(
      child: AnimatedDecoratedShadowedShape(
        duration: const Duration(milliseconds: 200),
        shape: shape,
        decoration: decoration,
        shadows: shadows,
        insetShadows: insetShadows,
        method: method,
        onEnd: onEnd,
        child: SizedBox.fromSize(size: size),
      ),
    ),
  );
}

DecoratedShadowedShape currentShape(WidgetTester tester) =>
    tester.widget<DecoratedShadowedShape>(find.byType(DecoratedShadowedShape));

Future<void> pumpThrough(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 40));
    expect(tester.takeException(), isNull);
  }
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

void main() {
  testWidgets('animates between shapes, decorations and shadows',
      (tester) async {
    var ended = 0;
    await tester.pumpWidget(animated(
      shape: const RectangleShapeBorder(border: solidBorder),
      decoration: const BoxDecoration(color: red),
      shadows: const [ShapeShadow(blurRadius: 3)],
      insetShadows: const [ShapeShadow(color: blue, spreadRadius: 2)],
      onEnd: () => ended++,
    ));
    expect(tester.takeException(), isNull);
    expect(currentShape(tester).shape,
        const RectangleShapeBorder(border: solidBorder));

    await tester.pump(const Duration(milliseconds: 10));
    await tester.pumpWidget(animated(
      shape: sampleShapes()['RoundedRectangle.borders'],
      decoration: const BoxDecoration(gradient: linearGradient),
      shadows: const [
        ShapeShadow(blurRadius: 6, offset: Offset(2, 2)),
        ShapeShadow(gradient: radialGradient, spreadRadius: 4),
      ],
      insetShadows: const [],
      onEnd: () => ended++,
    ));
    expect(tester.hasRunningAnimations, isTrue);
    await tester.pump(const Duration(milliseconds: 100));
    final halfway = currentShape(tester).shape as MorphShapeBorder;
    expect(halfway.t, closeTo(0.5, 0.01));
    expect(halfway.morphData.end, sampleShapes()['RoundedRectangle.borders']);
    await pumpThrough(tester);
    expect(ended, 1);

    expect(
        currentShape(tester).shape, sampleShapes()['RoundedRectangle.borders']);
    expect(currentShape(tester).shadows!.length, 2);
    expect(currentShape(tester).insetShadows, isEmpty);
  });

  testWidgets('every morph method animates', (tester) async {
    for (final method in MorphMethod.values) {
      await tester
          .pumpWidget(animated(shape: const StarShapeBorder(), method: method));
      await tester.pumpWidget(
          animated(shape: const CircleShapeBorder(), method: method));
      await pumpThrough(tester);
    }
  });

  testWidgets('works without a decoration, shape or shadows', (tester) async {
    await tester.pumpWidget(animated());
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(animated(shape: const CircleShapeBorder()));
    await pumpThrough(tester);
    await tester.pumpWidget(animated(
        shape: const CircleShapeBorder(),
        decoration: const BoxDecoration(color: green)));
    await pumpThrough(tester);
    await tester.pumpWidget(animated(shape: const CircleShapeBorder()));
    await pumpThrough(tester);
    await tester.pumpWidget(animated());
    await pumpThrough(tester);
  });

  testWidgets('animates the size of the child', (tester) async {
    await tester.pumpWidget(animated(
        shape: sampleShapes()['RoundedRectangle.borders'], size: Size.zero));
    await tester.pumpWidget(
        animated(shape: const StarShapeBorder(), size: const Size(200, 100)));
    await pumpThrough(tester);
    await tester.pumpWidget(
        animated(shape: const CircleShapeBorder(), size: Size.zero));
    await pumpThrough(tester);
  });

  testWidgets('rebuilding with an equal shape does not restart the animation',
      (tester) async {
    await tester.pumpWidget(animated(shape: const StarShapeBorder(corners: 6)));
    await tester.pumpAndSettle();
    final corners = int.parse('6');
    await tester.pumpWidget(animated(shape: StarShapeBorder(corners: corners)));
    expect(tester.hasRunningAnimations, isFalse);
  });

  test('ListShapeShadowTween', () {
    final tween = ListShapeShadowTween(
      begin: const [ShapeShadow(blurRadius: 2), ShapeShadow(color: red)],
      end: const [ShapeShadow(blurRadius: 4)],
    );
    final middle = tween.lerp(0.5)!;
    expect(middle.length, 2);
    expect(middle[0].blurRadius, 3);
    expect(tween.lerp(1)!.first, const ShapeShadow(blurRadius: 4));
    expect(ListShapeShadowTween().lerp(0.5), isNull);
  });
}
