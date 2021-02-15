import 'package:length_unit/length_unit.dart';

import 'morphable_shape.dart';

const Map<String, Shape> presetShapeMap = {
  "Circle": const CircleShape(),
  "Rectangle": const RectangleShape(
      borderRadius: DynamicBorderRadius.all(DynamicRadius.zero)),
  "RoundRectangle10": const RectangleShape(
      borderRadius: DynamicBorderRadius.all(
          const DynamicRadius.circular(const Length(10, unit: LengthUnit.percent)))),
  "DiagonalBottomRight": const RectangleShape(
      bottomRightStyle: CornerStyle.straight,
      borderRadius: DynamicBorderRadius.only(
          bottomRight: const DynamicRadius.elliptical(
              Length(100, unit: LengthUnit.percent),
              Length(15, unit: LengthUnit.percent)))),
  "CutCornerAll10": const RectangleShape(
      topLeftStyle: CornerStyle.straight,
      topRightStyle: CornerStyle.straight,
      bottomLeftStyle: CornerStyle.straight,
      bottomRightStyle: CornerStyle.straight,
      borderRadius: DynamicBorderRadius.all(
          const DynamicRadius.circular(const Length(10, unit: LengthUnit.percent)))),
  "CutoutCornerAll10": const RectangleShape(
      topLeftStyle: CornerStyle.cutout,
      topRightStyle: CornerStyle.cutout,
      bottomLeftStyle: CornerStyle.cutout,
      bottomRightStyle: CornerStyle.cutout,
      borderRadius: DynamicBorderRadius.all(
          const DynamicRadius.circular(const Length(10, unit: LengthUnit.percent)))),
  "ConcaveCornerAll10": const RectangleShape(
      topLeftStyle: CornerStyle.concave,
      topRightStyle: CornerStyle.concave,
      bottomLeftStyle: CornerStyle.concave,
      bottomRightStyle: CornerStyle.concave,
      borderRadius: DynamicBorderRadius.all(
          const DynamicRadius.circular(const Length(10, unit: LengthUnit.percent)))),
  "BubbleTopLeft": const BubbleShape(corner: ShapeCorner.topLeft),
  "BubbleBottomRight": const BubbleShape(corner: ShapeCorner.bottomRight),
  "BubbleLeftTop": const BubbleShape(corner: ShapeCorner.leftTop),
  "BubbleRightBottom": const BubbleShape(corner: ShapeCorner.rightBottom),
  "ArcTop": const ArcShape(
      side: ShapeSide.top, arcHeight: Length(20, unit: LengthUnit.percent)),
  "ArcBottom": const ArcShape(
      side: ShapeSide.bottom, arcHeight: Length(20, unit: LengthUnit.percent)),
  "ArrowRight": const ArrowShape(),
  "ArrowLeft": const ArrowShape(side: ShapeSide.left),
  "Trapezoid": const TrapezoidShape(),
  "TrapezoidBottom": const TrapezoidShape(side: ShapeSide.top),
  "Polygon3": const PolygonShape(sides: 3),
  "Polygon5": const PolygonShape(sides: 5),
  "Polygon6": const PolygonShape(sides: 6),
  "Polygon8": const PolygonShape(sides: 8),
  "Polygon12": const PolygonShape(sides: 12),
  "Star4": const StarShape(corners: 4),
  "Star5": const StarShape(corners: 5),
  "Star6": const StarShape(corners: 6),
  "Star8": const StarShape(corners: 8),
  "Star12": const StarShape(corners: 12),
  "Triangle": const TriangleShape(),
  "TriangleLeft": const TriangleShape(point1 : const DynamicOffset(
      const Length(0, unit: LengthUnit.percent),
      const Length(0, unit: LengthUnit.percent)),
      point2 :const DynamicOffset(
          const Length(100, unit: LengthUnit.percent),
          const Length(0, unit: LengthUnit.percent)),
      point3 : const DynamicOffset(
          const Length(0, unit: LengthUnit.percent),
          const Length(100, unit: LengthUnit.percent))),
  "TriangleRight": const TriangleShape(point1 : const DynamicOffset(
      const Length(0, unit: LengthUnit.percent),
      const Length(0, unit: LengthUnit.percent)),
      point2 :const DynamicOffset(
          const Length(100, unit: LengthUnit.percent),
          const Length(0, unit: LengthUnit.percent)),
      point3 : const DynamicOffset(
          const Length(100, unit: LengthUnit.percent),
          const Length(100, unit: LengthUnit.percent))),
};
