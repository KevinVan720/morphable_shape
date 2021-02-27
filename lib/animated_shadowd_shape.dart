import 'package:flutter/material.dart';
import 'package:morphable_shape/dynamic_path_morph.dart';
import 'package:morphable_shape/morphable_shape.dart';

class ListShapeShadowTween extends Tween<List<ShapeShadow>?> {
  ListShapeShadowTween({
    List<ShapeShadow>? begin,
    List<ShapeShadow>? end,
  }) : super(begin: begin, end: end);

  @override
  List<ShapeShadow>? lerp(double t) {
    return ShapeShadow.lerpList(begin, end, t);
  }
}

class AnimatedShadowedShape extends ImplicitlyAnimatedWidget {
  AnimatedShadowedShape({
    Key? key,
    this.child,
    this.shadows,
    this.shape,
    this.method,
    Curve curve = Curves.linear,
    required Duration duration,
    VoidCallback? onEnd,
  }) : super(key: key, curve: curve, duration: duration, onEnd: onEnd);

  final Widget? child;
  final List<ShapeShadow>? shadows;
  final ShapeBorder? shape;
  final MorphMethod? method;

  @override
  _AnimatedShadowedShapeState createState() => _AnimatedShadowedShapeState();
}

class _AnimatedShadowedShapeState
    extends AnimatedWidgetBaseState<AnimatedShadowedShape> {
  MorphableShapeBorderTween? _shapeBorderTween;
  ListShapeShadowTween? _listShadowTween;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _shapeBorderTween = visitor(
            _shapeBorderTween,
            widget.shape,
            (dynamic value) => MorphableShapeBorderTween(
                begin: value as MorphableShapeBorder,
                method: widget.method ?? MorphMethod.auto))
        as MorphableShapeBorderTween?;
    _listShadowTween = visitor(
            _listShadowTween,
            widget.shadows,
            (dynamic value) =>
                ListShapeShadowTween(begin: value as List<ShapeShadow>))
        as ListShapeShadowTween?;
  }

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = this.animation;
    return ShadowedShape(
      shape: _shapeBorderTween?.evaluate(animation),
      shadows: _listShadowTween?.evaluate(animation),
      child: widget.child,
    );
  }
}
