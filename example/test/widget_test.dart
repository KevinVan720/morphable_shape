import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shape_editor/edit_shape_page.dart';
import 'package:flutter_shape_editor/main.dart';
import 'package:flutter_shape_editor/morph_shape_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morphable_shape/morphable_shape.dart';

/// Runs [body] with the app pumped in a large window.
///
/// The test font draws every glyph as a full square, so texts are a lot wider
/// than with the fonts the app uses. The layout overflows this causes in the
/// side panels are not what this smoke test is about and are ignored, every
/// other error fails the test.
Future<void> withApp(WidgetTester tester, Future<void> Function() body) async {
  tester.view.physicalSize = const Size(1600, 1000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final FlutterExceptionHandler? handler = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    if (!details.exceptionAsString().contains('A RenderFlex overflowed')) {
      handler?.call(details);
    }
  };
  try {
    await tester.pumpWidget(const MyApp());
    await tester.pump();
    await body();
  } finally {
    FlutterError.onError = handler;
  }
}

Future<void> toggleEditing(WidgetTester tester) async {
  final Finder shape = find.byType(DecoratedShadowedShape);
  await tester.tap(shape, warnIfMissed: false);
  await tester.pump(kDoubleTapMinTime);
  await tester.tap(shape, warnIfMissed: false);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the shape editor starts', (WidgetTester tester) async {
    await withApp(tester, () async {
      expect(find.text('Edit Shape'), findsOneWidget);
      expect(find.byType(DecoratedShadowedShape), findsOneWidget);
    });
  });

  testWidgets('every shape can be edited', (WidgetTester tester) async {
    await withApp(tester, () async {
      await toggleEditing(tester);
      expect(find.text('BASIC'), findsOneWidget);

      final EditShapePageState state =
          tester.state<EditShapePageState>(find.byType(EditShapePage));
      // one preset of every shape type, plus shapes with borders
      final Map<Type, MorphableShapeBorder> presets = {
        for (final group in presetShapeMap.values)
          for (final shape in group.values) shape.runtimeType: shape,
      };
      final List<MorphableShapeBorder> shapes = [
        ...presets.values,
        const RoundedRectangleShapeBorder(
            borderSides: RectangleBorderSides.all(
                DynamicBorderSide(width: 4, color: Colors.red))),
        const CircleShapeBorder(
            border: DynamicBorderSide(
                width: 4,
                gradient: LinearGradient(colors: [Colors.red, Colors.blue]))),
      ];
      for (final shape in shapes) {
        // ignore: invalid_use_of_protected_member
        state.setState(() => state.updateCurrentShape(shape));
        for (final tab in ['SHAPE', 'BORDER', 'BASIC']) {
          await tester.tap(find.text(tab));
          await tester.pumpAndSettle();
        }
      }

      // convert the current shape to a freeform path and edit that
      await tester.tap(find.text('CONVERT'));
      await tester.pumpAndSettle();
      expect(state.currentShapeBorder, isA<PathShapeBorder>());
      await tester.tap(find.text('SHAPE'));
      await tester.pumpAndSettle();
    });
  });

  testWidgets('the morph page animates', (WidgetTester tester) async {
    await withApp(tester, () async {
      await tester.tap(find.byIcon(Icons.remove_red_eye));
      // the morph animation repeats forever, it never settles
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.byType(MorphShapePage), findsOneWidget);
    });
  });
}
