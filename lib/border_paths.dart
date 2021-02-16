import 'package:flutter/material.dart';
import 'morphable_shape.dart';

class BorderPaths {
  static double tolerancePercent = 0.01;

  DynamicPath outer;
  DynamicPath inner;
  List<Color> fillColors;

  BorderPaths(
      {required this.outer, required this.inner, required this.fillColors});

  void removeOverlappingPaths() {

    assert(outer.nodes.length == inner.nodes.length);
    if (outer.nodes.isNotEmpty) {
      List<DynamicNode> outerNodes = [outer.nodes[0]];
      List<DynamicNode> innerNodes = [inner.nodes[0]];
      List<Color> newColors = [fillColors[0]];
      for (int i = 0; i < outer.nodes.length; i++) {
        if ((outer.nodes[i].position - outerNodes.last.position).distance <
            tolerancePercent*outer.size.shortestSide &&
            (inner.nodes[i].position - innerNodes.last.position).distance <
                tolerancePercent*outer.size.shortestSide) {
          outerNodes.last.next = outer.nodes[i].next;
          innerNodes.last.next = inner.nodes[i].next;
          newColors.last = fillColors[i];
        } else if (i == outer.nodes.length - 1 &&
            (outer.nodes[i].position - outerNodes.first.position).distance <
                tolerancePercent*outer.size.shortestSide &&
            (inner.nodes[i].position - innerNodes.first.position).distance <
                tolerancePercent*outer.size.shortestSide) {
          outerNodes.first.prev = outer.nodes[i].prev;
          innerNodes.first.prev = inner.nodes[i].prev;
          newColors.first = fillColors[i];
        } else {
          outerNodes.add(outer.nodes[i]);
          innerNodes.add(inner.nodes[i]);
          newColors.add(fillColors[i]);
        }
      }
      outer.nodes = outerNodes;
      inner.nodes = innerNodes;

      fillColors = newColors;
    }
  }

  List<Path> generateBorderPaths(Rect rect) {
    int pathLength = outer.nodes.length;
    List<Path> rst = [];

    for (int i = 0; i < pathLength; i++) {
      DynamicNode nextNode = outer.nodes[(i + 1) % pathLength];
      DynamicPath borderPath = DynamicPath(size: rect.size, nodes: []);
      borderPath.nodes.add(DynamicNode(
          position: outer.nodes[i].position, next: outer.nodes[i].next));
      borderPath.nodes
          .add(DynamicNode(position: nextNode.position, prev: nextNode.prev));
      DynamicNode nextInnerNode = inner.nodes[(i + 1) % pathLength];
      borderPath.nodes.add(DynamicNode(
          position: nextInnerNode.position, next: nextInnerNode.prev));
      borderPath.nodes.add(DynamicNode(
          position: inner.nodes[i % pathLength].position,
          prev: inner.nodes[i % pathLength].next));
      rst.add(borderPath.getPath(rect.size));
    }

    return rst;
  }
}