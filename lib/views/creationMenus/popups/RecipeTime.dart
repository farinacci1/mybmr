import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mybmr/constants/Themes.dart';
import 'package:mybmr/services/custom_rect_twenn.dart';
import 'package:numberpicker/numberpicker.dart';

class RecipeTime extends StatefulWidget {
  const RecipeTime({Key key}) : super(key: key);
  @override
  _RecipeTimeState createState() => _RecipeTimeState();
}

class _RecipeTimeState extends State<RecipeTime> {
  int _dayValue = 0;
  int _hourValue = 0;
  int _minuteValue = 0;
  String _RecipeTimePopup = "RECIPE_TIME_POPUP";

  String timeString() {
    return "$_dayValue Days $_hourValue Hours $_minuteValue Minutes ";
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
    return Center(
        child: Hero(
            tag: _RecipeTimePopup,
            createRectTween: (begin, end) {
              return CustomRectTween(begin: begin, end: end);
            },
            child: Container(
              width: 397.5.h,
              child: Material(
                elevation: 3,
                color: color_palette["white"],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26.5.h)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                        margin: EdgeInsets.only(top: 15),
                        child: Text(
                          "Time To Make",
                          style: TextStyle(
                              fontSize: 29.15.h,
                              color: color_palette["background_color"]),
                        )),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Days",
                              style: TextStyle(
                                  fontSize: 22.h,
                                  color: color_palette["background_color"]),
                            ),
                            NumberPicker(
                              value: _dayValue,
                              itemHeight: 53.h,
                              itemWidth: 69.25.h,
                              minValue: 0,
                              maxValue: 364,
                              onChanged: (value) =>
                                  setState(() => _dayValue = value),
                              selectedTextStyle: TextStyle(
                                  color: color_palette["text_color_alt"],
                                  fontSize: 28.h),
                              textStyle: TextStyle(
                                  color: color_palette["text_color_dark"],
                                  fontSize: 23.h),
                            ),
                          ],
                        ),
                        Container(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Hours",
                              style: TextStyle(
                                  fontSize: 22.h,
                                  color: color_palette["background_color"]),
                            ),
                            NumberPicker(
                              value: _hourValue,
                              itemHeight: 53.h,
                              itemWidth: 69.25.h,
                              minValue: 0,
                              maxValue: 23,
                              onChanged: (value) =>
                                  setState(() => _hourValue = value),
                              selectedTextStyle: TextStyle(
                                  color: color_palette["text_color_alt"],
                                  fontSize: 28.h),
                              textStyle: TextStyle(
                                  color: color_palette["text_color_dark"],
                                  fontSize: 23.h),
                            ),
                          ],
                        ),
                        Container(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Minutes",
                              style: TextStyle(
                                  fontSize: 22.h,
                                  color: color_palette["background_color"]),
                            ),
                            NumberPicker(
                              value: _minuteValue,
                              itemHeight: 53.h,
                              itemWidth: 69.25.h,
                              minValue: 0,
                              maxValue: 59,
                              onChanged: (value) =>
                                  setState(() => _minuteValue = value),
                              selectedTextStyle: TextStyle(
                                  color: color_palette["text_color_alt"],
                                  fontSize: 28.h),
                              textStyle: TextStyle(
                                  color: color_palette["text_color_dark"],
                                  fontSize: 23.h),
                            ),
                          ],
                        )
                      ],
                    ),
                    Container(
                        padding:
                            EdgeInsets.only(top: 10, ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                                child: Container(

                                    child: GestureDetector(
                                        onTap: () {
                                          Navigator.pop(context,
                                              {"hasResult": false});
                                        },
                                        child: Container(
                                            height: 53.h,
                                            child: Text(
                                              "Cancel",

                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 28.h,
                                                  color: color_palette[
                                                  "background_color"]),
                                            ))))),
                            Expanded(
                                child: Container(
                                    child: GestureDetector(
                                        onTap: () {
                                          Navigator.pop(
                                            context,
                                            {
                                              "hasResult": true,
                                              "result": timeString()
                                            },
                                          );
                                        },
                                        child: Container(
                                            height: 53.h,
                                            child: Text(
                                          "Submit",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 28.h,
                                              color: color_palette[
                                                  "background_color"]),
                                        ))))),

                          ],
                        ))
                  ],
                ),
              ),
            )));
  }
}
