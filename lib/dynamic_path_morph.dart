import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';
import 'dart:math';
import 'morphable_shape_border.dart';

enum MorphMethod {
  auto,
  weighted,
  unweighted,
}

///Data class associated with a MorphableShapeTween
///supplyCounts are used to make two paths becoming equal length, they are
///initialized when the morphing first starts and does not change afterwards
///even with the bounding box changing size.
class SampledDynamicPathData {
  DynamicPath path1;
  DynamicPath path2;
  Rect boundingBox;

  MorphMethod method;
  List<int>? supplyCounts1;
  List<int>? supplyCounts2;
  int? minimumShift;

  SampledDynamicPathData(
      {required this.path1,
      required this.path2,
      required this.boundingBox,
      this.method = MorphMethod.auto});
}

///Class for controlling the morphing of two shapes
///what it does basically is try to make the two shape having the
///same number of control points.
///
///If both shape have only a few control points (smaller than maxControlPoints),
///the more elegant way to morph should be making as little sides to bend as possible
///(morphing a rectangle to a triangle, we would want only one of the sides of the
///triangle to bend into two sides of the rectangle).
///The total control points in this case should be max(points1, points2). And we use a Monte Carlo
///(with a maxTrial) to determine which sides to put the extra control points (on the shape that
///has less control points) will make the total amount of travel the control points need to morph
///minimal.
///
/// If one of the shape has many control points, the Monte Carlo is not guaranteed to find the optimal
/// solution in time. In this case, we set the total control points to be lcm(points1, points2) and then
/// we can supply equal number of extra control points to each side of each shape. The morphing may
/// not be the best looking, but since at least one of the shapes is pretty complicated, this method saves
/// time and gives generally acceptable results (I don't think there is a good way to morph a rounded
/// rectangle into a 30 corner star without some weird shape in between).

class DynamicPathMorph {
  static void samplePathsFromShape(
    SampledDynamicPathData data,
    Shape shape1,
    Shape shape2,
    Rect rect, {
    double maxTrial = 100,
    int maxControlPoints = 16,
  }) {
    data.boundingBox = rect;
    DynamicPath path1 = shape1.generateDynamicPath(rect);
    DynamicPath path2 = shape2.generateDynamicPath(rect);

    sampleDynamicPaths(data, path1, path2,
        maxTrial: maxTrial, maxControlPoints: maxControlPoints);
  }

  static void sampleDynamicPaths(
    SampledDynamicPathData data,
    DynamicPath path1,
    DynamicPath path2, {
    double maxTrial = 100,
    int maxControlPoints = 16,
  }) {
    if (data.supplyCounts1 != null && data.supplyCounts2 != null) {
      data.path1 = supplyPoints(path1, data.supplyCounts1!);
      data.path2 = supplyPoints(path2, data.supplyCounts2!);
    } else {
      int totalPoints = max(path1.nodes.length, path2.nodes.length);
      if (data.method == MorphMethod.weighted ||
          (data.method == MorphMethod.auto &&
              totalPoints <= maxControlPoints)) {
        ///we try adding points multiple times and choose the one that need the least offset to morph
        ///from one shape to another. Because the function to choose the least weighted edge is random,
        ///this is a Monte Carlo method. Because the total points is small, it should be fine to try
        ///multiple times (maxTrial) here

        double tempMinOffset = double.infinity;
        DynamicPath optimalPath1 =
                DynamicPath(size: data.boundingBox.size, nodes: []),
            optimalPath2 = DynamicPath(size: data.boundingBox.size, nodes: []);
        List<int> tempCounts1 = [], tempCounts2 = [];
        List<int> optimalCount1 = tempCounts1, optimalCount2 = tempCounts2;
        DynamicPath tempPath1, tempPath2;
        for (int trial = 0; trial < maxTrial; trial++) {
          tempCounts1 = sampleSupplyCounts(path1, totalPoints);
          tempCounts2 = sampleSupplyCounts(path2, totalPoints);
          tempPath1 = supplyPoints(path1, tempCounts1);
          tempPath2 = supplyPoints(path2, tempCounts2);
          double tempOffset = computeMinimumOffset(
              tempPath1.nodes.map((e) => e.position).toList(),
              tempPath2.nodes.map((e) => e.position).toList());
          if (tempOffset < tempMinOffset) {
            tempMinOffset = tempOffset;
            optimalPath1 = tempPath1;
            optimalPath2 = tempPath2;
            optimalCount1 = tempCounts1;
            optimalCount2 = tempCounts2;
          }
        }
        data.path1 = optimalPath1;
        data.path2 = optimalPath2;
        data.supplyCounts1 = optimalCount1;
        data.supplyCounts2 = optimalCount2;
      } else {
        totalPoints = lcm(path1.nodes.length, path2.nodes.length);
        if (totalPoints < maxControlPoints) {
          totalPoints = path1.nodes.length * path2.nodes.length;
        }
        if (totalPoints > 120) {
          totalPoints = max(120, max(path1.nodes.length, path2.nodes.length));
        }
        data.supplyCounts1 =
            sampleSupplyCounts(path1, totalPoints, weightBased: false);
        data.supplyCounts2 =
            sampleSupplyCounts(path2, totalPoints, weightBased: false);
        data.path1 = supplyPoints(path1, data.supplyCounts1!);
        data.path2 = supplyPoints(path2, data.supplyCounts2!);
      }
    }

    int shift;
    if (data.minimumShift == null) {
      shift = computeMinimumOffsetIndex(
          data.path1.nodes.map((e) => e.position).toList(),
          data.path2.nodes.map((e) => e.position).toList());
      data.minimumShift = shift;
    } else {
      shift = data.minimumShift!;
    }
    data.path1.nodes = rotateList(data.path1.nodes, shift) as List<DynamicNode>;
  }

  static int computeMinimumOffsetIndex(
      List<Offset> points1, List<Offset> points2) {
    int minimumShift = 0;
    double minimumOffset = double.infinity;
    assert(points1.length == points2.length);
    int length = points1.length;
    for (int shift = 0; shift < length; shift++) {
      double currentOffset = 0.0;
      for (int i = 0; i < length; i++) {
        currentOffset += (points1[(i + shift) % length] - points2[i]).distance;
      }
      if (currentOffset <= minimumOffset) {
        minimumOffset = currentOffset;
        minimumShift = shift;
      }
    }
    return minimumShift;
  }

  static double computeMinimumOffset(
      List<Offset> points1, List<Offset> points2) {
    double minimumOffset = double.infinity;
    assert(points1.length == points2.length);
    int length = points1.length;
    for (int shift = 0; shift < length; shift++) {
      double currentOffset = 0.0;
      for (int i = 0; i < length; i += 1) {
        currentOffset +=
            (points1[(i + shift) % length] - points2[i]).distanceSquared;
      }
      if (currentOffset <= minimumOffset) {
        minimumOffset = currentOffset;
      }
    }
    return minimumOffset;
  }

  static DynamicPath lerpPath(double t, SampledDynamicPathData data) {
    DynamicPath rst = DynamicPath(size: data.boundingBox.size, nodes: []);
    for (var i = 0; i < data.path1.nodes.length; i++) {
      var start = data.path1.getNodeWithControlPoints(i);
      var end = data.path2.getNodeWithControlPoints(i);
      var tween1 = Tween<Offset>(begin: start.position, end: end.position);
      Offset offset1 = tween1.transform(t);
      var tween2 = Tween<Offset>(begin: start.prev, end: end.prev);
      Offset offset2 = tween2.transform(t);
      var tween3 = Tween<Offset>(begin: start.next, end: end.next);
      Offset offset3 = tween3.transform(t);
      rst.nodes
          .add(DynamicNode(position: offset1, prev: offset2, next: offset3));
    }
    return rst;
  }
}

num total(List<num> list) {
  num total = 0;
  list.forEach((element) {
    total += element;
  });
  return total;
}

List<Object> rotateList(List<Object> list, int v) {
  if (list.isEmpty) return list;
  var i = v % list.length;
  return list.sublist(i)..addAll(list.sublist(0, i));
}

bool haveEqualLength(DynamicPath path) {
  int length = path.nodes.length;
  List<double> weights = [];
  for (int i = 0; i < length; i++) {
    weights.add(path.getPathLengthAt(i));
  }
  if (weights.toSet().length != length) {
    return true;
  }
  return false;
}

int randomChoose(List<num> list) {
  int index = 0;
  num totalWeight = total(list);
  var rng = new Random();
  double randomDraw = rng.nextDouble() * totalWeight;
  double currentSum = 0;
  for (int i = 0; i < list.length; i++) {
    if (randomDraw <= currentSum) return i;
    currentSum += list[i];
  }
  return index;
}

int nonzeroMinWeighted(List<num> list, List<double> weights) {
  int index = 0;
  num currentMin = double.infinity;
  for (int i = 0; i < list.length; i++) {
    bool replace = false;
    if (list[i] > 0) {
      if (list[i] < currentMin ||
          (list[i] == currentMin && weights[i] < weights[index])) {
        replace = true;
      } else if (list[i] == currentMin && weights[i] == weights[index]) {
        ///randomly choose between equal weight and equal value indices,
        ///key to using Monte Carlo to find the optimal control points in function supplyPoints
        var rng = new Random();
        replace = rng.nextInt(2).isEven;
      }
    }
    if (replace) {
      index = i;
      currentMin = list[i];
    }
  }
  return index;
}

List<int> sampleSupplyCounts(DynamicPath path, int totalPointsCount,
    {bool weightBased = true}) {
  int length = path.nodes.length;

  int newPointsCount = totalPointsCount - length;
  if (newPointsCount == 0) return List.generate(length, (index) => 0);

  List<double> weights = [];
  double totalWeights = 0.0;
  for (int i = 0; i < length; i++) {
    if (weightBased) {
      weights.add(path.getPathLengthAt(i));
    } else {
      weights.add(1.0);
    }
  }
  for (int i = 0; i < length; i++) {
    totalWeights += weights[i];
  }

  List<int> counts;

  double scale = totalWeights / newPointsCount;
  counts = weights.map((w) => (w / scale).ceil()).toList();

  while (total(counts) > newPointsCount) {
    int minIndex = randomChoose(weights);
    if (counts[minIndex] > 0) {
      counts[minIndex] -= 1;
    }
  }

  return counts;
}

DynamicPath supplyPoints(DynamicPath path, List<int> counts) {
  int length = path.nodes.length;

  DynamicPath newPath = DynamicPath(size: path.size, nodes: []);

  Offset? updatedPrev;

  for (int i = 0; i < length; i++) {
    newPath.nodes.add(DynamicNode(
        position: path.nodes[i].position,
        prev: path.nodes[i].prev,
        next: path.nodes[i].next));
    if (updatedPrev != null) {
      newPath.nodes.last.prev = updatedPrev;
    }
    updatedPrev = null;
    int count = counts[i];
    if (count >= 1) {
      int nextIndex = (i + 1) % length;
      List<Offset> controlPoints = path.getNextPathControlPointsAt(i);
      if (controlPoints.length == 2) {
        Offset diff = (path.nodes[nextIndex].position - path.nodes[i].position);
        for (int j = 1; j < count + 1; j++) {
          newPath.nodes.add(DynamicNode(
              position: path.nodes[i].position +
                  diff * j.roundToDouble() / (count.roundToDouble() + 1)));
        }
      } else {
        for (int j = count; j > 0; j--) {
          List<Offset> splittedControlPoints =
              DynamicPath.splitCubicAt(1 / (j + 1), controlPoints);
          newPath.nodes.last.next = splittedControlPoints[1];
          newPath.nodes.add(DynamicNode(
              position: splittedControlPoints[3],
              prev: splittedControlPoints[2],
              next: splittedControlPoints[4]));
          controlPoints[0] = splittedControlPoints[3];
          controlPoints[1] = splittedControlPoints[4];
          controlPoints[2] = splittedControlPoints[5];
          updatedPrev = splittedControlPoints[5];
        }
      }
    }
  }
  if (updatedPrev != null) {
    newPath.nodes.first.prev = updatedPrev;
  }

  return newPath;
}
