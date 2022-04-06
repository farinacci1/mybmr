import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:like_button/like_button.dart';
import 'package:mybmr/notifiers/FavoritesNotifier.dart';
import 'package:mybmr/notifiers/RecipeNotifier.dart';
import 'package:mybmr/constants/messages/en_messages.dart';
import 'package:mybmr/models/AppUser.dart';
import 'package:mybmr/models/Recipe.dart';
import 'package:mybmr/services/AdService.dart';

import 'package:mybmr/services/hero_dialog_route.dart';
import 'package:mybmr/services/toast.dart';
import 'package:mybmr/views/ProfileViewer.dart';
import 'package:mybmr/widgets/AnimatedLikeScreen.dart';
import 'package:mybmr/widgets/CircularTextContainer.dart';
import 'package:provider/provider.dart';

import '../constants/Themes.dart';
import 'RecipeExpanded.dart';
import 'creationMenus/popups/MealPlanner.dart';
import 'creationMenus/popups/RecipeNutrition.dart';
import 'creationMenus/popups/ReportPopup.dart';
import 'creationMenus/popups/SearchCard.dart';

class RecipePageView extends StatefulWidget {
  @override
  _RecipePageViewState createState() => _RecipePageViewState();
}

class _RecipePageViewState extends State<RecipePageView> {
  PageController pageController;

  bool isHeartAnimating = false;
  bool  isHeartAnimating2 = false;
  @override
  void initState() {
    pageController = PageController(
        initialPage:
            Provider.of<RecipeNotifier>(context, listen: false).currPage);

    super.initState();
  }

  @override
  void dispose() {
    if (pageController != null) pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<RecipeNotifier>(context, listen: true);
    ScreenUtil.init(
        BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width,
            maxHeight: MediaQuery.of(context).size.height),
        designSize: Size(2400, 1080),
        context: context,
        minTextAdapt: true,
        orientation: Orientation.portrait);

    Provider.of<FavoritesNotifier>(context, listen: true);
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: Colors.black,
        ),
        child:
            (Provider.of<RecipeNotifier>(context, listen: false).isFetching ==
                        false &&
                    Provider.of<RecipeNotifier>(context, listen: false)
                            .recipes
                            .length ==
                        0)
                ? errorPage()
                : RefreshIndicator(
                    backgroundColor: Colors.black38,
                    color: Colors.white70,
                    onRefresh: () async {
                      if (AdService.shouldShowAd(adProbability: 0.15)) {
                        AdService.showInterstitialAd(() {
                          Provider.of<RecipeNotifier>(context, listen: false)
                              .shouldRefresh();
                        });
                      } else {
                        Provider.of<RecipeNotifier>(context, listen: false)
                            .shouldRefresh();
                      }
                      return true;
                    },
                    child: recipePageView(context)));
  }

  Widget errorPage() {
    return PageView(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(gradient: color_palette["gradient"]),
          padding: EdgeInsets.symmetric(horizontal: 18),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              height: 228,
              margin: EdgeInsets.only(bottom: 10),
              child: Image.asset(
                "assets/images/MyBMRLogo.png",
                fit: BoxFit.fitHeight,
              ),
            ),
            Container(
              height: 38.h + 14,
            ),
            AutoSizeText(
              en_messages["no_recipes_found"],
              style: TextStyle(color: color_palette["white"], fontSize: 23.h),
              maxLines: 6,
              textAlign: TextAlign.center,
            ),
            CircularTextContainer(
              iconSize: 38.h,
              icon: FontAwesomeIcons.search,
              margin: EdgeInsets.only(top: 14, right: 5),
              iconColor: color_palette["white"],
              primary: color_palette["white"],
              value: 'Search',
              onTap: () async {
                await Navigator.of(context)
                    .push(HeroDialogRoute(builder: (context) {
                  return SearchCard();
                }));
              },
            )
          ]),
        )
      ],
    );
  }

  Widget recipePage(Recipe recipe) {
    List<String> tags = recipe.mealTimes + recipe.neededDiets;

    return Stack(alignment: AlignmentDirectional.center, children: [
      Stack(alignment: AlignmentDirectional.bottomEnd, children: [
        Stack(alignment: AlignmentDirectional.bottomStart, children: [
          Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                alignment: AlignmentDirectional.center,
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    image: NetworkImage(
                      recipe.recipeImageFromDB,
                    ),
                    filterQuality: FilterQuality.high,
                    fit: BoxFit.fill,
                  )),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                  Color.fromARGB(200, 0, 0, 0),
                  Color.fromARGB(0, 0, 0, 0)
                ], begin: Alignment.bottomCenter, end: Alignment.topCenter)),
              )
            ],
          ),
          Positioned(
            bottom: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(
                    left: 15,
                  ),
                  alignment: AlignmentDirectional.topStart,
                  width:
                      MediaQuery.of(context).size.width - ((38.h * 1.75) + 10),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                            child: Text('${recipe.title}',
                                maxLines: 2,
                                style: TextStyle(
                                    fontSize: 40.h,
                                    color: Colors.white,
                                    decoration: TextDecoration.none))),
                        Container(
                          margin: EdgeInsets.fromLTRB(1, 2, 0, 6),
                          width: MediaQuery.of(context).size.width -
                              ((38.h * 1.75) + 25),
                          child: Text('${recipe.description}',
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 26.h,
                                  color: Colors.orange,
                                  decoration: TextDecoration.none)),
                        ),
                        Wrap(
                            spacing: 10,
                            runSpacing: 5,
                            children: tags.map((String recipeTag) {
                              return Material(
                                  color: color_palette["text_color_dark"],
                                  borderRadius: BorderRadius.circular(10),
                                  child: Text(
                                    "  ${recipeTag.toUpperCase()}  ",
                                    maxLines: 1,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 19.h),
                                  ));
                            }).toList())
                      ]),
                ),
                GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfileViewer(
                                    userId: recipe.createdBy,
                                  )));
                    },
                    child: Container(
                      height: 66.25.h,
                      width: MediaQuery.of(context).size.width - 20,
                      alignment: AlignmentDirectional.center,
                      margin: EdgeInsets.fromLTRB(10, 8, 10, 0),
                      decoration: BoxDecoration(
                          color: color_palette["overlay"],
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        children: [
                          Container(
                              margin: EdgeInsets.only(left: 12),
                              child: (Provider.of<RecipeNotifier>(context,
                                                  listen: false)
                                              .posters[recipe.createdBy]
                                              .profileImagePath ==
                                          null ||
                                      Provider.of<RecipeNotifier>(context,
                                                  listen: false)
                                              .posters[recipe.createdBy]
                                              .profileImagePath ==
                                          "")
                                  ? Icon(
                                      FontAwesomeIcons.userAstronaut,
                                      color: color_palette["white"],
                                      size: 28.h,
                                    )
                                  : CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          Provider.of<RecipeNotifier>(context,
                                                  listen: false)
                                              .posters[recipe.createdBy]
                                              .profileImagePath),
                                      radius: 28.h,
                                    )),
                          Expanded(
                            child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 15),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      Provider.of<RecipeNotifier>(context,
                                              listen: false)
                                          .posters[recipe.createdBy]
                                          .userName,
                                      maxLines: 1,
                                      style: TextStyle(
                                          color: color_palette["white"],
                                          fontSize: 18.55.h),
                                    ),
                                    Text(
                                      Provider.of<RecipeNotifier>(context,
                                              listen: false)
                                          .posters[recipe.createdBy]
                                          .aboutUser,
                                      style: TextStyle(
                                          color:
                                              color_palette["text_color_alt"],
                                          fontSize: 14.575.h),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                )),
                          ),
                          Container(
                            margin: EdgeInsets.only(right: 15),
                            child: Container(
                              height: double.infinity,
                              child: Icon(
                                FontAwesomeIcons.arrowCircleRight,
                                color: color_palette["white"],
                                size: 31.h,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ))
              ],
            ),
          ),
        ]),
        Container(
            padding: EdgeInsets.only(
              bottom: 66.25.h + 28,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CircularTextContainer(
                  icon: FontAwesomeIcons.fire,
                  iconSize: 38.h,
                  margin: EdgeInsets.only(bottom: 15, right: 0),
                  iconColor: color_palette["offWhite"],
                  value:
                      '${(recipe.nutritionalValue["totalCalories"] / recipe.peopleServed).ceil().toString()} ${en_messages["calories_label2"]}',
                  onTap: () async {
                    await Navigator.of(context)
                        .push(HeroDialogRoute(builder: (context) {
                      return RecipeNutrition(
                        recipe: recipe,
                      );
                    }));
                  },
                ),
                CircularTextContainer(
                  icon: Icons.ramen_dining,
                  iconColor: color_palette["offWhite"],
                  iconSize: 38.h,
                  margin: EdgeInsets.only(bottom: 15, right: 0),
                  value: '${recipe.peopleServed} Serv.',
                ),
                CircularTextContainer(
                  icon: FontAwesomeIcons.calendarAlt,
                  iconColor: color_palette["offWhite"],
                  iconSize: 38.h,
                  onTap: () async {
                    await Navigator.of(context)
                        .push(HeroDialogRoute(builder: (context) {
                      return MealPlannerPopup(
                        recipe: recipe,
                      );
                    }));
                  },
                  margin: EdgeInsets.only(bottom: 15, right: 0),
                  value: 'Meal Plan',
                ),
                Container(
                    alignment: AlignmentDirectional.center,
                    width: (38.h * 1.75) + 20,
                    margin: EdgeInsets.only(bottom: 15, right: 0),
                    child: Container(
                        width: 38.h * 1.75,
                        padding: EdgeInsets.only(left: 10),
                        alignment: AlignmentDirectional.center,
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          Container(
                              constraints: BoxConstraints(maxHeight: 38.h),
                              child: SingleChildScrollView(
                                  physics: const NeverScrollableScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        GestureDetector(
                                            behavior: HitTestBehavior.translucent,
                                            onTap: () {
                                              setState(() {
                                                isHeartAnimating2 = true;
                                                Provider.of<FavoritesNotifier>(
                                                        context,
                                                        listen: false)
                                                    .handleLikeEvent(recipe.id,
                                                        recipe: recipe);
                                              });
                                            },
                                            child: AnimatedLikeScreen(
                                              size: 38.h,
                                              hasScaleFactor: false,
                                              isAnimating: isHeartAnimating2,
                                              icon: FontAwesomeIcons.solidStar,
                                              iconColor: AppUser
                                                      .instance.likedRecipesIds
                                                      .contains(recipe.id)
                                                  ? Colors.cyanAccent
                                                  : color_palette["offWhite"],
                                              bubblesColor: BubblesColor(
                                                  dotPrimaryColor:
                                                      color_palette[
                                                          "text_color_dark"],
                                                  dotSecondaryColor:
                                                      color_palette[
                                                          "text_color_dark"],
                                                  dotThirdColor: color_palette[
                                                      "text_color_dark"],
                                                  dotLastColor: color_palette[
                                                      "text_color_dark"]),
                                              circleColor: CircleColor(
                                                  start: color_palette[
                                                      "text_color_alt"],
                                                  end: color_palette[
                                                      "text_color_alt"]),
                                              onEnd: () => setState(() =>
                                              isHeartAnimating2 = false),
                                            ))
                                      ]))),
                          Container(
                              margin: EdgeInsets.only(top: 4),
                              child: AutoSizeText(
                                "Like",
                                textAlign: TextAlign.center,
                                minFontSize: 10,
                                maxLines: 2,
                                style: TextStyle(
                                    color: Colors.orangeAccent,
                                    fontSize: 38.h / 2.5),
                              )),
                        ]))),
                CircularTextContainer(
                  icon: FontAwesomeIcons.ellipsisH,
                  iconSize: 38.h,
                  iconColor: color_palette["offWhite"],
                  onTap: () async {
                    await Navigator.of(context)
                        .push(HeroDialogRoute(builder: (context) {
                      return ReportPopup(recipe: recipe);
                    }));
                  },
                  margin: EdgeInsets.only(bottom: 15, right: 0),
                  value: 'Report',
                ),
                CircularTextContainer(
                  iconSize: 38.h,
                  icon: FontAwesomeIcons.search,
                  iconColor: color_palette["offWhite"],
                  value: 'Search',
                  onTap: () async {
                    await Navigator.of(context)
                        .push(HeroDialogRoute(builder: (context) {
                      return SearchCard();
                    }));
                    pageController.jumpToPage(
                        Provider.of<RecipeNotifier>(context, listen: false)
                            .currPage);
                  },
                ),
              ],
            )),
      ]),
    ]);
  }

  Widget recipePageView(BuildContext context) {
    return PageView(
      scrollDirection: Axis.vertical,
      controller: pageController,
      children: Provider.of<RecipeNotifier>(context, listen: false)
          .recipes
          .map((Recipe recipe) {
        return GestureDetector(
          onTap: () {
            {
              if (AdService.shouldShowAd(adProbability: 0.1)) {
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
            }
          },
          onDoubleTap: () {
            if (AppUser.instance.uuid != null && AppUser.instance.uuid != "") {
              setState(() {
                isHeartAnimating = true;
                Provider.of<FavoritesNotifier>(context, listen: false)
                    .handleLikeEvent(recipe.id, recipe: recipe);
              });
            }
          },
          child: Stack(alignment: AlignmentDirectional.center, children: [
            recipePage(recipe),
            if (isHeartAnimating)
              AnimatedLikeScreen(
                size: 100.h,
                isAnimating: isHeartAnimating,
                icon: FontAwesomeIcons.solidStar,
                iconColor: AppUser.instance.likedRecipesIds.contains(recipe.id)
                    ? Colors.cyanAccent
                    : color_palette["offWhite"],
                bubblesColor: BubblesColor(
                    dotPrimaryColor: color_palette["text_color_dark"],
                    dotSecondaryColor: color_palette["text_color_dark"],
                    dotThirdColor: color_palette["text_color_dark"],
                    dotLastColor: color_palette["text_color_dark"]),
                circleColor: CircleColor(
                    start: color_palette["text_color_alt"],
                    end: color_palette["text_color_alt"]),
                onEnd: () => setState(() => isHeartAnimating = false),
              )
          ]),
        );
      }).toList(),
      onPageChanged: (int idx) {
        if (Provider.of<RecipeNotifier>(context, listen: false)
                    .canFetchRecipes ==
                false &&
            idx ==
                Provider.of<RecipeNotifier>(context, listen: false)
                        .recipes
                        .length -
                    1) {
          CustomToast(en_messages["out_of_recipes"]);
        }
        Provider.of<RecipeNotifier>(context, listen: false).currPage = idx;
        RecipeNotifier recipeNotifier =
            Provider.of<RecipeNotifier>(context, listen: false);
        int fetchIdx =
            recipeNotifier.recipes.length - (recipeNotifier.batchSize ~/ 2);
        if (AdService.shouldShowAd(adProbability: 0.07)) {
          AdService.showInterstitialAd(() {});
        }
        if (recipeNotifier.isFetching == false &&
            recipeNotifier.recipes.length % recipeNotifier.batchSize == 0 &&
            idx == fetchIdx) {
          Provider.of<RecipeNotifier>(context, listen: false).fetchRecipes();
        }
      },
    );
  }
}
