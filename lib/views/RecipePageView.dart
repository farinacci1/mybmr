import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';

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
import 'package:mybmr/views/creationMenus/popups/RecipeOptionPopup.dart';
import 'package:mybmr/widgets/AnimatedLikeScreen.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

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
  bool isHeartAnimating = false;
  bool isHeartAnimating2 = false;
  List<Key> itemKeys = [];
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    for (var key in itemKeys) {
      VisibilityDetectorController.instance.forget(key);
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: color_palette["background_color"],
      systemNavigationBarColor: color_palette["background_color"],
      systemNavigationBarDividerColor: color_palette["background_color"],
    ));
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
        decoration: BoxDecoration(color: color_palette["background_color"]),
        child: RefreshIndicator(
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
            child: recipeFeed()));
  }

  Widget recipeFeed() {
    RecipeNotifier recipeNotifier =
        Provider.of<RecipeNotifier>(context, listen: false);

    return Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: color_palette["semi_transparent"],
        child: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (overscroll) {
              overscroll.disallowIndicator();
              return;
            },
            child: ListView.builder(
              itemCount: recipeNotifier.recipes.length,
              itemBuilder: (BuildContext ctx, int index) {
                Key key = Key(recipeNotifier.recipes[index].id);
                itemKeys.add(key);
                ScreenUtil.init(
                    BoxConstraints(
                        maxWidth: MediaQuery.of(ctx).size.width,
                        maxHeight: MediaQuery.of(ctx).size.height),
                    designSize: Size(2400, 1080),
                    context: ctx,
                    minTextAdapt: true,
                    orientation: Orientation.portrait);
                return Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: VisibilityDetector(
                        key: key,
                        onVisibilityChanged: (VisibilityInfo info) {
                          if (Provider.of<RecipeNotifier>(context,
                                          listen: false)
                                      .canFetchRecipes ==
                                  false &&
                              index ==
                                  Provider.of<RecipeNotifier>(context,
                                              listen: false)
                                          .recipes
                                          .length -
                                      1) {
                            CustomToast(en_messages["out_of_recipes"]);
                          }
                          Provider.of<RecipeNotifier>(context, listen: false)
                              .currPage = index;
                          RecipeNotifier recipeNotifier =
                              Provider.of<RecipeNotifier>(context,
                                  listen: false);
                          int fetchIdx = recipeNotifier.recipes.length -
                              (recipeNotifier.batchSize ~/ 2);
                          if (AdService.shouldShowAd(adProbability: 0.07)) {
                            AdService.showInterstitialAd(() {});
                          }
                          if (recipeNotifier.isFetching == false &&
                              recipeNotifier.recipes.length %
                                      recipeNotifier.batchSize ==
                                  0 &&
                              index == fetchIdx) {
                            Provider.of<RecipeNotifier>(context, listen: false)
                                .fetchRecipes();
                          }
                        },
                        child: recipeCard(recipeNotifier.recipes[index])));
              },
            )));
  }

  Widget recipeCard(Recipe recipe,{bool ShowPopupOptions = true}) {
    List<String> tags = recipe.mealTimes + recipe.neededDiets;
    return Card(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
            color: color_palette["background_color"],
            borderRadius: BorderRadius.circular(10)),
        width: MediaQuery.of(context).size.width - 20,
        margin: EdgeInsets.symmetric(horizontal: 10),
        constraints: BoxConstraints(
          minWidth: 200,
          minHeight: 200,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                  gradient: color_palette["gradient"]
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(

                        padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
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
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                          child: (Provider.of<RecipeNotifier>(
                                                              context,
                                                              listen: false)
                                                          .posters[
                                                              recipe.createdBy]
                                                          .profileImagePath ==
                                                      null ||
                                                  Provider.of<RecipeNotifier>(
                                                              context,
                                                              listen: false)
                                                          .posters[
                                                              recipe.createdBy]
                                                          .profileImagePath ==
                                                      "")
                                              ? Icon(
                                                  FontAwesomeIcons
                                                      .userAstronaut,
                                                  color: color_palette["white"],
                                                  size: 30.h,
                                                )
                                              : CircleAvatar(
                                                  backgroundImage: NetworkImage(
                                                      Provider.of<RecipeNotifier>(
                                                              context,
                                                              listen: false)
                                                          .posters[
                                                              recipe.createdBy]
                                                          .profileImagePath),
                                                  radius: 30.h,
                                                )),
                                     Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20),
                                       width: MediaQuery.of(context).size.width - 125,
                                        child:
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                    child: Text(
                                                  Provider.of<RecipeNotifier>(
                                                          context,
                                                          listen: false)
                                                      .posters[recipe.createdBy]
                                                      .userName ,
                                                  maxLines: 1,
                                                      softWrap: false,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color: color_palette[
                                                          "white"],
                                                      fontSize: 30.h),
                                                )),
                                                Text(
                                                  Provider.of<RecipeNotifier>(
                                                          context,
                                                          listen: false)
                                                      .posters[recipe.createdBy]
                                                      .aboutUser,
                                                  style: TextStyle(
                                                      color: color_palette[
                                                          "text_color_alt"],
                                                      fontSize: 16.h),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),

                                      ),
                                    ],
                                  )),
                            ),
                            Spacer(),

                            GestureDetector(
                                onTap: () async {
                                  await Navigator.of(context).push(
                                      HeroDialogRoute(builder: (context) {
                                        return RecipeOptionPopup(
                                          recipe: recipe,
                                          isOwnedByUser: true,
                                          isDeletable: false,
                                        );
                                      }));
                                },
                                child: Container(
                                  width: 30,
                                  child: Icon(MaterialIcons.more_vert,
                                      color: color_palette["white"]),
                                )),
                          ],
                        )),
                    Container(
                      width: MediaQuery.of(context).size.width - 20,
                      padding: EdgeInsets.fromLTRB(10, 10, 15, 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recipe.title,
                            maxLines: 1,
                            style: TextStyle(
                                color: color_palette["white"], fontSize: 30.h),
                          ),
                          RichText(
                            text: TextSpan(children: [
                              TextSpan(
                                text: recipe.description,
                                style: TextStyle(
                                    color: color_palette["white"],
                                    fontSize: 16.h),
                              ),
                              TextSpan(
                                text: " #" + tags.join(" #"),
                                style: TextStyle(
                                    color: color_palette["text_color_alt"],
                                    fontSize: 14.h),
                              )
                            ]),
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
            GestureDetector(
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
                            builder: (context) =>
                                RecipeExpanded(recipe: recipe)));
                  }
                }
              },
              onDoubleTap: () {
                if (AppUser.instance.uuid != null &&
                    AppUser.instance.uuid != "") {
                  setState(() {
                    isHeartAnimating = true;
                    Provider.of<FavoritesNotifier>(context, listen: false)
                        .handleLikeEvent(recipe.id, recipe: recipe);
                  });
                }
              },
              child: IntrinsicHeight(
                  child:
                      Stack(alignment: AlignmentDirectional.center, children: [
                Image.network(
                  recipe.recipeImageFromDB,
                  loadingBuilder: (BuildContext ctx,Widget child,ImageChunkEvent loadEvent){
                    if (loadEvent == null) return child;
                    return Container(
                      width: double.infinity,
                      color: Colors.transparent,
                      alignment: AlignmentDirectional.center,
                      child: JumpingDotsProgressIndicator(
                        color: Colors.white,
                        fontSize: 40,
                      ),
                    );
                  },
                  width: MediaQuery.of(context).size.width - 20,
                  fit: BoxFit.fitWidth,
                ),
                if (isHeartAnimating)
                  AnimatedLikeScreen(
                    size: 100.h,
                    isAnimating: isHeartAnimating,
                    icon: FontAwesomeIcons.solidStar,
                    iconColor:
                        AppUser.instance.likedRecipesIds.contains(recipe.id)
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
              ])),
            ),
            Container(
              decoration:
                  BoxDecoration(color:   Color(0xff380036),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(10)
                    )
                  ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          setState(() {
                            isHeartAnimating2 = true;
                            Provider.of<FavoritesNotifier>(context,
                                    listen: false)
                                .handleLikeEvent(recipe.id, recipe: recipe);
                          });
                        },
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            alignment: AlignmentDirectional.center,
                            child: AnimatedLikeScreen(
                              size: 28.h,
                              hasScaleFactor: false,
                              isAnimating: isHeartAnimating2,
                              icon: FontAwesomeIcons.solidStar,
                              iconColor: AppUser.instance.likedRecipesIds
                                      .contains(recipe.id)
                                  ? Colors.cyanAccent
                                  : color_palette["offWhite"],
                              bubblesColor: BubblesColor(
                                  dotPrimaryColor:
                                      color_palette["text_color_dark"],
                                  dotSecondaryColor:
                                      color_palette["text_color_dark"],
                                  dotThirdColor:
                                      color_palette["text_color_dark"],
                                  dotLastColor:
                                      color_palette["text_color_dark"]),
                              circleColor: CircleColor(
                                  start: color_palette["text_color_alt"],
                                  end: color_palette["text_color_alt"]),
                              onEnd: () =>
                                  setState(() => isHeartAnimating2 = false),
                            )),
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 24.h,
                    color: color_palette["white"],
                  ),
                  Expanded(
                    child: Container(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () async {
                          await Navigator.of(context)
                              .push(HeroDialogRoute(builder: (context) {
                            return MealPlannerPopup(
                              recipe: recipe,
                            );
                          }));
                        },
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            alignment: AlignmentDirectional.center,
                            child: Icon(AntDesign.calendar,
                                color: color_palette["white"], size: 24.h)),
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 24.h,
                    color: color_palette["white"],
                  ),
                  Expanded(
                    child: Container(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {},
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            alignment: AlignmentDirectional.center,
                            child: Icon(FontAwesomeIcons.comment,
                                color: color_palette["white"], size: 24.h)),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),


    );
  }
}
