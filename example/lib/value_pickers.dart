import 'package:dimension/dimension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:morphable_shape/morphable_shape.dart';

export 'color_picker.dart';
export 'gradient_picker.dart';
export 'shape_picker.dart'
    hide useWhiteForeground, PickerItem, PickerItemBuilder, PickerLayoutBuilder;

class LengthSlider extends StatefulWidget {
  const LengthSlider({
    required this.min,
    required this.max,
    this.divisions = 30,
    this.sliderColor = Colors.amber,
    required this.value,
    required this.onChanged,
    required this.constraint,
    this.allowedUnits = const ["px"],
  });

  final double min;
  final double max;
  final int divisions;
  final Color sliderColor;
  final List<String> allowedUnits;
  final Length value;
  final double constraint;

  final ValueChanged onChanged;

  @override
  _LengthSlider createState() => _LengthSlider();
}

class _LengthSlider extends State<LengthSlider> {
  late Length _sliderValue;

  late double min;
  late double max;
  late int divisions;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.value != null) {
      _sliderValue = widget.value
          .copyWith(value: widget.value.value.roundWithPrecision(1));
    } else {
      if (widget.min != null && widget.max != null) {
        _sliderValue = Length((widget.min + widget.max) / 2);
      } else {
        _sliderValue = Length(1);
      }
    }

    if (_sliderValue.unit == LengthUnit.px) {
      min = widget.min ?? 0.0;
      max = widget.max ?? widget.constraint.roundWithPrecision(1);
      divisions = widget.divisions ??
          ((max - min) > 10 ? (max - min) / 5 : (max - min)).round();
    } else {
      min = 0;
      max = 100.0;
      divisions = widget.divisions;
    }

    return Container(
      height: 50,
      child: Row(
        children: <Widget>[
          Expanded(
              child: Container(
                  padding: EdgeInsets.only(top: 3.0),
                  alignment: Alignment.center,
                  child: Offstage(
                    offstage: _sliderValue == null,
                    child: Slider(
                      activeColor: widget.sliderColor,
                      min: min,
                      max: max,
                      divisions: divisions,
                      value: (_sliderValue.value ?? 0).clamp(min, max),
                      onChanged: (newValue) {
                        setState(() {
                          widget.onChanged(
                              widget.value.copyWith(value: newValue));
                        });
                      },
                    ),
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
                _sliderValue != null
                    ? Container(
                        alignment: Alignment.centerLeft,
                        width: 50,
                        child: FocusTextField(
                          key: ObjectKey(_sliderValue.value),
                          initText: _sliderValue.value.toStringAsFixed(1),
                          onSubmitted: (value) {
                            double newValue =
                                double.tryParse(value) ?? widget.value.value;
                            widget.onChanged(
                                widget.value.copyWith(value: newValue));
                          },
                        ))
                    : Container(
                        width: 10,
                      ),
                Container(
                  width: _sliderValue != null ? 38 : 50,
                  height: 30,
                  margin: EdgeInsets.only(right: 4),
                  padding: EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.25),
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
                    onChanged: (String value) {
                      setState(() {
                        ///avoid null for non auto values
                        double oldPX = _sliderValue.toPX(
                              constraint: widget.constraint,
                            ) ??
                            100;
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
                        child: Container(width: 100, child: Text(value)),
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

  @override
  void dispose() {
    super.dispose();
  }
}

class FixedUnitValuePicker extends StatefulWidget {
  final double value;
  final String unit;
  final Function onValueChanged;

  FixedUnitValuePicker({this.value, this.unit, this.onValueChanged});

  @override
  _FixedUnitValuePickerState createState() => _FixedUnitValuePickerState();
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
                color: Colors.grey.withOpacity(0.25),
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
  final Size constraintSize;
  final Function onPositionChanged;

  const OffsetPicker(
      {this.position, this.onPositionChanged, this.constraintSize});

  @override
  _OffsetPickerState createState() => _OffsetPickerState();
}

class _OffsetPickerState extends State<OffsetPicker> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
  final Function onSubmitted;

  const FocusTextField({Key key, this.initText, this.onSubmitted})
      : super(key: key);

  @override
  _FocusTextFieldState createState() => _FocusTextFieldState();
}

class _FocusTextFieldState extends State<FocusTextField> {
  TextEditingController textController;
  FocusNode focus;
  String hintText;
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
