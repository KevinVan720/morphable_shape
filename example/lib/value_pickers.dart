import 'package:flutter/material.dart';
import 'package:morphable_shape/morphable_shape.dart';

export 'color_picker.dart';
export 'gradient_picker.dart';
export 'shape_picker.dart'
    hide useWhiteForeground, PickerItem, PickerItemBuilder, PickerLayoutBuilder;

class LengthSlider extends StatefulWidget {
  const LengthSlider({
    super.key,
    this.min,
    this.max,
    this.divisions = 30,
    this.sliderColor = Colors.amber,
    required this.value,
    required this.onChanged,
    this.constraint,
    this.allowedUnits = const ["px"],
  });

  final double? min;
  final double? max;
  final int divisions;
  final Color sliderColor;
  final List<String> allowedUnits;

  ///the editor only creates [Length]s, other dimensions are shown in px
  final Dimension value;
  final double? constraint;

  final ValueChanged<Length> onChanged;

  @override
  State<LengthSlider> createState() => _LengthSlider();
}

class _LengthSlider extends State<LengthSlider> {
  late Length _sliderValue;

  late double min;
  late double max;
  late int divisions;

  Length get _value {
    Dimension value = widget.value;
    return value is Length
        ? value
        : Length(value.toPX(constraint: widget.constraint));
  }

  @override
  Widget build(BuildContext context) {
    _sliderValue = _value.copyWith(value: _value.value.roundWithPrecision(1));

    if (_sliderValue.unit == LengthUnit.px) {
      min = widget.min ?? 0.0;
      max = widget.max ?? (widget.constraint ?? 100.0).roundWithPrecision(1);
      divisions = widget.divisions;
    } else {
      min = 0;
      max = 100.0;
      divisions = widget.divisions;
    }

    return SizedBox(
      height: 50,
      child: Row(
        children: <Widget>[
          Expanded(
              child: Container(
                  padding: const EdgeInsets.only(top: 3.0),
                  alignment: Alignment.center,
                  child: Slider(
                    activeColor: widget.sliderColor,
                    min: min,
                    max: max,
                    divisions: divisions,
                    value: _sliderValue.value.clamp(min, max),
                    onChanged: (newValue) {
                      setState(() {
                        widget.onChanged(_value.copyWith(value: newValue));
                      });
                    },
                  ))),
          //editable text field
          Container(
            decoration: BoxDecoration(
              color: Colors.black38,
              border: Border.all(width: 1, color: Colors.black),
              borderRadius: BorderRadius.all(Radius.circular(4.0)),
            ),
            width: 100,
            height: 40,
            margin: EdgeInsets.only(right: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                    alignment: Alignment.centerLeft,
                    width: 50,
                    child: FocusTextField(
                      key: ObjectKey(_sliderValue.value),
                      initText: _sliderValue.value.toStringAsFixed(1),
                      onSubmitted: (value) {
                        double newValue =
                            double.tryParse(value) ?? _value.value;
                        widget.onChanged(_value.copyWith(value: newValue));
                      },
                    )),
                Container(
                  width: 38,
                  height: 30,
                  margin: EdgeInsets.only(right: 4),
                  padding: EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.all(Radius.circular(4.0)),
                  ),
                  alignment: Alignment.center,
                  child: DropdownButton<String>(
                    elevation: 1,
                    style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        letterSpacing: 0.1,
                        color: Colors.black),
                    isDense: true,
                    isExpanded: true,
                    iconSize: 0,
                    icon: null,
                    underline: Container(),
                    value: _sliderValue.getUnit(),
                    onChanged: (String? value) {
                      setState(() {
                        double oldPX = _sliderValue.toPX(
                          constraint: widget.constraint,
                        );
                        LengthUnit newUnit =
                            lengthUnitMap[value] ?? LengthUnit.px;
                        widget.onChanged(_sliderValue.copyWith(
                            value: Length.fromPX(
                              oldPX,
                              newUnit,
                              constraint: widget.constraint,
                            ),
                            unit: newUnit));
                        //myController.text =
                        //    '${(_sliderValue.value * 100).round() / 100.0}';
                      });
                    },
                    items: widget.allowedUnits
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: SizedBox(width: 100, child: Text(value)),
                      );
                    }).toList(),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FixedUnitValuePicker extends StatefulWidget {
  final double value;
  final String unit;
  final ValueChanged<double> onValueChanged;

  const FixedUnitValuePicker(
      {super.key,
      required this.value,
      required this.unit,
      required this.onValueChanged});

  @override
  State<FixedUnitValuePicker> createState() => _FixedUnitValuePickerState();
}

class _FixedUnitValuePickerState extends State<FixedUnitValuePicker> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black38,
        border: Border.all(width: 1, color: Colors.black),
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
      width: 100,
      height: 40,
      margin: EdgeInsets.only(right: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(
              alignment: Alignment.centerLeft,
              width: 50,
              child: FocusTextField(
                key: ObjectKey(widget.value),
                initText: widget.value.toStringAsFixed(1),
                onSubmitted: (value) {
                  double newValue = double.tryParse(value) ?? widget.value;
                  widget.onValueChanged(newValue);
                },
              )),
          Container(
              width: 38,
              height: 30,
              margin: EdgeInsets.only(right: 4),
              padding: EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.25),
                borderRadius: BorderRadius.all(Radius.circular(4.0)),
              ),
              alignment: Alignment.center,
              child: Text(
                widget.unit,
                style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 0.1,
                    color: Colors.black),
              ))
        ],
      ),
    );
  }
}

class OffsetPicker extends StatefulWidget {
  final Offset position;
  final Size? constraintSize;
  final ValueChanged<Offset> onPositionChanged;

  const OffsetPicker(
      {super.key,
      required this.position,
      required this.onPositionChanged,
      this.constraintSize});

  @override
  State<OffsetPicker> createState() => _OffsetPickerState();
}

class _OffsetPickerState extends State<OffsetPicker> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Row(
        children: [
          Text("X  "),
          FixedUnitValuePicker(
            value: widget.position.dx,
            onValueChanged: (value) {
              widget.onPositionChanged(Offset(value, widget.position.dy));
            },
            unit: "px",
          ),
          Container(
            width: 10,
          ),
          Text("Y  "),
          FixedUnitValuePicker(
            value: widget.position.dy,
            onValueChanged: (value) {
              widget.onPositionChanged(Offset(widget.position.dx, value));
            },
            unit: "px",
          ),
        ],
      ),
    );
  }
}

class FocusTextField extends StatefulWidget {
  final String initText;
  final ValueChanged<String> onSubmitted;

  const FocusTextField(
      {super.key, required this.initText, required this.onSubmitted});

  @override
  State<FocusTextField> createState() => _FocusTextFieldState();
}

class _FocusTextFieldState extends State<FocusTextField> {
  late TextEditingController textController;
  late FocusNode focus;
  late String hintText;
  bool hasSubmitted = false;

  @override
  void initState() {
    super.initState();

    hintText = widget.initText;
    focus = FocusNode();
    focus.addListener(() {
      if (focus.hasFocus) {
        textController.text = widget.initText;
      } else {
        textController.clear();
      }
    });
    textController = TextEditingController(text: widget.initText);
    textController.addListener(() {
      if (textController.text.isEmpty) {
        if (!hasSubmitted) {
          setState(() {
            hintText = "";
          });
        } else {
          setState(() {
            hasSubmitted = false;
            hintText = widget.initText;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: focus,
      textAlign: TextAlign.center,
      maxLines: 1,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white),
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.all(0),
      ),
      style: TextStyle(
          fontSize: 16,
          fontStyle: FontStyle.italic,
          letterSpacing: 0.5,
          color: Colors.white),
      controller: textController,
      onSubmitted: (value) {
        if (value.isEmpty) {
          setState(() {
            hasSubmitted = true;
          });
        } else {
          widget.onSubmitted(value);
        }
      },
    );
  }

  @override
  void dispose() {
    focus.dispose();
    textController.dispose();
    super.dispose();
  }
}
