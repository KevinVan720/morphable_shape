import 'dart:math' as math;
import 'dart:ui' as ui show Shadow, lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ShapeShadow extends ui.Shadow {
  /// Creates a box shadow.
  ///
  /// By default, the shadow is solid black with zero [offset], [blurRadius],
  /// and [spreadRadius].
  const ShapeShadow({
    Color color = const Color(0xFF000000),
    Offset offset = Offset.zero,
    double blurRadius = 0.0,
    this.spreadRadius = 0.0,
    this.gradient,
  }) : super(color: color, offset: offset, blurRadius: blurRadius);

  /// The amount the box should be inflated prior to applying the blur.
  final double spreadRadius;

  final Gradient? gradient;

  /// Create the [Paint] object that corresponds to this shadow description.
  ///
  /// The [offset] and [spreadRadius] are not represented in the [Paint] object.
  /// To honor those as well, the shape should be inflated by [spreadRadius] pixels
  /// in every direction and then translated by [offset] before being filled using
  /// this [Paint].
  @override
  Paint toPaint() {
    final Paint result = Paint()
      ..color = color
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurSigma);
    assert(() {
      if (debugDisableShadows) result.maskFilter = null;
      return true;
    }());
    return result;
  }

  /// Returns a new box shadow with its offset, blurRadius, and spreadRadius scaled by the given factor.
  @override
  ShapeShadow scale(double factor) {
    return ShapeShadow(
      color: color,
      gradient: gradient,
      offset: offset * factor,
      blurRadius: blurRadius * factor,
      spreadRadius: spreadRadius * factor,
    );
  }

  /// Linearly interpolate between two box shadows.
  ///
  /// If either box shadow is null, this function linearly interpolates from a
  /// a box shadow that matches the other box shadow in color but has a zero
  /// offset and a zero blurRadius.
  ///
  /// {@macro dart.ui.shadow.lerp}
  static ShapeShadow? lerp(ShapeShadow? a, ShapeShadow? b, double t) {
    assert(t != null);
    if (a == null && b == null) return null;
    if (a == null) return b!.scale(t);
    if (b == null) return a.scale(1.0 - t);
    return ShapeShadow(
      color: Color.lerp(a.color, b.color, t)!,
      gradient: Gradient.lerp(a.gradient, b.gradient, t),
      offset: Offset.lerp(a.offset, b.offset, t)!,
      blurRadius: ui.lerpDouble(a.blurRadius, b.blurRadius, t)!,
      spreadRadius: ui.lerpDouble(a.spreadRadius, b.spreadRadius, t)!,
    );
  }

  /// Linearly interpolate between two lists of box shadows.
  ///
  /// If the lists differ in length, excess items are lerped with null.
  ///
  /// {@macro dart.ui.shadow.lerp}
  static List<ShapeShadow>? lerpList(
      List<ShapeShadow>? a, List<ShapeShadow>? b, double t) {
    assert(t != null);
    if (a == null && b == null) return null;
    a ??= <ShapeShadow>[];
    b ??= <ShapeShadow>[];
    final int commonLength = math.min(a.length, b.length);
    return <ShapeShadow>[
      for (int i = 0; i < commonLength; i += 1)
        ShapeShadow.lerp(a[i], b[i], t)!,
      for (int i = commonLength; i < a.length; i += 1) a[i].scale(1.0 - t),
      for (int i = commonLength; i < b.length; i += 1) b[i].scale(t),
    ];
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is ShapeShadow &&
        other.color == color &&
        other.offset == offset &&
        other.gradient == gradient &&
        other.blurRadius == blurRadius &&
        other.spreadRadius == spreadRadius;
  }

  @override
  int get hashCode =>
      hashValues(color, gradient, offset, blurRadius, spreadRadius);

  @override
  String toString() =>
      'BoxShadow($color, $gradient, $offset, ${debugFormatDouble(blurRadius)}, ${debugFormatDouble(spreadRadius)})';
}
