import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mybmr/constants/Themes.dart';
import 'package:mybmr/constants/messages/en_messages.dart';

import 'package:mybmr/models/AppUser.dart';
import 'package:mybmr/models/Recipe.dart';
import 'package:mybmr/services/Firebase_db.dart';
import 'package:mybmr/services/custom_rect_twenn.dart';
import 'package:mybmr/services/toast.dart';

class ReportPopup extends StatefulWidget {
  final Recipe recipe;

  const ReportPopup({Key key, this.recipe}) : super(key: key);
  @override
  _ReportPopupState createState() => _ReportPopupState();
}

class _ReportPopupState extends State<ReportPopup> {
  static const String _REPORTPOPUP = "REPORT_POPUP";

  void reportRecipe(String recipeId, int flagType) {
    if (AppUser.instance.uuid != null &&
        AppUser.instance.uuid != "" &&
        !AppUser.instance.reportedRecipesIds.contains(recipeId)) {
      FirebaseDB.updateRecipeFlags(recipeId, flagType,
              flaggersId: AppUser.instance.uuid)
          .whenComplete(() {
        AppUser.instance.insertReportedRecipe(recipeId);
        CustomToast(en_messages["report_received"]);
        Navigator.pop(context, true);
      });
    }else{
      CustomToast(en_messages["sign_in_required"]);
      Navigator.pop(context, true);
    }
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
            tag: _REPORTPOPUP,
            createRectTween: (begin, end) {
              return CustomRectTween(begin: begin, end: end);
            },
            child: Container(
              width: min(MediaQuery.of(context).size.width - 20, 344.5.h),
              child: Material(
                elevation: 3,
                color: color_palette["white"],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 344.5.h,
                        padding: EdgeInsets.symmetric(vertical: 3),
                        margin: EdgeInsets.only(bottom: 5),
                        alignment: AlignmentDirectional.center,
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(color: Colors.black))),
                        child: Text(
                          "Report",
                          style: TextStyle(fontSize: 21.2.h),
                        ),
                      ),
                      Container(
                          width: 344.5.h,
                          height: 53.h,
                          decoration: BoxDecoration(
                              gradient: color_palette["gradient"],
                              borderRadius: BorderRadius.circular(5)),
                          margin: EdgeInsets.only(top: 5),
                          child: ElevatedButton(
                            onPressed: () {
                              reportRecipe(widget.recipe.id, 1);
                            },
                            style: ElevatedButton.styleFrom(
                                primary: Colors.transparent),
                            child: Text(
                              "Contains personally identifiable information",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 21.2.h,
                              ),
                            ),
                          )),
                      Container(
                          width: 344.5.h,
                          height: 53.h,
                          decoration: BoxDecoration(
                              gradient: color_palette["gradient"],
                              borderRadius: BorderRadius.circular(5)),
                          margin: EdgeInsets.only(top: 5),
                          child: ElevatedButton(
                            onPressed: () {
                              reportRecipe(widget.recipe.id, 2);
                            },
                            style: ElevatedButton.styleFrom(
                                primary: Colors.transparent),
                            child: Text(
                              "NSFW",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 21.2.h),
                            ),
                          )),
                      Container(
                          width: 344.5.h,
                          height: 53.h,
                          decoration: BoxDecoration(
                              gradient: color_palette["gradient"],
                              borderRadius: BorderRadius.circular(5)),
                          margin: EdgeInsets.only(top: 5),
                          child: ElevatedButton(
                            onPressed: () {
                              reportRecipe(widget.recipe.id, 3);
                            },
                            style: ElevatedButton.styleFrom(
                                primary: Colors.transparent),
                            child: Text(
                              "Incites violence/Is offensive",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 21.2.h),
                            ),
                          )),
                      Container(
                          width: 344.5.h,
                          height: 53.h,
                          decoration: BoxDecoration(
                              gradient: color_palette["gradient"],
                              borderRadius: BorderRadius.circular(5)),
                          margin: EdgeInsets.only(top: 5),
                          child: ElevatedButton(
                            onPressed: () {
                              reportRecipe(widget.recipe.id, 4);
                            },
                            style: ElevatedButton.styleFrom(
                                primary: Colors.transparent),
                            child: Text(
                              "Not a real recipe",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 21.2.h),
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            )));
  }
}
