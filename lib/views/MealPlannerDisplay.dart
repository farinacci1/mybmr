import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mybmr/notifiers/MealPlanNotifier.dart';
import 'package:mybmr/constants/Constants.dart';
import 'package:mybmr/constants/messages/en_messages.dart';
import 'package:mybmr/models/MealPlan.dart';
import 'package:mybmr/models/Recipe.dart';
import 'package:mybmr/services/AdService.dart';
import 'package:mybmr/services/hero_dialog_route.dart';
import 'package:mybmr/views/RecipeExpanded.dart';
import 'package:mybmr/widgets/CustomDatePicker/CalendarTimeline.dart';
import 'package:provider/provider.dart';

import '../constants/Themes.dart';
import 'creationMenus/popups/MealSharePopup.dart';
class MealPlannerDisplay extends StatefulWidget{

  @override _MealPlannerDisplayState createState() => _MealPlannerDisplayState();
}

class _MealPlannerDisplayState extends State<MealPlannerDisplay> {

  @override
  Widget build(BuildContext context) {
    MealPlanNotifier mealPlanNotifier =
        Provider.of<MealPlanNotifier>(context, listen: true);
    mealPlanNotifier.mealPlans
        .sort((a, b) => compareTime(b.timeOfDay, a.timeOfDay));

    DateTime date = mealPlanNotifier.startOfDay;

    List<MealPlan> dailyPlans = mealPlanNotifier.filterByDate(date);

    ScreenUtil.init(
      context,
      designSize: Size(2400, 1080),
      minTextAdapt: true,
    );
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: color_palette["background_color"],
        systemNavigationBarColor: color_palette["background_color"],
        systemNavigationBarDividerColor: color_palette["background_color"]));
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: color_palette["background_color"],
        child: Container(
            decoration: BoxDecoration(color: color_palette["semi_transparent"]
                //gradient: color_palette["gradient"],
                ),
            child: Column(children: [
              Container(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 10),
                decoration:
                    BoxDecoration(color: color_palette["background_color"]),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      alignment: AlignmentDirectional.center,
                      child: AutoSizeText(
                        en_messages["meal_plan_label"],
                        maxLines: 1,
                        style: TextStyle(
                            color: color_palette["white"], fontSize: 42.4.h),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.only(bottom: 7),
                      alignment: AlignmentDirectional.topStart,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                              width: 2.0,
                              color: color_palette["background_color"]),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.only(top: 10),
                              child: CalendarTimeline(
                                height: 93.h + 10,
                                showYears: true,
                                initialDate: Provider.of<MealPlanNotifier>(
                                        context,
                                        listen: false)
                                    .startOfDay,
                                firstDate:
                                    DateTime.now().subtract(Duration(days: 7)),
                                lastDate:
                                    DateTime.now().add(Duration(days: 14)),
                                onDateSelected: (date) {
                                  Provider.of<MealPlanNotifier>(context,
                                          listen: false)
                                      .setStartOfDay(date);
                                },
                                leftMargin: 20,
                                monthColor: color_palette["offWhite"],
                                dayColor: color_palette["white"],
                                dayNameColor: color_palette["text_color_dark"],
                                activeDayColor:
                                    color_palette["text_color_dark"],
                                activeBackgroundDayColor:
                                    color_palette["white"],
                                dotsColor: color_palette["text_color_dark"],
                                locale: 'en',
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if(dailyPlans.length == 0 ) Spacer(),
              dailyPlans.length > 0
                  ? NotificationListener<OverscrollIndicatorNotification>(
                      onNotification: (overscroll) {
                        overscroll.disallowIndicator();
                        return;
                      },
                      child: Expanded(
                          child: Container(
                              child: ListView.builder(

                                  itemCount:dailyPlans.length,
                                  itemBuilder: (BuildContext ctx, index) {
                                    MealPlanNotifier mealPlanNotifier =
                                        Provider.of<MealPlanNotifier>(ctx,
                                            listen: false);

                                    MealPlan mealPlan = dailyPlans[index];
                                    //ensure that recipe exists
                                    if ((mealPlanNotifier.recipesInMealPlans
                                            .firstWhere(
                                                (it) =>
                                                    it.id == mealPlan.recipeId,
                                                orElse: () => null)) !=
                                        null) {
                                      Recipe recipe = mealPlanNotifier
                                          .recipesInMealPlans
                                          .firstWhere(
                                              (element) =>
                                                  element.id ==
                                                  mealPlan.recipeId,
                                              orElse: () => null);

                                      return mealCard(
                                          context, mealPlan, recipe, index);

                                    } else {
                                      return Container();
                                    }
                                  }))))
                  : Center(
                      child: AutoSizeText(
                      en_messages["no_meals_found"],
                      maxLines: 3,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: color_palette["white"], fontSize: 23.h),
                    )),
              Spacer(),
              totalCaloriesWidget(context),
            ])),
      ),
    );
  }

  Widget totalCaloriesWidget(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 13.1.h),
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          AutoSizeText(
            en_messages["total_calories_label"],
            maxLines: 1,
            style: TextStyle(color: color_palette["white"], fontSize: 31.h),
          ),
          AutoSizeText(
            "${Provider.of<MealPlanNotifier>(context, listen: false).obtainCaloriesForDate().toStringAsFixed(1)} " +
                en_messages["calories_label2"],
            maxLines: 1,
            style: TextStyle(color: color_palette["white"], fontSize: 23.6.h),
          )
        ],
      ),
    );
  }

  Widget mealCard(
      BuildContext context, MealPlan mealPlan, Recipe recipe, int index) {
    return Dismissible(
        key: UniqueKey(),
        confirmDismiss: (DismissDirection direction) async {
          if (direction == DismissDirection.endToStart) {
            return await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(
                    en_messages["delete_confirmation"],
                    maxLines: 1,
                  ),
                  content: Text(
                    en_messages["remove_mealPlan_question"],
                    maxLines: 3,
                  ),
                  actions: <Widget>[
                    ElevatedButton(
                        onPressed: () {
                          Provider.of<MealPlanNotifier>(context, listen: false)
                              .removePlan(mealPlan);
                          Navigator.of(context).pop(true);
                        },
                        child: Text(
                          en_messages["delete"],
                          maxLines: 1,
                        )),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        en_messages["cancel"],
                        maxLines: 1,
                      ),
                    ),
                  ],
                );
              },
            );
          }
          return null;
        },
        child: GestureDetector(
            onTap: () {
              if (AdService.shouldShowAd(adProbability: 0.10) == true) {
                AdService.showInterstitialAd(() {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              RecipeExpanded(recipe: recipe)));
                });
              } else {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RecipeExpanded(recipe: recipe)));
              }
            },
            child: Container(
                height: 70.h,
                width: MediaQuery.of(context).size.width - 20,
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6.625.h),
                decoration: BoxDecoration(
                  color: color_palette["text_color_dark"],
                  gradient: color_palette["gradient"],
                  borderRadius: BorderRadius.circular(40.h / 2),
                  boxShadow: [
                    BoxShadow(
                      color: color_palette["overlay"],
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  elevation: 10,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                          height: 53.h,
                          width: 53.h,
                          margin: EdgeInsets.only(left: 10, right: 5),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(53.h / 2),
                                right: Radius.circular(53.h / 2),
                              ),
                              image: DecorationImage(
                                  image:
                                      NetworkImage((recipe.recipeImageFromDB)),
                                  fit: BoxFit.cover))),
                      Expanded(
                          child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AutoSizeText(
                                    recipe.title.toUpperCase(),
                                    maxLines: 1,
                                    minFontSize: 12,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: color_palette["white"], fontSize: 21.2.h),
                                  ),
                                  AutoSizeText(
                                    mealPlan.title.toUpperCase(),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    minFontSize: 8,
                                    style: TextStyle(
                                        color: color_palette["white"],
                                        fontSize: 15.9.h),
                                  ),
                                ],
                              ))),
                      Container(
                          width: 72.875.h,
                          margin: EdgeInsets.only(right: 5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              AutoSizeText(
                                mealPlan.timeOfDay,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                minFontSize: 8,
                                style: TextStyle(
                                    color: Colors.orangeAccent, fontSize: 17.h),
                              ),
                              AutoSizeText(
                                (recipe.nutritionalValue["totalCalories"] /
                                            recipe.peopleServed)
                                        .toStringAsFixed(1) +
                                    " Cal",
                                textAlign: TextAlign.center,
                                minFontSize: 8,
                                style: TextStyle(
                                    color:color_palette["neutral"],
                                    fontSize: 13.25.h),
                              ),
                            ],
                          )),
                      GestureDetector(
                        onTap: () async {
                          await Navigator.of(context)
                              .push(HeroDialogRoute(builder: (context) {
                            return MealSharePopup(
                              recipe: recipe,
                              isCopy: true,
                            );
                          }));
                        },
                        child: Container(
                          width: 32,
                          height: double.infinity,
                          margin: EdgeInsets.only(right: 5),
                          decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.horizontal(
                                right: Radius.circular(70.h / 2),
                              )),
                          child: Icon(
                            Icons.copy,
                            color: color_palette["white"],
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ))));
  }
}
