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
///supplyCounts are used to make two dynamic paths becoming equal length, they are
///initialized when the morphing first starts and does not change afterwards
///even if the bounding box changes size.
class SampledDynamicPathData {
  Shape begin;
  Shape end;

  late DynamicPath path1;
  late DynamicPath path2;
  Rect boundingBox;

  MorphMethod method;
  List<int>? supplyCounts1;
  List<int>? supplyCounts2;
  int? minimumShift;

  SampledDynamicPathData(
      {required this.begin,
      required this.end,
      //required this.path1,
      //required this.path2,
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
    SampledDynamicPathData data, {
    int maxTrial = 100,
    int minControlPoints = 16,
    int maxControlPoints = 120,
  }) {
    DynamicPath path1 = data.begin.generateDynamicPath(data.boundingBox);
    DynamicPath path2 = data.end.generateDynamicPath(data.boundingBox);

    sampleDynamicPaths(data, path1, path2,
        maxTrial: maxTrial,
        minControlPoints: minControlPoints,
        maxControlPoints: maxControlPoints);
  }

  static void sampleDynamicPaths(
    SampledDynamicPathData data,
    DynamicPath path1,
    DynamicPath path2, {
    required int maxTrial,
    required int minControlPoints,
    required int maxControlPoints,
  }) {
    ///the supply points have been calculated
    if (data.supplyCounts1 != null &&
        data.supplyCounts2 != null &&
        path1.nodes.length == data.supplyCounts1!.length &&
        path2.nodes.length == data.supplyCounts2!.length) {
      data.path1 = supplyPoints(path1, data.supplyCounts1!);
      data.path2 = supplyPoints(path2, data.supplyCounts2!);
      data.path1.nodes =
          rotateList(data.path1.nodes, data.minimumShift!) as List<DynamicNode>;
    } else {
      List rst = [];
      if (data.method == MorphMethod.weighted) {
        ///we try adding points multiple times and choose the one that need the least offset to morph
        ///from one shape to another. Because the function to choose the least weighted edge is random,
        ///this is a Monte Carlo method. Because the total points is small, it should be fine to try
        ///multiple times (maxTrial) here
        rst = weightedSampling(path1, path2, maxTrial: maxTrial);
      } else if (data.method == MorphMethod.unweighted) {
        ///use the unweighted method, spread the extra points needed evenly on each curve
        rst = unweightedSampling(path1, path2,
            minControlPoints: minControlPoints,
            maxControlPoints: maxControlPoints);
      } else {
        List rst1 = weightedSampling(path1, path2, maxTrial: maxTrial);
        List rst2 = unweightedSampling(path1, path2,
            minControlPoints: minControlPoints,
            maxControlPoints: maxControlPoints);
        rst = rst1[5] > rst2[5] ? rst2 : rst1;
      }
      data.path1 = rst[2];
      data.path2 = rst[3];
      data.supplyCounts1 = rst[0];
      data.supplyCounts2 = rst[1];
      data.minimumShift = rst[4];
    }
  }

  static List<dynamic> weightedSampling(DynamicPath path1, DynamicPath path2,
      {required int maxTrial}) {
    int totalPoints = max(path1.nodes.length, path2.nodes.length);

    double tempMinOffset = double.infinity;
    List<int> tempCounts1, tempCounts2 = [];
    DynamicPath tempPath1, tempPath2;

    DynamicPath optimalPath1 = DynamicPath(size: Size.zero, nodes: []),
        optimalPath2 = DynamicPath(size: Size.zero, nodes: []);
    List<int> optimalCount1 = [], optimalCount2 = [];

    ///Monte Carlo to find the optimal way to distribute the extra control points
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
    int shift = computeMinimumOffsetIndex(
        optimalPath1.nodes.map((e) => e.position).toList(),
        optimalPath2.nodes.map((e) => e.position).toList());

    optimalPath1.nodes =
        rotateList(optimalPath1.nodes, shift) as List<DynamicNode>;

    double centerShift = (centerOfMass(
                optimalPath1.nodes.map((e) => e.position).toList()) -
            centerOfMass(optimalPath2.nodes.map((e) => e.position).toList()))
        .distance
        .clamp(1e-10, double.infinity);
    double angleShift = computeTotalRotation(
            optimalPath1.nodes.map((e) => e.position).toList(),
            optimalPath2.nodes.map((e) => e.position).toList())
        .abs()
        .clamp(1e-10, double.infinity);

    //print("weightd "+centerShift.toString()+", "+angleShift.toString());

    return [
      optimalCount1,
      optimalCount2,
      optimalPath1,
      optimalPath2,
      shift,
      centerShift * optimalPath1.nodes.length * angleShift,
    ];
  }

  static List<dynamic> unweightedSampling(
    DynamicPath path1,
    DynamicPath path2, {
    required int minControlPoints,
    required int maxControlPoints,
  }) {
    int totalPoints = lcm(path1.nodes.length, path2.nodes.length);
    if (totalPoints < minControlPoints) {
      totalPoints = path1.nodes.length * path2.nodes.length;
    }

    ///cap at maxControlPoints, but it is possible that the minimum required points
    ///(max(points1, points2)) is larger than maxControlPoints.
    if (totalPoints > maxControlPoints) {
      totalPoints =
          max(maxControlPoints, max(path1.nodes.length, path2.nodes.length));
    }
    List<int> optimalCount1 =
        sampleSupplyCounts(path1, totalPoints, weightBased: false);
    List<int> optimalCount2 =
        sampleSupplyCounts(path2, totalPoints, weightBased: false);
    DynamicPath optimalPath1 = supplyPoints(path1, optimalCount1);
    DynamicPath optimalPath2 = supplyPoints(path2, optimalCount2);
    int shift = computeMinimumOffsetIndex(
        optimalPath1.nodes.map((e) => e.position).toList(),
        optimalPath2.nodes.map((e) => e.position).toList());

    optimalPath1.nodes =
        rotateList(optimalPath1.nodes, shift) as List<DynamicNode>;

    double centerShift = (centerOfMass(
                optimalPath1.nodes.map((e) => e.position).toList()) -
            centerOfMass(optimalPath2.nodes.map((e) => e.position).toList()))
        .distance
        .clamp(1e-10, double.infinity);
    double angleShift = computeTotalRotation(
            optimalPath1.nodes.map((e) => e.position).toList(),
            optimalPath2.nodes.map((e) => e.position).toList())
        .abs()
        .clamp(1e-10, double.infinity);

    return [
      optimalCount1,
      optimalCount2,
      optimalPath1,
      optimalPath2,
      shift,
      centerShift * optimalPath1.nodes.length * angleShift,
    ];
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

  static Offset centerOfMass(List<Offset> points) {
    int length = points.length;
    Offset rst = Offset.zero;
    for (int i = 0; i < length; i += 1) {
      rst += points[i];
    }
    return rst / length.toDouble();
  }

  static double computeTotalOffset(List<Offset> points1, List<Offset> points2) {
    assert(points1.length == points2.length);
    int length = points1.length;
    double currentOffset = 0.0;
    for (int i = 0; i < length; i += 1) {
      currentOffset += (points1[i] - points2[i]).distance;
    }
    return currentOffset;
  }

  static double computeTotalRotation(
      List<Offset> points1, List<Offset> points2) {
    assert(points1.length == points2.length);
    int length = points1.length;
    double currentAngle = 0.0;
    Offset center1 = centerOfMass(points1), center2 = centerOfMass(points2);
    for (int i = 0; i < length; i += 1) {
      double diff =
          (points1[i] - center1).direction - (points2[i] - center2).direction;
      if (diff < -pi) diff += 2 * pi;
      if (diff > pi) diff -= 2 * pi;
      currentAngle += diff;
    }
    return currentAngle;
  }

  static double computeMinimumOffset(
      List<Offset> points1, List<Offset> points2) {
    double minimumOffset = double.infinity;
    assert(points1.length == points2.length);
    int length = points1.length;
    for (int shift = 0; shift < length; shift++) {
      double currentOffset = 0.0;
      for (int i = 0; i < length; i += 1) {
        currentOffset += (points1[(i + shift) % length] - points2[i]).distance;
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
