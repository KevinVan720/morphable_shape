import 'package:flutter/material.dart';
import 'package:length_unit/length_unit.dart';

class LengthSlider extends StatefulWidget {
  const LengthSlider({
    this.min,
    this.max,
    this.divisions = 30,
    this.sliderValue,
    @required this.valueChanged,
    @required this.constraintSize,
    this.allowedUnits = const ["px"],
  });

  final double min;
  final double max;
  final int divisions;
  final List<String> allowedUnits;
  final Length sliderValue;
  final double constraintSize;

  final ValueChanged valueChanged;

  @override
  _LengthSlider createState() => _LengthSlider();
}

class _LengthSlider extends State<LengthSlider> {
  Length _sliderValue;

  double min;
  double max;
  int divisions;

  @override
  void initState() {
    super.initState();
  }

  /*
  _updatesValue() {
    setState(() {
      double value =
          double.tryParse(textController.text) ?? widget.sliderValue.value;
      value = value.roundWithPrecision(1);
      widget.valueChanged(widget.sliderValue.copyWith(value: value));
    });
  }

   */

  @override
  Widget build(BuildContext context) {
    if (widget.sliderValue != null) {
      _sliderValue = widget.sliderValue
          .copyWith(value: widget.sliderValue.value.roundWithPrecision(1));
    } else {
      if (widget.min != null && widget.max != null) {
        _sliderValue = Length((widget.min + widget.max) / 2);
      } else {
        _sliderValue = Length(1);
      }
    }

    if (_sliderValue.unit == LengthUnit.px) {
      min = widget.min ?? 0.0;
      max = widget.max ?? widget.constraintSize.roundWithPrecision(1);
      divisions = ((max - min) > 10 ? (max - min) / 5 : (max - min)).round();
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
                      activeColor: Colors.amber,
                      inactiveColor: Colors.grey[400],
                      min: min,
                      max: max,
                      divisions: divisions,
                      //label:
                      //    '${((_sliderValue.value ?? 0) * 100).round() / 100.0}',
                      value: (_sliderValue.value ?? 0).clamp(min, max),
                      onChanged: (newValue) {
                        setState(() {
                          //textController.text =
                          //    '${newValue.roundWithPrecision(1)}';
                          widget.valueChanged(widget.sliderValue.copyWith(value: newValue));
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
            width: 110,
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
                            double newValue=double.tryParse(value) ?? widget.sliderValue.value;
                            widget.valueChanged(widget.sliderValue.copyWith(value: newValue));
                          },
                        ))
                    : Container(
                        width: 10,
                      ),
                Container(
                  width: _sliderValue != null ? 46 : 58,
                  height: 30,
                  margin: EdgeInsets.only(right: 4),
                  padding: EdgeInsets.only(left: 11),
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
                    underline: Container(),
                    value: _sliderValue.getUnit(),
                    onChanged: (String value) {
                      setState(() {
                        ///avoid null for non auto values
                        double oldPX = _sliderValue.toPX(
                              constraintSize: widget.constraintSize,
                            ) ??
                            100;
                        LengthUnit newUnit =
                            lengthUnitMap[value] ?? LengthUnit.px;
                        widget.valueChanged(_sliderValue.copyWith(
                            value: Length.newValue(
                              oldPX,
                              newUnit,
                              constraintSize: widget.constraintSize,
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
      height: 30,
      child: Row(
        children: [
          Text("X: "),
          Container(
              decoration: BoxDecoration(
                color: Colors.black38,
                border: Border.all(width: 1, color: Colors.black),
                borderRadius: BorderRadius.all(Radius.circular(4.0)),
              ),
              width: 80,
              alignment: Alignment.center,
              margin: EdgeInsets.only(right: 4),
              child: FocusTextField(
                key: ObjectKey(widget.position.dx),
                initText: widget.position.dx.toStringAsFixed(1),
                onSubmitted: (value) {
                  double dx= double.tryParse(value) ?? widget.position.dx;
                  widget.onPositionChanged(Offset(dx, widget.position.dy));
                },
              )),
          Text("Y: "),
          Container(
              decoration: BoxDecoration(
                color: Colors.black38,
                border: Border.all(width: 1, color: Colors.black),
                borderRadius: BorderRadius.all(Radius.circular(4.0)),
              ),
              width: 80,
              alignment: Alignment.center,
              margin: EdgeInsets.only(right: 4),
              child: FocusTextField(
                key: ObjectKey(widget.position.dy),
                initText: widget.position.dy.toStringAsFixed(1),
                onSubmitted: (value) {
                  double dy= double.tryParse(value) ?? widget.position.dy;
                  //double dy = double.tryParse(yController.text) ?? widget.position.dy;
                  //dy = dy.roundWithPrecision(1);
                  widget.onPositionChanged(Offset(widget.position.dx, dy));
                },
              ))
        ],
      ),
    );
  }
}

class FocusTextField extends StatefulWidget {

  final String initText;
  final Function onSubmitted;

  const FocusTextField({Key key, this.initText, this.onSubmitted}): super(key: key);

  @override
  _FocusTextFieldState createState() => _FocusTextFieldState();
}

class _FocusTextFieldState extends State<FocusTextField> {

  TextEditingController textController;

  FocusNode focus;
  @override
  void initState() {
    super.initState();

    focus = FocusNode();
    focus.addListener(() {
      if(focus.hasFocus) {
        textController.text= widget.initText;
      }else{
        textController.clear();
      }
    });
    textController =
        TextEditingController(text: widget.initText);
  }

  @override
  Widget build(BuildContext context) {

    return TextField(
      focusNode: focus,
      textAlign: TextAlign.center,
      maxLines: 1,
      decoration: InputDecoration(
        hintText: widget.initText,
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
        widget.onSubmitted(value);
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

