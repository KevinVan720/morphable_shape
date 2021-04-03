import 'package:dimension/dimension.dart';
import 'package:morphable_shape/morphable_shape.dart';

const Map<String, Map<String, MorphableShapeBorder>> presetShapeMap = {
  "Rounded Rectangles": presetRoundedRectangleShapeMap,
  "Rectangle Like": presetRectangleShapeMap,
  "Circle": presetCircleShapeMap,
  "Polygons": presetPolygonShapeMap,
  "Stars": presetStarShapeMap,
  "Triangles": presetTriangleShapeMap,
  "Others": presetOtherShapeMap,
};

const Map<String, MorphableShapeBorder> presetCircleShapeMap = {
  "Circle": const CircleShapeBorder(),
};

const Map<String, MorphableShapeBorder> presetRoundedRectangleShapeMap = {
  "RectangleAll0": const RoundedRectangleShapeBorder(
      borderRadius: DynamicBorderRadius.all(DynamicRadius.zero)),
  "RoundRectangleAll10": const RoundedRectangleShapeBorder(
      borderRadius: DynamicBorderRadius.all(const DynamicRadius.circular(
          const Length(10, unit: LengthUnit.percent)))),
  "RoundRectangleAll25": const RoundedRectangleShapeBorder(
      borderRadius: DynamicBorderRadius.all(const DynamicRadius.circular(
          const Length(25, unit: LengthUnit.percent)))),
  "RoundRectangleTLBR25": const RoundedRectangleShapeBorder(
      borderRadius: DynamicBorderRadius.only(
          topLeft: const DynamicRadius.circular(
              const Length(25, unit: LengthUnit.percent)),
          bottomRight: const DynamicRadius.circular(
              const Length(25, unit: LengthUnit.percent)))),
  "RoundRectangleTRBL25": const RoundedRectangleShapeBorder(
      borderRadius: DynamicBorderRadius.only(
          topRight: const DynamicRadius.circular(
              const Length(25, unit: LengthUnit.percent)),
          bottomLeft: const DynamicRadius.circular(
              const Length(25, unit: LengthUnit.percent)))),
  "RoundRectangleTL50BL50BR50": const RoundedRectangleShapeBorder(
      borderRadius: DynamicBorderRadius.only(
          topLeft: const DynamicRadius.circular(
              const Length(50, unit: LengthUnit.percent)),
          bottomLeft: const DynamicRadius.circular(
              const Length(50, unit: LengthUnit.percent)),
          bottomRight: const DynamicRadius.circular(
              const Length(50, unit: LengthUnit.percent)))),
  "RoundRectangleTL50BL50TR50": const RoundedRectangleShapeBorder(
      borderRadius: DynamicBorderRadius.only(
          topLeft: const DynamicRadius.circular(
              const Length(50, unit: LengthUnit.percent)),
          bottomLeft: const DynamicRadius.circular(
              const Length(50, unit: LengthUnit.percent)),
          topRight: const DynamicRadius.circular(
              const Length(50, unit: LengthUnit.percent)))),
};

const Map<String, MorphableShapeBorder> presetRectangleShapeMap = {
  "RoundAll25": const RectangleShapeBorder(
      cornerStyles: RectangleCornerStyles.all(CornerStyle.rounded),
      borderRadius: DynamicBorderRadius.all(const DynamicRadius.circular(
          const Length(25, unit: LengthUnit.percent)))),
  "CutCornerAll25": const RectangleShapeBorder(
      cornerStyles: RectangleCornerStyles.all(CornerStyle.straight),
      borderRadius: DynamicBorderRadius.all(const DynamicRadius.circular(
          const Length(25, unit: LengthUnit.percent)))),
  "CutoutCornerAll25": const RectangleShapeBorder(
      cornerStyles: RectangleCornerStyles.all(CornerStyle.cutout),
      borderRadius: DynamicBorderRadius.all(const DynamicRadius.circular(
          const Length(25, unit: LengthUnit.percent)))),
  "ConcaveCornerAll25": const RectangleShapeBorder(
      cornerStyles: RectangleCornerStyles.all(CornerStyle.concave),
      borderRadius: DynamicBorderRadius.all(const DynamicRadius.circular(
          const Length(25, unit: LengthUnit.percent)))),
  "DiagonalBottomRight": const RectangleShapeBorder(
      cornerStyles:
          RectangleCornerStyles.only(bottomRight: CornerStyle.straight),
      borderRadius: DynamicBorderRadius.only(
          bottomRight: const DynamicRadius.elliptical(
              Length(100, unit: LengthUnit.percent),
              Length(25, unit: LengthUnit.percent)))),
  "DiagonalBottomLeft": const RectangleShapeBorder(
      cornerStyles:
          RectangleCornerStyles.only(bottomLeft: CornerStyle.straight),
      borderRadius: DynamicBorderRadius.only(
          bottomLeft: const DynamicRadius.elliptical(
              Length(100, unit: LengthUnit.percent),
              Length(25, unit: LengthUnit.percent)))),
  "ChevronLeft": const RectangleShapeBorder(
      cornerStyles: RectangleCornerStyles.only(
          bottomLeft: CornerStyle.straight, topLeft: CornerStyle.straight),
      borderRadius: DynamicBorderRadius.only(
          topLeft: const DynamicRadius.circular(
              Length(50, unit: LengthUnit.percent)),
          bottomLeft: const DynamicRadius.circular(
              Length(50, unit: LengthUnit.percent)))),
  "ChevronRight": const RectangleShapeBorder(
      cornerStyles: RectangleCornerStyles.only(
          bottomRight: CornerStyle.straight, topRight: CornerStyle.straight),
      borderRadius: DynamicBorderRadius.only(
          topRight: const DynamicRadius.circular(
              Length(50, unit: LengthUnit.percent)),
          bottomRight: const DynamicRadius.circular(
              Length(50, unit: LengthUnit.percent)))),
  "Diamond": const RectangleShapeBorder(
      cornerStyles: RectangleCornerStyles.all(CornerStyle.straight),
      borderRadius: DynamicBorderRadius.all(
          const DynamicRadius.circular(Length(50, unit: LengthUnit.percent)))),
  "ArcTL": const RectangleShapeBorder(
      borderRadius: DynamicBorderRadius.only(
          topLeft: const DynamicRadius.circular(
              Length(100, unit: LengthUnit.percent)))),
  "ArcBR": const RectangleShapeBorder(
      borderRadius: DynamicBorderRadius.only(
          bottomRight: const DynamicRadius.circular(
              Length(100, unit: LengthUnit.percent)))),
  "DonutTL": const RectangleShapeBorder(
      cornerStyles:
          RectangleCornerStyles.only(bottomRight: CornerStyle.concave),
      borderRadius: DynamicBorderRadius.only(
          topLeft: const DynamicRadius.circular(
              Length(100, unit: LengthUnit.percent)),
          bottomRight: const DynamicRadius.circular(
              Length(50, unit: LengthUnit.percent)))),
};

const Map<String, MorphableShapeBorder> presetPolygonShapeMap = {
  "Polygon3": const PolygonShapeBorder(sides: 3),
  "Polygon5": const PolygonShapeBorder(sides: 5),
  "Polygon6": const PolygonShapeBorder(sides: 6),
  "Polygon8": const PolygonShapeBorder(sides: 8),
  "Polygon12": const PolygonShapeBorder(sides: 12),
  "Polygon5Rounded": const PolygonShapeBorder(
      sides: 5, cornerRadius: Length(50, unit: LengthUnit.percent)),
  "Polygon6Rounded": const PolygonShapeBorder(
      sides: 6, cornerRadius: Length(50, unit: LengthUnit.percent)),
  "Polygon8Rounded": const PolygonShapeBorder(
      sides: 8, cornerRadius: Length(50, unit: LengthUnit.percent)),
  "Polygon6Straight": const PolygonShapeBorder(
      cornerStyle: CornerStyle.straight,
      sides: 6,
      cornerRadius: Length(50, unit: LengthUnit.percent)),
  "Polygon6Cutout": const PolygonShapeBorder(
      cornerStyle: CornerStyle.cutout,
      sides: 6,
      cornerRadius: Length(50, unit: LengthUnit.percent)),
  "Polygon6Concave": const PolygonShapeBorder(
      cornerStyle: CornerStyle.concave,
      sides: 6,
      cornerRadius: Length(50, unit: LengthUnit.percent)),
};

const Map<String, MorphableShapeBorder> presetStarShapeMap = {
  "Star4": const StarShapeBorder(corners: 4),
  "Star5": const StarShapeBorder(corners: 5),
  "Star6": const StarShapeBorder(corners: 6),
  "Star8": const StarShapeBorder(corners: 8),
  "Star12": const StarShapeBorder(corners: 12),
  "Star4Rounded": const StarShapeBorder(
      corners: 4,
      cornerRadius: Length(50, unit: LengthUnit.percent),
      insetRadius: Length(50, unit: LengthUnit.percent)),
  "Star6Rounded": const StarShapeBorder(
      corners: 6,
      cornerRadius: Length(30, unit: LengthUnit.percent),
      insetRadius: Length(30, unit: LengthUnit.percent)),
  "Star8Rounded": const StarShapeBorder(
      corners: 8,
      cornerRadius: Length(10, unit: LengthUnit.percent),
      insetRadius: Length(10, unit: LengthUnit.percent)),
};

const Map<String, MorphableShapeBorder> presetTriangleShapeMap = {
  "Triangle": const TriangleShapeBorder(),
  "TriangleBottom": const TriangleShapeBorder(
      point1: const DynamicOffset(const Length(50, unit: LengthUnit.percent),
          const Length(0, unit: LengthUnit.percent)),
      point2: const DynamicOffset(const Length(100, unit: LengthUnit.percent),
          const Length(100, unit: LengthUnit.percent)),
      point3: const DynamicOffset(const Length(0, unit: LengthUnit.percent),
          const Length(100, unit: LengthUnit.percent))),
  "TriangleLeft": const TriangleShapeBorder(
      point1: const DynamicOffset(const Length(0, unit: LengthUnit.percent),
          const Length(0, unit: LengthUnit.percent)),
      point2: const DynamicOffset(const Length(100, unit: LengthUnit.percent),
          const Length(0, unit: LengthUnit.percent)),
      point3: const DynamicOffset(const Length(0, unit: LengthUnit.percent),
          const Length(100, unit: LengthUnit.percent))),
  "TriangleRight": const TriangleShapeBorder(
      point1: const DynamicOffset(const Length(0, unit: LengthUnit.percent),
          const Length(0, unit: LengthUnit.percent)),
      point2: const DynamicOffset(const Length(100, unit: LengthUnit.percent),
          const Length(0, unit: LengthUnit.percent)),
      point3: const DynamicOffset(const Length(100, unit: LengthUnit.percent),
          const Length(100, unit: LengthUnit.percent))),
};

const Map<String, MorphableShapeBorder> presetOtherShapeMap = {
  "BubbleTopLeft": const BubbleShapeBorder(
      corner: ShapeCorner.topLeft,
      borderRadius: Length(20, unit: LengthUnit.percent)),
  "BubbleBottomRight": const BubbleShapeBorder(
      corner: ShapeCorner.bottomRight,
      borderRadius: Length(20, unit: LengthUnit.percent)),
  "BubbleLeftTop": const BubbleShapeBorder(
      corner: ShapeCorner.leftTop,
      borderRadius: Length(20, unit: LengthUnit.percent)),
  "BubbleRightBottom": const BubbleShapeBorder(
      corner: ShapeCorner.rightBottom,
      borderRadius: Length(20, unit: LengthUnit.percent)),
  "ArcTop": const ArcShapeBorder(
      side: ShapeSide.top, arcHeight: Length(20, unit: LengthUnit.percent)),
  "ArcBottom": const ArcShapeBorder(
      side: ShapeSide.bottom, arcHeight: Length(20, unit: LengthUnit.percent)),
  "ArrowRight": const ArrowShapeBorder(),
  "ArrowLeft": const ArrowShapeBorder(side: ShapeSide.left),
  "Trapezoid": const TrapezoidShapeBorder(),
  "TrapezoidBottom": const TrapezoidShapeBorder(side: ShapeSide.top),
};
