import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mybmr/constants/Constants.dart';


import 'CustomDropdown.dart';

class MealDropdown extends StatefulWidget {
  @required final String selectedMeal;
  @required final Function(String) onChange;

  const MealDropdown({Key key, this.selectedMeal, this.onChange}) : super(key: key);
  @override
  _MealDropdownState createState() => _MealDropdownState();
}

class _MealDropdownState extends State<MealDropdown> {
  String selectedMeal;
  @override void initState() {
    selectedMeal = widget.selectedMeal;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: Size(2400, 1080),
      minTextAdapt: true,
    );
    return  CustomDropdownButton<String>(

      value: selectedMeal,
      items: MEALTYPES.map((String obj){
        return DropdownMenuItem<String>(
            child: AutoSizeText(obj,maxLines: 1,style: TextStyle(fontSize: 14.h),),
            value: obj
        );
      }) .toList(),
      onChanged: (meal) {
        setState(() {
          selectedMeal= meal;
          widget.onChange(selectedMeal);
        });
      },
    );
  }

}