import 'dart:math';
import 'package:dimension/dimension.dart';

import 'package:morphable_shape/morphable_shape.dart';

const Map<String, Map<String, Shape>> presetShapeMap = {
  "Rounded Rectangles": presetRoundedRectangleMap,
  "Rectangle Like": presetRectangleMap,
  "Arcs": presetCircleMap,
  "Polygons": presetPolygonMap,
  "Stars": presetStarMap,
  "Triangles": presetTriangleMap,
  "Others": presetOtherMap,
};

const Map<String, Shape> presetCircleMap = {
  "Circle": const CircleShape(),
  "Circle90": const CircleShape(startAngle: 0, sweepAngle: pi),
  "Circle180": const CircleShape(startAngle: pi, sweepAngle: pi),
  "Circle270": const CircleShape(startAngle: 0, sweepAngle: 3 / 2 * pi),
  "Circle270-2": const CircleShape(startAngle: pi, sweepAngle: 3 / 2 * pi),
};

const Map<String, Shape> presetRoundedRectangleMap = {
  "RectangleAll0": const RoundedRectangleShape(
      borderRadius: DynamicBorderRadius.all(DynamicRadius.zero)),
  "RoundRectangleAll10": const RoundedRectangleShape(
      borderRadius: DynamicBorderRadius.all(const DynamicRadius.circular(
          const Length(10, unit: LengthUnit.percent)))),
  "RoundRectangleAll25": const RoundedRectangleShape(
      borderRadius: DynamicBorderRadius.all(const DynamicRadius.circular(
          const Length(25, unit: LengthUnit.percent)))),
  "RoundRectangleTLBR25": const RoundedRectangleShape(
      borderRadius: DynamicBorderRadius.only(
          topLeft: const DynamicRadius.circular(
              const Length(25, unit: LengthUnit.percent)),
          bottomRight: const DynamicRadius.circular(
              const Length(25, unit: LengthUnit.percent)))),
  "RoundRectangleTRBL25": const RoundedRectangleShape(
      borderRadius: DynamicBorderRadius.only(
          topRight: const DynamicRadius.circular(
              const Length(25, unit: LengthUnit.percent)),
          bottomLeft: const DynamicRadius.circular(
              const Length(25, unit: LengthUnit.percent)))),
  "RoundRectangleTL50BL50BR50": const RoundedRectangleShape(
      borderRadius: DynamicBorderRadius.only(
          topLeft: const DynamicRadius.circular(
              const Length(50, unit: LengthUnit.percent)),
          bottomLeft: const DynamicRadius.circular(
              const Length(50, unit: LengthUnit.percent)),
          bottomRight: const DynamicRadius.circular(
              const Length(50, unit: LengthUnit.percent)))),
  "RoundRectangleTL50BL50TR50": const RoundedRectangleShape(
      borderRadius: DynamicBorderRadius.only(
          topLeft: const DynamicRadius.circular(
              const Length(50, unit: LengthUnit.percent)),
          bottomLeft: const DynamicRadius.circular(
              const Length(50, unit: LengthUnit.percent)),
          topRight: const DynamicRadius.circular(
              const Length(50, unit: LengthUnit.percent)))),
};

const Map<String, Shape> presetRectangleMap = {
  "RoundAll25": const RectangleShape(
      cornerStyles: RectangleCornerStyles.all(CornerStyle.rounded),
      borderRadius: DynamicBorderRadius.all(const DynamicRadius.circular(
          const Length(25, unit: LengthUnit.percent)))),
  "CutCornerAll25": const RectangleShape(
      cornerStyles: RectangleCornerStyles.all(CornerStyle.straight),
      borderRadius: DynamicBorderRadius.all(const DynamicRadius.circular(
          const Length(25, unit: LengthUnit.percent)))),
  "CutoutCornerAll25": const RectangleShape(
      cornerStyles: RectangleCornerStyles.all(CornerStyle.cutout),
      borderRadius: DynamicBorderRadius.all(const DynamicRadius.circular(
          const Length(25, unit: LengthUnit.percent)))),
  "ConcaveCornerAll25": const RectangleShape(
      cornerStyles: RectangleCornerStyles.all(CornerStyle.concave),
      borderRadius: DynamicBorderRadius.all(const DynamicRadius.circular(
          const Length(25, unit: LengthUnit.percent)))),
  "DiagonalBottomRight": const RectangleShape(
      cornerStyles:
          RectangleCornerStyles.only(bottomRight: CornerStyle.straight),
      borderRadius: DynamicBorderRadius.only(
          bottomRight: const DynamicRadius.elliptical(
              Length(100, unit: LengthUnit.percent),
              Length(25, unit: LengthUnit.percent)))),
  "DiagonalBottomLeft": const RectangleShape(
      cornerStyles:
          RectangleCornerStyles.only(bottomLeft: CornerStyle.straight),
      borderRadius: DynamicBorderRadius.only(
          bottomLeft: const DynamicRadius.elliptical(
              Length(100, unit: LengthUnit.percent),
              Length(25, unit: LengthUnit.percent)))),
  "ChevronLeft": const RectangleShape(
      cornerStyles: RectangleCornerStyles.only(
          bottomLeft: CornerStyle.straight, topLeft: CornerStyle.straight),
      borderRadius: DynamicBorderRadius.only(
          topLeft: const DynamicRadius.circular(
              Length(50, unit: LengthUnit.percent)),
          bottomLeft: const DynamicRadius.circular(
              Length(50, unit: LengthUnit.percent)))),
  "ChevronRight": const RectangleShape(
      cornerStyles: RectangleCornerStyles.only(
          bottomRight: CornerStyle.straight, topRight: CornerStyle.straight),
      borderRadius: DynamicBorderRadius.only(
          topRight: const DynamicRadius.circular(
              Length(50, unit: LengthUnit.percent)),
          bottomRight: const DynamicRadius.circular(
              Length(50, unit: LengthUnit.percent)))),
  "Diamond": const RectangleShape(
      cornerStyles: RectangleCornerStyles.all(CornerStyle.straight),
      borderRadius: DynamicBorderRadius.all(
          const DynamicRadius.circular(Length(50, unit: LengthUnit.percent)))),
  "ArcTL": const RectangleShape(
      borderRadius: DynamicBorderRadius.only(
          topLeft: const DynamicRadius.circular(
              Length(100, unit: LengthUnit.percent)))),
  "ArcBR": const RectangleShape(
      borderRadius: DynamicBorderRadius.only(
          bottomRight: const DynamicRadius.circular(
              Length(100, unit: LengthUnit.percent)))),
  "DonutTL": const RectangleShape(
      cornerStyles:
          RectangleCornerStyles.only(bottomRight: CornerStyle.concave),
      borderRadius: DynamicBorderRadius.only(
          topLeft: const DynamicRadius.circular(
              Length(100, unit: LengthUnit.percent)),
          bottomRight: const DynamicRadius.circular(
              Length(50, unit: LengthUnit.percent)))),
};

const Map<String, Shape> presetPolygonMap = {
  "Polygon3": const PolygonShape(sides: 3),
  "Polygon5": const PolygonShape(sides: 5),
  "Polygon6": const PolygonShape(sides: 6),
  "Polygon8": const PolygonShape(sides: 8),
  "Polygon12": const PolygonShape(sides: 12),
  "Polygon5Rounded": const PolygonShape(
      sides: 5, cornerRadius: Length(50, unit: LengthUnit.percent)),
  "Polygon6Rounded": const PolygonShape(
      sides: 6, cornerRadius: Length(50, unit: LengthUnit.percent)),
  "Polygon8Rounded": const PolygonShape(
      sides: 8, cornerRadius: Length(50, unit: LengthUnit.percent)),
  "Polygon6Straight": const PolygonShape(
      cornerStyle: CornerStyle.straight,
      sides: 6,
      cornerRadius: Length(50, unit: LengthUnit.percent)),
  "Polygon6Cutout": const PolygonShape(
      cornerStyle: CornerStyle.cutout,
      sides: 6,
      cornerRadius: Length(50, unit: LengthUnit.percent)),
  "Polygon6Concave": const PolygonShape(
      cornerStyle: CornerStyle.concave,
      sides: 6,
      cornerRadius: Length(50, unit: LengthUnit.percent)),
};

const Map<String, Shape> presetStarMap = {
  "Star4": const StarShape(corners: 4),
  "Star5": const StarShape(corners: 5),
  "Star6": const StarShape(corners: 6),
  "Star8": const StarShape(corners: 8),
  "Star12": const StarShape(corners: 12),
  "Star4Rounded": const StarShape(
      corners: 4,
      cornerRadius: Length(50, unit: LengthUnit.percent),
      insetRadius: Length(50, unit: LengthUnit.percent)),
  "Star6Rounded": const StarShape(
      corners: 6,
      cornerRadius: Length(30, unit: LengthUnit.percent),
      insetRadius: Length(30, unit: LengthUnit.percent)),
  "Star8Rounded": const StarShape(
      corners: 8,
      cornerRadius: Length(10, unit: LengthUnit.percent),
      insetRadius: Length(10, unit: LengthUnit.percent)),
};

const Map<String, Shape> presetTriangleMap = {
  "Triangle": const TriangleShape(),
  "TriangleBottom": const TriangleShape(
      point1: const DynamicOffset(const Length(50, unit: LengthUnit.percent),
          const Length(0, unit: LengthUnit.percent)),
      point2: const DynamicOffset(const Length(100, unit: LengthUnit.percent),
          const Length(100, unit: LengthUnit.percent)),
      point3: const DynamicOffset(const Length(0, unit: LengthUnit.percent),
          const Length(100, unit: LengthUnit.percent))),
  "TriangleLeft": const TriangleShape(
      point1: const DynamicOffset(const Length(0, unit: LengthUnit.percent),
          const Length(0, unit: LengthUnit.percent)),
      point2: const DynamicOffset(const Length(100, unit: LengthUnit.percent),
          const Length(0, unit: LengthUnit.percent)),
      point3: const DynamicOffset(const Length(0, unit: LengthUnit.percent),
          const Length(100, unit: LengthUnit.percent))),
  "TriangleRight": const TriangleShape(
      point1: const DynamicOffset(const Length(0, unit: LengthUnit.percent),
          const Length(0, unit: LengthUnit.percent)),
      point2: const DynamicOffset(const Length(100, unit: LengthUnit.percent),
          const Length(0, unit: LengthUnit.percent)),
      point3: const DynamicOffset(const Length(100, unit: LengthUnit.percent),
          const Length(100, unit: LengthUnit.percent))),
};

const Map<String, Shape> presetOtherMap = {
  "BubbleTopLeft": const BubbleShape(
      corner: ShapeCorner.topLeft,
      borderRadius: Length(20, unit: LengthUnit.percent)),
  "BubbleBottomRight": const BubbleShape(
      corner: ShapeCorner.bottomRight,
      borderRadius: Length(20, unit: LengthUnit.percent)),
  "BubbleLeftTop": const BubbleShape(
      corner: ShapeCorner.leftTop,
      borderRadius: Length(20, unit: LengthUnit.percent)),
  "BubbleRightBottom": const BubbleShape(
      corner: ShapeCorner.rightBottom,
      borderRadius: Length(20, unit: LengthUnit.percent)),
  "ArcTop": const ArcShape(
      side: ShapeSide.top, arcHeight: Length(20, unit: LengthUnit.percent)),
  "ArcBottom": const ArcShape(
      side: ShapeSide.bottom, arcHeight: Length(20, unit: LengthUnit.percent)),
  "ArrowRight": const ArrowShape(),
  "ArrowLeft": const ArrowShape(side: ShapeSide.left),
  "Trapezoid": const TrapezoidShape(),
  "TrapezoidBottom": const TrapezoidShape(side: ShapeSide.top),
};
