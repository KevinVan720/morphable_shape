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

class CustomBoxDecorationTween extends DecorationTween {
  CustomBoxDecorationTween({
    Decoration? begin,
    Decoration? end,
  }) : super(begin: begin, end: end);

  @override
  Decoration lerp(double t) {
    if (begin is BoxDecoration && end is BoxDecoration) {
      return lerpDecoration(begin as BoxDecoration, end as BoxDecoration, t)??BoxDecoration();
    }
    return Decoration.lerp(begin, end, t)??BoxDecoration();
  }

  BoxDecoration? lerpDecoration(BoxDecoration? a, BoxDecoration? b, double t) {
    assert(t != null);
    if (a == null && b == null) return null;
    if (a == null) return b!.scale(t);
    if (b == null) return a.scale(1.0 - t);
    if (t == 0.0) return a;
    if (t == 1.0) return b;

    return BoxDecoration(
      color: Color.lerp(a.color, b.color, t),
      image: t < 0.5 ? a.image : b.image, // TODO(ianh): cross-fade the image
      border: BoxBorder.lerp(a.border, b.border, t),
      borderRadius:
          BorderRadiusGeometry.lerp(a.borderRadius, b.borderRadius, t),
      boxShadow: BoxShadow.lerpList(a.boxShadow, b.boxShadow, t),
      gradient: lerpGradient(t, a.gradient, b.gradient, a.color ?? Colors.white,
          b.color ?? Colors.white),
      shape: t < 0.5 ? a.shape : b.shape,
    );
  }

  Gradient? lerpGradient(double t, Gradient? beginGradient,
      Gradient? endGradient, Color beginColor, Color endColor) {
    if (beginGradient == null) {
      if (endGradient == null) {
        return null;
      } else {
        if (endGradient is LinearGradient) {
          return Gradient.lerp(
              LinearGradient(colors: [beginColor, beginColor]), endGradient, t);
        }
        if (endGradient is RadialGradient) {
          return Gradient.lerp(
              RadialGradient(colors: [beginColor, beginColor]), endGradient, t);
        }
        if (endGradient is SweepGradient) {
          return Gradient.lerp(
              SweepGradient(colors: [beginColor, beginColor]), endGradient, t);
        }
      }
    } else {
      if (endGradient == null) {
        if (beginGradient is LinearGradient) {
          return Gradient.lerp(
              beginGradient, LinearGradient(colors: [endColor, endColor]), t);
        }
        if (beginGradient is RadialGradient) {
          return Gradient.lerp(
              beginGradient, RadialGradient(colors: [endColor, endColor]), t);
        }
        if (beginGradient is SweepGradient) {
          return Gradient.lerp(
              beginGradient, SweepGradient(colors: [endColor, endColor]), t);
        }
      } else {
        return Gradient.lerp(beginGradient, endGradient, t);
      }
    }
  }
}

///An implicitly animated version of the DecoratedShadowedShape widget

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
    _decorationTween = visitor(
            _decorationTween,
            widget.decoration,
            (dynamic value) =>
                CustomBoxDecorationTween(begin: value as Decoration))
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
