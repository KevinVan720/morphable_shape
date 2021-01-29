import 'morphable_shape_border.dart';

Map<String, Shape> presetShapeMap = {
  "Rectangle": const RoundRectShape(
      borderRadius: DynamicBorderRadius.all(DynamicRadius.zero)),
  "RoundRectangle5": const RoundRectShape(
      borderRadius: DynamicBorderRadius.all(
          const DynamicRadius.circular(const Length(5)))),
  "RoundRectangle10": const RoundRectShape(
      borderRadius: DynamicBorderRadius.all(
          const DynamicRadius.circular(const Length(10)))),
  "RoundRectangle15": const RoundRectShape(
      borderRadius: DynamicBorderRadius.all(
          const DynamicRadius.circular(const Length(15)))),
  "DiagonalBottomRight": const DiagonalShape(
      corner: ShapeCorner.bottomRight,
      inset: Length(20, unit: LengthUnit.percent)),
  "DiagonalBottomLeft": const DiagonalShape(
      corner: ShapeCorner.bottomLeft,
      inset: Length(20, unit: LengthUnit.percent)),
  "DiagonalTopRight": const DiagonalShape(
      corner: ShapeCorner.topRight,
      inset: Length(20, unit: LengthUnit.percent)),
  "DiagonalTopLeft": const DiagonalShape(
      corner: ShapeCorner.topLeft,
      inset: Length(20, unit: LengthUnit.percent)),
  "CutCornerAll5": CutCornerShape(
      borderRadius: DynamicBorderRadius.all(
          const DynamicRadius.circular(const Length(5)))),
  "CutCornerAll10": CutCornerShape(
      borderRadius: DynamicBorderRadius.all(
          const DynamicRadius.circular(const Length(10)))),
  "CutCornerAll15": CutCornerShape(
      borderRadius: DynamicBorderRadius.all(
          const DynamicRadius.circular(const Length(15)))),
  "CutCornerTopLeft10": CutCornerShape(
      borderRadius: DynamicBorderRadius.only(
          topLeft: const DynamicRadius.circular(const Length(10)))),
  "CutCornerTopRight10": CutCornerShape(
      borderRadius: DynamicBorderRadius.only(
          topRight: const DynamicRadius.circular(const Length(10)))),
  "CutCornerBottomLeft10": CutCornerShape(
      borderRadius: DynamicBorderRadius.only(
          bottomLeft: const DynamicRadius.circular(const Length(10)))),
  "CutCornerBottomRight10": CutCornerShape(
      borderRadius: DynamicBorderRadius.only(
          bottomRight: const DynamicRadius.circular(const Length(10)))),
  "BubbleTopLeft": const BubbleShape(corner: ShapeCorner.topLeft),
  "BubbleBottomRight": const BubbleShape(corner: ShapeCorner.bottomRight),
  "BubbleLeftTop": const BubbleShape(corner: ShapeCorner.leftTop),
  "BubbleRightBottom": const BubbleShape(corner: ShapeCorner.rightBottom),
  "ArcTop": const ArcShape(
      side: ShapeSide.top, arcHeight: Length(20, unit: LengthUnit.percent)),
  "ArcBottom": const ArcShape(
      side: ShapeSide.bottom, arcHeight: Length(20, unit: LengthUnit.percent)),
  "Circle": const CircleShape(),
  "Trapezoid": const TrapezoidShape(),
  "Polygon3": const PolygonShape(sides: 3),
  "Polygon5": const PolygonShape(sides: 5),
  "Polygon6": const PolygonShape(sides: 6),
  "Polygon8": const PolygonShape(sides: 8),
  "Polygon12": const PolygonShape(sides: 12),
  "Triangle": const TriangleShape(),
  "Star4": const StarShape(corners: 4),
  "Star5": const StarShape(corners: 5),
  "Star6": const StarShape(corners: 6),
  "Star8": const StarShape(corners: 8),
  "Star12": const StarShape(corners: 12),
};
