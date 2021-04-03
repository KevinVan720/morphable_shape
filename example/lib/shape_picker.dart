import 'dart:math';

import 'package:flutter/material.dart';
import 'package:morphable_shape/morphable_shape.dart';

bool useWhiteForeground(Color color) {
  return 1.05 / (color.computeLuminance() + 0.05) > 4.5;
}

typedef PickerLayoutBuilder = Widget Function(BuildContext context,
    List<MorphableShapeBorder> allShape, PickerItem child);
typedef PickerItem = Widget Function(MorphableShapeBorder shape);
typedef PickerItemBuilder = Widget Function(
  MorphableShapeBorder shape,
  bool isCurrentShape,
  void Function() changeShape,
);

class BlockShapePicker extends StatefulWidget {
  const BlockShapePicker({
    @required this.onShapeChanged,
    this.itemBuilder = defaultItemBuilder,
  });

  final Function onShapeChanged;
  final PickerItemBuilder itemBuilder;

  static Widget defaultItemBuilder(MorphableShapeBorder shape,
      bool isCurrentShape, void Function() changeShape) {
    return Material(
      clipBehavior: Clip.antiAlias,
      type: MaterialType.canvas,
      elevation: 1,
      shape: shape,
      child: Container(
        color: isCurrentShape
            ? Colors.black.withOpacity(0.7)
            : Colors.black.withOpacity(0.1),
        child: InkWell(
          onTap: changeShape,
          radius: 60,
          child: Container(),
        ),
      ),
    );
  }

  @override
  State<StatefulWidget> createState() => _BlockShapePickerState();
}

class _BlockShapePickerState extends State<BlockShapePicker> {
  MorphableShapeBorder _currentShape;

  @override
  void initState() {
    _currentShape = presetRoundedRectangleShapeMap["RectangleAll0"];
    super.initState();
  }

  void changeShape(MorphableShapeBorder shape) {
    setState(() {
      _currentShape = shape;
    });
    widget.onShapeChanged(shape);
  }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    Size screenSize = MediaQuery.of(context).size;

    return Container(
        width: min(screenSize.width * 0.8, 360.0),
        height: min(screenSize.height * 0.8, 360.0),
        child: ListView(
          children: presetShapeMap.keys
              .map((category) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(left: 3, top: 1, bottom: 1),
                          //color: Colors.grey.withOpacity(0.2),
                          child: Text(
                            category,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                      GridView.count(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        crossAxisCount:
                            (min(screenSize.width * 0.8, 360.0) / 50).floor(),
                        crossAxisSpacing: 15.0,
                        mainAxisSpacing: 15.0,
                        padding:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                        children:
                            presetShapeMap[category].keys.map((String name) {
                          MorphableShapeBorder shape =
                              presetShapeMap[category][name];
                          return widget.itemBuilder(shape,
                              shape == _currentShape, () => changeShape(shape));
                        }).toList(),
                      ),
                    ],
                  ))
              .toList(),
        ));
  }
}

class BottomSheetShapePicker extends StatefulWidget {
  BottomSheetShapePicker({
    this.headText = "Pick a shape",
    this.currentShape,
    @required this.valueChanged,
  });

  final String headText;
  final MorphableShapeBorder currentShape;
  final ValueChanged valueChanged;

  @override
  _BottomSheetShapePicker createState() => _BottomSheetShapePicker();
}

class _BottomSheetShapePicker extends State<BottomSheetShapePicker> {
  MorphableShapeBorder currentShape;

  @override
  void initState() {
    currentShape = widget.currentShape ?? RectangleShapeBorder();
    super.initState();
  }

  void changeShape(MorphableShapeBorder shape) {
    setState(() => currentShape = shape);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.all(0),
        child: RawMaterialButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(
                              widget.headText,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            )),
                        BlockShapePicker(
                          onShapeChanged: changeShape,
                        ),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text(
                        'Got it',
                      ),
                      onPressed: () {
                        setState(() {
                          widget.valueChanged(currentShape);
                        });
                        Navigator.of(context)?.pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
          child: Icon(
            Icons.streetview_outlined,
            size: 28,
          ),
          elevation: 5.0,
          constraints: BoxConstraints.tight(Size(24, 24)),
          padding: const EdgeInsets.all(0.5),
        ));
  }
}
