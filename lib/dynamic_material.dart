import 'package:flutter/material.dart';

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
  final List<Shadow> shadow;
  final CustomClipper<Path> clipper;
  final Widget child;

  ClipShadowPath({
    required this.shadow,
    required this.clipper,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ClipShadowShadowPainter(
        clipper: this.clipper,
        shadow: this.shadow,
      ),
      child: ClipPath(child: child, clipper: this.clipper),
    );
  }
}

class _ShapeBorderPaint extends StatelessWidget {
  const _ShapeBorderPaint({
    required this.child,
    required this.shape,
    this.borderOnForeground = true,
  });

  final Widget child;
  final ShapeBorder shape;
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
  final ShapeBorder border;
  final TextDirection? textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    border.paint(canvas, Offset.zero & size, textDirection: textDirection);
  }

  @override
  bool shouldRepaint(_ShapeBorderPainter oldDelegate) {
    return oldDelegate.border != border;
  }
}

class _ClipShadowShadowPainter extends CustomPainter {
  final List<Shadow> shadow;
  final CustomClipper<Path> clipper;

  _ClipShadowShadowPainter({required this.shadow, required this.clipper});

  @override
  void paint(Canvas canvas, Size size) {
    shadow.forEach((element) {
      var paint = element.toPaint();
      var clipPath = clipper.getClip(size).shift(element.offset);
      canvas.drawPath(clipPath, paint);
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class DynamicMaterial extends StatelessWidget {
  final ShapeBorder shape;
  final List<Shadow> shadow;
  final Widget child;

  DynamicMaterial(
      {required this.shape, this.shadow = const [], required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipShadowPath(
      clipper: CustomShapeBorderClipper(
        shape: shape,
        textDirection: Directionality.maybeOf(context),
      ),
      shadow: shadow,
      child: _ShapeBorderPaint(
        shape: shape,
        child: child,
      ),
    );
  }
}
