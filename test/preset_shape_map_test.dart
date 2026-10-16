import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morphable_shape/morphable_shape.dart';

import 'test_utils.dart';

void main() {
  test('the preset map contains every group', () {
    expect(presetShapeMap.keys, [
      'Rounded Rectangles',
      'Rectangle Like',
      'Circle',
      'Polygons',
      'Stars',
      'Triangles',
      'Others',
    ]);
    expect(presetShapeMap['Circle'], presetCircleShapeMap);
    expect(presetShapeMap['Others'], presetOtherShapeMap);
    final count =
        presetShapeMap.values.fold<int>(0, (sum, group) => sum + group.length);
    expect(count, 53);
  });

  for (final group in presetShapeMap.entries) {
    for (final preset in group.value.entries) {
      final shape = preset.value;

      test('${group.key}/${preset.key} paints', () {
        for (final size in sampleSizes) {
          final rect = const Offset(12, 34) & size;
          final bounds = shape.getOuterPath(rect).getBounds();
          expect(rect.inflate(0.01).contains(bounds.topLeft), isTrue);
          expect(rect.inflate(0.01).contains(bounds.bottomRight), isTrue);
          paintShape(shape, rect);
        }
        paintShape(shape, Rect.zero);
      });

      testWidgets('${group.key}/${preset.key} in widgets', (tester) async {
        await pumpCentered(
          tester,
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DecoratedShadowedShape(
                shape: shape,
                shadows: const [ShapeShadow(blurRadius: 4)],
                insetShadows: const [ShapeShadow(color: red, blurRadius: 2)],
                decoration: const BoxDecoration(color: green),
                child: const SizedBox(width: 100, height: 80),
              ),
              Container(
                width: 100,
                height: 80,
                decoration: ShapeDecoration(shape: shape, color: blue),
              ),
            ],
          ),
        );
        expect(tester.takeException(), isNull);
      });
    }
  }

  test('presets morph into each other', () {
    final presets = [
      for (final group in presetShapeMap.values) ...group.values,
    ];
    for (var i = 0; i < presets.length; i++) {
      final begin = presets[i];
      final end = presets[(i + 7) % presets.length];
      final tween = MorphableShapeBorderTween(begin: begin, end: end);
      const rect = Rect.fromLTWH(0, 0, 100, 100);
      for (final t in const [0.0, 0.5, 1.0]) {
        final shape = tween.lerp(t)!;
        paintShape(shape, rect);
      }
    }
  });
}
