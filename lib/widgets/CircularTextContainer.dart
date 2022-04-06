import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../constants/Themes.dart';



class CircularTextContainer extends StatelessWidget {
  final String value;
  final Function onTap;

  final Color primary;
  final Color iconColor;
  final EdgeInsets margin;
  final IconData icon;
  final double iconSize;
  CircularTextContainer({
    @required this.value,
    this.primary,
    this.margin = EdgeInsets.zero,
    this.icon,
    this.iconSize = 42, this.iconColor =Colors.white70, this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return
      GestureDetector(
          onTap: (){
            if(this.onTap != null) this.onTap();
          },
          behavior: HitTestBehavior.translucent,
          child:
      Container(
        alignment: AlignmentDirectional.center,


        width: (iconSize * 1.75) + 20,
        margin: margin,

        child:Container(
          padding: EdgeInsets.only(left: 10),
          width: (iconSize * 1.75),
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            if(this.icon != null) Icon(
              this.icon,
              size: this.iconSize,
              color: this.iconColor
            ),
            if(value != null && value != "")Container(
                margin: EdgeInsets.only(top: 4),
                child:AutoSizeText(
              value,
              textAlign: TextAlign.center,
              minFontSize: 6,
              maxLines: 2,
              style: TextStyle(color: this.primary ??  Colors.orangeAccent, fontSize: this.iconSize /2.5),
            )),
          ],
        )),
        ));
  }
}