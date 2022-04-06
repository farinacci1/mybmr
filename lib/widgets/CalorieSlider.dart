import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mybmr/constants/messages/en_messages.dart';

class CalorieSlider extends StatefulWidget {
  /*
  * Calorie slider is a slider widget that represents all selectable calorie groups in range startCalories to endCalories
  * designed to aid in filtering of recipes
  * */

  final double calorieStartRange;
  final double calorieEndRange;
  final double defaultCalories;
  final int divisions;
  final ValueSetter<double> onChanged;
  final Color activeColor;
  final Color inactiveColor;
  const CalorieSlider(
      {Key key,
      this.calorieStartRange = 250,
      this.calorieEndRange = 4000,
      this.defaultCalories = 500,
      this.onChanged,
      this.divisions = 15,
        this.activeColor =  Colors.purpleAccent,
        this.inactiveColor =Colors.purple
      })
      : super(key: key);

  @override
  _CalorieSliderState createState() => _CalorieSliderState();
}

class _CalorieSliderState extends State<CalorieSlider> {
  double _calorieVal = 0;
  TextEditingController _controller;
  @override
  void initState() {
    _controller = new TextEditingController();
    _controller.text = widget.defaultCalories.toInt().toString();
    _calorieVal = widget.defaultCalories;
    super.initState();
  }
  @override void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
        BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width,
            maxHeight: MediaQuery.of(context).size.height),
        designSize: Size(2400, 1080),
        context: context,
        minTextAdapt: true,
        orientation: Orientation.portrait);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
                width: 79.5.h,
                height: 53.h,
                alignment: AlignmentDirectional.bottomCenter,
                child: TextField(
                  enabled: false,

                  controller: _controller,
                  textAlign: TextAlign.center,
                  textAlignVertical: TextAlignVertical.bottom,
                  style: TextStyle(fontSize: 18.55.h),
                )),
            AutoSizeText(
              "   ${en_messages["calories_label"]}",
              maxLines: 1,
              style: TextStyle(fontSize: 18.55.h, fontWeight: FontWeight.bold),
            )
          ],
        ),
        Slider(
            value: _calorieVal,
            min: widget.calorieStartRange,
            max: widget.calorieEndRange,
            divisions: widget.divisions,
            activeColor: widget.activeColor,
            inactiveColor: widget.inactiveColor,
            onChanged: (double val) {
              setState(() {
                _calorieVal = val.ceilToDouble();
                _controller.text = _calorieVal.toInt().toString();
                if (widget.onChanged != null) widget.onChanged(_calorieVal);
              });
            })

      ],
    );
  }
}
