import 'package:morphable_shape/src/common_includes.dart';

///Why is there no shapeTween?
///Because to morph shape we need to know the rect at every time step,
/// which can only be retrieved from a shapeBorder
class MorphableShapeBorderTween extends Tween<MorphableShapeBorder?> {
  MorphShapeData? data;
  MorphMethod method;
  MorphableShapeBorderTween(
      {super.begin, super.end, this.method = MorphMethod.auto});

  @override
  MorphableShapeBorder? lerp(double t) {
    if (begin == null && end == null) {
      return null;
    }

    ///a missing shape is morphed from/to a rectangle, a morph shape (e.g. the
    ///current value of an interrupted animation) is replaced by its own
    ///begin/end shape
    MorphableShapeBorder beginShape = switch (begin) {
      null => const RectangleShapeBorder(),
      MorphShapeBorder morph => morph.morphData.begin,
      MorphableShapeBorder shape => shape,
    };
    MorphableShapeBorder endShape = switch (end) {
      null => const RectangleShapeBorder(),
      MorphShapeBorder morph => morph.morphData.end,
      MorphableShapeBorder shape => shape,
    };

    ///the morph data is expensive to compute, only do it when the shapes change
    if (data == null ||
        data!.begin != beginShape ||
        data!.end != endShape ||
        data!.method != method) {
      data = MorphShapeData(
          begin: beginShape,
          end: endShape,
          boundingBox: const Rect.fromLTRB(0, 0, 100, 100),
          method: method);
      DynamicPathMorph.sampleBorderPathsFromShape(data!);
    }
    return MorphShapeBorder(t: t, morphData: data!);
  }
}
