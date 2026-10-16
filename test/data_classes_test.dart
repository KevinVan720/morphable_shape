import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morphable_shape/morphable_shape.dart';

import 'test_utils.dart';

void main() {
  group('DynamicBorderSide', () {
    test('defaults', () {
      const side = DynamicBorderSide();
      expect(side.color, const Color(0xFF000000));
      expect(side.width, 1.0);
      expect(side.style, BorderStyle.solid);
      expect(side.gradient, isNull);
      expect(side.begin, isNull);
      expect(side.end, isNull);
      expect(side.shift, isNull);
      expect(side.strokeJoin, StrokeJoin.miter);
      expect(side.strokeCap, StrokeCap.butt);
      expect(DynamicBorderSide.none.style, BorderStyle.none);
      expect(DynamicBorderSide.none.width, 0);
    });

    test('lerp at the ends returns the ends', () {
      expect(DynamicBorderSide.lerp(solidBorder, gradientBorder, 0),
          same(solidBorder));
      expect(DynamicBorderSide.lerp(solidBorder, gradientBorder, 1),
          same(gradientBorder));
    });

    test('lerp between solid sides', () {
      final side = DynamicBorderSide.lerp(
          solidBorder, const DynamicBorderSide(width: 8, color: blue), 0.5);
      expect(side.width, 6);
      expect(side.color, Color.lerp(red, blue, 0.5));
      expect(side.style, BorderStyle.solid);
      expect(side.begin, isNull);
      expect(side.end, isNull);
      expect(side.shift, isNull);
    });

    test('lerp between partial sides', () {
      final side = DynamicBorderSide.lerp(solidBorder, partialBorder, 0.5);
      expect(side.begin!.toPX(constraint: 100), 5);
      expect(side.end!.toPX(constraint: 100), 80);
      expect(side.shift!.toPX(constraint: 100), 10);
      expect(side.strokeCap, StrokeCap.round);
      expect(side.strokeJoin, StrokeJoin.round);
    });

    test('lerp from no side fades the color', () {
      final side = DynamicBorderSide.lerp(DynamicBorderSide.none,
          const DynamicBorderSide(width: 10, color: red), 0.5);
      expect(side.style, BorderStyle.solid);
      expect(side.width, 5);
      expect(side.color.a, closeTo(0.5, 0.01));
    });

    test('scale', () {
      final scaled = gradientBorder.scale(0.5);
      expect(scaled.width, 3);
      expect(scaled.style, BorderStyle.solid);
      expect(scaled.gradient, isNotNull);
      expect(solidBorder.scale(0).style, BorderStyle.none);
      expect(solidBorder.scale(-1).width, 0);
    });
  });

  group('ShapeShadow', () {
    test('fromBoxShadow', () {
      final shadow = ShapeShadow.fromBoxShadow(const BoxShadow(
          color: red,
          offset: Offset(1, 2),
          blurRadius: 3,
          spreadRadius: 4,
          blurStyle: BlurStyle.inner));
      expect(
          shadow,
          const ShapeShadow(
              color: red,
              offset: Offset(1, 2),
              blurRadius: 3,
              spreadRadius: 4,
              blurStyle: BlurStyle.inner));
    });

    test('scale', () {
      const shadow = ShapeShadow(
          offset: Offset(2, 4),
          blurRadius: 6,
          spreadRadius: 8,
          gradient: linearGradient);
      final scaled = shadow.scale(0.5);
      expect(scaled.offset, const Offset(1, 2));
      expect(scaled.blurRadius, 3);
      expect(scaled.spreadRadius, 4);
      expect(scaled.gradient, linearGradient);
      expect(shadow.scale(-1).blurRadius, 0);
    });

    test('lerp', () {
      expect(ShapeShadow.lerp(null, null, 0.5), isNull);
      const a = ShapeShadow(color: red, blurRadius: 2, spreadRadius: 2);
      const b = ShapeShadow(
          color: blue,
          blurRadius: 4,
          offset: Offset(4, 4),
          blurStyle: BlurStyle.outer);
      final middle = ShapeShadow.lerp(a, b, 0.5)!;
      expect(middle.blurRadius, 3);
      expect(middle.spreadRadius, 1);
      expect(middle.offset, const Offset(2, 2));
      expect(middle.color, Color.lerp(red, blue, 0.5));
      expect(ShapeShadow.lerp(a, b, 0.4)!.blurStyle, BlurStyle.normal);
      expect(ShapeShadow.lerp(a, b, 0.6)!.blurStyle, BlurStyle.outer);
      expect(ShapeShadow.lerp(null, b, 0.5)!.blurRadius, 2);
      expect(ShapeShadow.lerp(a, null, 0.5)!.blurRadius, 1);
    });

    test('lerpList', () {
      expect(ShapeShadow.lerpList(null, null, 0.5), isNull);
      final list = ShapeShadow.lerpList(const [ShapeShadow(blurRadius: 2)],
          const [ShapeShadow(blurRadius: 4), ShapeShadow(blurRadius: 8)], 0.5)!;
      expect(list.map((e) => e.blurRadius).toList(), [3, 4]);
      expect(
          ShapeShadow.lerpList(null, const [ShapeShadow(blurRadius: 4)], 0.25)!
              .single
              .blurRadius,
          1);
    });

    test('toPaint uses the color and blur style', () {
      const shadow =
          ShapeShadow(color: red, blurRadius: 4, blurStyle: BlurStyle.outer);
      // Paint stores the sigma as a float, compare with a filter that went
      // through a Paint as well.
      MaskFilter? blur(BlurStyle style) => (Paint()
            ..maskFilter =
                MaskFilter.blur(style, Shadow.convertRadiusToSigma(4)))
          .maskFilter;
      final paint = shadow.toPaint();
      expect(paint.color, red);
      expect(paint.maskFilter, blur(BlurStyle.outer));
      expect(const ShapeShadow(blurRadius: 4).toPaint().maskFilter,
          blur(BlurStyle.normal));
    });
  });
}
