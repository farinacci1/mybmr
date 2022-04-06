import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mybmr/constants/Constants.dart';
import 'CustomDropdown.dart';

class DietDropdown extends StatefulWidget {
  @required final String selectedDiet;
  @required final Function(String) onChange;

  const DietDropdown({Key key, this.selectedDiet, this.onChange}) : super(key: key);
  @override
  _DietDropdownState createState() => _DietDropdownState();
}

class _DietDropdownState extends State<DietDropdown> {
  String selectedDiet;
  @override void initState() {
    selectedDiet = widget.selectedDiet;
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
    return  CustomDropdownButton<String>(
      value: selectedDiet,

      iconSize: 31.8.h,
      items: DietTypes.map((String obj){
        return DropdownMenuItem<String>(
            child: AutoSizeText(obj,maxLines: 1,style: TextStyle(fontSize: 14.h)),
            value: obj
        );
      }) .toList(),
      onChanged: (diet) {
        setState(() {
          selectedDiet = diet;
          widget.onChange(selectedDiet);
        });
      },
    );
  }

}