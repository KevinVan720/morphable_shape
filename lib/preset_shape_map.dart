import 'package:morphable_shape/morphable_shape.dart';

///A collection of predefined shapes, grouped into maps

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
  "Circle": CircleShapeBorder(),
};

const Map<String, MorphableShapeBorder> presetRoundedRectangleShapeMap = {
  "RectangleAll0": RoundedRectangleShapeBorder(
      borderRadius: DynamicBorderRadius.all(DynamicRadius.zero)),
  "RoundRectangleAll10": RoundedRectangleShapeBorder(
      borderRadius: DynamicBorderRadius.all(
          DynamicRadius.circular(Length(10, unit: LengthUnit.percent)))),
  "RoundRectangleAll25": RoundedRectangleShapeBorder(
      borderRadius: DynamicBorderRadius.all(
          DynamicRadius.circular(Length(25, unit: LengthUnit.percent)))),
  "RoundRectangleTLBR25": RoundedRectangleShapeBorder(
      borderRadius: DynamicBorderRadius.only(
          topLeft: DynamicRadius.circular(Length(25, unit: LengthUnit.percent)),
          bottomRight:
              DynamicRadius.circular(Length(25, unit: LengthUnit.percent)))),
  "RoundRectangleTRBL25": RoundedRectangleShapeBorder(
      borderRadius: DynamicBorderRadius.only(
          topRight:
              DynamicRadius.circular(Length(25, unit: LengthUnit.percent)),
          bottomLeft:
              DynamicRadius.circular(Length(25, unit: LengthUnit.percent)))),
  "RoundRectangleTL50BL50BR50": RoundedRectangleShapeBorder(
      borderRadius: DynamicBorderRadius.only(
          topLeft: DynamicRadius.circular(Length(50, unit: LengthUnit.percent)),
          bottomLeft:
              DynamicRadius.circular(Length(50, unit: LengthUnit.percent)),
          bottomRight:
              DynamicRadius.circular(Length(50, unit: LengthUnit.percent)))),
  "RoundRectangleTL50BL50TR50": RoundedRectangleShapeBorder(
      borderRadius: DynamicBorderRadius.only(
          topLeft: DynamicRadius.circular(Length(50, unit: LengthUnit.percent)),
          bottomLeft:
              DynamicRadius.circular(Length(50, unit: LengthUnit.percent)),
          topRight:
              DynamicRadius.circular(Length(50, unit: LengthUnit.percent)))),
};

const Map<String, MorphableShapeBorder> presetRectangleShapeMap = {
  "RoundAll25": RectangleShapeBorder(
      cornerStyles: RectangleCornerStyles.all(CornerStyle.rounded),
      borderRadius: DynamicBorderRadius.all(
          DynamicRadius.circular(Length(25, unit: LengthUnit.percent)))),
  "CutCornerAll25": RectangleShapeBorder(
      cornerStyles: RectangleCornerStyles.all(CornerStyle.straight),
      borderRadius: DynamicBorderRadius.all(
          DynamicRadius.circular(Length(25, unit: LengthUnit.percent)))),
  "CutoutCornerAll25": RectangleShapeBorder(
      cornerStyles: RectangleCornerStyles.all(CornerStyle.cutout),
      borderRadius: DynamicBorderRadius.all(
          DynamicRadius.circular(Length(25, unit: LengthUnit.percent)))),
  "ConcaveCornerAll25": RectangleShapeBorder(
      cornerStyles: RectangleCornerStyles.all(CornerStyle.concave),
      borderRadius: DynamicBorderRadius.all(
          DynamicRadius.circular(Length(25, unit: LengthUnit.percent)))),
  "DiagonalBottomRight": RectangleShapeBorder(
      cornerStyles:
          RectangleCornerStyles.only(bottomRight: CornerStyle.straight),
      borderRadius: DynamicBorderRadius.only(
          bottomRight: DynamicRadius.elliptical(
              Length(100, unit: LengthUnit.percent),
              Length(25, unit: LengthUnit.percent)))),
  "DiagonalBottomLeft": RectangleShapeBorder(
      cornerStyles:
          RectangleCornerStyles.only(bottomLeft: CornerStyle.straight),
      borderRadius: DynamicBorderRadius.only(
          bottomLeft: DynamicRadius.elliptical(
              Length(100, unit: LengthUnit.percent),
              Length(25, unit: LengthUnit.percent)))),
  "ChevronLeft": RectangleShapeBorder(
      cornerStyles: RectangleCornerStyles.only(
          bottomLeft: CornerStyle.straight, topLeft: CornerStyle.straight),
      borderRadius: DynamicBorderRadius.only(
          topLeft: DynamicRadius.circular(Length(50, unit: LengthUnit.percent)),
          bottomLeft:
              DynamicRadius.circular(Length(50, unit: LengthUnit.percent)))),
  "ChevronRight": RectangleShapeBorder(
      cornerStyles: RectangleCornerStyles.only(
          bottomRight: CornerStyle.straight, topRight: CornerStyle.straight),
      borderRadius: DynamicBorderRadius.only(
          topRight:
              DynamicRadius.circular(Length(50, unit: LengthUnit.percent)),
          bottomRight:
              DynamicRadius.circular(Length(50, unit: LengthUnit.percent)))),
  "Diamond": RectangleShapeBorder(
      cornerStyles: RectangleCornerStyles.all(CornerStyle.straight),
      borderRadius: DynamicBorderRadius.all(
          DynamicRadius.circular(Length(50, unit: LengthUnit.percent)))),
  "ArcTL": RectangleShapeBorder(
      borderRadius: DynamicBorderRadius.only(
          topLeft:
              DynamicRadius.circular(Length(100, unit: LengthUnit.percent)))),
  "ArcBR": RectangleShapeBorder(
      borderRadius: DynamicBorderRadius.only(
          bottomRight:
              DynamicRadius.circular(Length(100, unit: LengthUnit.percent)))),
  "DonutTL": RectangleShapeBorder(
      cornerStyles:
          RectangleCornerStyles.only(bottomRight: CornerStyle.concave),
      borderRadius: DynamicBorderRadius.only(
          topLeft:
              DynamicRadius.circular(Length(100, unit: LengthUnit.percent)),
          bottomRight:
              DynamicRadius.circular(Length(50, unit: LengthUnit.percent)))),
};

const Map<String, MorphableShapeBorder> presetPolygonShapeMap = {
  "Polygon3": PolygonShapeBorder(sides: 3),
  "Polygon5": PolygonShapeBorder(sides: 5),
  "Polygon6": PolygonShapeBorder(sides: 6),
  "Polygon8": PolygonShapeBorder(sides: 8),
  "Polygon12": PolygonShapeBorder(sides: 12),
  "Polygon5Rounded": PolygonShapeBorder(
      sides: 5, cornerRadius: Length(50, unit: LengthUnit.percent)),
  "Polygon6Rounded": PolygonShapeBorder(
      sides: 6, cornerRadius: Length(50, unit: LengthUnit.percent)),
  "Polygon8Rounded": PolygonShapeBorder(
      sides: 8, cornerRadius: Length(50, unit: LengthUnit.percent)),
  "Polygon6Straight": PolygonShapeBorder(
      cornerStyle: CornerStyle.straight,
      sides: 6,
      cornerRadius: Length(50, unit: LengthUnit.percent)),
  "Polygon6Cutout": PolygonShapeBorder(
      cornerStyle: CornerStyle.cutout,
      sides: 6,
      cornerRadius: Length(50, unit: LengthUnit.percent)),
  "Polygon6Concave": PolygonShapeBorder(
      cornerStyle: CornerStyle.concave,
      sides: 6,
      cornerRadius: Length(50, unit: LengthUnit.percent)),
};

const Map<String, MorphableShapeBorder> presetStarShapeMap = {
  "Star4": StarShapeBorder(corners: 4),
  "Star5": StarShapeBorder(corners: 5),
  "Star6": StarShapeBorder(corners: 6),
  "Star8": StarShapeBorder(corners: 8),
  "Star12": StarShapeBorder(corners: 12),
  "Star4Rounded": StarShapeBorder(
      corners: 4,
      cornerRadius: Length(50, unit: LengthUnit.percent),
      insetRadius: Length(50, unit: LengthUnit.percent)),
  "Star6Rounded": StarShapeBorder(
      corners: 6,
      cornerRadius: Length(30, unit: LengthUnit.percent),
      insetRadius: Length(30, unit: LengthUnit.percent)),
  "Star8Rounded": StarShapeBorder(
      corners: 8,
      cornerRadius: Length(10, unit: LengthUnit.percent),
      insetRadius: Length(10, unit: LengthUnit.percent)),
};

const Map<String, MorphableShapeBorder> presetTriangleShapeMap = {
  "Triangle": TriangleShapeBorder(),
  "TriangleBottom": TriangleShapeBorder(
      point1: DynamicOffset(Length(50, unit: LengthUnit.percent),
          Length(0, unit: LengthUnit.percent)),
      point2: DynamicOffset(Length(100, unit: LengthUnit.percent),
          Length(100, unit: LengthUnit.percent)),
      point3: DynamicOffset(Length(0, unit: LengthUnit.percent),
          Length(100, unit: LengthUnit.percent))),
  "TriangleLeft": TriangleShapeBorder(
      point1: DynamicOffset(Length(0, unit: LengthUnit.percent),
          Length(0, unit: LengthUnit.percent)),
      point2: DynamicOffset(Length(100, unit: LengthUnit.percent),
          Length(0, unit: LengthUnit.percent)),
      point3: DynamicOffset(Length(0, unit: LengthUnit.percent),
          Length(100, unit: LengthUnit.percent))),
  "TriangleRight": TriangleShapeBorder(
      point1: DynamicOffset(Length(0, unit: LengthUnit.percent),
          Length(0, unit: LengthUnit.percent)),
      point2: DynamicOffset(Length(100, unit: LengthUnit.percent),
          Length(0, unit: LengthUnit.percent)),
      point3: DynamicOffset(Length(100, unit: LengthUnit.percent),
          Length(100, unit: LengthUnit.percent))),
};

const Map<String, MorphableShapeBorder> presetOtherShapeMap = {
  "BubbleTop": BubbleShapeBorder(
      side: ShapeSide.top, borderRadius: Length(20, unit: LengthUnit.percent)),
  "BubbleBottom": BubbleShapeBorder(
      side: ShapeSide.bottom,
      borderRadius: Length(20, unit: LengthUnit.percent)),
  "BubbleLeft": BubbleShapeBorder(
      side: ShapeSide.left, borderRadius: Length(20, unit: LengthUnit.percent)),
  "BubbleRight": BubbleShapeBorder(
      side: ShapeSide.right,
      borderRadius: Length(20, unit: LengthUnit.percent)),
  "ArcTop": ArcShapeBorder(
      side: ShapeSide.top, arcHeight: Length(20, unit: LengthUnit.percent)),
  "ArcBottom": ArcShapeBorder(
      side: ShapeSide.bottom, arcHeight: Length(20, unit: LengthUnit.percent)),
  "ArrowRight": ArrowShapeBorder(),
  "ArrowLeft": ArrowShapeBorder(side: ShapeSide.left),
  "Trapezoid": TrapezoidShapeBorder(),
  "TrapezoidBottom": TrapezoidShapeBorder(side: ShapeSide.top),
};
