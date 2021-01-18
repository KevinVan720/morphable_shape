import 'package:flutter/material.dart';

typedef ShapeBuilder = Path Function(Rect rect);
/*
class CustomShape extends Shape {
  final ShapeBuilder builder;

  const CustomShape({this.builder});

  Path generatePath({double scale=1, Rect rect= const Rect.fromLTRB(0.0, 0.0, 0.0, 0.0)}) {
    return this.builder(rect);
  }
}

 */

