
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mybmr/notifiers/MealPlanNotifier.dart';
import 'package:mybmr/constants/messages/en_messages.dart';
import 'package:mybmr/models/MealPlan.dart';

import 'package:mybmr/models/Recipe.dart';
import 'package:mybmr/services/Firebase_db.dart';

import 'package:mybmr/services/conversion.dart';

import 'package:mybmr/services/custom_rect_twenn.dart';
import 'package:mybmr/services/toast.dart';
import 'package:mybmr/widgets/CustomDatePicker/MyDate.dart';
import 'package:provider/provider.dart';

import '../../../constants/Themes.dart';

class MealPlannerPopup extends StatefulWidget {
  @required
  final Recipe recipe;
  final bool isCopy;
  const MealPlannerPopup({
    Key key,
    this.recipe, this.isCopy = false,
  }) : super(key: key);
  @override
  _MealSharePopupState createState() => _MealSharePopupState();
}

class _MealSharePopupState extends State<MealPlannerPopup> {
  static const String _MEALPLANPOPUP = "MEALPLAN_POPUP";
  DateTime selectDate;
  TextEditingController _timeController = TextEditingController();
  TextEditingController _titleController = TextEditingController();
  String time;
  bool hasValue = false;
  @override void dispose() {
    _timeController.dispose();
    _titleController.dispose();
    super.dispose();
  }
  void addMealPlan()  {

      if (_titleController.value != null &&
          _titleController.value.text.trim().length > 0 &&
          _timeController.value != null &&
          _timeController.value.text.length > 0 &&
          selectDate != null) {

        MealPlan mealPlan = MealPlan(
            title: _titleController.value.text,
            timeOfDay: _timeController.value.text,
            date: DateTime(selectDate.year, selectDate.month, selectDate.day) ,
            recipeId: widget.recipe.id);
        Provider.of<MealPlanNotifier>(context,listen: false).createMealPlan(mealPlan, widget.recipe);

        FirebaseDB.updateRecipeCounter(widget.recipe.id).whenComplete(() {
          Navigator.pop(context);
        });

      }else{

        CustomToast(en_messages["meal_planner_missing_fields"]);
      }





  }

  @override
  void initState() {

    selectDate = DateTime.now();
    time = (selectDate.hour > 12
            ? (selectDate.hour - 12).toString()
            : selectDate.hour.toString()) +
        ":" +
        selectDate.minute.toString().padLeft(2, '0') +
        (selectDate.hour  < 12 ? " AM" : " PM");
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
    _timeController.text = time;
    Provider.of<MealPlanNotifier>(context,listen: true);
    return Center(
        child: Hero(
      tag: _MEALPLANPOPUP,
      createRectTween: (begin, end) {
        return CustomRectTween(begin: begin, end: end);
      },
      child: Container(
        width: 344.5.h,
        constraints: BoxConstraints(
          maxWidth: 520
        ),
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        decoration: BoxDecoration(
            color: color_palette["white"], borderRadius: BorderRadius.circular(20)),
        child: Material(
          elevation: 3,
          color: Colors.grey[200],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: EdgeInsets.all(15),
            child: SingleChildScrollView(child:Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.isCopy ? "Copy Meal Plan To": "Add To Meal Plan",
                  style: TextStyle(
                      fontSize: 31.8.h,
                      color: Colors.black,
                      decoration: TextDecoration.underline),
                ),
                Container(
                  height: 10,
                ),
                Container(
                  height: 86.125.h,
                  margin: EdgeInsets.only(top: 15),
                  child: CalendarList(
                    dateRange: Conversion.getDaysInBetween(
                        DateTime.now(), DateTime.now().add(Duration(days: 14))),
                    activeDate: DateTime.now(),
                    onUpdate: (DateTime datetime) {
                      selectDate = datetime;
                      setState(() {});
                    },
                  ),
                ),
                Container(

                    margin: EdgeInsets.only(top: 28.h,bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          child: Focus(
                              onFocusChange: (hasFocus){
                                if(hasFocus){
                                  hasValue = true;
                                }
                                else  hasValue = false;
                              },
                              child:TextField(
                            controller: _titleController,

                            textAlign: TextAlign.center,
                            textAlignVertical: TextAlignVertical.center,
                                style: TextStyle(
                                    color: color_palette["background_color"], fontSize: 53.h /2,height:1.5),
                                decoration: InputDecoration(
                                    floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                    suffixIcon: hasValue ? Container(
                                        child:IconButton(
                                          onPressed: _titleController.clear,
                                          icon: Icon(Icons.clear, size: 53.h /2,color: color_palette["text_color_dark"],),
                                        )): null,
                                    label: Text("🍜 Meal Name "),
                                    hintText: "Breakfast",
                                    contentPadding: EdgeInsets.symmetric(vertical:  53.h /4,horizontal: 15.h),

                                    hintStyle: TextStyle(
                                      color: color_palette["semi_transparent"],
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                        borderSide: BorderSide(color: color_palette["text_color_dark"],width: 2)),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                        borderSide: BorderSide(color: color_palette["text_color_dark"],width: 2))),

                          )),
                        ),
                        Container(

                          margin: EdgeInsets.only(top: 15),
                          child: TextField(
                            controller: this._timeController,


                            onTap: () async {
                              TimeOfDay selectedTime = await showTimePicker(
                                  initialTime: TimeOfDay.now(),
                                  context: context);
                              if(selectedTime != null){
                                this.time = selectedTime.format(context);
                                this._timeController.text = time;
                                setState(() {});
                              }

                            },
                            enableInteractiveSelection: false,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(32),
                            ],
                            textAlign: TextAlign.center,
                            readOnly: true,
                            style: TextStyle(
                                color: color_palette["background_color"], fontSize: 53.h /2,height:1.5),
                            decoration: InputDecoration(
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              label: Text("🕑 Time Of Day "),
                              contentPadding: EdgeInsets.symmetric(vertical:  53.h /4,horizontal: 15.h),
                              counterText: "",
                              focusedBorder: OutlineInputBorder(
                                borderSide:  BorderSide(
                                    color:color_palette["text_color_dark"], width: 2.0),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide:  BorderSide(
                                    color: color_palette["text_color_dark"], width: 2.0),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
                GestureDetector(
                    onTap: () {
                      addMealPlan();
                    },
                    child: Container(
                      height: 45.h,
                      margin: EdgeInsets.only(top: 10),
                      alignment: AlignmentDirectional.center,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.black),
                      child: Text(
                        "Add",
                        style: TextStyle(
                            color:color_palette["white"],
                            fontWeight: FontWeight.bold,
                            fontSize: 26.h),
                      ),
                    ))
              ],
            ),)
          ),
        ),
      ),
    ));
  }
}
