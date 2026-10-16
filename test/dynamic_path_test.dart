import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morphable_shape/morphable_shape.dart';
import 'package:morphable_shape/src/dynamic_path/border_paths.dart';

import 'test_utils.dart';

DynamicPath square({double size = 100}) =>
    DynamicPath(size: Size(size, size), nodes: [
      DynamicNode(position: Offset.zero),
      DynamicNode(position: Offset(size, 0)),
      DynamicNode(position: Offset(size, size)),
      DynamicNode(position: Offset(0, size)),
    ]);

void main() {
  group('DynamicNode', () {
    test('json', () {
      final node = DynamicNode(
          position: const Offset(1, 2),
          prev: const Offset(3, 4),
          next: const Offset(5, 6));
      final copy = DynamicNode.fromJson(node.toJson());
      expect(copy.position, node.position);
      expect(copy.prev, node.prev);
      expect(copy.next, node.next);
      expect(DynamicNode(position: Offset.zero).toJson().keys, ['pos']);
    });
  });

  group('DynamicPath', () {
    test('clamps nodes into its size and rounds them', () {
      final path = DynamicPath(size: const Size(10, 10), nodes: [
        DynamicNode(position: const Offset(-5, 3.123456)),
        DynamicNode(position: const Offset(15, 5)),
        DynamicNode(position: const Offset(5, 20)),
      ]);
      expect(path.nodes.map((e) => e.position).toList(),
          const [Offset(0, 3.123), Offset(10, 5), Offset(5, 10)]);
    });

    test('splits curves whose control points are out of bounds', () {
      final path = DynamicPath(size: const Size(100, 100), nodes: [
        DynamicNode(position: const Offset(0, 50), next: const Offset(0, -60)),
        DynamicNode(
            position: const Offset(100, 50), prev: const Offset(100, -60)),
      ]);
      expect(path.nodes.length, greaterThan(2));
      expectNodesWithin(path, const Rect.fromLTWH(0, 0, 100, 100));
    });

    test('does not change paths that are already within bounds', () {
      for (final shape in sampleShapes().values) {
        final path =
            shape.generateOuterDynamicPath(const Rect.fromLTWH(0, 0, 100, 100));
        final copy = parseDynamicPath(path.toJson())!;
        expect(copy.nodes.length, path.nodes.length);
      }
    });

    test('works with an empty size', () {
      for (final size in const [Size.zero, Size(0, 10), Size(10, 0)]) {
        final path = DynamicPath(size: size, nodes: [
          DynamicNode(position: Offset.zero, next: const Offset(3, 3)),
          DynamicNode(position: const Offset(5, 5), prev: const Offset(1, 1)),
          DynamicNode(position: const Offset(0, 5)),
        ]);
        expect(path.nodes.length, 3);
        expectNodesWithin(path, Offset.zero & size);
        final result = path.getPath(const Size(20, 20)).getBounds();
        expect(result.left.isFinite && result.bottom.isFinite, isTrue);
        path.resize(Size.zero);
        expectNodesWithin(path, Rect.zero);
      }
    });

    test('resize scales every point', () {
      final path = DynamicPath(size: const Size(10, 20), nodes: [
        DynamicNode(position: const Offset(5, 10), prev: const Offset(1, 2)),
        DynamicNode(position: const Offset(10, 20), next: const Offset(10, 0)),
        DynamicNode(position: Offset.zero),
      ]);
      path.resize(const Size(20, 10));
      expect(path.size, const Size(20, 10));
      expect(path.nodes[0].position, const Offset(10, 5));
      expect(path.nodes[0].prev, const Offset(2, 1));
      expect(path.nodes[1].next, const Offset(20, 0));
    });

    test('getPath draws lines and cubics', () {
      final path = square().getPath(const Size(50, 50));
      expect(path.getBounds(), rectCloseTo(const Rect.fromLTWH(0, 0, 50, 50)));
      expect(path.contains(const Offset(25, 25)), isTrue);

      final curved = samplePath().getPath(const Size(100, 100));
      expect(curved.contains(const Offset(80, 60)), isTrue);
      expect(curved.contains(const Offset(10, 90)), isFalse);

      expect(
          DynamicPath(size: const Size(10, 10), nodes: [])
              .getPath(const Size(10, 10))
              .getBounds(),
          Rect.zero);
    });

    test('node editing stays within bounds', () {
      final path = square();
      path.moveNodeTo(0, const Offset(-10, 20));
      expect(path.nodes[0].position, const Offset(0, 20));
      path.moveNodeBy(1, const Offset(30, 30));
      expect(path.nodes[1].position, const Offset(100, 30));
      path.moveNodeControlTo(2, true, const Offset(150, 50.12345));
      expect(path.nodes[2].prev, const Offset(100, 50.123));
      path.moveNodeControlTo(2, false, const Offset(-5, 50));
      expect(path.nodes[2].next, const Offset(0, 50));

      final curved = samplePath();
      curved.moveNodeTo(1, const Offset(90, 10));
      // control points move along with their node
      expect(curved.nodes[1].next, const Offset(90, 60));
      curved.moveNodeBy(2, const Offset(-10, 0));
      expect(curved.nodes[2].prev, const Offset(80, 100));
    });

    test('control points', () {
      final path = samplePath();
      expect(path.getNextPathControlPointsAt(0),
          const [Offset(0, 0), Offset(100, 0)]);
      expect(path.getNextPathControlPointsAt(1).length, 4);
      expect(path.getNextPathControlPointsAt(2).length, 2);
      final node = path.getNodeWithControlPoints(0);
      expect(node.prev, isNotNull);
      expect(node.next, const Offset(100 / 3, 0));
      expect(path.getPathLengthAt(0), 100);
      expect(path.getPathLengthAt(1), greaterThan(100));
    });

    test('splitCubicAt', () {
      const points = [
        Offset(0, 0),
        Offset(0, 10),
        Offset(10, 10),
        Offset(10, 0)
      ];
      final split = DynamicPath.splitCubicAt(0.5, points);
      expect(split.length, 7);
      expect(split.first, points.first);
      expect(split.last, points.last);
      expect(split[3], const Offset(5, 7.5));
      expect(DynamicPath.estimateCubicLength(points),
          closeTo(20, 1e-9)); // (10 + 10 + 10 + 10) / 2
    });

    test('removeOverlappingNodes merges points that are on top of each other',
        () {
      final path = DynamicPath(size: const Size(100, 100), nodes: [
        DynamicNode(position: Offset.zero),
        DynamicNode(position: const Offset(0.01, 0)),
        DynamicNode(position: const Offset(100, 0)),
        DynamicNode(position: const Offset(100, 100)),
        DynamicNode(position: const Offset(0, 0.02)),
      ]);
      path.removeOverlappingNodes();
      expect(path.nodes.length, 3);
    });

    test('json round trip', () {
      final path = samplePath();
      final copy = parseDynamicPath(path.toJson())!;
      expect(copy.toJson(), path.toJson());
    });
  });

  group('BorderPaths', () {
    BorderPaths borderPaths(Rect rect, RoundedRectangleShapeBorder shape) =>
        BorderPaths(
          outer: shape.generateOuterDynamicPath(rect),
          inner: shape.generateInnerDynamicPath(rect),
          fillColors: shape.borderFillColors(),
          fillGradients: shape.borderFillGradients(),
        );

    test('one path per side segment', () {
      const shape = RoundedRectangleShapeBorder(
          borderSides: RectangleBorderSides.all(solidBorder),
          borderRadius:
              DynamicBorderRadius.all(DynamicRadius.circular(Length(10))));
      const rect = Rect.fromLTWH(0, 0, 100, 60);
      final paths = borderPaths(rect, shape);
      expect(paths.outer.nodes.length, 12);
      expect(paths.inner.nodes.length, 12);
      expect(paths.fillColors.length, 12);
      expect(paths.fillGradients.length, 12);
      expect(paths.generateBorderPaths(rect).length, 12);
    });

    test('removing overlapping points keeps everything aligned', () {
      const shape = RoundedRectangleShapeBorder(
          borderSides: RectangleBorderSides.only(
              top: DynamicBorderSide(width: 3, color: red),
              left: DynamicBorderSide(width: 5, gradient: linearGradient)));
      for (final size in const [Size(100, 60), Size(10, 10), Size(100, 0)]) {
        final rect = Offset.zero & size;
        final paths = borderPaths(rect, shape)..removeOverlappingPaths();
        final length = paths.outer.nodes.length;
        expect(length, lessThanOrEqualTo(12));
        expect(paths.inner.nodes.length, length);
        expect(paths.fillColors.length, length);
        expect(paths.fillGradients.length, length);
        expect(paths.generateBorderPaths(rect).length, length);
      }
    });
  });

  group('geometry utilities', () {
    test('arcToCubicBezier', () {
      const rect = Rect.fromLTWH(0, 0, 100, 100);
      final quarter = arcToCubicBezier(rect, 0, pi / 2);
      expect(quarter.length, 8); // split once with the default pi / 4 limit
      expect(quarter.first, const Offset(100, 50));
      expect((quarter.last - const Offset(50, 100)).distance, lessThan(1e-9));
      expect(arcToCubicBezier(rect, 0, pi / 2, splitTimes: 0).length, 4);
      expect(arcToCubicBezier(rect, 0, pi / 2, splitTimes: 2).length, 16);
      final point = getPointOnArc(rect, pi);
      expect(point.dx, closeTo(0, 1e-9));
      expect(point.dy, closeTo(50, 1e-9));
      expect(getDerivativeOnArc(rect, 0), const Offset(-0.0, 50));
    });

    test('triangles', () {
      expect(getThirdSideLength(3, 4, pi / 2), closeTo(5, 1e-9));
      expect(getThirdAngle(3, 4, 5), closeTo(pi / 2, 1e-9));
    });

    test('rotateList', () {
      expect(rotateList([1, 2, 3, 4], 1), [2, 3, 4, 1]);
      expect(rotateList([1, 2, 3, 4], -1), [4, 1, 2, 3]);
      expect(rotateList([], 3), isEmpty);
    });

    test('extensions', () {
      expect(const Offset(-1, 20).clamp(Offset.zero, const Offset(10, 10)),
          const Offset(0, 10));
      expect(const Offset(1.23456, 2.34567).roundWithPrecision(2),
          const Offset(1.23, 2.35));
      final rotated = const Offset(1, 0).rotateAround(angle: pi / 2);
      expect(rotated.dx, closeTo(0, 1e-9));
      expect(rotated.dy, closeTo(1, 1e-9));
      expect([1, 2.5, 3].total(), 6.5);
      expect(['a', 'b'].mapIndexed((e, i) => '$e$i').toList(), ['a0', 'b1']);
      expect(180.0.toRadian(), closeTo(pi, 1e-12));
      expect(pi.toDegree(), closeTo(180, 1e-12));
      expect((1.5 * pi).clampAngleWithin(), closeTo(-0.5 * pi, 1e-12));
      expect((-1.5 * pi).clampAngleWithin(), closeTo(0.5 * pi, 1e-12));
      expect(CornerStyle.concave.isConcave, isTrue);
      expect(CornerStyle.cutout.isConcave, isTrue);
      expect(CornerStyle.rounded.isConcave, isFalse);
      expect(ShapeSide.top.isHorizontal, isTrue);
      expect(ShapeSide.left.isVertical, isTrue);
    });

    test('node list builders', () {
      final nodes = <DynamicNode>[];
      nodes.cubicTo(Offset.zero, Offset.zero, Offset.zero);
      expect(nodes, isEmpty);
      nodes.addArc(const Rect.fromLTWH(0, 0, 10, 10), 0, pi, splitTimes: 1);
      expect(nodes.length, 3);
      for (final style in CornerStyle.values) {
        final corner = <DynamicNode>[DynamicNode(position: Offset.zero)];
        corner.addStyledCorner(const Offset(50, 50), 10, -pi / 4, pi / 2,
            style: style, splitTimes: 1);
        expect(corner.length, greaterThan(1), reason: '$style');
      }
    });
  });
}
