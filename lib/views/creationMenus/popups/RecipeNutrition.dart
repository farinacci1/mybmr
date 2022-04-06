import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mybmr/constants/messages/en_messages.dart';
import 'package:mybmr/models/Recipe.dart';
import 'package:mybmr/services/custom_rect_twenn.dart';

import '../../../constants/Themes.dart';

class RecipeNutrition extends StatelessWidget {
  final Recipe recipe;
  const RecipeNutrition({Key key, this.recipe}) : super(key: key);
  static const String _RECIPE_NUTRITION = "RECIPE_NUTRITION";
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
            tag: _RECIPE_NUTRITION,
            createRectTween: (begin, end) {
              return CustomRectTween(begin: begin, end: end);
            },
            child: Material(
                type: MaterialType.transparency,
                child: Container(
                    height: MediaQuery.of(context).size.height * .72,
                    width: max(min(MediaQuery.of(context).size.width * .85,700),320),
                    padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),

                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 4,
                              blurRadius: 4,
                              offset: Offset(3, 3))
                        ]),

                    child: Column(
                      children: [
                        Expanded(
                          flex: 1, //
                          child: Container(
                            padding: EdgeInsets.all(10.0),
                            child: Title(
                                color: Colors.black,
                                child: Text(
                                  "Nutrition Info",
                                  style: TextStyle(
                                      fontSize: 31.8.h,
                                      decoration: TextDecoration.underline),
                                )),
                          ),
                        ),
                        Expanded(
                          flex: 9,
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            child:NotificationListener<OverscrollIndicatorNotification>(
                              onNotification: (overscroll){
                                overscroll.disallowIndicator();
                                return;
                              },child: SingleChildScrollView(
                              child: Column(children: [
                                Column(
                                  children:
                                      recipe.nutritionalValue.entries.map((e) {
                                    String fieldName = e.key.substring(5);
                                    double val = e.value / recipe.peopleServed;

                                    String label = "g";
                                    if (fieldName != "Calories") {
                                      if (val < 1) {
                                        val *= 1000;
                                        label = "mg";
                                      }
                                      if (val < 1) {
                                        val *= 1000;
                                        label = "mcg";
                                      }
                                    } else {
                                      label = "Cal";
                                    }

                                    return Container(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            fieldName,
                                            style: TextStyle(fontSize: 26.h),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(left: 10),
                                          ),
                                          Text(val.toStringAsFixed(2) + label,
                                              style: TextStyle(
                                                  fontSize: 21.h,
                                                  color:color_palette["text_color_dark"]))
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                      top: 7, bottom: 3, left: 4, right: 4),
                                  child: Text(
                                    en_messages["nutrition_disclosure"],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 18.h),
                                  ),
                                )
                              ]),
                            )),
                          ),
                        )
                      ],
                    )))));
  }
}
