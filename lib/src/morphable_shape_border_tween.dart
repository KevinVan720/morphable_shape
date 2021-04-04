import 'package:morphable_shape/src/common_includes.dart';
import 'package:morphable_shape/src/shape_borders/morph.dart';

///Why is there no shapeTween?
///Because to morph shape we need to know the rect at every time step,
/// which can only be retrieved from a shapeBorder
class MorphableShapeBorderTween extends Tween<MorphableShapeBorder?> {
  MorphShapeData? data;
  MorphMethod method;
  MorphableShapeBorderTween(
      {MorphableShapeBorder? begin,
      MorphableShapeBorder? end,
      this.method = MorphMethod.auto})
      : super(begin: begin, end: end);

  @override
  MorphableShapeBorder? lerp(double t) {
    if (begin == null && end == null) {
      return null;
    }
    if (begin == null) {
      if (data == null || end != data!.end) {
        data = MorphShapeData(
            begin: RectangleShapeBorder(),
            end: !(end! is MorphShapeBorder)
                ? end!
                : (end! as MorphShapeBorder).morphData.end,
            boundingBox: Rect.fromLTRB(0, 0, 100, 100),
            method: method);
        DynamicPathMorph.sampleBorderPathsFromShape(data!);
      }
      return MorphShapeBorder(t: t, morphData: data!);
    } else if (end == null) {
      if (data == null) {
        data = MorphShapeData(
            begin: !(begin! is MorphShapeBorder)
                ? begin!
                : (begin! as MorphShapeBorder).morphData.begin,
            end: RectangleShapeBorder(),
            boundingBox: Rect.fromLTRB(0, 0, 100, 100),
            method: method);
        DynamicPathMorph.sampleBorderPathsFromShape(data!);
      }
      return MorphShapeBorder(t: t, morphData: data!);
    }

    if (data == null || begin != data!.begin || end != data!.end) {
      MorphableShapeBorder beginShape = !(begin! is MorphShapeBorder)
          ? begin!
          : (begin! as MorphShapeBorder).morphData.begin;
      MorphableShapeBorder endShape = !(end! is MorphShapeBorder)
          ? end!
          : (end! as MorphShapeBorder).morphData.end;
      data = MorphShapeData(
          begin: beginShape,
          end: endShape,
          boundingBox: Rect.fromLTRB(0, 0, 100, 100),
          method: method);
      DynamicPathMorph.sampleBorderPathsFromShape(data!);
    }
    return MorphShapeBorder(t: t, morphData: data!);
  }
}
