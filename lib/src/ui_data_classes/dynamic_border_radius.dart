import 'package:morphable_shape/src/common_includes.dart';

class DynamicRadius {
  const DynamicRadius.circular(Length radius) : this.elliptical(radius, radius);

  /// Constructs an elliptical radius with the given radii.
  const DynamicRadius.elliptical(this.x, this.y);

  static const DynamicRadius zero = DynamicRadius.circular(const Length(0));

  DynamicRadius.fromJson(Map<String, dynamic> map)
      : x = parseDimension(map["x"]) ?? 0.toPXLength,
        y = parseDimension(map["y"]) ?? 0.toPXLength;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {};
    map["x"] = x.toJson();
    map["y"] = y.toJson();
    return map;
  }

  /// The radius value on the horizontal axis.
  final Dimension x;

  /// The radius value on the vertical axis.
  final Dimension y;

  DynamicRadius copyWith({
    Dimension? x,
    Dimension? y,
  }) {
    return DynamicRadius.elliptical(
      x ?? this.x,
      y ?? this.y,
    );
  }

  Radius toRadius({Size? size, Size? screenSize}) {
    return Radius.elliptical(
        x.toPX(constraint: size?.width, screenSize: screenSize),
        y.toPX(constraint: size?.height, screenSize: screenSize));
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;

    return other is DynamicRadius && other.x == x && other.y == y;
  }

  @override
  int get hashCode => hashValues(x, y);
}

class DynamicBorderRadius {
  const DynamicBorderRadius.all(DynamicRadius radius)
      : this.only(
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        );

  const DynamicBorderRadius.only({
    this.topLeft = const DynamicRadius.circular(Length(0)),
    this.topRight = const DynamicRadius.circular(Length(0)),
    this.bottomLeft = const DynamicRadius.circular(Length(0)),
    this.bottomRight = const DynamicRadius.circular(Length(0)),
  });

  DynamicBorderRadius.fromJson(Map<String, dynamic> map)
      : topLeft = DynamicRadius.fromJson(map["topLeft"]),
        topRight = DynamicRadius.fromJson(map["topRight"]),
        bottomLeft = DynamicRadius.fromJson(map["bottomLeft"]),
        bottomRight = DynamicRadius.fromJson(map["bottomRight"]);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {};
    map["topLeft"] = topLeft.toJson();
    map["topRight"] = topRight.toJson();
    map["bottomLeft"] = bottomLeft.toJson();
    map["bottomRight"] = bottomRight.toJson();
    return map;
  }

  DynamicBorderRadius copyWith({
    DynamicRadius? topLeft,
    DynamicRadius? topRight,
    DynamicRadius? bottomLeft,
    DynamicRadius? bottomRight,
  }) {
    return DynamicBorderRadius.only(
      topLeft: topLeft ?? this.topLeft,
      topRight: topRight ?? this.topRight,
      bottomLeft: bottomLeft ?? this.bottomLeft,
      bottomRight: bottomRight ?? this.bottomRight,
    );
  }

  final DynamicRadius topLeft;
  final DynamicRadius topRight;
  final DynamicRadius bottomLeft;
  final DynamicRadius bottomRight;

  BorderRadius toBorderRadius({Size? size, Size? screenSize}) {
    return BorderRadius.only(
      topLeft: topLeft.toRadius(size: size, screenSize: screenSize),
      topRight: topRight.toRadius(size: size, screenSize: screenSize),
      bottomLeft: bottomLeft.toRadius(size: size, screenSize: screenSize),
      bottomRight: bottomRight.toRadius(size: size, screenSize: screenSize),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;

    return other is DynamicBorderRadius &&
        other.topLeft == topLeft &&
        other.topRight == topRight &&
        other.bottomLeft == bottomLeft &&
        other.bottomRight == bottomRight;
  }

  @override
  int get hashCode => hashValues(topLeft, topRight, bottomLeft, bottomRight);
}
