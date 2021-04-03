import 'package:flutter/material.dart';
import 'package:morphable_shape/morphable_shape.dart';

///border paths for a FilledBorderShape
///has an outer path, an inner path and
///a list of fill colors.
///Returns a list of closed paths constructed
///from each pair of points on the outer and inner
///path and the fill color
class BorderPaths {
  static double tolerancePercent = 0.001;

  DynamicPath outer;
  DynamicPath inner;
  List<Color> fillColors;
  List<Gradient?> fillGradients;

  BorderPaths(
      {required this.outer,
      required this.inner,
      required this.fillColors,
      required this.fillGradients});

  void removeOverlappingPaths() {
    assert(outer.nodes.length == inner.nodes.length);
    assert(outer.nodes.length == fillColors.length);
    assert(outer.nodes.length == fillGradients.length);

    if (outer.nodes.isNotEmpty) {
      double pointGroupWeight = 1;
      List<DynamicNode> outerNodes = [outer.nodes[0]];
      List<DynamicNode> innerNodes = [inner.nodes[0]];
      List<Color> newColors = [fillColors[0]];
      List<Gradient?> newGradients = [fillGradients[0]];
      for (int i = 1; i < outer.nodes.length; i++) {
        if ((outer.nodes[i].position - outerNodes.last.position).distance <
                tolerancePercent * outer.size.shortestSide &&
            (inner.nodes[i].position - innerNodes.last.position).distance <
                tolerancePercent * outer.size.shortestSide) {
          outerNodes.last.next = outer.nodes[i].next;
          outerNodes.last.position +=
              (outer.nodes[i].position - outerNodes.last.position) /
                  (pointGroupWeight + 1);
          innerNodes.last.next = inner.nodes[i].next;
          innerNodes.last.position +=
              (inner.nodes[i].position - innerNodes.last.position) /
                  (pointGroupWeight + 1);
          newColors.last = fillColors[i];
          newGradients.last = fillGradients[i];

          pointGroupWeight++;
        } else if (i == outer.nodes.length - 1 &&
            (outer.nodes[i].position - outerNodes.first.position).distance <
                tolerancePercent * outer.size.shortestSide &&
            (inner.nodes[i].position - innerNodes.first.position).distance <
                tolerancePercent * outer.size.shortestSide) {
          outerNodes.first.prev = outer.nodes[i].prev;
          outerNodes.first.position +=
              (outer.nodes[i].position - outerNodes.first.position) /
                  (pointGroupWeight + 1);
          innerNodes.first.prev = inner.nodes[i].prev;
          innerNodes.first.position +=
              (inner.nodes[i].position - innerNodes.first.position) /
                  (pointGroupWeight + 1);
          newColors.first = fillColors[i];
          newGradients.first = fillGradients[i];
        } else {
          pointGroupWeight = 1;
          outerNodes.add(outer.nodes[i]);
          innerNodes.add(inner.nodes[i]);
          newColors.add(fillColors[i]);
          newGradients.add(fillGradients[i]);
        }
      }
      outer.nodes = outerNodes;
      inner.nodes = innerNodes;

      fillColors = newColors;
      fillGradients = newGradients;
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
