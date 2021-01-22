import 'MorphableShapeBorder.dart';
import 'package:flutter/material.dart';
import 'package:length_unit/length_unit.dart';
import 'dart:math';

class DynamicRadius {
  const DynamicRadius.circular(Length radius) : this.elliptical(radius, radius);

  /// Constructs an elliptical radius with the given radii.
  const DynamicRadius.elliptical(this.x, this.y);

  static const DynamicRadius zero = DynamicRadius.circular(const Length(0));

  /// The radius value on the horizontal axis.
  final Length x;

  /// The radius value on the vertical axis.
  final Length y;

  DynamicRadius copyWith({
    Length? x,
    Length? y,
  }) {
    return DynamicRadius.elliptical(
      x ?? this.x,
      y ?? this.y,
    );
  }

  Radius toRadius(Size size) {
    return Radius.elliptical(x.toPX(constraintSize: size.width),
        y.toPX(constraintSize: size.height));
  }
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

  DynamicBorderRadius copyWith({
    DynamicRadius? topLeft,
    DynamicRadius? topRight,
    DynamicRadius? bottomLeft,
    DynamicRadius? bottomRight,
  }
  ) {
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

  BorderRadius toBorderRadius(Size size) {
    return BorderRadius.only(
      topLeft: topLeft.toRadius(size),
      topRight: topRight.toRadius(size),
      bottomLeft: bottomLeft.toRadius(size),
      bottomRight: bottomRight.toRadius(size),
    );
  }
}

/*
abstract class DynamicShape {
  Size size;

  DynamicShape({required this.size});

  //DynamicShape.fromJson(Map<String, dynamic> map);

  //Map<String, dynamic> toJson();

  Shape generateShape();

  void resize(Size newSize) {
    size = newSize;
  }
}

class DynamicPathShape extends DynamicShape {
  DynamicPath path;
  DynamicPathShape({required this.path, required Size size})
      : super(size: size);

  Shape generateShape() {
    return PathShape(path: path);
  }

  void resize(Size size) {
    super.resize(size);
    path.resize(size);
  }
}

class DynamicArcShape extends DynamicShape {
  ShapeSide side;
  Length arcHeight;
  bool isOutward;

  DynamicArcShape(
      {this.side = ShapeSide.bottom,
      this.isOutward = true,
      this.arcHeight = const Length(10),
      required Size size})
      : super(size: size);

  Shape generateShape() {
    double arcHeight;
    if (side == ShapeSide.top || side == ShapeSide.bottom) {
      arcHeight = this.arcHeight.toPX(constraintSize: size.height);
    } else {
      arcHeight = this.arcHeight.toPX(constraintSize: size.width);
    }
    return ArcShape(
      side: side,
      arcHeight: arcHeight,
      isOutward: isOutward,
    );
  }
}

class DynamicBubbleShape extends DynamicShape {
  ShapeCorner corner;

  Length borderRadius;
  Length arrowHeight;
  Length arrowWidth;

  Length arrowCenterPosition;
  Length arrowHeadPosition;

  DynamicBubbleShape({
    required Size size,
    this.corner = ShapeCorner.bottomRight,
    this.borderRadius = const Length(12),
    this.arrowHeight = const Length(10),
    this.arrowWidth = const Length(10),
    this.arrowCenterPosition = const Length(0.5, unit: LengthUnit.percent),
    this.arrowHeadPosition = const Length(0.5, unit: LengthUnit.percent),
  }) : super(size: size);

  Shape generateShape() {
    double borderRadius;
    double arrowHeight;
    double arrowWidth;
    double arrowCenterPosition;
    double arrowHeadPosition;
    borderRadius =
        this.borderRadius.toPX(constraintSize: min(size.height, size.width));
    if (corner.isHorizontal) {
      arrowHeight = this.arrowHeight.toPX(constraintSize: size.height);
      arrowWidth = this.arrowWidth.toPX(constraintSize: size.width);
      arrowCenterPosition =
          this.arrowCenterPosition.toPX(constraintSize: size.width);
      arrowHeadPosition =
          this.arrowHeadPosition.toPX(constraintSize: size.width);
    } else {
      arrowHeight = this.arrowHeight.toPX(constraintSize: size.width);
      arrowWidth = this.arrowWidth.toPX(constraintSize: size.height);
      arrowCenterPosition =
          this.arrowCenterPosition.toPX(constraintSize: size.height);
      arrowHeadPosition =
          this.arrowHeadPosition.toPX(constraintSize: size.height);
    }
    return BubbleShape(
      corner: corner,
      arrowHeight: arrowHeight,
      arrowWidth: arrowWidth,
      arrowCenterPosition: arrowCenterPosition,
      arrowHeadPosition: arrowHeadPosition,
      borderRadius: borderRadius,
    );
  }
}

 */
