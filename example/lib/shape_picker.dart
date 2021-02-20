import 'package:flutter/material.dart';
import 'package:morphable_shape/morphable_shape.dart';

bool useWhiteForeground(Color color) {
  return 1.05 / (color.computeLuminance() + 0.05) > 4.5;
}

typedef PickerLayoutBuilder = Widget Function(
    BuildContext context, List<String> allShape, PickerItem child);
typedef PickerItem = Widget Function(String shape);
typedef PickerItemBuilder = Widget Function(
  String shape,
  bool isCurrentShape,
  void Function() changeShape,
);

class BlockShapePicker extends StatefulWidget {
  const BlockShapePicker({
    @required this.onShapeChanged,
    this.itemBuilder = defaultItemBuilder,
  });

  final ValueChanged<String> onShapeChanged;
  final PickerItemBuilder itemBuilder;

  static Widget defaultItemBuilder(
      String shape, bool isCurrentShape, void Function() changeShape) {
    return Material(
      clipBehavior: Clip.antiAlias,
      type: MaterialType.canvas,
      shape: MorphableShapeBorder(
        shape: presetShapeMap[shape] ??
            RectangleShape(
                borderRadius: DynamicBorderRadius.all(DynamicRadius.zero)),
        //borderWidth: isCurrentShape ? 4 : 2,
        //borderColor: isCurrentShape ? Colors.black87 : Colors.grey
      ),
      child: Container(
        color:
            isCurrentShape ? Colors.black.withOpacity(0.7) : Colors.transparent,
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
  String _currentShape;

  @override
  void initState() {
    _currentShape = "Rectangle";
    super.initState();
  }

  void changeShape(String shape) {
    setState(() => _currentShape = shape);
    widget.onShapeChanged(shape);
  }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;

    return Container(
      width: orientation == Orientation.portrait ? 300.0 : 300.0,
      height: orientation == Orientation.portrait ? 360.0 : 200.0,
      child: GridView.count(
        crossAxisCount: orientation == Orientation.portrait ? 4 : 6,
        crossAxisSpacing: 15.0,
        mainAxisSpacing: 15.0,
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        children: presetShapeMap.keys
            .map((String shape) => widget.itemBuilder(
                shape, shape == _currentShape, () => changeShape(shape)))
            .toList(),
      ),
    );
  }
}

class BottomSheetShapePicker extends StatefulWidget {
  BottomSheetShapePicker({
    this.headText = "Pick a shape",
    this.currentShape,
    @required this.valueChanged,
  });

  final String headText;
  final Shape currentShape;
  final ValueChanged valueChanged;

  @override
  _BottomSheetShapePicker createState() => _BottomSheetShapePicker();
}

class _BottomSheetShapePicker extends State<BottomSheetShapePicker> {
  Shape currentShape;

  @override
  void initState() {
    currentShape = widget.currentShape ?? RectangleShape();
    super.initState();
  }

  void changeShape(String shape) {
    setState(() => currentShape = presetShapeMap[shape]);
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
