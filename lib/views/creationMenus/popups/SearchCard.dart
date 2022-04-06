
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mybmr/notifiers/RecipeNotifier.dart';
import 'package:mybmr/constants/Constants.dart';
import 'package:mybmr/constants/messages/en_messages.dart';
import 'package:mybmr/services/custom_rect_twenn.dart';

import 'package:mybmr/widgets/DietDropdown.dart';
import 'package:provider/provider.dart';

import '../../../constants/Themes.dart';
import '../../../widgets/CalorieSlider.dart';
import '../../../widgets/MealDropdown.dart';

class SearchCard extends StatefulWidget {
  @override
  _SearchCardState createState() => _SearchCardState();
}

class _SearchCardState extends State<SearchCard>
    with SingleTickerProviderStateMixin {
  static const String _SEARCH_POPUP = "SEARCH_POPUP";
  TextEditingController _controller = new TextEditingController();

  bool hasValue = false;
  int selectedTab = 2;
  double selectedCalories;
  String selectedDiet;
  String selectedCuisine;
  @override void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    selectedCalories = 2000.0;
    selectedDiet = DietTypes.first;
    selectedCuisine = MEALTYPES.first;

    super.initState();
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
        tag: _SEARCH_POPUP,
        createRectTween: (begin, end) {
          return CustomRectTween(begin: begin, end: end);
        },
        child: Container(
          margin: EdgeInsets.fromLTRB(30,0,30,MediaQuery.of(context).viewInsets.bottom),
          width: min(MediaQuery.of(context).size.width - 30,440.h),
          child: Card(
              color:  color_palette["white"],
             
              elevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Container(
                  margin: EdgeInsets.all(8),
                  child: SingleChildScrollView(child:Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          en_messages["search_recipes"],
                          style: TextStyle(
                            fontSize: 29.h,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Container(
                          height: 60.h,
                          margin: EdgeInsets.only(top: 13.125.h),
                          child: Row(
                            children: [
                              Expanded(
                                  child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedTab = 0;
                                        });
                                      },
                                      child: Container(
                                          height: double.infinity,
                                          alignment:
                                              AlignmentDirectional.center,
                                          decoration: BoxDecoration(
                                              color: selectedTab == 0
                                                  ? color_palette["text_color_dark"]
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                      top: Radius.circular(
                                                          58.h / 2))),
                                          child: Text(
                                            en_messages["search_type_cuisine"],
                                            style: TextStyle(
                                                fontSize: 18.h,
                                                color: selectedTab == 0
                                                    ? Colors.white
                                                    : Colors.black),
                                            textAlign: TextAlign.center,
                                          )))),
                              Expanded(
                                  child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedTab = 1;
                                        });
                                      },
                                      child: Container(
                                          height: double.infinity,
                                          alignment:
                                              AlignmentDirectional.center,
                                          decoration: BoxDecoration(
                                              color: selectedTab == 1
                                                  ? color_palette["text_color_dark"]
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                      top: Radius.circular(
                                                          58.h / 2))),
                                          child: Text(
                                            en_messages["search_type_diet"],
                                            style: TextStyle(
                                                fontSize: 18.h,
                                                color: selectedTab == 1
                                                    ? Colors.white
                                                    : Colors.black),
                                            textAlign: TextAlign.center,
                                          )))),
                              Expanded(
                                  child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedTab = 2;
                                        });
                                      },
                                      child: Container(
                                          height: double.infinity,
                                          alignment:
                                              AlignmentDirectional.center,
                                          decoration: BoxDecoration(
                                              color: selectedTab == 2
                                                  ? color_palette["text_color_dark"]
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                      top: Radius.circular(
                                                          58.h / 2))),
                                          child: Text(
                                            en_messages["search_type_name"],
                                            style: TextStyle(
                                                fontSize: 18.h,
                                                color: selectedTab == 2
                                                    ? Colors.white
                                                    : Colors.black),
                                            textAlign: TextAlign.center,
                                          )))),
                            ],
                          ),
                        ),
                        Builder(builder: (_) {
                          if (selectedTab == 0) {
                            return Container(
                                margin: EdgeInsets.only(top: 5),
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        height: 50.h,
                                        margin: EdgeInsets.only(top: 5),
                                        child: MealDropdown(
                                          selectedMeal: selectedCuisine,
                                          onChange: (String newMeal) {
                                            selectedCuisine = newMeal;

                                          },
                                        ),
                                      ),
                                      CalorieSlider(
                                        defaultCalories: selectedCalories,
                                        activeColor: color_palette["text_color_dark"],
                                        inactiveColor: Colors.grey[300],
                                        onChanged: (double val) {
                                          selectedCalories = val;
                                          setState(() {});
                                        },
                                      ),
                                    ]));
                          } else if (selectedTab == 1) {
                            return Container(
                                margin: EdgeInsets.only(top: 5),
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                          margin: EdgeInsets.only(top: 5),
                                          height: 50.h,
                                          child: DietDropdown(
                                            selectedDiet: selectedDiet,
                                            onChange: (String newDiet) {
                                              selectedDiet = newDiet;
                                            },
                                          )),
                                      CalorieSlider(
                                          defaultCalories: selectedCalories,
                                          inactiveColor: Colors.grey[300],
                                          activeColor: color_palette["text_color_dark"],
                                          onChanged: (double val) {
                                            selectedCalories = val;
                                            setState(() {});
                                          }),
                                    ]));
                          } else {
                            return Container(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              margin: EdgeInsets.only(top: 5),
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CalorieSlider(
                                      defaultCalories: selectedCalories,
                                      inactiveColor: Colors.grey[300],
                                      activeColor: color_palette["text_color_dark"],
                                      onChanged: (double val) {
                                        selectedCalories = val;
                                        setState(() {});
                                      },
                                    ),
                                    TextField(
                                      controller: _controller,
                                      keyboardType: TextInputType.text,
                                      style: TextStyle(fontSize: 18.h),
                                      onChanged: (str){
                                        if(str.length > 0){
                                          hasValue = true;
                                        }else{
                                          hasValue = false;
                                        }
                                        setState(() {

                                        });

                                      },
                                      decoration: InputDecoration(
                                        labelStyle: TextStyle(fontSize: 18.h),

                                          suffixIcon: hasValue ? Container(
                                              child:IconButton(
                                                onPressed: (){
                                                  _controller.clear();
                                                  hasValue = false;

                                                  setState(() {});
                                                },
                                                icon: Icon(Icons.clear, size: 53.h /2,),
                                              )): null,
                                          labelText:
                                              en_messages["recipe_label_name"]),
                                    ),
                                  ]),
                            );
                          }
                        }),
                        Container(
                            height: 59.625.h,
                            margin: EdgeInsets.only(top: 15.9.h, bottom: 5),
                            width: double.infinity,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  onPrimary: Colors.white,
                                  primary: color_palette["text_color_dark"],
                                ),
                                onPressed: () {
                                  switch (selectedTab) {
                                    case 0:
                                      Provider.of<RecipeNotifier>(context,
                                              listen: false)
                                          .sortBy(RecipeSortBy.CUISINE,
                                              cuisine: selectedCuisine,
                                              calories: selectedCalories);
                                      break;
                                    case 1:
                                      Provider.of<RecipeNotifier>(context,
                                              listen: false)
                                          .sortBy(RecipeSortBy.DIETS,
                                              diet: selectedDiet,
                                              calories: selectedCalories);
                                      break;
                                    case 2:
                                      Provider.of<RecipeNotifier>(context,
                                              listen: false)
                                          .sortBy(RecipeSortBy.TITLE,
                                              title:
                                                  _controller.value.text ?? "",
                                              calories: selectedCalories);
                                      break;
                                  }
                                  Navigator.pop(context);
                                },
                                child: Text(en_messages["search_recipes2"], style: TextStyle(fontSize: 21.h),)))
                      ])))),
        ),
      ),
    );
  }
}
