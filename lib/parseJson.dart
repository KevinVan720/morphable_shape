import 'package:flutter/material.dart';
import 'package:flutter_class_parser/parseJson.dart';

import 'MorphableShapeBorder.dart';

Shape? parseShape(Map<String, dynamic>? map) {
  if (map == null || map["name"] == null) return null;
/*
  String shapeName = map["name"];
  switch (shapeName) {
    case "ArcShape":
      return ArcShape.fromJson(map);
    case "BubbleShape":
      return BubbleShape.fromJson(map);
    case "CircleShape":
      return CircleShape.fromJson(map);
    case "DiagonalShape":
      return DiagonalShape.fromJson(map);
    case "CutCornerShape":
      return CutCornerShape.fromJson(map);
    case "DiamondShape":
      return DiamondShape.fromJson(map);
    case "PolygonShape":
      return PolygonShape.fromJson(map);
    case "RoundRectShape":
      return RoundRectShape.fromJson(map);
    case "StarShape":
      return StarShape.fromJson(map);
    case "TrapezoidShape":
      return TrapezoidShape.fromJson(map);
    case "TriangleShape":
      return TriangleShape.fromJson(map);
    default:
      return RoundRectShape();
  }

 */
}

MorphableShapeBorder? parseMorphableShapeBorder(Map<String, dynamic>? map) {
  if (map == null) return null;
  return MorphableShapeBorder(
    shape: parseShape(map["shape"]) ??
        RoundRectShape(borderRadius: BorderRadius.zero),
    borderWidth: map["borderWidth"] ?? 0.0,
    borderColor: parseColor(map["borderColor"]) ?? Colors.white,
  );
}
