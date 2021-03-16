import 'package:flutter/material.dart';
import 'package:morphable_shape/morphable_shape.dart';

///A simpler version of the Material class
///Not in use right now

class CustomShapeBorderClipper extends CustomClipper<Path> {
  const CustomShapeBorderClipper({
    required this.shape,
    this.textDirection,
  });

  /// The shape border whose outer path this clipper clips to.
  final ShapeBorder shape;

  /// The text direction to use for getting the outer path for [shape].
  ///
  /// [ShapeBorder]s can depend on the text direction (e.g having a "dent"
  /// towards the start of the shape).
  final TextDirection? textDirection;

  /// Returns the outer path of [shape] as the clip.
  @override
  Path getClip(Size size) {
    return shape.getOuterPath(Offset.zero & size, textDirection: textDirection);
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

class ClipShadowPath extends StatelessWidget {
  final List<ShapeShadow>? shadows;
  final CustomClipper<Path> clipper;
  final Widget child;

  ClipShadowPath({
    this.shadows,
    required this.clipper,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ClipShapeShadowPainter(
        clipper: this.clipper,
        shadows: this.shadows,
      ),
      child: ClipPath(child: child, clipper: this.clipper),
    );
  }
}

class _ClipShapeShadowPainter extends CustomPainter {
  final List<ShapeShadow>? shadows;
  final CustomClipper<Path> clipper;

  _ClipShapeShadowPainter({required this.shadows, required this.clipper});

  @override
  void paint(Canvas canvas, Size size) {
    shadows?.forEach((element) {
      Rect rect = Rect.fromLTRB(0, 0, size.width, size.height)
          .inflate(element.spreadRadius);
      var paint = element.toPaint()
        ..shader = element.gradient?.createShader(rect);
      var clipPath =
          clipper.getClip(rect.size).shift(element.offset + rect.topLeft);
      canvas.drawPath(clipPath, paint);
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class ClipInsetShadowPath extends StatelessWidget {
  final List<ShapeShadow>? shadows;
  final CustomClipper<Path> clipper;
  final Widget child;
  final Decoration decoration;

  ClipInsetShadowPath({
    this.shadows,
    required this.clipper,
    required this.child,
    required this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: decoration,
      child: CustomPaint(
        painter: _ClipInsetShapeShadowPainter(
          clipper: this.clipper,
          shadows: this.shadows,
        ),
        child: child,
      ),
    );
  }
}

class _ClipInsetShapeShadowPainter extends CustomPainter {
  final List<ShapeShadow>? shadows;
  final CustomClipper<Path> clipper;

  _ClipInsetShapeShadowPainter({
    required this.shadows,
    required this.clipper,
  });

  @override
  void paint(Canvas canvas, Size size) {
    shadows?.forEach((element) {
      Rect rect = Rect.fromLTRB(0, 0, size.width, size.height)
          .deflate(element.spreadRadius);

      Rect outerRect = Rect.fromLTRB(0, 0, size.width, size.height)
          .inflate(element.blurRadius);

      var paint = element.toPaint()
        ..shader = element.gradient?.createShader(rect);
      Path clipPath;
      if (rect.isEmpty) {
        clipPath = Path()..moveTo(rect.center.dx, rect.center.dy);
      } else {
        clipPath =
            clipper.getClip(rect.size).shift(element.offset + rect.topLeft);
      }
      Path outerPath = Path()
        ..moveTo(outerRect.topLeft.dx, outerRect.topLeft.dy)
        ..lineTo(outerRect.topRight.dx, outerRect.topRight.dy)
        ..lineTo(outerRect.bottomRight.dx, outerRect.bottomRight.dy)
        ..lineTo(outerRect.bottomLeft.dx, outerRect.bottomLeft.dy)
        ..close();

      Path finalPath = Path.combine(
        PathOperation.difference,
        outerPath,
        clipPath,
      );
      canvas.drawPath(finalPath, paint);
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class _ShapeBorderPaint extends StatelessWidget {
  const _ShapeBorderPaint({
    this.child,
    this.shape,
    this.borderOnForeground = true,
  });

  final Widget? child;
  final ShapeBorder? shape;
  final bool borderOnForeground;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      child: child,
      painter: borderOnForeground
          ? null
          : _ShapeBorderPainter(shape, Directionality.maybeOf(context)),
      foregroundPainter: borderOnForeground
          ? _ShapeBorderPainter(shape, Directionality.maybeOf(context))
          : null,
    );
  }
}

class _ShapeBorderPainter extends CustomPainter {
  _ShapeBorderPainter(this.border, this.textDirection);
  final ShapeBorder? border;
  final TextDirection? textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    border?.paint(canvas, Offset.zero & size, textDirection: textDirection);
  }

  @override
  bool shouldRepaint(_ShapeBorderPainter oldDelegate) {
    return oldDelegate.border != border;
  }
}

class DecoratedShadowedShape extends StatelessWidget {
  final ShapeBorder? shape;
  final List<ShapeShadow>? shadows;
  final List<ShapeShadow>? insetShadows;
  final Decoration? decoration;
  final Widget? child;

  DecoratedShadowedShape(
      {this.shape,
      this.shadows,
      this.insetShadows,
      this.decoration,
      this.child});

  @override
  Widget build(BuildContext context) {
    CustomClipper<Path> clipper = CustomShapeBorderClipper(
      shape: shape ?? MorphableShapeBorder(shape: RectangleShape()),
      textDirection: Directionality.maybeOf(context),
    );
    return ClipShadowPath(
      clipper: clipper,
      shadows: shadows,
      child: _ShapeBorderPaint(
        shape: shape,
        child: ClipInsetShadowPath(
          decoration: decoration ?? BoxDecoration(),
          clipper: clipper,
          shadows: insetShadows,
          child: child ??
              LimitedBox(
                maxWidth: 0.0,
                maxHeight: 0.0,
                child:
                    ConstrainedBox(constraints: const BoxConstraints.expand()),
              ),
        ),
      ),
    );
  }
}
