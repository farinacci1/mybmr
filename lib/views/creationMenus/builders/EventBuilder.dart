import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:mybmr/models/Event.dart';
import 'package:mybmr/notifiers/UserListNotifier.dart';
import 'package:mybmr/services/toast.dart';
import 'package:provider/provider.dart';

import '../../../constants/Themes.dart';


class EventBuilder extends StatefulWidget {
  @override
  _EventBuilderState createState() => _EventBuilderState();
}

class _EventBuilderState extends State<EventBuilder> {
  TextEditingController _controller = TextEditingController();
  TextEditingController _startDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  DateTime nowDate;
  DateTime startDate;
  DateTime endDate;


  String shortenDate(DateTime dateTime){
    return DateFormat('MMM dd, yyyy @ kk:mm').format(dateTime);
  }
  @override void initState() {
     nowDate = DateTime.now();
     startDate =nowDate;
     endDate =nowDate;
    _startDateController.text = shortenDate(nowDate);
    _endDateController.text = shortenDate(nowDate);
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
    return Scaffold(
      appBar:  AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor:  color_palette["background_color"],
        ),
        backgroundColor:  color_palette["background_color"],
        title: Text( "Event Builder",style: TextStyle(
            fontSize: 34.45.h,
            color: Colors.white,
            fontWeight: FontWeight.bold
        ),),

        actions: [
          IconButton(
            icon: Icon( MaterialIcons.send),
            onPressed: ()
            {
              String title = _controller.value.text;
              String description = _descriptionController.value.text;
              if(title.length > 0){
                MyEvent myEvent = MyEvent(
                    title: title,
                    startDate: startDate,
                    endDate: endDate,
                    description: description
                );
                Provider.of<UserListNotifier>(context,listen:false).addEvent(myEvent);
                Navigator.pop(context);
              }else {
                CustomToast("Event must have a name");
              }


            },
          ),
        ],
      ),
      body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
         color: color_palette["background_color"],
          child: Container(
            decoration: BoxDecoration(
              color: color_palette["semi_transparent"],
            ),
            child: Column(
              children: [

                Expanded(
                    child: Container(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(15, 10, 15, 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AutoSizeText(
                          "Title",
                          maxLines: 1,
                          style: TextStyle(
                              color: color_palette["white"],
                              fontSize: 26.5.h,
                              fontWeight: FontWeight.bold),
                        ),
                        Container(
                            margin: EdgeInsets.only(top: 10, bottom: 20),
                            child: TextField(
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(50),
                              ],
                              style: TextStyle(
                                  color: color_palette["white"],
                                  fontSize: 30.h,
                                  height: 1.5),
                              controller: _controller,
                              onChanged: (str) {
                                setState(() {});
                              },
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 30.h / 2, horizontal: 15.h),
                                  isDense: true,
                                  filled: true,
                                  fillColor: Colors.black54,
                                  hintText: "Event Name",
                                  hintStyle: TextStyle(
                                    color: color_palette["offWhite"],
                                  ),
                                  suffixIcon: _controller.value.text.length > 0
                                      ? IconButton(
                                          onPressed: () {
                                            _controller.clear();
                                            setState(() {});
                                          },
                                          icon: Icon(
                                            Icons.clear,
                                            color: color_palette["white"],
                                            size: 23.85.h,
                                          ),
                                        )
                                      : null,
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: BorderSide(
                                          color: color_palette["white"])),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: BorderSide(
                                          color: color_palette["white"]))),
                            )),
                        AutoSizeText(
                          "From ",
                          maxLines: 1,
                          style: TextStyle(
                              color: color_palette["white"],
                              fontSize: 26.5.h,
                              fontWeight: FontWeight.bold),
                        ),
                        Container(
                            margin: EdgeInsets.only(top: 10,bottom: 20),
                            child: TextFormField(
                              controller: _startDateController,

                              onTap: () {
                                DatePicker.showDateTimePicker(context,
                                    theme: DatePickerTheme(
                                      backgroundColor: color_palette["background_color"],
                                      cancelStyle: TextStyle(color: color_palette["white"], fontSize: 16),
                                      itemStyle : TextStyle(color: color_palette["white"], fontSize: 18),

                                    ),
                                    showTitleActions: true,
                                    minTime: nowDate.subtract(Duration(days: 15)),
                                    maxTime: nowDate.add(Duration(days: 60)),
                                    currentTime: startDate,
                                    onChanged: (date) {
                                }, onConfirm: (date) {
                                  setState(() {
                                    startDate = date;
                                    _startDateController.text =  shortenDate(date);
                                  });

                                }, locale: LocaleType.en);
                              },
                              readOnly: true,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(50),
                              ],
                              style: TextStyle(
                                  color: color_palette["white"],
                                  fontSize: 30.h,
                                  height: 1.5),
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 30.h / 2, horizontal: 15.h),
                                  isDense: true,
                                  filled: true,
                                  fillColor: Colors.black54,
                                  hintStyle: TextStyle(
                                    color: color_palette["offWhite"],
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: BorderSide(
                                          color: color_palette["white"])),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: BorderSide(
                                          color: color_palette["white"]))),
                            )),
                        AutoSizeText(
                          "End ",
                          maxLines: 1,
                          style: TextStyle(
                              color: color_palette["white"],
                              fontSize: 26.5.h,
                              fontWeight: FontWeight.bold),
                        ),
                        Container(
                            margin: EdgeInsets.only(top: 10,bottom: 20),
                            child: TextFormField(
                              controller: _endDateController,
                              onTap: () {
                                DatePicker.showDateTimePicker(context,
                                    theme: DatePickerTheme(
                                      backgroundColor: color_palette["background_color"],
                                      cancelStyle: TextStyle(color: color_palette["white"], fontSize: 16),
                                      itemStyle : TextStyle(color: color_palette["white"], fontSize: 18),

                                    ),
                                    showTitleActions: true,
                                    minTime: nowDate.subtract(Duration(days: 15)),
                                    maxTime: nowDate.add(Duration(days: 60)),
                                    currentTime: endDate,
                                    onChanged: (date) {

                                    }, onConfirm: (date) {
                                      setState(() {
                                        endDate = date;
                                        _endDateController.text = shortenDate(date);
                                      });

                                    }, locale: LocaleType.en);
                              },
                              readOnly: true,

                              style: TextStyle(
                                  color: color_palette["white"],
                                  fontSize: 30.h,
                                  height: 1.5),
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 30.h / 2, horizontal: 15.h),
                                  isDense: true,
                                  filled: true,
                                  fillColor: Colors.black54,
                                  hintText: "Event Name",
                                  hintStyle: TextStyle(
                                    color: color_palette["offWhite"],
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: BorderSide(
                                          color: color_palette["white"])),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: BorderSide(
                                          color: color_palette["white"]))),
                            )),
                        AutoSizeText(
                          "Description ",
                          maxLines: 1,
                          style: TextStyle(
                              color: color_palette["white"],
                              fontSize: 26.5.h,
                              fontWeight: FontWeight.bold),
                        ),
                        Container(
                            margin: EdgeInsets.only(top: 10),
                            child: TextField(
                              controller: _descriptionController,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(512),
                              ],
                              style: TextStyle(
                                  color: color_palette["white"],
                                  fontSize: 30.h,
                                  height: 1.5),
                              maxLines: null,
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 30.h / 2, horizontal: 15.h),

                                  filled: true,
                                  fillColor: Colors.black54,
                                  hintText: "Tell us about your event...",
                                  hintStyle: TextStyle(
                                    color: color_palette["offWhite"],
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: BorderSide(
                                          color: color_palette["white"])),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: BorderSide(
                                          color: color_palette["white"]))),
                            )),

                      ],
                    ),
                  ),
                ))
              ],
            ),
          )),
    );
  }
}
