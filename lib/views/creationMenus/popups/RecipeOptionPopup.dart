import 'dart:math';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
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

                        color: color_palette["background_color"],
                        borderRadius: BorderRadius.circular(20)
                    ),


                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          alignment: AlignmentDirectional.center,
                            height: 92.75.h,
                            width: 92.75.h,
                          margin: EdgeInsets.symmetric(vertical: 20.h),
                          
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(30.h),
                              child:_buildImage(
                            widget.recipe.recipeImageFromDB,
                            height: 92.75.h,
                            width: 92.75.h,
                            aspect: 1.0
                          ))
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
                                          .push(HeroDialogRoute(
                                              statusBarColor: Color.alphaBlend(Color(0x33FFFFFF), color_palette["white"]),
                                          bgColor: Colors.transparent,
                                          builder: (context) {
                                           return RecipeNutrition(recipe: widget.recipe,);
                                          }));
                                      Navigator.of(context).pop();
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
                                          .push(HeroDialogRoute(
                                          statusBarColor: Color.alphaBlend(Color(0x33FFFFFF), color_palette["white"]),
                                          bgColor: Colors.transparent,
                                          builder: (context) {
                                            return ReportPopup(recipe: widget.recipe,);
                                          }));
                                      Navigator.of(context).pop();
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
  Widget _buildImage(String recipeImageFromDB,
      {double height = 300, double width = 300, aspect = 0.75}) {
    return AspectRatio(
      aspectRatio: aspect,
      child: Container(
        width: double.infinity,
        child: ClipRRect(
            child: FancyShimmerImage(
              imageUrl: recipeImageFromDB,
              height: height,
              width: width,
            )),
      ),
    );
  }
}
