import 'package:flutter/material.dart';

const List<Widget> howToTextWidgets = [
  Text("Welcome to Flutter shape editor!", style: TextStyle(fontSize: 20)),
  Divider(),
  Text("Double click to enable/disable shape editing."),
  Divider(),
  Text(
      "Resize the shape by dragging the four handles when shape editing is disabled."),
  Divider(),
  Text(
      '''Drag the various handles on the shape to change shape properties (or edit their values directly in the side panel) when in shape editing mode.'''),
  Divider(),
  Text(
      "Click the To Bezier button to convert the shape to a freeform path shape."),
  Divider(),
  Text("Click the shape icon button to choose other shapes."),
  Divider(),
  Text(
      "Click the code icon button to see the JSON representation of the current shape."),
  Divider(),
  Text(
      "Click the eye icon button at the top left corner to see the current shape morph between other predefined shapes."),
  Divider(),
  Text(
      "If the morphing process is lagging, try turn off the control points. Painting hundreds of small circles is heavy for the raster thread"),
];
