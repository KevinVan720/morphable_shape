import 'package:flutter/material.dart';
import 'package:morphable_shape/morphable_shape.dart';
import 'package:morphable_shape/src/dynamic_path/dynamic_path_morph.dart';

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

class AnimatedDecoratedShadowedShape extends ImplicitlyAnimatedWidget {
  AnimatedDecoratedShadowedShape({
    Key? key,
    this.child,
    this.shadows,
    this.insetShadows,
    this.decoration,
    this.shape,
    this.method,
    Curve curve = Curves.linear,
    required Duration duration,
    VoidCallback? onEnd,
  }) : super(key: key, curve: curve, duration: duration, onEnd: onEnd);

  final Widget? child;
  final List<ShapeShadow>? shadows;
  final List<ShapeShadow>? insetShadows;
  final Decoration? decoration;
  final ShapeBorder? shape;
  final MorphMethod? method;

  @override
  _AnimatedShadowedShapeState createState() => _AnimatedShadowedShapeState();
}

class _AnimatedShadowedShapeState
    extends AnimatedWidgetBaseState<AnimatedDecoratedShadowedShape> {
  MorphableShapeBorderTween? _shapeBorderTween;
  ListShapeShadowTween? _listShadowTween;
  ListShapeShadowTween? _listInsetShadowTween;
  DecorationTween? _decorationTween;

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
    _listInsetShadowTween = visitor(
            _listInsetShadowTween,
            widget.insetShadows,
            (dynamic value) =>
                ListShapeShadowTween(begin: value as List<ShapeShadow>))
        as ListShapeShadowTween?;
    _decorationTween = visitor(_decorationTween, widget.decoration,
            (dynamic value) => DecorationTween(begin: value as Decoration))
        as DecorationTween;
  }

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = this.animation;
    return DecoratedShadowedShape(
      decoration: _decorationTween?.evaluate(animation),
      shape: _shapeBorderTween?.evaluate(animation),
      shadows: _listShadowTween?.evaluate(animation),
      insetShadows: _listInsetShadowTween?.evaluate(animation),
      child: widget.child,
    );
  }
}
