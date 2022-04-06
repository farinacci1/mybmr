import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mybmr/constants/Themes.dart';

class HeaderBar extends StatefulWidget {
  @required final String title;
   final Widget popWidget;
  @required final Widget submitWidget;
  final Decoration submitDecoration;
  final TextStyle titleStyle;
  final Color submitColor;
  @required final VoidCallback onPopCallback;
  @required final VoidCallback submitCallback;
  const HeaderBar({Key key, this.title, this.popWidget, this.submitWidget, this.submitCallback, this.titleStyle, this.onPopCallback, this.submitDecoration, this.submitColor = Colors.purple}) : super(key: key);
  @override
  _HeaderBarState createState() => _HeaderBarState();
}

class _HeaderBarState extends State<HeaderBar> {
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
    return Container(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(
                        8, MediaQuery.of(context).padding.top + 8, 10, 5),
                    width: double.infinity,
                    color:    color_palette["semi_transparent"],
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                       if(widget.popWidget != null) GestureDetector(
                          onTap: () {
                            widget.onPopCallback();
                            Navigator.pop(context);
                          },
                          child: widget.popWidget,
                         behavior: HitTestBehavior.translucent,
                        ),
                        Expanded(
                            child: Container(
                                padding: EdgeInsets.only(left: 15, right: 5),
                                child: Text(
                                  widget.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.clip,
                                  style: widget.titleStyle == null ?TextStyle(
                                      fontSize: 34.45.h,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold) : widget.titleStyle,
                                ))),
                       GestureDetector(
                         onTap: (){
                           widget.submitCallback();
                         },
                         behavior: HitTestBehavior.translucent,
                         child:  Container(
                             padding: EdgeInsets.symmetric(horizontal: 16,vertical: 10),
                             child: widget.submitWidget,
                             decoration: widget.submitDecoration ?? BoxDecoration(
                                 color: widget.submitColor,
                                 borderRadius: BorderRadius.circular(80))
                         ),
                       )

                      ],
                    ),
                  ),]));
  }

}