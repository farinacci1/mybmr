import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mybmr/constants/Constants.dart';





class CalendarList extends StatefulWidget{
  final List<DateTime> dateRange;
  final DateTime activeDate;
  final Function(DateTime) onUpdate;
  const CalendarList({Key key, @required this.dateRange, @required this.activeDate, this.onUpdate}) : super(key: key);
  @override
  _CalendarListState createState()  => _CalendarListState();

}

class _CalendarListState extends State<CalendarList>{
  /*
  * Scrollable UI List containing all dates in range startDte to endDate
  * */
  DateTime activeDate;
    @override void initState() {
    this.activeDate = widget.activeDate;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
        context,
        designSize: Size(2400, 1080),
        minTextAdapt: true,
      );
    return ListView(
      scrollDirection: Axis.horizontal,
      children: widget.dateRange.map((dateTime) {
        return CalendarDateCell(
          date: dateTime,
          cellWidth: 53.h,
          cellHeight: 53.h,
          isActive:  dateTime.isSameDate(activeDate),
          activeBGCOLOR: dateTime.isSameDate(activeDate) ? Colors.grey.withOpacity(0.5) : Colors.transparent,
          onTap: (DateTime selected){
            activeDate = selected;
            widget.onUpdate(selected);
            setState(() {});
            },
        );
      }).toList(),
    );
  }


}

class CalendarDateCell extends StatelessWidget{
  /*
  * UI Widget containing date object
  * */


  final DateTime date;

  final TextStyle weekDayStyle;
  final TextStyle dayNumStyle;
  final TextStyle monthStyle;

  final double cellWidth;
  final double cellHeight;

  final bool isActive;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final activeBGCOLOR;  /*background shadow*/
  final BorderRadius radius;
  final Function(DateTime) onTap;

  const CalendarDateCell({Key key,
    @required this.date,
    @required this.onTap,
    this.cellWidth = 40.0,
    this.cellHeight = 40.0,
    this.isActive = false,
    this.weekDayStyle ,
    this.dayNumStyle ,
    this.monthStyle ,
    this.activeBGCOLOR = Colors.transparent,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    this.radius = BorderRadius.zero
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: Size(2400, 1080),
      minTextAdapt: true,
    );

    return
    GestureDetector(
      onTap: (){ if(onTap != null) onTap(this.date);},
      child:Container(
      width: this.cellWidth,
      height: this.cellHeight,
      padding: this.padding,
      margin:  this.margin,
      alignment: AlignmentDirectional.center,
      decoration: BoxDecoration(
        borderRadius: radius,
        color: this.activeBGCOLOR,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AutoSizeText('${monthsOfYear[this.date.month]}',maxLines: 1,style: monthStyle ?? TextStyle(fontSize: 18.5.h, color: Colors.black54),),
          AutoSizeText('${this.date.day}',maxLines: 1,style: dayNumStyle ?? TextStyle(fontSize: 30.5.h, color: Colors.black,fontWeight: FontWeight.bold)),
          AutoSizeText('${dayOfWeek[this.date.weekday]}',maxLines: 1,style: weekDayStyle ?? TextStyle(fontSize: 18.5.h, color: Colors.black54)),
        ],
      ),
    ));
  }

}
