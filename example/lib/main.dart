import 'package:flutter/material.dart';
import 'edit_shape_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Shape Editor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: EditShapePage(),
    );
  }
}


