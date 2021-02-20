import 'package:flutter/material.dart';

const List<ColorSwatch> materialColors = const <ColorSwatch>[
  const ColorSwatch(0xFFFFFFFF, {500: Colors.white}),
  const ColorSwatch(0xFF000000, {500: Colors.black}),
  Colors.red,
  Colors.pink,
  Colors.purple,
  Colors.deepPurple,
  Colors.indigo,
  Colors.blue,
  Colors.lightBlue,
  Colors.cyan,
  Colors.teal,
  Colors.green,
  Colors.lightGreen,
  Colors.lime,
  Colors.yellow,
  Colors.amber,
  Colors.orange,
  Colors.deepOrange,
  Colors.brown,
  Colors.blueGrey
];

List<Color> _getMaterialColorShades(ColorSwatch color) {
  return <Color>[
    if (color[50] != null) color[50],
    if (color[100] != null) color[100],
    if (color[200] != null) color[200],
    if (color[300] != null) color[300],
    if (color[400] != null) color[400],
    if (color[500] != null) color[500],
    if (color[600] != null) color[600],
    if (color[700] != null) color[700],
    if (color[800] != null) color[800],
    if (color[900] != null) color[900],
  ];
}

List<Color> MaterialColorShade = materialColors
    .sublist(2)
    .map((color) => _getMaterialColorShades(color))
    .expand((i) => i)
    .toList();

bool useWhiteForeground(Color color) {
  return 1.05 / (color.computeLuminance() + 0.05) > 4.5;
}

typedef PickerLayoutBuilder = Widget Function(
    BuildContext context, List<Color> colors, PickerItem child);
typedef PickerItem = Widget Function(Color color);
typedef PickerItemBuilder = Widget Function(
  Color color,
  bool isCurrentColor,
  void Function() changeColor,
);

class BlockColorPicker extends StatefulWidget {
  const BlockColorPicker({
    @required this.pickerColor,
    @required this.onColorChanged,
    this.availableColors = materialColors,
    this.layoutBuilder = defaultLayoutBuilder,
    this.itemBuilder = defaultItemBuilder,
  });

  final Color pickerColor;
  final ValueChanged<Color> onColorChanged;
  final List<Color> availableColors;
  final PickerLayoutBuilder layoutBuilder;
  final PickerItemBuilder itemBuilder;

  static Widget defaultLayoutBuilder(
      BuildContext context, List<Color> colors, PickerItem child) {
    Orientation orientation = MediaQuery.of(context).orientation;

    return Container(
      width: orientation == Orientation.portrait ? 300.0 : 400.0,
      height: orientation == Orientation.portrait ? 360.0 : 160.0,
      child: GridView.count(
        physics: ClampingScrollPhysics(),
        shrinkWrap: true,
        crossAxisCount: orientation == Orientation.portrait ? 4 : 8,
        crossAxisSpacing: 5.0,
        mainAxisSpacing: 5.0,
        children: colors.map((Color color) => child(color)).toList(),
      ),
    );
  }

  static Widget denseLayoutBuilder(
      BuildContext context, List<Color> colors, PickerItem child) {
    Orientation orientation = MediaQuery.of(context).orientation;

    return Container(
      width: orientation == Orientation.portrait ? 300.0 : 400.0,
      height: orientation == Orientation.portrait ? 360.0 : 160.0,
      child: GridView.builder(
        physics: ClampingScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 10,
          crossAxisSpacing: 0,
          mainAxisSpacing: 2,
        ),
        itemBuilder: (BuildContext context, int index) {
          return child(colors[index]);
        },
        itemCount: colors.length,
      ),
    );
  }

  static Widget defaultItemBuilder(
      Color color, bool isCurrentColor, void Function() changeColor) {
    return Container(
      margin: EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50.0),
        color: color,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.8),
            offset: Offset(1.0, 2.0),
            blurRadius: 3.0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: changeColor,
          borderRadius: BorderRadius.circular(50.0),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 210),
            opacity: isCurrentColor ? 1.0 : 0.0,
            child: Icon(
              Icons.done,
              color: useWhiteForeground(color) ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  static Widget denseItemBuilder(
      Color color, bool isCurrentColor, void Function() changeColor) {
    return Container(
      decoration: BoxDecoration(
        color: color,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: changeColor,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 210),
            opacity: isCurrentColor ? 1.0 : 0.0,
            child: Icon(
              Icons.done,
              color: useWhiteForeground(color) ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  @override
  State<StatefulWidget> createState() => _BlockColorPickerState();
}

class _BlockColorPickerState extends State<BlockColorPicker> {
  Color _currentColor;
  double _currentOpacity;

  @override
  void initState() {
    _currentColor = widget.pickerColor;
    _currentOpacity = _currentColor.opacity;
    super.initState();
  }

  void changeColor(Color color) {
    setState(() {
      _currentColor = color;
      _currentOpacity = 1;
    });
    widget.onColorChanged(_currentColor);
  }

  void changeOpacity(double opacity) {
    setState(() {
      _currentOpacity = opacity;
    });
    widget.onColorChanged(_currentColor.withOpacity(_currentOpacity));
  }

  @override
  Widget build(BuildContext context) {
    Widget opacityWidgets = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Flexible(
          flex: 1,
          child: Text("Opacity: "),
        ),
        Flexible(
            flex: 3,
            child: Slider(
              activeColor: Colors.blueAccent,
              min: 0.0,
              max: 1.0,
              divisions: 10,
              label: '${_currentOpacity}',
              value: _currentOpacity,
              onChanged: changeOpacity,
            )),
      ],
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        widget.layoutBuilder(
          context,
          widget.availableColors.map((Color f) => f).toList(),
          (Color color) => widget.itemBuilder(
              color,
              _currentColor.withOpacity(1) == color.withOpacity(1),
              () => changeColor(color)),
        ),
        SizedBox(height: 50, child: opacityWidgets)
      ],
    );
  }
}

class BottomSheetColorPicker extends StatefulWidget {
  BottomSheetColorPicker({
    Key key,
    this.headText = "Pick a color",
    this.currentColor,
    @required this.valueChanged,
  }) : super(key: key);

  final String headText;
  final Color currentColor;
  final ValueChanged valueChanged;

  @override
  _BottomSheetColorPicker createState() => _BottomSheetColorPicker();
}

class _BottomSheetColorPicker extends State<BottomSheetColorPicker> {
  Color currentColor;

  @override
  void initState() {
    currentColor = widget.currentColor ?? Colors.black;
    super.initState();
  }

  void changeColor(Color color) {
    setState(() => currentColor = color);
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
                        BlockColorPicker(
                          pickerColor: currentColor,
                          onColorChanged: changeColor,
                        ),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text(
                        'More Colors',
                      ),
                      onPressed: () {
                        Navigator.of(context)?.pop();
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              content: SingleChildScrollView(
                                child: BlockColorPicker(
                                  pickerColor: currentColor,
                                  onColorChanged: changeColor,
                                  layoutBuilder:
                                      BlockColorPicker.denseLayoutBuilder,
                                  itemBuilder:
                                      BlockColorPicker.denseItemBuilder,
                                  availableColors: MaterialColorShade,
                                ),
                              ),
                              actions: <Widget>[
                                FlatButton(
                                  child: const Text('Got it'),
                                  onPressed: () {
                                    setState(() {
                                      widget.valueChanged(currentColor);
                                    });
                                    Navigator.of(context)?.pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    TextButton(
                      child: const Text('Got it'),
                      onPressed: () {
                        setState(() {
                          widget.valueChanged(currentColor);
                        });
                        Navigator.of(context)?.pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
          child: Container(
            decoration: BoxDecoration(
                color: currentColor, border: Border.all(color: Colors.black)),
          ),
          elevation: 5.0,
          constraints: BoxConstraints.tight(Size(24, 24)),
          padding: const EdgeInsets.all(0.5),
        ));
  }
}
