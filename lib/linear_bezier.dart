import 'package:bezier/bezier.dart';
import 'package:vector_math/vector_math.dart';

class LinearBezier extends Bezier {
  /// Constructs a cubic Bézier curve from a [List] of [Vector2].  The first point
  /// in [points] will be the curve's start point, the second and third points will
  /// be its control points, and the fourth point will be its end point.
  LinearBezier(List<Vector2> points) : super(points) {
    if (points.length != 2) {
      throw ArgumentError('Linear Bézier curves require exactly four points');
    }
  }

  @override
  int get order => 1;

  @override
  Vector2 pointAt(double t) {
    return points[0]+points[1]*t;
  }

  @override
  Vector2 derivativeAt(double t,
      {List<Vector2>? cachedFirstOrderDerivativePoints}) {

    return (points[1]-points[0]).normalized();
  }

  @override
  String toString() =>
      'BDLinearBezier([${points[0]}, ${points[1]}])';
}