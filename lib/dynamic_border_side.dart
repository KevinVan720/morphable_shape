import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_class_parser/flutter_class_parser.dart';
import 'package:flutter_class_parser/to_json.dart';
import 'package:morphable_shape/morphable_shape.dart';

class DynamicBorderSide {
  const DynamicBorderSide({
    this.color = const Color(0xFF000000),
    this.width = 1.0,
    this.style = BorderStyle.solid,
    this.gradient,
    this.begin,
    this.end,
    this.shift,
    this.strokeJoin = StrokeJoin.miter,
    this.strokeCap = StrokeCap.butt,
  });

  DynamicBorderSide.fromJson(Map<String, dynamic> map)
      : color = parseColor(map["color"]) ?? Color(0xFF000000),
        gradient = parseGradient(map["gradient"]),
        width = map["width"].toDouble() ?? 1.0,
        style = parseBorderStyle(map["style"]) ?? BorderStyle.solid,
        begin =
            parseDimension(map["begin"]) ?? Length(0, unit: LengthUnit.percent),
        end = parseDimension(map["end"]) ?? Length(0, unit: LengthUnit.percent),
        shift =
            parseDimension(map["shift"]) ?? Length(0, unit: LengthUnit.percent),
        strokeCap = parseStrokeCap(map["strokeCap"]) ?? StrokeCap.square,
        strokeJoin = parseStrokeJoin(map["strokeJoin"]) ?? StrokeJoin.miter;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst = {};
    rst["color"] = color.toJson();
    rst.updateNotNull("gradient", gradient?.toJson());
    rst["width"] = width;
    rst["style"] = style.toJson();
    rst.updateNotNull("begin", begin?.toJson());
    rst.updateNotNull("end", end?.toJson());
    rst.updateNotNull("shift", end?.toJson());
    rst.updateNotNull("strokeCap", strokeCap.toJson());
    rst.updateNotNull("strokeJoin", strokeJoin.toJson());
    return rst;
  }

  /// The color of this side of the border.
  final Color color;

  final Gradient? gradient;

  /// The width of this side of the border, in logical pixels.
  ///
  /// Setting width to 0.0 will result in a hairline border. This means that
  /// the border will have the width of one physical pixel. Also, hairline
  /// rendering takes shortcuts when the path overlaps a pixel more than once.
  /// This means that it will render faster than otherwise, but it might
  /// double-hit pixels, giving it a slightly darker/lighter result.
  ///
  /// To omit the border entirely, set the [style] to [BorderStyle.none].
  final double width;

  /// The style of this side of the border.
  ///
  /// To omit a side, set [style] to [BorderStyle.none]. This skips
  /// painting the border, but the border still has a [width].
  final BorderStyle style;

  final Dimension? begin;
  final Dimension? end;
  final Dimension? shift;

  final StrokeJoin strokeJoin;
  final StrokeCap strokeCap;

  /// A hairline black border that is not rendered.
  static const DynamicBorderSide none =
      DynamicBorderSide(width: 0.0, style: BorderStyle.none);

  DynamicBorderSide copyWith({
    Color? color,
    Gradient? gradient,
    double? width,
    BorderStyle? style,
    Dimension? begin,
    Dimension? end,
    Dimension? shift,
    StrokeJoin? strokeJoin,
    StrokeCap? strokeCap,
  }) {
    return DynamicBorderSide(
      color: color ?? this.color,
      gradient: gradient ?? this.gradient,
      width: width ?? this.width,
      style: style ?? this.style,
      begin: begin ?? this.begin,
      end: end ?? this.end,
      shift: shift ?? this.shift,
      strokeCap: strokeCap ?? this.strokeCap,
      strokeJoin: strokeJoin ?? this.strokeJoin,
    );
  }

  DynamicBorderSide scale(double t) {
    return DynamicBorderSide(
      color: color,
      gradient: gradient?.scale(t),
      width: max(0.0, width * t),
      style: t <= 0.0 ? BorderStyle.none : style,
      begin: begin,
      end: end,
      shift: shift,
      strokeJoin: strokeJoin,
      strokeCap: strokeCap,
    );
  }

  static DynamicBorderSide lerp(
      DynamicBorderSide a, DynamicBorderSide b, double t) {
    if (t == 0.0) return a;
    if (t == 1.0) return b;
    final double width = lerpDouble(a.width, b.width, t) ?? 0.0;
    if (width < 0.0) return DynamicBorderSide.none;
    if (a.style == b.style) {
      return DynamicBorderSide(
        color: Color.lerp(a.color, b.color, t)!,
        gradient: Gradient.lerp(a.gradient, b.gradient, t),
        width: width,
        style: a.style, // == b.style
        begin: Dimension.lerp(a.begin, b.begin, t),
        end: a.end == null && b.end == null
            ? null
            : Dimension.lerp(
                a.end ?? 100.toPercentLength, b.end ?? 100.toPercentLength, t),
        shift: Dimension.lerp(a.shift, b.shift, t),
        strokeCap: t < 0.5 ? a.strokeCap : b.strokeCap,
        strokeJoin: t < 0.5 ? a.strokeJoin : b.strokeJoin,
      );
    }
    Color colorA, colorB;
    switch (a.style) {
      case BorderStyle.solid:
        colorA = a.color;
        break;
      case BorderStyle.none:
        colorA = a.color.withAlpha(0x00);
        break;
    }
    switch (b.style) {
      case BorderStyle.solid:
        colorB = b.color;
        break;
      case BorderStyle.none:
        colorB = b.color.withAlpha(0x00);
        break;
    }
    return DynamicBorderSide(
      color: Color.lerp(colorA, colorB, t)!,
      gradient: Gradient.lerp(a.gradient, b.gradient, t),
      width: width,
      style: BorderStyle.solid,
      begin: Dimension.lerp(a.begin, b.begin, t),
      end: a.end == null && b.end == null
          ? null
          : Dimension.lerp(
              a.end ?? 100.toPercentLength, b.end ?? 100.toPercentLength, t),
      shift: Dimension.lerp(a.shift, b.shift, t),
      strokeCap: t < 0.5 ? a.strokeCap : b.strokeCap,
      strokeJoin: t < 0.5 ? a.strokeJoin : b.strokeJoin,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is DynamicBorderSide &&
        other.color == color &&
        other.gradient == gradient &&
        other.width == width &&
        other.style == style &&
        other.begin == begin &&
        other.end == end &&
        other.shift == shift &&
        other.strokeCap == strokeCap &&
        other.strokeJoin == strokeJoin;
  }

  @override
  int get hashCode => hashValues(
      color, gradient, width, style, begin, end, shift, strokeJoin, strokeCap);
}
