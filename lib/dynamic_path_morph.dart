import 'dart:math';
import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:morphable_shape/morphable_shape.dart';

enum MorphMethod {
  auto,
  weighted,
  unweighted,
}

///Data class associated with a MorphableShapeTween
///supplyCounts are used to make two dynamic paths becoming equal length, they are
///initialized when the morphing first starts and does not change afterwards
///even if the bounding box changes size.
class MorphShapeData {
  Shape begin;
  Shape end;

  ///outer path of the shapes, used to calculate the morphing
  late DynamicPath beginOuterPath;
  late DynamicPath endOuterPath;

  ///used to morph FilledBorderShape
  BorderPaths? beginPaths;
  BorderPaths? endPaths;

  Rect boundingBox;

  List<int>? supplyCounts1;
  List<int>? supplyCounts2;
  int? minimumShift;

  MorphMethod method;

  MorphShapeData(
      {required this.begin,
      required this.end,
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
  static void sampleBorderPathsFromShape(
    MorphShapeData data, {
    int maxTrial = 360,
    int minControlPoints = 16,
    int maxControlPoints = 360,
  }) {
    DynamicPath path1 = data.begin.generateOuterDynamicPath(data.boundingBox);
    if (data.begin is FilledBorderShape) {
      DynamicPath outer = path1;
      DynamicPath inner = data.begin.generateInnerDynamicPath(data.boundingBox);
      List<Color> borderColors =
          (data.begin as FilledBorderShape).borderFillColors();
      List<Gradient?> borderGradients =
          (data.begin as FilledBorderShape).borderFillGradients();

      BorderPaths borderPaths = BorderPaths(
          outer: outer,
          inner: inner,
          fillColors: borderColors,
          fillGradients: borderGradients);

      borderPaths.removeOverlappingPaths();
      path1 = borderPaths.outer;
      data.beginPaths = borderPaths;
    } else {
      path1.removeOverlappingNodes();
    }
    DynamicPath path2 = data.end.generateOuterDynamicPath(data.boundingBox);
    if (data.end is FilledBorderShape) {
      DynamicPath outer = path2;
      DynamicPath inner = data.end.generateInnerDynamicPath(data.boundingBox);
      List<Color> borderColors =
          (data.end as FilledBorderShape).borderFillColors();

      List<Gradient?> borderGradients =
          (data.end as FilledBorderShape).borderFillGradients();

      BorderPaths borderPaths = BorderPaths(
          outer: outer,
          inner: inner,
          fillColors: borderColors,
          fillGradients: borderGradients);

      borderPaths.removeOverlappingPaths();
      path2 = borderPaths.outer;
      data.endPaths = borderPaths;
    } else {
      path2.removeOverlappingNodes();
    }

    sampleDynamicPaths(data, path1, path2,
        maxTrial: maxTrial,
        minControlPoints: minControlPoints,
        maxControlPoints: maxControlPoints);
  }

  static void sampleDynamicPaths(
    MorphShapeData data,
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
      data.beginOuterPath = supplyPoints(path1, data.supplyCounts1!);
      data.endOuterPath = supplyPoints(path2, data.supplyCounts2!);
      data.beginOuterPath.nodes =
          rotateList(data.beginOuterPath.nodes, data.minimumShift!)
              as List<DynamicNode>;
    } else {
      List rst = [];
      if (data.method == MorphMethod.weighted) {
        ///we try adding points multiple times and choose the one that need the least offset to morph
        ///from one shape to another. Because the function to choose the least weighted edge is random,
        ///this is a Monte Carlo method. Because the total points is small, it should be fine to try
        ///multiple times (maxTrial) here

        rst = weightedSampling(path1, path2,
            maxTrial: maxTrial,
            minControlPoints: minControlPoints,
            origin: data.boundingBox.center);
      } else if (data.method == MorphMethod.unweighted) {
        ///use the unweighted method, spread the extra points needed evenly on each curve
        rst = unweightedSampling(path1, path2,
            minControlPoints: minControlPoints,
            maxControlPoints: maxControlPoints,
            origin: data.boundingBox.center);
      } else {
        ///too many possible ways to distribute the points for the weighted algorithm
        ///just j=ignore it

        List weighted = weightedSampling(path1, path2,
            maxTrial: maxTrial,
            minControlPoints: minControlPoints,
            origin: data.boundingBox.center);

        List unweighted = unweightedSampling(path1, path2,
            minControlPoints: minControlPoints,
            maxControlPoints: maxControlPoints,
            origin: data.boundingBox.center);

        /*print("weighted" +
            weighted[5].toString() +
            ", unweighted" +
            unweighted[5].toString());*/

        ///the 5th element is the weight of the sampling
        rst = weighted[5] > unweighted[5] ? unweighted : weighted;
      }
      data.beginOuterPath = rst[2];
      data.endOuterPath = rst[3];
      data.supplyCounts1 = rst[0];
      data.supplyCounts2 = rst[1];
      data.minimumShift = rst[4];
    }

    if (data.begin is FilledBorderShape) {
      BorderPaths borderPaths = data.beginPaths!;
      borderPaths.outer = data.beginOuterPath;
      borderPaths.inner = supplyPoints(borderPaths.inner, data.supplyCounts1!);
      borderPaths.inner.nodes =
          rotateList(borderPaths.inner.nodes, data.minimumShift!)
              as List<DynamicNode>;
      borderPaths.fillColors =
          supplyList(borderPaths.fillColors, data.supplyCounts1!).cast<Color>();
      borderPaths.fillColors =
          rotateList(borderPaths.fillColors, data.minimumShift!) as List<Color>;
      borderPaths.fillGradients =
          supplyList(borderPaths.fillGradients, data.supplyCounts1!)
              .cast<Gradient?>();
      borderPaths.fillGradients =
          rotateList(borderPaths.fillGradients, data.minimumShift!)
              as List<Gradient?>;
    }

    if (data.end is FilledBorderShape) {
      BorderPaths borderPaths = data.endPaths!;

      borderPaths.outer = data.endOuterPath;
      borderPaths.inner = supplyPoints(borderPaths.inner, data.supplyCounts2!);
      borderPaths.fillColors =
          supplyList(borderPaths.fillColors, data.supplyCounts2!).cast<Color>();
      borderPaths.fillGradients =
          supplyList(borderPaths.fillGradients, data.supplyCounts2!)
              .cast<Gradient?>();
    }
  }

  static List<dynamic> weightedSampling(DynamicPath path1, DynamicPath path2,
      {required int minControlPoints,
      required int maxTrial,
      required Offset origin}) {
    int totalPoints = max(path1.nodes.length, path2.nodes.length);
    int minPoints = min(path1.nodes.length, path2.nodes.length);

    double tempMinWeight = double.infinity;
    List<int>? tempCounts1, tempCounts2;
    DynamicPath tempPath1, tempPath2;

    DynamicPath optimalPath1 = DynamicPath(size: Size.zero, nodes: []),
        optimalPath2 = DynamicPath(size: Size.zero, nodes: []);
    List<int> optimalCount1 = [], optimalCount2 = [];

    if (totalPoints > minPoints) {
      int maxPossibleWay =
          estimateCombinationsOf(totalPoints - 1, minPoints - 1);

      List<List<int>> allPossibleCounts = [];

      ///not so much possible ways, we can just do a brute force search
      if (maxPossibleWay <= 2 * maxTrial) {
        maxTrial = maxPossibleWay;
        allPossibleCounts =
            generateAllSupplyCounts(totalPoints - minPoints, minPoints);
      } else {
        maxTrial =
            min((maxTrial * minControlPoints / totalPoints).round(), maxTrial);
      }

      for (int trial = 0; trial < maxTrial; trial++) {
        if (maxPossibleWay != maxTrial) {
          tempCounts1 =
              sampleSupplyCounts(path1, totalPoints, oldCounts: tempCounts1);
          tempCounts2 =
              sampleSupplyCounts(path2, totalPoints, oldCounts: tempCounts2);
        } else {
          if (path1.nodes.length > path2.nodes.length) {
            tempCounts1 = List.generate(path1.nodes.length, (index) => 0);
            tempCounts2 = allPossibleCounts[trial];
          } else {
            tempCounts2 = List.generate(path2.nodes.length, (index) => 0);
            tempCounts1 = allPossibleCounts[trial];
          }
        }

        tempPath1 = supplyPoints(path1, tempCounts1);
        tempPath2 = supplyPoints(path2, tempCounts2);

        int tempShift = computeMinimumOffsetIndex(
            tempPath1.nodes.map((e) => e.position).toList(),
            tempPath2.nodes.map((e) => e.position).toList());

        tempPath1.nodes =
            rotateList(tempPath1.nodes, tempShift) as List<DynamicNode>;

        List<Offset> path1Nodes =
                tempPath1.nodes.map((e) => e.position).toList(),
            path2Nodes = tempPath2.nodes.map((e) => e.position).toList();

        double tempWeight =
            computeTotalMorphWeight(path1Nodes, path2Nodes, origin: origin);

        tempPath1.nodes =
            rotateList(tempPath1.nodes, -tempShift) as List<DynamicNode>;
        if (tempWeight < tempMinWeight) {
          tempMinWeight = tempWeight;
          optimalPath1 = tempPath1;
          optimalPath2 = tempPath2;
          optimalCount1 = tempCounts1;
          optimalCount2 = tempCounts2;
        }
      }
    } else {
      ///Two path have equal length, no need to supply any points
      optimalCount1 = List.generate(path1.nodes.length, (index) => 0);
      optimalCount2 = List.generate(path2.nodes.length, (index) => 0);
      optimalPath1 = supplyPoints(path1, optimalCount1);
      optimalPath2 = supplyPoints(path2, optimalCount2);
    }

    int shift = computeMinimumOffsetIndex(
        optimalPath1.nodes.map((e) => e.position).toList(),
        optimalPath2.nodes.map((e) => e.position).toList());

    optimalPath1.nodes =
        rotateList(optimalPath1.nodes, shift) as List<DynamicNode>;

    List<Offset> path1Nodes =
            optimalPath1.nodes.map((e) => e.position).toList(),
        path2Nodes = optimalPath2.nodes.map((e) => e.position).toList();

    return [
      optimalCount1,
      optimalCount2,
      optimalPath1,
      optimalPath2,
      shift,
      computeTotalMorphWeight(path1Nodes, path2Nodes, origin: origin),
    ];
  }

  static List<dynamic> unweightedSampling(DynamicPath path1, DynamicPath path2,
      {required int minControlPoints,
      required int maxControlPoints,
      required Offset origin}) {
    int totalPoints = lcm(path1.nodes.length, path2.nodes.length);

    ///cap at maxControlPoints, but it is possible that the minimum required points
    ///(max(points1, points2)) is larger than maxControlPoints.
    if (totalPoints > maxControlPoints) {
      totalPoints =
          max(maxControlPoints, max(path1.nodes.length, path2.nodes.length));
    }

    double tempMinWeight = double.infinity;
    List<int>? tempCounts1, tempCounts2;
    DynamicPath tempPath1, tempPath2;

    DynamicPath optimalPath1 = DynamicPath(size: Size.zero, nodes: []),
        optimalPath2 = DynamicPath(size: Size.zero, nodes: []);
    List<int> optimalCount1 = [], optimalCount2 = [];

    int tempTotalPoints = totalPoints;
    do {
      tempCounts1 =
          sampleSupplyCounts(path1, tempTotalPoints, weightBased: false);
      tempCounts2 =
          sampleSupplyCounts(path2, tempTotalPoints, weightBased: false);

      tempPath1 = supplyPoints(path1, tempCounts1);
      tempPath2 = supplyPoints(path2, tempCounts2);

      int tempShift = computeMinimumOffsetIndex(
          tempPath1.nodes.map((e) => e.position).toList(),
          tempPath2.nodes.map((e) => e.position).toList());

      tempPath1.nodes =
          rotateList(tempPath1.nodes, tempShift) as List<DynamicNode>;

      List<Offset> path1Nodes = tempPath1.nodes.map((e) => e.position).toList(),
          path2Nodes = tempPath2.nodes.map((e) => e.position).toList();

      double tempWeight =
          computeTotalMorphWeight(path1Nodes, path2Nodes, origin: origin);

      tempPath1.nodes =
          rotateList(tempPath1.nodes, -tempShift) as List<DynamicNode>;
      if (tempWeight < tempMinWeight) {
        tempMinWeight = tempWeight;
        optimalPath1 = tempPath1;
        optimalPath2 = tempPath2;
        optimalCount1 = tempCounts1;
        optimalCount2 = tempCounts2;
      }
      tempTotalPoints += totalPoints;
    } while (tempTotalPoints < maxControlPoints);

    int shift = computeMinimumOffsetIndex(
        optimalPath1.nodes.map((e) => e.position).toList(),
        optimalPath2.nodes.map((e) => e.position).toList());

    optimalPath1.nodes =
        rotateList(optimalPath1.nodes, shift) as List<DynamicNode>;

    List<Offset> path1Nodes =
            optimalPath1.nodes.map((e) => e.position).toList(),
        path2Nodes = optimalPath2.nodes.map((e) => e.position).toList();

    return [
      optimalCount1,
      optimalCount2,
      optimalPath1,
      optimalPath2,
      shift,
      computeTotalMorphWeight(path1Nodes, path2Nodes, origin: origin),
    ];
  }

  static int computeMinimumOffsetIndex(
      List<Offset> points1, List<Offset> points2) {
    assert(points1.length == points2.length);
    int length = points1.length;
    int startShift = 0;
    double? startOffset, leftOffset, rightOffset;

    ///just don't use a polyline that is longer than 1000...
    int maxIter = 1000;
    int iter = 0;
    while (iter < maxIter) {
      startOffset = startOffset ??
          computeTotalOffset(points1, points2, shift: startShift % length);
      leftOffset = leftOffset ??
          computeTotalOffset(points1, points2,
              shift: (startShift - 1) % length);
      rightOffset = rightOffset ??
          computeTotalOffset(points1, points2,
              shift: (startShift + 1) % length);
      if (leftOffset < startOffset) {
        startShift -= 1;
        rightOffset = startOffset;
        startOffset = leftOffset;
        leftOffset = null;
      } else if (rightOffset < startOffset) {
        startShift += 1;
        leftOffset = startOffset;
        startOffset = rightOffset;
        rightOffset = null;
      } else {
        break;
      }
      iter++;
    }

    return startShift % length;
  }

  static double computeTotalOffset(List<Offset> points1, List<Offset> points2,
      {int shift = 0}) {
    assert(points1.length == points2.length);
    int length = points1.length;
    double currentOffset = 0.0;
    for (int i = 0; i < length; i += 1) {
      currentOffset += (points1[(i + shift) % length] - points2[i]).distance;
    }
    return currentOffset;
  }

  static Offset centerOfMass(List<Offset> points) {
    int length = points.length;
    Offset rst = Offset.zero;
    for (int i = 0; i < length; i += 1) {
      rst += points[i];
    }
    return rst / length.toDouble();
  }

  static double computeTotalMorphWeight(
      List<Offset> points1, List<Offset> points2,
      {Offset origin = Offset.zero}) {
    assert(points1.length == points2.length);
    int length = points1.length;
    double maxAngle = 0.0;
    double totalAngle = 0.0;

    Offset center1 = centerOfMass(points1), center2 = centerOfMass(points2);
    for (int i = 0; i < length; i += 1) {
      double diff =
          (points1[i] - center1).direction - (points2[i] - center2).direction;
      if (diff < -pi) diff += 2 * pi;
      if (diff > pi) diff -= 2 * pi;
      if (diff.abs() > maxAngle) maxAngle = diff.abs();
      totalAngle += diff;
      double diffFromOrigin =
          (points1[i] - origin).direction - (points2[i] - origin).direction;
      if (diffFromOrigin < -pi) diffFromOrigin += 2 * pi;
      if (diffFromOrigin > pi) diffFromOrigin -= 2 * pi;
    }

    return points1.length * max(1e-10, maxAngle) * max(1e-10, totalAngle);
  }

  static DynamicPath lerpPaths(
      double t, DynamicPath beginPath, DynamicPath endPath) {
    DynamicPath rst = DynamicPath(size: beginPath.size, nodes: []);

    for (var i = 0; i < beginPath.nodes.length; i++) {
      var start = beginPath.getNodeWithControlPoints(i);
      var end = endPath.getNodeWithControlPoints(i);
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

  static List<List<int>> generateAllSupplyCounts(int totalPoints, int slots) {
    if (slots < 1) {
      return [];
    }
    if (slots == 1) {
      return [
        [totalPoints]
      ];
    }
    if (totalPoints < 1) {
      return [List.generate(slots, (index) => 0)];
    }
    List<List<int>> rst = [];
    for (int i = 0; i <= totalPoints; i++) {
      List<List<int>> temp =
          generateAllSupplyCounts(totalPoints - i, slots - 1);
      temp.forEach((l) {
        l.insert(0, i);
      });
      rst.addAll(temp);
    }
    return rst;
  }

  static List<int> sampleSupplyCounts(DynamicPath path, int totalPointsCount,
      {bool weightBased = true, List<int>? oldCounts}) {
    int length = path.nodes.length;

    int newPointsCount = totalPointsCount - length;

    if (newPointsCount == 0) return List.generate(length, (index) => 0);

    List<double> weights = [];
    double totalWeights = 0.0;
    for (int i = 0; i < length; i++) {
      if (weightBased && oldCounts == null) {
        weights.add(path.getPathLengthAt(i));
      } else {
        weights.add(1.0);
      }
    }
    for (int i = 0; i < length; i++) {
      totalWeights += weights[i];
    }

    List<int> counts;
    int chooseIndex;

    if (oldCounts == null) {
      double scale = totalWeights / newPointsCount;
      counts = weights.map((w) => (w / scale).ceil()).toList();
    } else {
      counts = oldCounts.map((e) => (e + 1)).toList();
    }

    while (counts.total() > newPointsCount) {
      chooseIndex = randomChoose(weights);

      if (counts[chooseIndex] > 0) {
        counts[chooseIndex] -= 1;
      }
    }

    return counts;
  }

  static DynamicPath supplyPoints(DynamicPath path, List<int> supplyCounts) {
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
      int count = supplyCounts[i];
      if (count >= 1) {
        int nextIndex = (i + 1) % length;
        List<Offset> controlPoints = path.getNextPathControlPointsAt(i);
        if (controlPoints.length == 2) {
          Offset diff =
              (path.nodes[nextIndex].position - path.nodes[i].position);
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

  static List<dynamic> supplyList(List<dynamic> list, List<int> counts) {
    int length = list.length;

    List<dynamic> newList = [];

    for (int i = 0; i < length; i++) {
      newList.add(list[i]);
      if (counts[i] >= 1) {
        newList.addAll(List.generate(counts[i], (index) => list[i]));
      }
    }

    return newList;
  }

  static int randomChoose(List<num> list) {
    int index = 0;
    num totalWeight = list.total();
    var rng = new Random();
    double randomDraw = rng.nextDouble() * totalWeight;
    double currentSum = 0;
    for (int i = 0; i < list.length; i++) {
      currentSum += list[i];
      if (randomDraw <= currentSum) return i;
    }
    return index;
  }

  static int estimateCombinationsOf(int n, int k, {int maximum = 10000000}) {
    if (k > n) {
      return 0;
    }
    int r = 1;
    for (int d = 1; d <= k; ++d) {
      if (r > maximum) break;
      r *= n--;
      r = r ~/ d;
    }
    return r;
  }
}
