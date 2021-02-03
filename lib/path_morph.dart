import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';
import 'dart:math';
import 'morphable_shape_border.dart';

///Data class that records the start, end and intermediate shape used for shape morphing
/// endIndices is used for multi contour shapes, which is not considered in the current version
class SampledPathData {
  List<Offset> points1;
  List<Offset> points2;
  List<int> endIndices;
  List<Offset> shiftedPoints;
  late Rect boundingBox;

  SampledPathData(
      {required this.points1,
      required this.points2,
      required this.shiftedPoints,
      required this.endIndices,
      required this.boundingBox});
}

/// This class has all the methods you need to create your morph animations.
class PathMorph {
  static void samplePathsFromShape(
    SampledPathData data,
    Shape shape1,
    Shape shape2,
    Rect rect, {
    double precision = 0.001,
    double maxTrial = 200,
    int maxControlPoints = 16,
  }) {
    data.boundingBox = rect;
    data.points2.clear();
    data.points1.clear();
    data.shiftedPoints.clear();
    data.endIndices.clear();

    Path path1 = shape1.generatePath(rect: rect);
    Path path2 = shape2.generatePath(rect: rect);

    samplePaths(data, path1, path2,
        precision: precision,
        maxTrial: maxTrial,
        maxControlPoints: maxControlPoints);
    //return data;
  }

  static void samplePaths(
    SampledPathData data,
    Path path1,
    Path path2, {
    double precision = 0.001,
    double maxTrial = 100,
    int maxControlPoints = 12,
  }) {
    ///first try to sample the key control points needed to paint the path
    ///by walking through the path using the pathMetric class and look at the tangent angles
    ///which means all straight lines should only be sampled at its beginning and end
    ///curved paths are sampled according to the precision
    data.points1 = controlPointPathWalker(path1, precision: precision);
    data.points2 = controlPointPathWalker(path2, precision: precision);

    ///used to record the end of each contour, but we only consider one shape(contour) now
    data.endIndices.add(0);

    ///the number of control points we need to morph between two shapes
    ///we need the two point sets to have the same number of points to morph
    int totalPoints = max(data.points1.length, data.points2.length);

    ///if the total points needed is small, its very likely that both shapes have no curves in them
    ///and have few edges. Then the best way to morph is to use as few as possible control points.
    ///Then the problem is to add the extra points needed to the path that has fewer points.
    ///The criteria chosen here is just distribute the points based on the length of each edge.
    if (totalPoints < maxControlPoints) {
      ///if the shorter length shape has no equal length edge, then there is a unique way to add points to it
      if ((data.points2.length == totalPoints &&
              haveEqualLength(data.points1) == false) ||
          (data.points1.length == totalPoints &&
              haveEqualLength(data.points2) == false)) {
        data.points2 = supplyPoints(data.points2, totalPoints);
        data.points1 = supplyPoints(data.points1, totalPoints);
      } else {
        ///otherwise we try adding points multiple times and choose the one that need the least offset to morph
        ///from one shape to another. Because the function to choose the least weighted edge is random,
        ///this is a Monte Carlo method
        ///because the total points is small, it should be fine to try multiple times here
        double tempMinOffset = double.infinity;
        List<Offset> optimalPoints1 = data.points1,
            optimalPoints2 = data.points2;
        List<Offset> tempPoints1, tempPoints2;
        for (int trial = 0; trial < maxTrial; trial++) {
          tempPoints1 = supplyPoints(data.points1, totalPoints);
          tempPoints2 = supplyPoints(data.points2, totalPoints);
          double tempOffset = computeMinimumOffset(tempPoints1, tempPoints2);
          if (tempOffset < tempMinOffset) {
            tempMinOffset = tempOffset;
            optimalPoints1 = tempPoints1;
            optimalPoints2 = tempPoints2;
          }
        }
        data.points1 = optimalPoints1;
        data.points2 = optimalPoints2;
      }
    } else {
      ///total points is pretty big, probably one shape has curved edges, sample that shape evenly then
      data.points1 = simplePathWalker(path1, precision: precision);
      data.points2 = simplePathWalker(path2, precision: precision);
    }

    ///the control points are set up for both shape now,
    ///we need to find how to align them to make the total offset minimal
    int shift = computeMinimumOffsetIndex(data.points1, data.points2);
    data.points1 = rotateList(data.points1, shift) as List<Offset>;

    ///shifted points are the points used to construct the intermediate path
    data.shiftedPoints.addAll(data.points1);
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

  ///get the intermediate Path at time/progress t
  static Path lerpPath(double t, SampledPathData data) {
    for (var i = 0; i < data.points1.length; i++) {
      var start = data.points1[i];
      var end = data.points2[i];
      var tween = Tween<Offset>(begin: start, end: end);
      Offset offset = tween.transform(t);
      data.shiftedPoints[i] = offset;
    }
    return generatePath(data);
  }

  ///get the intermediate control points at time/progress t
  static List<Offset> lerpPoints(double t, SampledPathData data) {
    for (var i = 0; i < data.points1.length; i++) {
      var start = data.points1[i];
      var end = data.points2[i];
      var tween = Tween(begin: start, end: end);
      Offset offset = tween.transform(t);
      data.shiftedPoints[i] = offset;
    }
    return generatePoints(data);
  }

  /// Generates a path using the [SampledPathData] object.
  /// You can use this path while drawing the frames of
  /// the morph animation on your canvas.
  static Path generatePath(SampledPathData data) {
    Path p = Path();
    for (var i = 0; i < data.shiftedPoints.length; i++) {
      for (var j = 0; j < data.endIndices.length; j++) {
        if (i == data.endIndices[j]) {
          p.moveTo(data.shiftedPoints[i].dx, data.shiftedPoints[i].dy);
          break;
        }
      }
      p.lineTo(data.shiftedPoints[i].dx, data.shiftedPoints[i].dy);
    }
    p.close();
    return p;
  }

  ///generate circles around the control points, for demonstration purposes
  static List<Offset> generatePoints(SampledPathData data) {
    List<Offset> rst = [];
    for (var i = 0; i < data.shiftedPoints.length; i++) {
      rst.add(Offset(data.shiftedPoints[i].dx, data.shiftedPoints[i].dy));
    }
    return rst;
  }
}

List<Object> rotateList(List<Object> list, int v) {
  if (list.isEmpty) return list;
  var i = v % list.length;
  return list.sublist(i)..addAll(list.sublist(0, i));
}

num total(List<num> list) {
  num total = 0;
  list.forEach((element) {
    total += element;
  });
  return total;
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

///test if a control point set have equal length edges
bool haveEqualLength(List<Offset> points) {
  int length = points.length;
  List<double> weights = [];
  for (int i = 0; i < length; i++) {
    weights.add((points[(i + 1) % length] - points[i % length]).distance);
  }
  if (weights.toSet().length != length) {
    return true;
  }
  return false;
}

///add points to the current points list till its length equals totalPointsCount
///we first try to allocate the extra points needed to each edge based on its length
///then for each edge, equally distribute the points along the edge line
///this function is random, as there might be multiple equal length edges,
///in that case, we randomly choose the edge to add the points. We will try this function multiple times to
///find the optimal way to add the points
List<Offset> supplyPoints(List<Offset> points, int totalPointsCount) {
  int length = points.length;

  int newPointsCount = totalPointsCount - length;
  if (newPointsCount == 0) return points;

  List<double> weights = [];
  double totalWeights = 0.0;
  for (int i = 0; i < length; i++) {
    weights.add((points[(i + 1) % length] - points[i % length]).distance);
  }
  for (int i = 0; i < length; i++) {
    totalWeights += weights[i];
  }

  double scale = totalWeights / newPointsCount;
  List<Offset> newPoints = [];
  List<int> counts = weights.map((w) => (w / scale).ceil()).toList();

  while (total(counts) > newPointsCount) {
    int minIndex = nonzeroMinWeighted(counts, weights);
    counts[minIndex] -= 1;
  }

  for (int i = 0; i < length; i++) {
    newPoints.add(points[i]);
    int count = counts[i];
    if (count >= 1) {
      Offset diff = (points[(i + 1) % length] - points[i % length]);
      for (int j = 1; j < count + 1; j++) {
        newPoints.add(
            points[i] + diff * j.roundToDouble() / (count.roundToDouble() + 1));
      }
    }
  }
  return newPoints;
}

List<Offset> controlPointPathWalker(Path path, {double precision = 0.001}) {
  List<Offset> keyPoints = [];
  double prevAngle = double.infinity;
  Offset? prevPoint;

  ///only support single contour shapes for now
  PathMetric metric = path.computeMetrics().toList().first;
  for (var i = 0.0; i <= 1.0 + precision; i += precision) {
    ///use a large testMove to quickly go through straight lines
    double testMove = min(20.0 * precision, 0.02);
    while (testMove > precision) {
      double newMove = i + testMove;
      double? angle =
          metric.getTangentForOffset(metric.length * newMove)?.angle;
      if (angle != prevAngle) {
        testMove /= 2;
      } else {
        i += testMove;
        break;
      }
    }

    Offset? position = metric.getTangentForOffset(metric.length * i)?.position;
    double? angle = metric.getTangentForOffset(metric.length * i)?.angle;
    if (angle != prevAngle) {
      keyPoints.add(prevPoint ?? position ?? Offset.zero);
    }
    prevAngle = angle ?? double.infinity;
    prevPoint = position;
  }
  return keyPoints;
}

List<Offset> simplePathWalker(Path path, {double precision = 0.001}) {
  List<Offset> keyPoints = [];
  PathMetric metric = path.computeMetrics().toList().first;
  for (var i = 0.0; i <= 1.0 + precision; i += precision) {
    Offset position =
        metric.getTangentForOffset(metric.length * i)?.position ?? Offset.zero;
    keyPoints.add(position);
  }
  return keyPoints;
}
