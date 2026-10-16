import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morphable_shape/morphable_shape.dart';

import 'test_utils.dart';

/// JSON produced by morphable_shape 2.0.0 (and stored by its users and by
/// fluttershape.com exports). The output must stay byte for byte identical.
const Map<String, String> fixtures = {
  'rectangle':
      r'{"type":"Rectangle","border":{"color":"ffff0000","width":4.0,"style":"solid","strokeCap":"round","strokeJoin":"round"},"borderRadius":{"topLeft":{"x":"10.0px","y":"10.0px"},"topRight":{"x":"0.0px","y":"0.0px"},"bottomLeft":{"x":"0.0px","y":"0.0px"},"bottomRight":{"x":"60.0px","y":"10.0%"}},"cornerStyles":{"topLeft":"concave","bottomLeft":"rounded","topRight":"rounded","bottomRight":"cutout"}}',
  'roundedRectangle':
      r'{"type":"RoundedRectangle","borderRadius":{"topLeft":{"x":"25.0%","y":"25.0%"},"topRight":{"x":"25.0%","y":"25.0%"},"bottomLeft":{"x":"25.0%","y":"25.0%"},"bottomRight":{"x":"25.0%","y":"25.0%"}},"borderSides":{"top":{"color":"ff2196f3","width":5.0,"style":"solid","strokeCap":"butt","strokeJoin":"miter"},"bottom":{"color":"ff000000","width":0.0,"style":"none","strokeCap":"butt","strokeJoin":"miter"},"left":{"color":"ff000000","gradient":{"colors":["ffff0000","ff00ff00"],"type":"LinearGradient","begin":"centerLeft","end":"centerRight","tileMode":"clamp"},"width":8.0,"style":"solid","strokeCap":"butt","strokeJoin":"miter"},"right":{"color":"ff000000","width":0.0,"style":"none","strokeCap":"butt","strokeJoin":"miter"}}}',
  'circle':
      r'{"type":"Circle","border":{"color":"80123456","width":2.0,"style":"solid","strokeCap":"butt","strokeJoin":"miter"}}',
  'polygon':
      r'{"type":"Polygon","border":{"color":"ff000000","width":0.0,"style":"none","strokeCap":"butt","strokeJoin":"miter"},"sides":6,"cornerRadius":"20.0%","cornerStyle":"straight"}',
  'star':
      r'{"type":"Star","border":{"color":"ff000000","width":0.0,"style":"none","strokeCap":"butt","strokeJoin":"miter"},"corners":5,"inset":"40.0%","cornerRadius":"10.0px","insetRadius":"5.0px","cornerStyle":"concave","insetStyle":"cutout"}',
  'arc':
      r'{"type":"Arc","border":{"color":"ff000000","width":0.0,"style":"none","strokeCap":"butt","strokeJoin":"miter"},"arcHeight":"30.0%","isOutward":false,"side":"top"}',
  'arrow':
      r'{"type":"Arrow","border":{"color":"ff000000","width":0.0,"style":"none","strokeCap":"butt","strokeJoin":"miter"},"side":"left","arrowHeight":"30.0px","tailWidth":"50.0%"}',
  'bubble':
      r'{"type":"Bubble","border":{"color":"ff000000","width":0.0,"style":"none","strokeCap":"butt","strokeJoin":"miter"},"side":"right","borderRadius":"12.0px","arrowHeight":"15.0%","arrowWidth":"20.0%","arrowCenterPosition":"30.0%","arrowHeadPosition":"40.0%"}',
  'trapezoid':
      r'{"type":"Trapezoid","border":{"color":"ff000000","width":0.0,"style":"none","strokeCap":"butt","strokeJoin":"miter"},"inset":"15.0%","side":"top"}',
  'triangle':
      r'{"type":"Triangle","border":{"color":"ff000000","width":0.0,"style":"none","strokeCap":"butt","strokeJoin":"miter"},"point1":{"dx":"10.0px","dy":"0.0%"},"point2":{"dx":"100.0%","dy":"50.0%"},"point3":{"dx":"0.0px","dy":"100.0%"}}',
  'path':
      r'{"type":"Path","border":{"color":"ff000000","width":0.0,"style":"none","strokeCap":"butt","strokeJoin":"miter"},"path":{"size":{"width":100.0,"height":100.0},"nodes":[{"pos":{"dx":0.0,"dy":0.0}},{"pos":{"dx":100.0,"dy":0.0},"next":{"dx":100.0,"dy":50.0}},{"pos":{"dx":50.0,"dy":100.0},"prev":{"dx":90.0,"dy":100.0}}]}}',
  'defaultRectangle':
      r'{"type":"Rectangle","border":{"color":"ff000000","width":0.0,"style":"none","strokeCap":"butt","strokeJoin":"miter"},"borderRadius":{"topLeft":{"x":"0.0px","y":"0.0px"},"topRight":{"x":"0.0px","y":"0.0px"},"bottomLeft":{"x":"0.0px","y":"0.0px"},"bottomRight":{"x":"0.0px","y":"0.0px"}},"cornerStyles":{"topLeft":"rounded","bottomLeft":"rounded","topRight":"rounded","bottomRight":"rounded"}}',
  'defaultRoundedRectangle':
      r'{"type":"RoundedRectangle","borderRadius":{"topLeft":{"x":"0.0px","y":"0.0px"},"topRight":{"x":"0.0px","y":"0.0px"},"bottomLeft":{"x":"0.0px","y":"0.0px"},"bottomRight":{"x":"0.0px","y":"0.0px"}},"borderSides":{"top":{"color":"ff000000","width":0.0,"style":"none","strokeCap":"butt","strokeJoin":"miter"},"bottom":{"color":"ff000000","width":0.0,"style":"none","strokeCap":"butt","strokeJoin":"miter"},"left":{"color":"ff000000","width":0.0,"style":"none","strokeCap":"butt","strokeJoin":"miter"},"right":{"color":"ff000000","width":0.0,"style":"none","strokeCap":"butt","strokeJoin":"miter"}}}',
};

final Map<String, MorphableShapeBorder> fixtureShapes = {
  'rectangle': const RectangleShapeBorder(
    borderRadius: DynamicBorderRadius.only(
        topLeft: DynamicRadius.circular(Length(10)),
        bottomRight: DynamicRadius.elliptical(
            Length(60), Length(10, unit: LengthUnit.percent))),
    cornerStyles: RectangleCornerStyles.only(
        topLeft: CornerStyle.concave, bottomRight: CornerStyle.cutout),
    border: DynamicBorderSide(
        width: 4,
        color: Color(0xFFFF0000),
        strokeJoin: StrokeJoin.round,
        strokeCap: StrokeCap.round),
  ),
  'roundedRectangle': const RoundedRectangleShapeBorder(
    borderRadius: DynamicBorderRadius.all(
        DynamicRadius.circular(Length(25, unit: LengthUnit.percent))),
    borderSides: RectangleBorderSides.only(
        top: DynamicBorderSide(width: 5, color: Color(0xFF2196F3)),
        left: DynamicBorderSide(
            width: 8,
            gradient: LinearGradient(
                colors: [Color(0xFFFF0000), Color(0xFF00FF00)]))),
  ),
  'circle': const CircleShapeBorder(
      border: DynamicBorderSide(width: 2, color: Color(0x80123456))),
  'polygon': const PolygonShapeBorder(
      sides: 6,
      cornerRadius: Length(20, unit: LengthUnit.percent),
      cornerStyle: CornerStyle.straight),
  'star': const StarShapeBorder(
      corners: 5,
      inset: Length(40, unit: LengthUnit.percent),
      cornerRadius: Length(10),
      insetRadius: Length(5),
      cornerStyle: CornerStyle.concave,
      insetStyle: CornerStyle.cutout),
  'arc': const ArcShapeBorder(
      side: ShapeSide.top,
      isOutward: false,
      arcHeight: Length(30, unit: LengthUnit.percent)),
  'arrow': const ArrowShapeBorder(
      side: ShapeSide.left,
      arrowHeight: Length(30),
      tailWidth: Length(50, unit: LengthUnit.percent)),
  'bubble': const BubbleShapeBorder(
      side: ShapeSide.right,
      borderRadius: Length(12),
      arrowHeight: Length(15, unit: LengthUnit.percent),
      arrowWidth: Length(20, unit: LengthUnit.percent),
      arrowCenterPosition: Length(30, unit: LengthUnit.percent),
      arrowHeadPosition: Length(40, unit: LengthUnit.percent)),
  'trapezoid': const TrapezoidShapeBorder(
      side: ShapeSide.top, inset: Length(15, unit: LengthUnit.percent)),
  'triangle': const TriangleShapeBorder(
      point1: DynamicOffset(Length(10), Length(0, unit: LengthUnit.percent)),
      point2: DynamicOffset(Length(100, unit: LengthUnit.percent),
          Length(50, unit: LengthUnit.percent)),
      point3: DynamicOffset(Length(0), Length(100, unit: LengthUnit.percent))),
  'path': PathShapeBorder(path: samplePath()),
  'defaultRectangle': const RectangleShapeBorder(),
  'defaultRoundedRectangle': const RoundedRectangleShapeBorder(),
};

MorphableShapeBorder? roundTrip(MorphableShapeBorder shape) =>
    parseMorphableShapeBorder(
        json.decode(json.encode(shape.toJson())) as Map<String, dynamic>);

MorphableShapeBorder? parseString(String source) =>
    parseMorphableShapeBorder(json.decode(source) as Map<String, dynamic>);

void main() {
  group('stored JSON stays compatible', () {
    for (final entry in fixtures.entries) {
      test('${entry.key} toJson is unchanged', () {
        expect(json.encode(fixtureShapes[entry.key]!.toJson()), entry.value);
      });

      test('${entry.key} parses to the original shape', () {
        final parsed = parseString(entry.value)!;
        expect(parsed.runtimeType, fixtureShapes[entry.key].runtimeType);
        if (parsed is PathShapeBorder) {
          expect(json.encode(parsed.toJson()), entry.value);
        } else {
          expect(parsed, fixtureShapes[entry.key]);
        }
      });
    }

    test('json written by Flutter web (whole doubles as ints) parses', () {
      // dart2js encodes 4.0 as 4 and 10.0.toString() as "10".
      const source =
          r'{"type":"Rectangle","border":{"color":"ffff0000","width":4,"style":"solid","strokeCap":"round","strokeJoin":"round"},"borderRadius":{"topLeft":{"x":"10px","y":"10px"},"topRight":{"x":"0px","y":"0px"},"bottomLeft":{"x":"0px","y":"0px"},"bottomRight":{"x":"60px","y":"10%"}},"cornerStyles":{"topLeft":"concave","bottomLeft":"rounded","topRight":"rounded","bottomRight":"cutout"}}';
      expect(parseString(source), fixtureShapes['rectangle']);

      const path =
          r'{"type":"Path","border":{"color":"ff000000","width":0,"style":"none","strokeCap":"butt","strokeJoin":"miter"},"path":{"size":{"width":100,"height":100},"nodes":[{"pos":{"dx":0,"dy":0}},{"pos":{"dx":100,"dy":0},"next":{"dx":100,"dy":50}},{"pos":{"dx":50,"dy":100},"prev":{"dx":90,"dy":100}}]}}';
      expect(json.encode(parseString(path)!.toJson()), fixtures['path']);

      expect(parseString('{"type":"Polygon","sides":6.0}'),
          const PolygonShapeBorder(sides: 6));
      expect(parseString('{"type":"Star","corners":5.0}'),
          const StarShapeBorder(corners: 5));
    });
  });

  group('round trips', () {
    for (final entry in sampleShapes().entries) {
      test(entry.key, () {
        final shape = entry.value;
        final parsed = roundTrip(shape);
        expect(parsed, isNotNull);
        expect(parsed.runtimeType, shape.runtimeType);
        expect(parsed!.toJson(), shape.toJson());
        if (shape is! PathShapeBorder) {
          expect(parsed, shape);
          expect(parsed.hashCode, shape.hashCode);
        }
      });
    }

    for (final entry in presetShapeMap.entries) {
      test('presets: ${entry.key}', () {
        for (final shape in entry.value.values) {
          expect(roundTrip(shape), shape);
        }
      });
    }
  });

  group('lenient parsing', () {
    test('null, unknown or missing types give null', () {
      expect(parseMorphableShapeBorder(null), isNull);
      expect(parseMorphableShapeBorder(<String, dynamic>{}), isNull);
      expect(parseMorphableShapeBorder({'type': 'Hexagon'}), isNull);
      expect(parseMorphableShapeBorder({'type': 'Morph'}), isNull);
    });

    test('every type parses with only its type key', () {
      final expected = <String, MorphableShapeBorder>{
        'Rectangle': const RectangleShapeBorder(),
        'RoundedRectangle': const RoundedRectangleShapeBorder(),
        'Circle': const CircleShapeBorder(),
        'Polygon': const PolygonShapeBorder(),
        'Star': const StarShapeBorder(),
        'Arc': const ArcShapeBorder(),
        // the parser has always defaulted the arrow side to bottom
        'Arrow': const ArrowShapeBorder(side: ShapeSide.bottom),
        'Bubble': const BubbleShapeBorder(),
        'Trapezoid': const TrapezoidShapeBorder(),
        'Triangle': const TriangleShapeBorder(),
      };
      for (final entry in expected.entries) {
        expect(parseMorphableShapeBorder({'type': entry.key}), entry.value,
            reason: entry.key);
      }
      final path = parseMorphableShapeBorder({'type': 'Path'});
      expect(path, isA<PathShapeBorder>());
      expect((path as PathShapeBorder).path.nodes, isEmpty);
      // an empty path shape can still be measured and painted
      path.getOuterPath(const Rect.fromLTWH(0, 0, 10, 10));
      paintShape(path, const Rect.fromLTWH(0, 0, 10, 10));
    });

    test('nested objects with missing keys use defaults', () {
      final rectangle = parseString(
          '{"type":"Rectangle","border":{},"borderRadius":{},"cornerStyles":{}}');
      expect(
          rectangle,
          const RectangleShapeBorder(
              border: DynamicBorderSide(strokeCap: StrokeCap.square)));

      final rounded = parseString(
          '{"type":"RoundedRectangle","borderRadius":{"topLeft":{"x":"5px"}},"borderSides":{"top":{"width":3}}}');
      expect(
          rounded,
          const RoundedRectangleShapeBorder(
              borderRadius: DynamicBorderRadius.only(
                  topLeft: DynamicRadius.elliptical(Length(5), Length(0))),
              borderSides: RectangleBorderSides.only(
                  top: DynamicBorderSide(
                      width: 3, strokeCap: StrokeCap.square))));

      final triangle = parseString('{"type":"Triangle","point1":{"dx":"5px"}}');
      expect((triangle as TriangleShapeBorder).point1,
          const DynamicOffset(Length(5), Length(0)));

      final path = parseString(
          '{"type":"Path","path":{"size":{"width":10,"height":10},"nodes":[{},{"pos":{"dx":10,"dy":0}},{"pos":{"dx":10,"dy":10}}]}}');
      expect((path as PathShapeBorder).path.nodes.first.position, Offset.zero);
    });
  });

  group('DynamicBorderSide json', () {
    test('keeps begin, end and shift', () {
      final side = DynamicBorderSide.fromJson(
          json.decode(json.encode(partialBorder.toJson())));
      expect(side.begin, partialBorder.begin);
      expect(side.end, partialBorder.end);
      expect(side.shift, partialBorder.shift);
      expect(side, partialBorder);
    });

    test('omits unset begin, end and shift and reads them back as unset', () {
      final map = solidBorder.toJson();
      expect(map.containsKey('begin'), isFalse);
      expect(map.containsKey('end'), isFalse);
      expect(map.containsKey('shift'), isFalse);
      expect(DynamicBorderSide.fromJson(map), solidBorder);
    });

    test('reads gradients', () {
      final side = DynamicBorderSide.fromJson(
          json.decode(json.encode(gradientBorder.toJson())));
      expect(side.gradient, linearGradient);
    });
  });

  group('ShapeShadow json', () {
    test('output is unchanged', () {
      expect(
          json.encode(const ShapeShadow(
                  color: Color(0xFF00FF00),
                  offset: Offset(1, 2),
                  blurRadius: 3,
                  spreadRadius: 4)
              .toJson()),
          '{"color":"ff00ff00","offset":{"dx":1.0,"dy":2.0},"blurRadius":3.0,"spreadRadius":4.0}');
    });

    test('round trips', () {
      for (final shadow in const [
        ShapeShadow(),
        ShapeShadow(
            color: red,
            offset: Offset(-3, 5),
            blurRadius: 8,
            spreadRadius: -2,
            gradient: radialGradient),
        ShapeShadow(blurRadius: 4, blurStyle: BlurStyle.outer),
      ]) {
        expect(parseShapeShadow(json.decode(json.encode(shadow.toJson()))),
            shadow);
      }
    });

    test('parses old and web json', () {
      expect(parseShapeShadow(null), isNull);
      expect(parseShapeShadow(<String, dynamic>{}),
          const ShapeShadow(color: Color(0x00000000)));
      expect(
          parseShapeShadow(json.decode(
              '{"color":"ff00ff00","offset":{"dx":1,"dy":2},"blurRadius":3,"spreadRadius":4}')),
          const ShapeShadow(
              color: Color(0xFF00FF00),
              offset: Offset(1, 2),
              blurRadius: 3,
              spreadRadius: 4));
    });
  });

  group('small parsers', () {
    test('enums', () {
      for (final style in CornerStyle.values) {
        expect(parseCornerStyle(style.toJson()), style);
      }
      for (final side in ShapeSide.values) {
        expect(parseShapeSide(side.toJson()), side);
      }
      expect(CornerStyle.cutout.toJson(), 'cutout');
      expect(ShapeSide.left.toJson(), 'left');
      expect(parseCornerStyle(null), isNull);
      expect(parseCornerStyle('wobbly'), isNull);
      expect(parseShapeSide(null), isNull);
      expect(parseShapeSide('middle'), isNull);
    });

    test('dynamic offsets and paths', () {
      expect(parseDynamicOffset(null), isNull);
      expect(parseDynamicOffset({'dx': '5%', 'dy': '3px'}),
          const DynamicOffset(Length(5, unit: LengthUnit.percent), Length(3)));
      expect(parseDynamicPath(null), isNull);
      expect(parseDynamicPath({'nodes': []}), isNull);
      final path = parseDynamicPath(samplePath().toJson())!;
      expect(path.size, const Size(100, 100));
      expect(path.nodes.length, 3);
      expect(path.nodes[1].next, const Offset(100, 50));
      expect(path.nodes[2].prev, const Offset(90, 100));
    });

    test('radii and sides', () {
      expect(parseDynamicRadius(null), isNull);
      expect(parseDynamicBorderRadius(null), isNull);
      expect(parseDynamicBorderSide(null), isNull);
      expect(parseRectangleBorderSide(null), isNull);
      expect(parseRectangleCornerStyle(null), isNull);
      expect(
          parseDynamicRadius({'x': '1px', 'y': '2%'}),
          const DynamicRadius.elliptical(
              Length(1), Length(2, unit: LengthUnit.percent)));
    });
  });
}
