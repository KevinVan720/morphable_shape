import 'package:morphable_shape/morphable_shape.dart';

class RectangleCornerStyles {
  final CornerStyle topLeft;
  final CornerStyle bottomLeft;
  final CornerStyle topRight;
  final CornerStyle bottomRight;

  const RectangleCornerStyles.only({
    this.topLeft = CornerStyle.rounded,
    this.bottomLeft = CornerStyle.rounded,
    this.topRight = CornerStyle.rounded,
    this.bottomRight = CornerStyle.rounded,
  });

  const RectangleCornerStyles.all(CornerStyle style)
      : topLeft = style,
        bottomLeft = style,
        topRight = style,
        bottomRight = style;

  static RectangleCornerStyles fromJson(Map map) {
    return RectangleCornerStyles.only(
        topLeft: parseCornerStyle(map['topLeft']) ?? CornerStyle.rounded,
        bottomLeft: parseCornerStyle(map['bottomLeft']) ?? CornerStyle.rounded,
        topRight: parseCornerStyle(map['topRight']) ?? CornerStyle.rounded,
        bottomRight:
            parseCornerStyle(map['bottomRight']) ?? CornerStyle.rounded);
  }

  Map<String, dynamic> toJson() {
    return {
      "topLeft": topLeft.toJson(),
      "bottomLeft": bottomLeft.toJson(),
      "topRight": topRight.toJson(),
      "bottomRight": bottomRight.toJson()
    };
  }

  RectangleCornerStyles copyWith({
    CornerStyle? topLeft,
    CornerStyle? bottomLeft,
    CornerStyle? topRight,
    CornerStyle? bottomRight,
  }) {
    return RectangleCornerStyles.only(
      topLeft: topLeft ?? this.topLeft,
      topRight: topRight ?? this.topRight,
      bottomLeft: bottomLeft ?? this.bottomLeft,
      bottomRight: bottomRight ?? this.bottomRight,
    );
  }
}

class RectangleBorders {
  final DynamicBorderSide top;
  final DynamicBorderSide bottom;
  final DynamicBorderSide left;
  final DynamicBorderSide right;

  const RectangleBorders.only({
    this.top = defaultBorder,
    this.bottom = defaultBorder,
    this.left = defaultBorder,
    this.right = defaultBorder,
  });

  const RectangleBorders.all(DynamicBorderSide border)
      : top = border,
        bottom = border,
        left = border,
        right = border;

  const RectangleBorders.symmetric(
      {DynamicBorderSide horizontal = defaultBorder,
      DynamicBorderSide vertical = defaultBorder})
      : top = horizontal,
        bottom = horizontal,
        left = vertical,
        right = vertical;

  static RectangleBorders fromJson(Map map) {
    return RectangleBorders.only(
      top: parseDynamicBorderSide(map['top']) ?? defaultBorder,
      bottom: parseDynamicBorderSide(map['bottom']) ?? defaultBorder,
      left: parseDynamicBorderSide(map['left']) ?? defaultBorder,
      right: parseDynamicBorderSide(map['right']) ?? defaultBorder,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "top": top.toJson(),
      "bottom": bottom.toJson(),
      "left": left.toJson(),
      "right": right.toJson()
    };
  }

  RectangleBorders copyWith({
    DynamicBorderSide? top,
    DynamicBorderSide? bottom,
    DynamicBorderSide? left,
    DynamicBorderSide? right,
  }) {
    return RectangleBorders.only(
      top: top ?? this.top,
      bottom: bottom ?? this.bottom,
      left: left ?? this.left,
      right: right ?? this.right,
    );
  }
}
