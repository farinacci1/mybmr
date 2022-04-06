import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mybmr/notifiers/FavoritesNotifier.dart';
import 'package:mybmr/models/Recipe.dart';
import 'package:mybmr/services/AdService.dart';
import 'package:mybmr/services/custom_rect_twenn.dart';
import 'package:mybmr/services/hero_dialog_route.dart';
import 'package:mybmr/views/creationMenus/builders/RecipeBuilder.dart';
import 'package:provider/provider.dart';

import '../../../constants/Themes.dart';
import '../../RecipeExpanded.dart';
import 'MealPlanner.dart';

class FavoritePopup extends StatefulWidget {
  final Recipe recipe;
  final bool isOwnedByUser;
  final bool isDeletable;

  const FavoritePopup({Key key, this.isDeletable = true,this.isOwnedByUser = false, this.recipe})
      : super(key: key);
  @override
  _FavoritePopupState createState() => _FavoritePopupState();
}

class _FavoritePopupState extends State<FavoritePopup> {
  static const String _FavoritePopup = "FAVORITE_POPUP";
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
            tag: _FavoritePopup,
            createRectTween: (begin, end) {
              return CustomRectTween(begin: begin, end: end);
            },
            child: Container(
                width: 344.5.h,
                child: Material(
                  elevation: 3,
                  color: Color(0xFF28282B),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Container(

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
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: Color(0xFFF9F6EE),
                                        width: 3))),
                            child: Text(
                              widget.recipe.title.toUpperCase().substring(0, min(widget.recipe.title.length, 15)),
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 26.5.h,
                                color: Colors.blueGrey,
                              ),
                            )),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 13.125.h),
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Color(0xFFF9F6EE),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(3)),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 331.25.h,
                                height: 59.625.h,

                                child: ElevatedButton(
                                    onPressed: () {
                                      if (AdService.shouldShowAd(adProbability: 0.08)) {
                                        AdService.showInterstitialAd(() {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      RecipeExpanded(recipe: widget.recipe)));
                                        });
                                      } else {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    RecipeExpanded(recipe: widget.recipe)));
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                        fixedSize: Size(304.75.h, 53.h),
                                        primary:color_palette["alternative"],
                                      onPrimary: Colors.white,
                                      shape: ContinuousRectangleBorder(),
                                        alignment: AlignmentDirectional.centerStart
                                    ),
                                    child: Text(
                                      "🔍 Show Recipe",
                                      style: TextStyle(fontSize: 23.85.h),
                                    )),
                              ),
                              Container(
                                width: 331.25.h,
                                height: 59.625.h,

                                decoration: BoxDecoration(
                                    border: Border(
                                        top: BorderSide(
                                  color:Color(0xFFF9F6EE),
                                  width: 3,
                                ))),

                                child: ElevatedButton(
                                    onPressed: () async {
                                      await Navigator.of(context)
                                          .push(HeroDialogRoute(builder: (context) {
                                        return MealPlannerPopup(
                                          recipe: widget.recipe,
                                        );
                                      }));
                                    },
                                    style: ElevatedButton.styleFrom(
                                      fixedSize: Size(304.75.h, 53.h),
                                        primary: color_palette["alternative"],
                                        shape: ContinuousRectangleBorder(),
                                        alignment: AlignmentDirectional.centerStart,
                                      onPrimary: Colors.white,
                                    ),
                                    child: Text(
                                      "🍜 Meal Plan",
                                      style: TextStyle(fontSize: 23.85.h),
                                    )),
                              ),
                              if(widget.isOwnedByUser)Container(
                                width: 331.25.h,
                                height: 59.625.h,

                                decoration: BoxDecoration(
                                    border: Border(
                                        top: BorderSide(
                                          color:Color(0xFFF9F6EE),
                                          width: 3,
                                        ))),

                                child: ElevatedButton(
                                    onPressed: () async {
                                      Map<String,dynamic> response =await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  RecipeBuilder(recipe: widget.recipe)));
                                      if(response!= null  && response["isUpdated"] == true)Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      fixedSize: Size(304.75.h, 53.h),
                                      primary: color_palette["alternative"],
                                      shape: ContinuousRectangleBorder(),
                                      alignment: AlignmentDirectional.centerStart,
                                      onPrimary: Colors.white,
                                    ),
                                    child: Text(
                                      "🖊️ Edit",
                                      style: TextStyle(fontSize: 23.85.h),
                                    )),
                              ),
                              Container(
                             width: 331.25.h,
                                height: 59.625.h,

                                decoration: BoxDecoration(
                                    border: Border(
                                        top: BorderSide(
                                          color:Color(0xFFF9F6EE),
                                          width: 3,
                                        ))),

                                child: ElevatedButton(
                                    onPressed: () async {
                                      Map<String,dynamic> response =await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  RecipeBuilder(recipe: widget.recipe,shouldClone: true,)));
                                      if(response!= null  && response["isCreated"] == true)Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      fixedSize: Size(304.75.h, 53.h),
                                      primary: color_palette["alternative"],
                                      shape: ContinuousRectangleBorder(),
                                      alignment: AlignmentDirectional.centerStart,
                                      onPrimary: Colors.white,
                                    ),
                                    child: Text(
                                      "🆕️ Build From",
                                      style: TextStyle(fontSize: 23.85.h),
                                    )),
                              ),

                              if (widget.isDeletable)
                                Container(
                                  width: 230,
                                  height: 15,
                                  decoration: BoxDecoration(
                                    color:Colors.transparent,
                                  ),

                                ),
                              if (widget.isDeletable)
                                Container(
                                  width: 230,
                                  height: 53.h,

                                  child: ElevatedButton(
                                      onPressed: () {
                                        FavoritesNotifier favoritesNotifier =
                                        Provider.of<FavoritesNotifier>(context, listen: false);
                                        favoritesNotifier.handleLikeEvent(widget.recipe.id);
                                        Navigator.pop(context,true);
                                      },
                                      style: ElevatedButton.styleFrom(
                                          fixedSize: Size(304.75.h, 53.h),
                                          shape: ContinuousRectangleBorder(),
                                        alignment: AlignmentDirectional.centerStart,
                                        primary:color_palette["alternative"],
                                        onPrimary: Colors.white,
                                      ),
                                      child: Text(
                                        "❌ Remove",
                                        style: TextStyle(fontSize: 23.85.h),
                                      ))
                                )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ))));
  }
}
