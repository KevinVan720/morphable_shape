import 'package:flutter/material.dart';
import 'package:morphable_shape/morphable_shape.dart';

class ListShadowTween extends Tween<List<Shadow>> {
  ListShadowTween({
    List<Shadow>? begin,
    List<Shadow>? end,
  }) : super(begin: begin, end: end);

  @override
  List<Shadow> lerp(double t) {
    return Shadow.lerpList(begin, end, t) ?? [];
  }
}

class AnimatedShadowedShape extends ImplicitlyAnimatedWidget {
  AnimatedShadowedShape({
    Key? key,
    this.child,
    this.shadows,
    this.shape,
    Curve curve = Curves.linear,
    required Duration duration,
    VoidCallback? onEnd,
  }) : super(key: key, curve: curve, duration: duration, onEnd: onEnd);

  Widget? child;
  List<Shadow>? shadows;
  ShapeBorder? shape;

  @override
  _AnimatedShadowedShapeState createState() => _AnimatedShadowedShapeState();
}

class _AnimatedShadowedShapeState
    extends AnimatedWidgetBaseState<AnimatedShadowedShape> {
  MorphableShapeBorderTween? _shapeBorderTween;
  ListShadowTween? _listShadowTween;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _shapeBorderTween = visitor(
            _shapeBorderTween,
            widget.shape,
            (dynamic value) =>
                MorphableShapeBorderTween(begin: value as MorphableShapeBorder))
        as MorphableShapeBorderTween?;
    _listShadowTween = visitor(_listShadowTween, widget.shadows,
            (dynamic value) => ListShadowTween(begin: value as List<Shadow>))
        as ListShadowTween?;
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
