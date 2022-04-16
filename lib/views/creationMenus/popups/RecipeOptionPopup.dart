import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mybmr/models/Recipe.dart';
import 'package:mybmr/services/custom_rect_twenn.dart';
import 'package:mybmr/views/creationMenus/popups/RecipeNutrition.dart';
import 'package:mybmr/views/creationMenus/popups/ReportPopup.dart';

import '../../../constants/Themes.dart';
import '../../../services/hero_dialog_route.dart';

class RecipeOptionPopup extends StatefulWidget {
  final Recipe recipe;
  final bool isOwnedByUser;
  final bool isDeletable;

  const RecipeOptionPopup({Key key, this.isDeletable = true,this.isOwnedByUser = false, this.recipe})
      : super(key: key);
  @override
  _RecipeOptionPopupState createState() => _RecipeOptionPopupState();
}

class _RecipeOptionPopupState extends State<RecipeOptionPopup> {
  static const String RECIPE_OPTON_POPUP = "RECIPE_OPTON_POPUP";
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
            tag: RECIPE_OPTON_POPUP,
            createRectTween: (begin, end) {
              return CustomRectTween(begin: begin, end: end);
            },
            child: Container(
                width: 344.5.h,
                child: Material(
                  elevation: 3,
                  color: color_palette["white"],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Container(
                    decoration: BoxDecoration(

                         gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        Color(0xffd2ccc4),
                        Color(0xff04619f),
                        Color(0xff380036),
                        Color(0xff380036),
                        Color(0xff380036),
                        Color(0xff380036),
                      ],
                    ),
                        borderRadius: BorderRadius.circular(20)
                    ),


                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          alignment: AlignmentDirectional.center,
                          constraints:  BoxConstraints(minHeight: 132.5.h),
                          child: Container(
                            constraints: BoxConstraints(minHeight: 92.75.h,minWidth: 92.75.h),
                            height: 92.75.h,
                            width: 92.75.h,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(13.125.h),
                                image: DecorationImage(
                                    image: NetworkImage(
                                        widget.recipe.recipeImageFromDB),
                                    fit: BoxFit.cover
                                )),
                          ),
                        ),
                        Container(
                            width: 331.25.h,
                            padding: EdgeInsets.only(bottom: 5.3.h),
                            alignment: AlignmentDirectional.center,

                            child: Text(
                              widget.recipe.title.toUpperCase().substring(0, min(widget.recipe.title.length, 15)),
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 26.5.h,
                                color: color_palette["white"],
                              ),
                            )),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 13.125.h,horizontal: 15),

                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 331.25.h,
                                height: 59.625.h,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                  color:color_palette["overlay"],

                                ),

                                child: ElevatedButton(
                                    onPressed: () async {
                                      Map<String, dynamic> out =
                                          await Navigator.of(context)
                                          .pushReplacement(HeroDialogRoute(
                                          builder: (context) {
                                           return RecipeNutrition(recipe: widget.recipe,);
                                          }));
                                    },
                                    style: ElevatedButton.styleFrom(
                                        fixedSize: Size(304.75.h, 53.h),
                                        primary:Colors.transparent,
                                        onPrimary:  color_palette["white"],
                                        shape: ContinuousRectangleBorder(),
                                        alignment: AlignmentDirectional.centerStart
                                    ),
                                    child: Text(
                                      "Nutrition Facts",
                                      style: TextStyle(fontSize: 23.85.h,color:  color_palette["white"],),
                                    )),
                              ),
                              Container(
                                width: 331.25.h,
                                height: 59.625.h,
                                margin: EdgeInsets.only(bottom: 10,top: 5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color:color_palette["overlay"],

                                ),


                                child: ElevatedButton(
                                    onPressed: () async {
                                      Map<String, dynamic> out =
                                      await Navigator.of(context)
                                          .pushReplacement(HeroDialogRoute(
                                          builder: (context) {
                                            return ReportPopup(recipe: widget.recipe,);
                                          }));
                                    },
                                    style: ElevatedButton.styleFrom(
                                        fixedSize: Size(304.75.h, 53.h),
                                        primary:Colors.transparent,
                                        onPrimary:  color_palette["white"],
                                        shape: ContinuousRectangleBorder(),
                                        alignment: AlignmentDirectional.centerStart
                                    ),
                                    child: Text(
                                      "Report",
                                      style: TextStyle(fontSize: 23.85.h,color:  color_palette["white"],),
                                    )),
                              ),

                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ))));
  }
}
