import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/Themes.dart';

class UserSearch extends StatefulWidget {
  @override
  _UserSearchState createState() => _UserSearchState();
}

class _UserSearchState extends State<UserSearch>{
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
        backgroundColor: color_palette["white"],
        appBar: AppBar(
        backgroundColor: color_palette["background_color"],
        systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: color_palette["background_color"],
    ),
          title: Text("User Finder",style: TextStyle(fontSize: 28.h),),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: Size(
              MediaQuery.of(context).size.width,
              50.h + 16
            ),
            child: Container(
              height: 50.h,
              margin: EdgeInsets.symmetric(vertical: 8,horizontal: 5),
              child: TextField(

                style: TextStyle(fontSize: 25.h),
                decoration: InputDecoration(
                    filled: true,
                    fillColor: color_palette["white"],
                    hintText: "Search For Username...",
                    prefixIcon:
                    Icon(Icons.search, color: Theme.of(context).iconTheme.color),
                  contentPadding: EdgeInsets.only(
                    bottom: 50.h / 2 - 12.5.h,  // HERE THE IMPORTANT PART
                  ),
                    hintStyle: TextStyle(
                      color: color_palette["background_color"],
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),

                        borderSide: BorderSide(
                            color: color_palette["background_color"])),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),

                        borderSide: BorderSide(
                            color: color_palette["background_color"]))
                ),
              ),
            ),

          ),
    )
    );
  }
}