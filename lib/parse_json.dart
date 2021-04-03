import 'package:flutter/material.dart';
import 'package:flutter_class_parser/parse_json.dart';
import 'package:morphable_shape/morphable_shape.dart';

CornerStyle? parseCornerStyle(String? string) {
  if (string == null) return null;
  switch (string) {
    case "rounded":
      return CornerStyle.rounded;
    case "concave":
      return CornerStyle.concave;
    case "straight":
      return CornerStyle.straight;
    case "cutout":
      return CornerStyle.cutout;
  }
  return null;
}

ShapeSide? parseShapeSide(String? string) {
  if (string == null) return null;
  switch (string) {
    case "top":
      return ShapeSide.top;
    case "bottom":
      return ShapeSide.bottom;
    case "left":
      return ShapeSide.left;
    case "right":
      return ShapeSide.right;
  }
  return null;
}

ShapeCorner? parseShapeCorner(String? string) {
  if (string == null) return null;
  switch (string) {
    case "topLeft":
      return ShapeCorner.topLeft;
    case "topRight":
      return ShapeCorner.topRight;
    case "bottomLeft":
      return ShapeCorner.bottomLeft;
    case "bottomRight":
      return ShapeCorner.bottomRight;
    case "leftTop":
      return ShapeCorner.leftTop;
    case "leftBottom":
      return ShapeCorner.leftBottom;
    case "rightTop":
      return ShapeCorner.rightTop;
    case "rightBottom":
      return ShapeCorner.rightBottom;
  }
  return null;
}

DynamicBorderSide? parseDynamicBorderSide(Map<String, dynamic>? map) {
  if (map == null) return null;
  return DynamicBorderSide.fromJson(map);
}

RectangleBorders? parseRectangleBorderSide(Map<String, dynamic>? map) {
  if (map == null) return null;
  return RectangleBorders.fromJson(map);
}

RectangleCornerStyles? parseRectangleCornerStyle(Map<String, dynamic>? map) {
  if (map == null) return null;
  return RectangleCornerStyles.fromJson(map);
}

DynamicRadius? parseDynamicRadius(Map<String, dynamic>? map) {
  if (map == null) return null;
  return DynamicRadius.fromJson(map);
}

DynamicBorderRadius? parseDynamicBorderRadius(Map<String, dynamic>? map) {
  if (map == null) return null;
  return DynamicBorderRadius.fromJson(map);
}

DynamicOffset? parseDynamicOffset(Map<String, dynamic>? map) {
  if (map == null) return null;
  Dimension dx = parseDimension(map['dx']) ?? Length(0);
  Dimension dy = parseDimension(map['dy']) ?? Length(0);
  return DynamicOffset(dx, dy);
}

DynamicPath? parseDynamicPath(Map<String, dynamic>? map) {
  if (map == null) return null;
  Size? size = parseSize(map["size"]);
  List<DynamicNode>? nodes =
      (map["nodes"] as List?)?.map((e) => DynamicNode.fromJson(e)).toList();
  if (size == null || nodes == null) {
    return null;
  } else {
    return DynamicPath(size: size, nodes: nodes);
  }
}

ShapeShadow? parseShapeShadow(Map<String, dynamic>? map) {
  if (map == null) return null;
  Color color = parseColor(map["color"]) ?? Colors.transparent;
  Offset offset = parseOffset(map["offset"]) ?? Offset.zero;
  double blurRadius = (map["blurRadius"] ?? 0.0).toDouble();
  double spreadRadius = (map["spreadRadius"] ?? 0.0).toDouble();
  Gradient? gradient = parseGradient(map["gradient"]);

  return ShapeShadow(
      color: color,
      offset: offset,
      blurRadius: blurRadius,
      spreadRadius: spreadRadius,
      gradient: gradient);
}

MorphableShapeBorder? parseMorphableShapeBorder(Map<String, dynamic>? map) {
  if (map == null || map["type"] == null) return null;

  String shapeName = map["type"];
  switch (shapeName) {
    case "Arc":
      return ArcShapeBorder.fromJson(map);
    case "Arrow":
      return ArrowShapeBorder.fromJson(map);
    case "Bubble":
      return BubbleShapeBorder.fromJson(map);
    case "Circle":
      return CircleShapeBorder.fromJson(map);
    case "Polygon":
      return PolygonShapeBorder.fromJson(map);
    case "Rectangle":
      return RectangleShapeBorder.fromJson(map);
    case "RoundedRectangle":
      return RoundedRectangleShapeBorder.fromJson(map);
    case "Star":
      return StarShapeBorder.fromJson(map);
    case "Trapezoid":
      return TrapezoidShapeBorder.fromJson(map);
    case "Triangle":
      return TriangleShapeBorder.fromJson(map);
    case "Path":
      return PathShapeBorder.fromJson(map);
    default:
      return null;
  }
}
