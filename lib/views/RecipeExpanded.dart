
import 'package:auto_size_text/auto_size_text.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mybmr/notifiers/RecipeFieldsNotifier.dart';
import 'package:mybmr/constants/Constants.dart';
import 'package:mybmr/constants/messages/en_messages.dart';

import 'package:mybmr/models/Equipment.dart';

import 'package:mybmr/models/Recipe.dart';

import 'package:mybmr/services/conversion.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:provider/provider.dart';


import '../app_icons.dart';
import '../constants/Themes.dart';

class RecipeExpanded extends StatefulWidget {
  @required
  final Recipe recipe;
  const RecipeExpanded({Key key, this.recipe}) : super(key: key);
  @override
  _RecipeExpandedState createState() => _RecipeExpandedState();
}

class _RecipeExpandedState extends State<RecipeExpanded> {

  @override void initState() {

    Provider.of<RecipeFieldsNotifier>(context,listen:false).recipeState = ActiveRecipeState.LOADING;
    Provider.of<RecipeFieldsNotifier>(context,listen:false).activeRecipe = widget.recipe;
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
    //List<String> tags = widget.recipe.neededDiets + widget.recipe.mealTimes ;
    RecipeFieldsNotifier rp = Provider.of<RecipeFieldsNotifier>(context,listen:true);
    return Scaffold(
      body: Container(
          height: MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top,
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          decoration: BoxDecoration(
            gradient: color_palette["gradient"]
          ),
          child: Stack(children: [
          NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
      overscroll.disallowIndicator();
      return;
      },
           child:Container(
               color: color_palette["tone"],
               child: SingleChildScrollView(
                 physics: new ClampingScrollPhysics(),
              child: Column(
                children: [
                  Stack(children: [
                    Container(
                        height: MediaQuery.of(context).size.height * .35,
                        width: MediaQuery.of(context).size.width,
                        alignment: AlignmentDirectional.topCenter,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(15),
                              bottomRight: Radius.circular(15)),
                          image: (widget.recipe == null ||
                              widget.recipe.recipeImageFromDB == null ||
                              widget.recipe.recipeImageFromDB.length <= 0)
                              ? DecorationImage(
                              image:
                              AssetImage("assets/images/MyBMR.png"),
                              fit: BoxFit.cover)
                              : DecorationImage(
                              image:  NetworkImage( widget.recipe.recipeImageFromDB),
                              fit: BoxFit.cover),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 4,
                                blurRadius: 4,
                                offset: Offset(3, 3))
                          ],
                        )),
                    Container(
                        height: MediaQuery.of(context).size.height * .35,
                        width: MediaQuery.of(context).size.width,


                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(15),
                                bottomRight: Radius.circular(15)),
                            gradient: LinearGradient(
                                colors: [
                                  Color.fromARGB(200, 0, 0, 0),
                                  Color.fromARGB(0, 0, 0, 0)
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter)),
                        child: Container(
                          alignment: AlignmentDirectional.topCenter,
                          padding:
                          EdgeInsets.fromLTRB( 25,10,25,10),
                            child:
                            AutoSizeText(
                                  "${widget.recipe.title}",
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  style: TextStyle(
                                      fontSize: 47.7.h, color: color_palette["text_color_alt"]),
                                ),

                            ))
                  ]),
                  Container(
                      margin: EdgeInsets.fromLTRB(10, 10, 10, 5),
                      alignment: AlignmentDirectional.topEnd,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            MyFlutterApp.knife_fork,
                            size: 32.h,
                            color: color_palette["neutral"],
                          ),
                          Text(
                            " ${widget.recipe.peopleServed}",
                            maxLines: 1,
                            style: TextStyle(fontSize:24.h, color: color_palette["white"]),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 10),
                          ),
                          Icon(
                            MyFlutterApp.timer,
                            size: 32.h,
                            color: color_palette["neutral"],
                          ),
                          Text(
                            " ${Conversion.prepTimeShort(widget.recipe.prepTime)}",
                            maxLines: 1,
                            style: TextStyle(fontSize: 24.h, color: color_palette["white"]),
                          ),
                        ],
                      )),
                  Container(
                    margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                    alignment: AlignmentDirectional.topStart,
                    child: Text(
                      "Description",
                      maxLines: 1,
                      style: TextStyle(fontSize: 29.15.h, color: color_palette["white"]),
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(width: 2.0, color: color_palette["text_color_dark"]),
                      ),
                    ),
                  ),
                  Container(
                      margin: EdgeInsets.symmetric(vertical: 2, horizontal: 14),
                      alignment: AlignmentDirectional.topStart,
                      child: Text(
                        widget.recipe.description,
                        style: TextStyle(fontSize: 24.h, color: color_palette["white"]),
                      )),
                  Container(
                    margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                    alignment: AlignmentDirectional.topStart,
                    child: Text(
                      "Ingredients",
                      maxLines: 1,
                      style: TextStyle(fontSize: 24.h, color: color_palette["white"]),
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(width: 2.0, color: color_palette["text_color_dark"]),
                      ),
                    ),
                  ),
                  Container(
                      width: MediaQuery.of(context).size.width - 28.0,
                      height: 125.h,
                      margin: EdgeInsets.symmetric(vertical: 2, horizontal: 14),
                      alignment: AlignmentDirectional.center,
                      child: rp.recipeState == ActiveRecipeState.LOADING?
                      Container(width: double.infinity,height: double.infinity,child: JumpingDotsProgressIndicator(
                        fontSize: 26.5.h,
                        color: color_palette["white"],
                      ),
                      ):
                      ListView(
                        scrollDirection: Axis.horizontal,
                        children: Provider.of<RecipeFieldsNotifier>(context,
                            listen: false)
                            .ingredientsForActiveRecipe
                            .map((ingredient) {
                          List<RecipeIngredient> recipeIngredients =
                              Provider.of<RecipeFieldsNotifier>(context,
                                  listen: false)
                                  .activeRecipe
                                  .recipeIngredients;
                          RecipeIngredient current = recipeIngredients
                              .firstWhere((RecipeIngredient rp) =>
                          rp.ingredientId == ingredient.id,orElse:() => null);
                          return Container(
                            alignment: AlignmentDirectional.center,
                            margin: EdgeInsets.only(top: 10, right: 10),
                            child: Column(
                              children: [
                                Container(
                                    width: 53.h,
                                    height: 53.h,
                                    decoration: BoxDecoration(
                                        color:  color_palette["text_color_dark"],
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(53.h/2),
                                        ),
                                        image: (ingredient == null ||
                                            ingredient.ingredientImageFromDB ==
                                                null ||
                                            ingredient.ingredientImageFromDB.length <=
                                                0)
                                            ? DecorationImage(
                                            image: AssetImage(
                                                "assets/images/BMRLogo.png"),
                                            fit: BoxFit.fill)
                                            : DecorationImage(
                                            image: NetworkImage(
                                                ingredient.ingredientImageFromDB),
                                            fit: BoxFit.fill))),
                                Text(
                                  "${ingredient.ingredientName}",
                                  maxLines: 1,
                                  style: TextStyle(
                                      fontSize: 23.85.h, color: color_palette["white"]),
                                ),
                                Text(
                                  "${current.amountOfIngredient}${current.unitOfMeasurement}",
                                  maxLines: 1,
                                  style: TextStyle(
                                      fontSize: 21.2.h, color:  color_palette["neutral"]),
                                )
                              ],
                            ),
                          );
                        }).toList(),
                      )
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                    alignment: AlignmentDirectional.topStart,
                    child: Text(
                      "Equipment",
                      maxLines: 1,
                      style: TextStyle(fontSize: 24.h, color: color_palette["white"]),
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(width: 2.0, color: color_palette["text_color_dark"]),
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width - 28.0,
                    height: 104.h,
                    margin: EdgeInsets.symmetric(vertical: 2, horizontal: 14),
                    alignment: AlignmentDirectional.center,
                    child: rp.recipeState == ActiveRecipeState.LOADING?
                    Container(width: double.infinity,height: double.infinity,child: JumpingDotsProgressIndicator(
                      fontSize: 20.0,
                      color: color_palette["white"],
                    ),
                    ):ListView(
                      scrollDirection: Axis.horizontal,
                      children: rp.equipmentForActiveRecipe.map((Equipment equipment) {
                        return Container(
                          alignment: AlignmentDirectional.center,
                          margin: EdgeInsets.only(top: 10, right: 10),
                          child: Column(
                            children: [
                              Container(
                                  width: 53.h,
                                  height: 53.h,
                                  decoration: BoxDecoration(
                                      color: color_palette["text_color_alt"],
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(53.h/2),

                                      ),
                                      image: (equipment == null ||
                                          equipment.equipmentImageFromDb == null ||
                                          equipment.equipmentImageFromDb.length <= 0)
                                          ? DecorationImage(
                                          image: AssetImage(
                                              "assets/images/BMRLogo.png"),
                                          fit: BoxFit.fill)
                                          : DecorationImage(
                                          image: NetworkImage(
                                              equipment.equipmentImageFromDb),
                                          fit: BoxFit.fill))),
                              Text(
                                "${equipment.name}",
                                maxLines: 1,
                                style: TextStyle(
                                    fontSize: 23.85.h, color: color_palette["white"]),
                              )
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  
                  Container(
                    margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                    alignment: AlignmentDirectional.topStart,
                    child: Text(
                      "Steps",
                      style: TextStyle(fontSize: 24.h, color: color_palette["white"]),
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(width: 2.0, color: color_palette["text_color_dark"]),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 4, horizontal: 14),
                    alignment: AlignmentDirectional.topStart,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.recipe.steps
                          .asMap()
                          .map((idx, step) => MapEntry(
                          idx,
                          Container(
                            margin: EdgeInsets.only(top: 10),
                            child: Row(
                              children: [
                                Stack(
                                  alignment: AlignmentDirectional.center,
                                  children: [
                                    SvgPicture.asset(
                                      "assets/images/step.svg",
                                      height: 47.7.h,
                                      color: Colors.white,
                                    ),
                                    Text(
                                      (idx + 1).toString(),
                                      style: TextStyle(
                                          fontSize: 18.55.h,
                                          color: color_palette["white"],
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 10),
                                ),
                                Flexible(
                                  child: Text(
                                    step,
                                    textScaleFactor: 1.0,
                                    style: TextStyle(
                                        fontSize: 26.5.h, color:color_palette["text_color_dark"]),
                                    softWrap: true,
                                  ),
                                )
                              ],
                            ),
                          )))
                          .values
                          .toList(),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                    alignment: AlignmentDirectional.topStart,
                    child: Text(
                      en_messages["nutritional_value_per_serv_label"],
                      style: TextStyle(fontSize: 24.h, color: color_palette["white"]),
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(width: 2.0, color: color_palette["text_color_dark"]),
                      ),
                    ),
                  ),
                  Container(
                      width: MediaQuery.of(context).size.width - 28,
                      height: 337.857.h,
                      margin:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                      alignment: AlignmentDirectional.center,
                      child: Stack(
                        alignment: AlignmentDirectional.center,
                        children: [
                          PieChart(PieChartData(sections: [
                            PieChartSectionData(
                              value: Conversion.computePercentageValue(
                                  widget.recipe
                                      .nutritionalValue["totalProtein"] *
                                      4,
                                  widget.recipe
                                      .nutritionalValue["totalCalories"]),
                              title:
                              'Protein\n${Conversion.computePercentageValue(widget.recipe.nutritionalValue["totalProtein"] * 4, widget.recipe.nutritionalValue["totalCalories"]).toStringAsFixed(2)}%',
                              titleStyle:
                              TextStyle(color: color_palette["white"], fontSize: 21.2.h),
                              color: Color(0xffed733f),
                            ),
                            PieChartSectionData(
                              value: Conversion.computePercentageValue(
                                  widget.recipe.nutritionalValue["totalFat"] *
                                      9,
                                  widget.recipe
                                      .nutritionalValue["totalCalories"]),
                              title:
                              'Fats\n${Conversion.computePercentageValue(widget.recipe.nutritionalValue["totalFat"] * 9, widget.recipe.nutritionalValue["totalCalories"]).toStringAsFixed(2)}%',
                              titleStyle:
                              TextStyle(color: color_palette["white"], fontSize: 21.2.h),
                              color: Color(0xff584f84),
                            ),
                            PieChartSectionData(
                              value: Conversion.computePercentageValue(
                                  widget.recipe.nutritionalValue["totalCarbohydrates"] *
                                      4,
                                  widget.recipe
                                      .nutritionalValue["totalCalories"]),
                              title:
                              'Carbs\n${Conversion.computePercentageValue(widget.recipe.nutritionalValue["totalCarbohydrates"] * 4, widget.recipe.nutritionalValue["totalCalories"]).toStringAsFixed(2)}%',
                              titleStyle:
                              TextStyle(color: color_palette["white"], fontSize: 21.2.h),
                              color: Color(0xffd86f9b),
                            ),
                          ])),
                          Text(
                            "Calories\n${(widget.recipe.nutritionalValue["totalCalories"] / widget.recipe.peopleServed).toStringAsFixed(2)}",
                            style: TextStyle(
                                color:color_palette["white"], fontSize: 31.8.h),
                            textAlign: TextAlign.center,
                          )
                        ],
                      )),

                ],
              ),
            ))),
            GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                    width: 66.25.h,
                    height: 66.25.h,
                    margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(66.25.h / 2)),
                        gradient:color_palette["gradient"]),
                    alignment: AlignmentDirectional.center,
                    child: Icon(
                      Icons.arrow_back,
                      color: color_palette["white"],
                    )))
          ])),

    );
  }
}
