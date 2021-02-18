import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_class_parser/flutter_class_parser.dart';
import 'package:length_unit/length_unit.dart';
import 'package:flutter_class_parser/to_json.dart';

class DynamicBorderSides {
  const DynamicBorderSides({
    this.colors = const [Color(0xFF000000)],
    this.width = const Length(1.0),
    this.style = BorderStyle.solid,
  });

  DynamicBorderSides.fromJson(Map<String, dynamic> map)
      : colors = (map["colors"] as List).map((c) =>parseColor(c)??Color(0xFF000000)).toList(),
        width = parseLength(map["length"]) ?? Length(1),
        style = parseBorderStyle(map["style"]) ?? BorderStyle.solid;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst = {};
    rst["colors"] = colors.map((e) => e.toJson()).toList();
    rst["width"] = width.toJson();
    rst["style"] = style.toJson();
    return rst;
  }

  /// The color of this side of the border.
  final List<Color> colors;

  /// The width of this side of the border, in logical pixels.
  ///
  /// Setting width to 0.0 will result in a hairline border. This means that
  /// the border will have the width of one physical pixel. Also, hairline
  /// rendering takes shortcuts when the path overlaps a pixel more than once.
  /// This means that it will render faster than otherwise, but it might
  /// double-hit pixels, giving it a slightly darker/lighter result.
  ///
  /// To omit the border entirely, set the [style] to [BorderStyle.none].
  final Length width;

  /// The style of this side of the border.
  ///
  /// To omit a side, set [style] to [BorderStyle.none]. This skips
  /// painting the border, but the border still has a [width].
  final BorderStyle style;

  /// A hairline black border that is not rendered.
  static const DynamicBorderSides none =
  DynamicBorderSides(width: Length(0.0), style: BorderStyle.none);

  DynamicBorderSides copyWith({
    List<Color>? colors,
    Length? width,
    BorderStyle? style,
  }) {
    return DynamicBorderSides(
      colors: colors ?? this.colors,
      width: width ?? this.width,
      style: style ?? this.style,
    );
  }

  DynamicBorderSides scale(double t) {
    return DynamicBorderSides(
      colors: colors,
      width: width.copyWith(value: max(0.0, width.value * t)),
      style: t <= 0.0 ? BorderStyle.none : style,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is DynamicBorderSides &&
        other.colors == colors &&
        other.width == width &&
        other.style == style;
  }

  @override
  int get hashCode => hashValues(colors, width, style);
}