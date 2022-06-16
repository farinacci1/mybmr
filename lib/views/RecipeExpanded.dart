import 'package:fl_chart/fl_chart.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
import '../models/Ingredient.dart';

class RecipeExpanded extends StatefulWidget {
  @required
  final Recipe recipe;
  const RecipeExpanded({Key key, this.recipe}) : super(key: key);
  @override
  _RecipeExpandedState createState() => _RecipeExpandedState();
}

class _RecipeExpandedState extends State<RecipeExpanded> {
  SystemUiOverlayStyle _systemUiOverlayStyle =   SystemUiOverlayStyle(statusBarColor: Colors.transparent);
  @override
  void initState() {
    Provider.of<RecipeFieldsNotifier>(context, listen: false).recipeState =
        ActiveRecipeState.LOADING;
    Provider.of<RecipeFieldsNotifier>(context, listen: false).activeRecipe =
        widget.recipe;
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
    RecipeFieldsNotifier rp =
        Provider.of<RecipeFieldsNotifier>(context, listen: true);
    return WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Scaffold(
            backgroundColor: color_palette["white"],
            body: NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (overscroll) {
                  overscroll.disallowIndicator();
                  return;
                },
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverAppBar(
                      expandedHeight: 300,
                      forceElevated: true,
                      backgroundColor: color_palette["white"],
                      actionsIconTheme: IconThemeData(opacity: 0.0),
                      systemOverlayStyle:  _systemUiOverlayStyle,
                      leading: IconButton(
                          icon: Icon(FontAwesomeIcons.arrowLeft),
                          tooltip: 'Click to Home Screen',
                          onPressed: () {
                            Navigator.pop(context);
                          }),
                      flexibleSpace: FlexibleSpaceBar(
                        centerTitle: true,
                        title: Text(widget.recipe.title,
                            style: TextStyle(
                                fontSize: 47.7.h,
                                color: color_palette["white"])),
                        background: Image.network(
                          widget.recipe.recipeImageFromDB,
                          fit: BoxFit.fill,
                        ),
                        stretchModes: [StretchMode.fadeTitle],
                      ),
                    ),
                    SliverToBoxAdapter(
                        child: Column(
                      children: [
                        Container(
                            margin: EdgeInsets.fromLTRB(10, 10, 10, 5),
                            alignment: AlignmentDirectional.topEnd,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  MaterialIcons.room_service,
                                  size: 32.h,
                                  color: color_palette["background_color"],
                                ),
                                Text(
                                  " ${widget.recipe.peopleServed}",
                                  maxLines: 1,
                                  style: TextStyle(
                                      fontSize: 24.h,
                                      color: color_palette["background_color"]),
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 10),
                                ),
                                Icon(
                                  MyFlutterApp.timer,
                                  size: 32.h,
                                  color: color_palette["background_color"],
                                ),
                                Text(
                                  " ${Conversion.prepTimeShort(widget.recipe.prepTime)}",
                                  maxLines: 1,
                                  style: TextStyle(
                                      fontSize: 24.h,
                                      color: color_palette["background_color"]),
                                ),
                              ],
                            )),
                        Container(
                          margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                          alignment: AlignmentDirectional.topStart,
                          child: Text(
                            "About",
                            maxLines: 1,
                            style: TextStyle(
                                fontSize: 20.h,
                                color: color_palette["background_color"],
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                            margin: EdgeInsets.symmetric(
                                vertical: 2, horizontal: 14),
                            alignment: AlignmentDirectional.topStart,
                            child: Text(
                              widget.recipe.description,
                              style: TextStyle(
                                  fontSize: 24.h,
                                  color: color_palette["background_color"]),
                            )),
                        Container(
                          margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                          alignment: AlignmentDirectional.topStart,
                          child: Text(
                            "Ingredients",
                            maxLines: 1,
                            style: TextStyle(
                                fontSize: 20.h,
                                color: color_palette["background_color"],
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width - 28.0,
                          height: 125.h,
                          margin: EdgeInsets.fromLTRB(14,12,14,0),

                          child:
                        rp.recipeState == ActiveRecipeState.LOADING
                            ? Container(
                          width: double.infinity,
                          height: double.infinity,
                                alignment: AlignmentDirectional.center,
                                child: JumpingDotsProgressIndicator(
                                  fontSize: 26.5.h,
                                  color: color_palette["white"],
                                ),
                              )
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: Provider.of<RecipeFieldsNotifier>(
                                        context,
                                        listen: false)
                                    .ingredientsForActiveRecipe
                                    .length,
                                itemBuilder: (context, index) {
                                  Ingredient ingredient =
                                      Provider.of<RecipeFieldsNotifier>(context,
                                              listen: false)
                                          .ingredientsForActiveRecipe[index];
                                  RecipeIngredient current = widget
                                      .recipe.recipeIngredients
                                      .firstWhere(
                                          (RecipeIngredient rp) =>
                                              rp.ingredientId == ingredient.id,
                                          orElse: () => null);
                                  return Container(
                                    alignment: AlignmentDirectional.center,
                                    margin: EdgeInsets.only( right: 10),
                                    child: Column(
                                      children: [
                                        Container(
                                            width: 53.h,
                                            height: 53.h,
                                            decoration: BoxDecoration(
                                                color: color_palette[
                                                    "text_color_dark"],
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(53.h / 2),
                                                ),
                                                image: (ingredient == null ||
                                                        ingredient
                                                                .ingredientImageFromDB ==
                                                            null ||
                                                        ingredient
                                                                .ingredientImageFromDB
                                                                .length <=
                                                            0)
                                                    ? DecorationImage(
                                                        image: AssetImage(
                                                            "assets/images/BMRLogo.png"),
                                                        fit: BoxFit.fill)
                                                    : DecorationImage(
                                                        image: NetworkImage(
                                                            ingredient
                                                                .ingredientImageFromDB),
                                                        fit: BoxFit.fill))),
                                        Text(
                                          "${ingredient.ingredientName}",
                                          maxLines: 1,
                                          style: TextStyle(
                                              fontSize: 23.85.h,
                                              color: color_palette["background_color"]),
                                        ),
                                        Text(
                                          "${current.amountOfIngredient}${current.unitOfMeasurement}",
                                          maxLines: 1,
                                          style: TextStyle(
                                              fontSize: 21.2.h,
                                              color: color_palette["background_color"]),
                                        )
                                      ],
                                    ),
                                  );
                                }),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                          alignment: AlignmentDirectional.topStart,

                          child: Text(
                            "Equipment",
                            maxLines: 1,
                            style: TextStyle(
                                fontSize: 20.h,
                                color: color_palette["background_color"],
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width - 28.0,
                          height: 104.h,

                          margin:
                              EdgeInsets.symmetric(vertical: 2, horizontal: 14),
                          alignment: AlignmentDirectional.center,
                          child: rp.recipeState == ActiveRecipeState.LOADING
                              ? Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  child: JumpingDotsProgressIndicator(
                                    fontSize: 20.0,
                                    color: color_palette["background_color"],
                                  ),
                                )
                              : ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: rp.equipmentForActiveRecipe
                                      .map((Equipment equipment) {
                                    return Container(
                                      alignment: AlignmentDirectional.center,
                                      margin:
                                          EdgeInsets.only(top: 10, right: 10),
                                      child: Column(
                                        children: [
                                          Container(
                                              width: 53.h,
                                              height: 53.h,
                                              decoration: BoxDecoration(
                                                  color: color_palette[
                                                      "background_color"],
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(53.h / 2),
                                                  ),
                                                  image: (equipment == null ||
                                                          equipment
                                                                  .equipmentImageFromDb ==
                                                              null ||
                                                          equipment
                                                                  .equipmentImageFromDb
                                                                  .length <=
                                                              0)
                                                      ? DecorationImage(
                                                          image: AssetImage(
                                                              "assets/images/BMRLogo.png"),
                                                          fit: BoxFit.fill)
                                                      : DecorationImage(
                                                          image: NetworkImage(
                                                              equipment
                                                                  .equipmentImageFromDb),
                                                          fit: BoxFit.fill))),
                                          Text(
                                            "${equipment.name}",
                                            maxLines: 1,
                                            style: TextStyle(
                                                fontSize: 23.85.h,
                                                color: color_palette["background_color"]),
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
                            style: TextStyle(
                                fontSize: 20.h,
                                color: color_palette["background_color"],
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          margin:
                              EdgeInsets.symmetric(vertical: 4, horizontal: 14),
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
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Stack(
                                            alignment:
                                                AlignmentDirectional.center,
                                            children: [
                                              SvgPicture.asset(
                                                "assets/images/step.svg",
                                                height: 47.7.h,
                                                color: color_palette[
                                                    "background_color"],
                                              ),
                                              Text(
                                                (idx + 1).toString(),
                                                style: TextStyle(
                                                    fontSize: 18.55.h,
                                                    color: color_palette[
                                                        "background_color"],
                                                    fontWeight:
                                                        FontWeight.bold),
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
                                                  fontSize: 26.5.h,
                                                  color: color_palette[
                                                      "background_color"]),
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
                            style: TextStyle(
                                fontSize: 20.h,
                                color: color_palette["background_color"],
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                            width: MediaQuery.of(context).size.width - 28,
                            height: 337.857.h,
                            margin: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 14),
                            alignment: AlignmentDirectional.center,
                            child: Stack(
                              alignment: AlignmentDirectional.center,
                              children: [
                                PieChart(PieChartData(sections: [
                                  PieChartSectionData(
                                    value: Conversion.computePercentageValue(
                                        widget.recipe.nutritionalValue[
                                                "totalProtein"] *
                                            4,
                                        widget.recipe
                                            .nutritionalValue["totalCalories"]),
                                    title:
                                        'Protein\n${Conversion.computePercentageValue(widget.recipe.nutritionalValue["totalProtein"] * 4, widget.recipe.nutritionalValue["totalCalories"]).toStringAsFixed(2)}%',
                                    titleStyle: TextStyle(
                                        color: color_palette["background_color"],
                                        fontSize: 21.2.h,fontWeight: FontWeight.bold),
                                    color: Color(0xff89CFF0),
                                  ),
                                  PieChartSectionData(
                                    value: Conversion.computePercentageValue(
                                        widget.recipe
                                                .nutritionalValue["totalFat"] *
                                            9,
                                        widget.recipe
                                            .nutritionalValue["totalCalories"]),
                                    title:
                                        'Fats\n${Conversion.computePercentageValue(widget.recipe.nutritionalValue["totalFat"] * 9, widget.recipe.nutritionalValue["totalCalories"]).toStringAsFixed(2)}%',
                                    titleStyle: TextStyle(
                                        color: color_palette["background_color"],
                                        fontSize: 21.2.h,fontWeight: FontWeight.bold),
                                    color: color_palette["neutral"]
                                  ),
                                  PieChartSectionData(
                                    value: Conversion.computePercentageValue(
                                        widget.recipe.nutritionalValue[
                                                "totalCarbohydrates"] *
                                            4,
                                        widget.recipe
                                            .nutritionalValue["totalCalories"]),
                                    title:
                                        'Carbs\n${Conversion.computePercentageValue(widget.recipe.nutritionalValue["totalCarbohydrates"] * 4, widget.recipe.nutritionalValue["totalCalories"]).toStringAsFixed(2)}%',
                                    titleStyle: TextStyle(
                                        color: color_palette["background_color"],
                                        fontSize: 21.2.h,fontWeight: FontWeight.bold),
                                    color: Color(0xffFAD5A5),
                                  ),
                                ])),
                                Text(
                                  "Calories\n${(widget.recipe.nutritionalValue["totalCalories"] / widget.recipe.peopleServed).toStringAsFixed(2)}",
                                  style: TextStyle(
                                      color: color_palette["background_color"],
                                      fontSize: 31.8.h),
                                  textAlign: TextAlign.center,
                                )
                              ],
                            )),
                      ],
                    )),
                  ],
                ))));
  }
}
