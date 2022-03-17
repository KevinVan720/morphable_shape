import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:morphable_shape/src/box_decoration_mix.dart';
import 'package:morphable_shape/morphable_shape.dart';
import 'package:morphable_shape/src/dynamic_path/dynamic_path_morph.dart';
import '';

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
      return lerpDecoration(begin as BoxDecoration, end as BoxDecoration, t) ??
          BoxDecoration();
    }
    return Decoration.lerp(begin, end, t) ?? BoxDecoration();
  }

  bool sameGradient(Gradient a, Gradient b) {
    return (a is LinearGradient && b is LinearGradient) ||
        (a is RadialGradient && b is RadialGradient) ||
        (a is SweepGradient && b is SweepGradient);
  }

  Decoration? lerpDecoration(BoxDecoration? a, BoxDecoration? b, double t) {
    assert(t != null);
    if (a == null && b == null) return null;
    if (a == null) return b!.scale(t);
    if (b == null) return a.scale(1.0 - t);
    if (t == 0.0) return a;
    if (t == 1.0) return b;

    ///If there is image in either a or b or
    ///if the gradient in a and b are not the same type,
    ///use crossfade
    if (a.image != null ||
        b.image != null ||
        (a.gradient != null &&
            b.gradient != null &&
            !sameGradient(a.gradient!, b.gradient!))) {
      DecorationImage? aImageAtT, bImageAtT;

      if (a.image != null) {
        DecorationImage aImage = a.image!;
        aImageAtT = DecorationImage(
          image: aImage.image,
          onError: aImage.onError,
          colorFilter: aImage.colorFilter,
          fit: aImage.fit,
          alignment: aImage.alignment,
          centerSlice: aImage.centerSlice,
          repeat: aImage.repeat,
          matchTextDirection: aImage.matchTextDirection,
          scale: aImage.scale,
          opacity: lerpDouble(aImage.opacity, 0, t) ?? 0,
          filterQuality: aImage.filterQuality,
          invertColors: aImage.invertColors,
          isAntiAlias: aImage.isAntiAlias,
        );
      }

      if (b.image != null) {
        DecorationImage bImage = b.image!;
        bImageAtT = DecorationImage(
          image: bImage.image,
          onError: bImage.onError,
          colorFilter: bImage.colorFilter,
          fit: bImage.fit,
          alignment: bImage.alignment,
          centerSlice: bImage.centerSlice,
          repeat: bImage.repeat,
          matchTextDirection: bImage.matchTextDirection,
          scale: bImage.scale,
          opacity: lerpDouble(0, bImage.opacity, t) ?? 1,
          filterQuality: bImage.filterQuality,
          invertColors: bImage.invertColors,
          isAntiAlias: bImage.isAntiAlias,
        );
      }

      return BoxDecorationMix(
        color: Color.lerp(a.color, b.color, t),
        image1: t < 0.5 ? bImageAtT : aImageAtT,
        image2: t < 0.5 ? aImageAtT : bImageAtT,
        border: BoxBorder.lerp(a.border, b.border, t),
        borderRadius:
            BorderRadiusGeometry.lerp(a.borderRadius, b.borderRadius, t),
        boxShadow: BoxShadow.lerpList(a.boxShadow, b.boxShadow, t),
        gradient1: a.gradient?.scale(1 - t),
        gradient2: b.gradient?.scale(t),
        shape: t < 0.5 ? a.shape : b.shape,
      );
    }

    if (a.gradient != null || b.gradient != null) {
      return BoxDecoration(
        //color: Color.lerp(a.color, b.color, t),
        border: BoxBorder.lerp(a.border, b.border, t),
        borderRadius:
            BorderRadiusGeometry.lerp(a.borderRadius, b.borderRadius, t),
        boxShadow: BoxShadow.lerpList(a.boxShadow, b.boxShadow, t),
        gradient: lerpGradient(t, a.gradient, b.gradient,
            a.color ?? Color(0x00FFFFFF), b.color ?? Color(0x00FFFFFF)),
        shape: t < 0.5 ? a.shape : b.shape,
      );
    }

    return BoxDecoration(
      color: Color.lerp(a.color, b.color, t),
      border: BoxBorder.lerp(a.border, b.border, t),
      borderRadius:
          BorderRadiusGeometry.lerp(a.borderRadius, b.borderRadius, t),
      boxShadow: BoxShadow.lerpList(a.boxShadow, b.boxShadow, t),
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
          return LinearGradient.lerp(
              LinearGradient(
                  begin: endGradient.begin,
                  end: endGradient.end,
                  transform: endGradient.transform,
                  tileMode: endGradient.tileMode,
                  stops: endGradient.stops,
                  colors: List.generate(
                      endGradient.colors.length, (index) => beginColor)),
              endGradient,
              t);
        }
        if (endGradient is RadialGradient) {
          return RadialGradient.lerp(
              RadialGradient(
                  center: endGradient.center,
                  radius: endGradient.radius,
                  focal: endGradient.focal,
                  focalRadius: endGradient.focalRadius,
                  transform: endGradient.transform,
                  tileMode: endGradient.tileMode,
                  stops: endGradient.stops,
                  colors: List.generate(
                      endGradient.colors.length, (index) => beginColor)),
              endGradient,
              t);
        }
        if (endGradient is SweepGradient) {
          return SweepGradient.lerp(
              SweepGradient(
                  center: endGradient.center,
                  startAngle: endGradient.startAngle,
                  endAngle: endGradient.endAngle,
                  transform: endGradient.transform,
                  tileMode: endGradient.tileMode,
                  stops: endGradient.stops,
                  colors: List.generate(
                      endGradient.colors.length, (index) => beginColor)),
              endGradient,
              t);
        }
      }
    } else {
      if (endGradient == null) {
        if (beginGradient is LinearGradient) {
          return LinearGradient.lerp(
              beginGradient,
              LinearGradient(
                  begin: beginGradient.begin,
                  end: beginGradient.end,
                  transform: beginGradient.transform,
                  tileMode: beginGradient.tileMode,
                  stops: beginGradient.stops,
                  colors: List.generate(
                      beginGradient.colors.length, (index) => endColor)),
              t);
        }
        if (beginGradient is RadialGradient) {
          return RadialGradient.lerp(
              beginGradient,
              RadialGradient(
                  center: beginGradient.center,
                  radius: beginGradient.radius,
                  focal: beginGradient.focal,
                  focalRadius: beginGradient.focalRadius,
                  transform: beginGradient.transform,
                  tileMode: beginGradient.tileMode,
                  stops: beginGradient.stops,
                  colors: List.generate(
                      beginGradient.colors.length, (index) => endColor)),
              t);
        }
        if (beginGradient is SweepGradient) {
          return SweepGradient.lerp(
              beginGradient,
              SweepGradient(
                  center: beginGradient.center,
                  startAngle: beginGradient.startAngle,
                  endAngle: beginGradient.endAngle,
                  transform: beginGradient.transform,
                  tileMode: beginGradient.tileMode,
                  stops: beginGradient.stops,
                  colors: List.generate(
                      beginGradient.colors.length, (index) => endColor)),
              t);
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
