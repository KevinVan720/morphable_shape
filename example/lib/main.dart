import 'package:flutter/material.dart';

import 'edit_shape_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Shape Editor',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        primaryColor: Colors.amber,
        sliderTheme: SliderTheme.of(context).copyWith(
          inactiveTrackColor: Colors.black.withValues(alpha: 0.2),
          thumbColor: Colors.amber,
          activeTrackColor: Colors.amber,
          overlayColor: Colors.amber.withValues(alpha: 0.2),
        ),
      ),
      home: const EditShapePage(),
    );
  }
}
