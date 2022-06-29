import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_icons/flutter_icons.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:like_button/like_button.dart';
import 'package:mybmr/notifiers/FavoritesNotifier.dart';
import 'package:mybmr/notifiers/LookupUserNotifier.dart';
import 'package:mybmr/notifiers/RecipeNotifier.dart';
import 'package:mybmr/constants/messages/en_messages.dart';
import 'package:mybmr/models/AppUser.dart';
import 'package:mybmr/models/Recipe.dart';
import 'package:mybmr/services/AdService.dart';

import 'package:mybmr/services/hero_dialog_route.dart';
import 'package:mybmr/services/toast.dart';

import 'package:mybmr/widgets/AnimatedLikeScreen.dart';
import 'package:progress_indicators/progress_indicators.dart';

import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../constants/Themes.dart';
import '../services/helper.dart';
import '../widgets/BottomMenu.dart';
import 'ProfileViewer.dart';
import 'RecipeExpanded.dart';
import 'creationMenus/builders/RecipeBuilder.dart';
import 'creationMenus/popups/MealSharePopup.dart';
import 'creationMenus/popups/RecipeNutrition.dart';
import 'creationMenus/popups/ReportPopup.dart';

class RecipePageView extends StatefulWidget {
  final int mode;

  const RecipePageView({Key key, this.mode = 0}) : super(key: key);
  @override
  _RecipePageViewState createState() => _RecipePageViewState();
}

class _RecipePageViewState extends State<RecipePageView> {
  bool isHeartAnimating = false;
  bool isHeartAnimating2 = false;
  bool openBottomMenu = false;
  Recipe activeRecipe;

  List<Key> itemKeys = [];
  ScrollController _scrollController = ScrollController();
  List<Object> ads = [];
  DateTime lastRefreshAttempt = null;

  @override
  void initState() {
    super.initState();
    ads.add(null);
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
    ScreenUtil.init(
      context,
      designSize: Size(2400, 1080),
      minTextAdapt: true,
    );
    changeUiOverlayStyle(
      statusBarColor: color_palette["white"],
      systemNavigationBarColor: color_palette["background_color"],
      systemNavigationBarDividerColor: color_palette["background_color"],
    );

    Provider.of<RecipeNotifier>(context, listen: true);
    Provider.of<FavoritesNotifier>(context, listen: true);
    Provider.of<LookupUserNotifier>(context, listen: true);

    prepopulateAds();

    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: color_palette["white"],
        ),
        child: Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: [
          RefreshIndicator(
              backgroundColor: Colors.black38,
              color: Colors.white70,
              onRefresh: () async {
                handleRefreshAttempt();
                return true;
              },
              child: recipeFeed()),
          BottomMenu(
            isHidden: !openBottomMenu,
            backgroundColor: color_palette["background_color"],
            children: [
              Container(
                width: MediaQuery.of(context).size.width - 20,
                margin: EdgeInsets.symmetric(horizontal: 15),
                alignment: AlignmentDirectional.center,
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  "Options",
                  style:
                      TextStyle(color: color_palette["white"], fontSize: 32.h),
                ),
              ),
              Expanded(
                  child: Container(
                      child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if(AppUser.instance.isUserSignedIn() &&
                      activeRecipe != null
                      && widget.mode == 1
                      && activeRecipe.createdBy == AppUser.instance.uuid)
                    GestureDetector(
                    onTap: () async {
                      Map<String,dynamic> response =await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  RecipeBuilder(recipe: activeRecipe)));

                      setState(() {
                        openBottomMenu = false;
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      alignment: AlignmentDirectional.center,
                      padding: EdgeInsets.symmetric(vertical: 10),
                      margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                      decoration: BoxDecoration(
                          color: color_palette["alternative"],
                          borderRadius: BorderRadius.circular(8)),
                      child: Text("Edit Recipe",
                          style: TextStyle(
                              color: color_palette["white"], fontSize: 22.h)),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      Map<String, dynamic> response = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RecipeBuilder(
                                    recipe: activeRecipe,
                                    shouldClone: true,
                                  )));
                      setState(() {
                        openBottomMenu = false;
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      alignment: AlignmentDirectional.center,
                      padding: EdgeInsets.symmetric(vertical: 10),
                      margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                      decoration: BoxDecoration(
                          color: color_palette["alternative"],
                          borderRadius: BorderRadius.circular(8)),
                      child: Text("Build From",
                          style: TextStyle(
                              color: color_palette["white"], fontSize: 22.h)),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      showReportPopup(activeRecipe);

                      setState(() {
                        openBottomMenu = false;
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      alignment: AlignmentDirectional.center,
                      padding: EdgeInsets.symmetric(vertical: 10),
                      margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                      decoration: BoxDecoration(
                          color: color_palette["alternative"],
                          borderRadius: BorderRadius.circular(8)),
                      child: Text("Report",
                          style: TextStyle(
                              color: color_palette["white"], fontSize: 22.h)),
                    ),
                  ),
                ],
              ))),
            ],
            onClose: () {
              setState(() {
                openBottomMenu = false;
              });
            },
          )
        ]));
  }

  Widget recipeFeed() {
    if (getRecipeCount() > 0)
      return Stack(alignment: AlignmentDirectional.bottomCenter, children: [
        Stack(alignment: AlignmentDirectional.bottomCenter, children: [
          Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: color_palette["semi_transparent"],
              child: NotificationListener<OverscrollIndicatorNotification>(
                  onNotification: (overscroll) {
                    overscroll.disallowIndicator();
                    return;
                  },
                  child:
                      Stack(alignment: AlignmentDirectional.center, children: [
                    ListView.separated(
                      controller: _scrollController,
                      itemCount: getRecipeCount(),
                      itemBuilder: (BuildContext ctx, int index) {
                        Key key = Key(getCurrentRecipe(index).id);
                        itemKeys.add(key);
                        ScreenUtil.init(
                          ctx,
                          designSize: Size(2400, 1080),
                          minTextAdapt: true,
                        );
                        return VisibilityDetector(
                            key: key,
                            onVisibilityChanged: (VisibilityInfo info) {
                              notifyIfOutOfRecipes(index);
                              setCurrPage(index);
                              fetchMoreIfNecessary(index);
                            },
                            child: recipeCard(getCurrentRecipe(index), ctx));
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        if (shouldShowAd(index)) {
                          int idx = index ~/ getBatchSz();
                          if (ads[idx] != null) {
                            return ads[idx];
                          } else
                            return Container();
                        }
                        return Container();
                      },
                    ),
                    if (isHeartAnimating)
                      AnimatedLikeScreen(
                        size: 80.h,
                        isAnimating: isHeartAnimating,
                        icon: FontAwesomeIcons.solidStar,
                        iconColor: Colors.cyanAccent,
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
                  ]))),
        ]),
      ]);
    else
      return Center(
        child:
        isLoading() ? JumpingDotsProgressIndicator(fontSize: 28.h): Text("No Recipes Found", style: TextStyle(fontSize: 28.h),),
      );
  }

  Widget recipeCard(Recipe recipe, BuildContext ctx) {
    return Container(
      width: MediaQuery.of(ctx).size.width,
      child: Container(
        decoration: BoxDecoration(
            color: color_palette["white"],
            border: Border(bottom: BorderSide(color: Colors.grey[400]))),
        width: MediaQuery.of(context).size.width,
        constraints: BoxConstraints(
          minWidth: 200,
          minHeight: 200,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            headerBar(recipe),
            recipeImage(recipe),
            messageBody(recipe),
            optionsRow(recipe)
          ],
        ),
      ),
    );
  }

  void prepopulateAds() {
    int numAdsRequired = 0;
    if (widget.mode == 0)
      numAdsRequired =
          Provider.of<RecipeNotifier>(context, listen: false).recipes.length ~/
              Provider.of<RecipeNotifier>(context, listen: false).batchSize;
    else if (widget.mode == 1)
      numAdsRequired = Provider.of<FavoritesNotifier>(context, listen: false)
              .myCreations
              .length ~/
          Provider.of<FavoritesNotifier>(context, listen: false).bachSz;
    else if (widget.mode == 2)
      numAdsRequired = Provider.of<FavoritesNotifier>(context, listen: false)
              .favoriteRecipes
              .length ~/
          Provider.of<FavoritesNotifier>(context, listen: false).bachSz;
    else if (widget.mode == 3)
      numAdsRequired = Provider.of<LookupUserNotifier>(context, listen: false)
          .usersCreations
          .length ~/
          Provider.of<LookupUserNotifier>(context, listen: false).batchSz;
    else if (widget.mode == 4)
      numAdsRequired = Provider.of<LookupUserNotifier>(context, listen: false)
          .favoriteRecipes
          .length ~/
          Provider.of<LookupUserNotifier>(context, listen: false).batchSz;
    if (ads.length != numAdsRequired) {
      int missingAds = numAdsRequired - ads.length;
      for (int i = 0; i < missingAds; i++) {
        if (AdService.shouldShowAd(adProbability: 0.4)) {
          BannerAd ad =
              AdService.getBannerAD(MediaQuery.of(context).size.width.toInt())
                ..load();
          ads.add(buildAdWidget(
              ad: ad, padding: EdgeInsets.symmetric(vertical: 8)));
        } else {
          ads.add(null);
        }
      }
    }
  }

  void insertAd() {
    if (AdService.shouldShowAd(adProbability: 0.4)) {
      ads.add(Container(
        height: 200,
        padding: EdgeInsets.symmetric(vertical: 8),
        child: AdWidget(
            ad: AdService.getBannerAD(MediaQuery.of(context).size.width.toInt())
              ..load()),
        key: UniqueKey(),
      ));
    } else {
      ads.add(null);
    }
  }

  void notifyIfOutOfRecipes(index) {
    bool canFetchRecipes = false;
    int lastPageIndex = 0;
    if (widget.mode == 0)
      canFetchRecipes =
          Provider.of<RecipeNotifier>(context, listen: false).canFetchRecipes;
    lastPageIndex =
        Provider.of<RecipeNotifier>(context, listen: false).recipes.length - 1;
    if (widget.mode == 1)
      canFetchRecipes = Provider.of<FavoritesNotifier>(context, listen: false)
          .outOfMyCreations;
    lastPageIndex = Provider.of<FavoritesNotifier>(context, listen: false)
            .myCreations
            .length -
        1;

    if (widget.mode == 2)
      canFetchRecipes = Provider.of<FavoritesNotifier>(context, listen: false)
          .outOfFavoriteRecipes;
    lastPageIndex = Provider.of<FavoritesNotifier>(context, listen: false)
            .favoriteRecipes
            .length -
        1;
    if (widget.mode == 3)
      canFetchRecipes = Provider.of<LookupUserNotifier>(context, listen: false)
          .outOfMyCreations;
    lastPageIndex = Provider.of<LookupUserNotifier>(context, listen: false)
        .usersCreations
        .length -
        1;
    if (widget.mode == 4)
      canFetchRecipes = Provider.of<LookupUserNotifier>(context, listen: false)
          .outOfFavoriteRecipes;
    lastPageIndex = Provider.of<LookupUserNotifier>(context, listen: false)
        .favoriteRecipes
        .length -
        1;
    if (canFetchRecipes == false && index == lastPageIndex) {
      CustomToast(en_messages["out_of_recipes"]);
    }
  }

  void setCurrPage(index) {
    if (widget.mode == 0)
      Provider.of<RecipeNotifier>(context, listen: false).currPage = index;
    if (widget.mode == 1)
      Provider.of<FavoritesNotifier>(context, listen: false).myCurrPage = index;
    if (widget.mode == 2)
      Provider.of<FavoritesNotifier>(context, listen: false).favCurrPage =
          index;
    if(widget.mode == 3)
      Provider.of<LookupUserNotifier>(context, listen: false).creationsCurrPage =
          index;
    if(widget.mode == 4)
      Provider.of<LookupUserNotifier>(context, listen: false).favCurrPage =
          index;
  }

  void fetchMoreIfNecessary(int index) {
    if (widget.mode == 0) {
      RecipeNotifier recipeNotifier =
          Provider.of<RecipeNotifier>(context, listen: false);
      int fetchIdx =
          recipeNotifier.recipes.length - (recipeNotifier.batchSize ~/ 2);
      if (recipeNotifier.isFetching == false &&
          recipeNotifier.recipes.length % recipeNotifier.batchSize == 0 &&
          index == fetchIdx) {
        Provider.of<RecipeNotifier>(context, listen: false).fetchRecipes();
        insertAd();
      }
    }
    if (widget.mode == 1) {
      FavoritesNotifier recipeNotifier =
          Provider.of<FavoritesNotifier>(context, listen: false);
      int fetchIdx =
          recipeNotifier.myCreations.length - (recipeNotifier.bachSz ~/ 2);
      if (recipeNotifier.currentlyFetchingMyRecipes == false &&
          recipeNotifier.myCreations.length % recipeNotifier.bachSz == 0 &&
          index == fetchIdx) {
        Provider.of<FavoritesNotifier>(context, listen: false)
            .fetchRecipes(fetchFavorites: false);
        insertAd();
      }
    }
    if (widget.mode == 2) {
      FavoritesNotifier recipeNotifier =
          Provider.of<FavoritesNotifier>(context, listen: false);
      int fetchIdx =
          recipeNotifier.favoriteRecipes.length - (recipeNotifier.bachSz ~/ 2);
      if (recipeNotifier.currentlyFetchingFavorites == false &&
          recipeNotifier.favoriteRecipes.length % recipeNotifier.bachSz == 0 &&
          index == fetchIdx) {
        Provider.of<FavoritesNotifier>(context, listen: false).fetchRecipes();
        insertAd();
      }
    }


    if (widget.mode == 3) {
      LookupUserNotifier recipeNotifier =
      Provider.of<LookupUserNotifier>(context, listen: false);
      int fetchIdx =
          recipeNotifier.usersCreations.length - (recipeNotifier.batchSz ~/ 2);
      if (recipeNotifier.currentlyFetchingMyRecipes == false &&
          recipeNotifier.usersCreations.length % recipeNotifier.batchSz == 0 &&
          index == fetchIdx) {
        Provider.of<LookupUserNotifier>(context, listen: false).fetchRecipes(fetchFavorites: false);
        insertAd();
      }
    }

    if (widget.mode == 4) {
      LookupUserNotifier recipeNotifier =
      Provider.of<LookupUserNotifier>(context, listen: false);
      int fetchIdx =
          recipeNotifier.favoriteRecipes.length - (recipeNotifier.batchSz ~/ 2);
      if (recipeNotifier.currentlyFetchingFavorites == false &&
          recipeNotifier.favoriteRecipes.length % recipeNotifier.batchSz == 0 &&
          index == fetchIdx) {
        Provider.of<LookupUserNotifier>(context, listen: false).fetchRecipes(fetchFavorites: true);
        insertAd();
      }
    }
  }

  void handleRefreshAttempt() {
    if (lastRefreshAttempt == null ||
        lastRefreshAttempt
            .isBefore(DateTime.now().subtract(Duration(minutes: 3)))) {
      if (widget.mode == 0)
        Provider.of<RecipeNotifier>(context, listen: false).shouldRefresh();
      if (widget.mode == 1)
        Provider.of<FavoritesNotifier>(context, listen: false)
            .shouldRefresh(isMyRecipes: true);
      if (widget.mode == 2)
        Provider.of<FavoritesNotifier>(context, listen: false)
            .shouldRefresh(isMyRecipes: false);
      if (widget.mode == 3)
        Provider.of<LookupUserNotifier>(context, listen: false)
            .shouldRefresh(isMyRecipes: true);
      if (widget.mode == 4)
        Provider.of<LookupUserNotifier>(context, listen: false)
            .shouldRefresh(isMyRecipes: false);
    }
  }

  int getRecipeCount() {
    int count = 0;
    if (widget.mode == 0)
      count =
          Provider.of<RecipeNotifier>(context, listen: false).recipes.length;
    if (widget.mode == 1)
      count = Provider.of<FavoritesNotifier>(context, listen: false)
          .myCreations
          .length;
    if (widget.mode == 2)
      count = Provider.of<FavoritesNotifier>(context, listen: false)
          .favoriteRecipes
          .length;
    if (widget.mode == 3)
      count = Provider.of<LookupUserNotifier>(context, listen: false)
          .usersCreations
          .length;
    if (widget.mode == 4)
      count = Provider.of<LookupUserNotifier>(context, listen: false)
          .favoriteRecipes
          .length;
    return count;
  }

  Recipe getCurrentRecipe(index) {
    Recipe recipe = null;
    if (widget.mode == 0)
      recipe =
          Provider.of<RecipeNotifier>(context, listen: false).recipes[index];
    if (widget.mode == 1)
      recipe = Provider.of<FavoritesNotifier>(context, listen: false)
          .myCreations[index];
    if (widget.mode == 2)
      recipe = Provider.of<FavoritesNotifier>(context, listen: false)
          .favoriteRecipes[index];
    if (widget.mode == 3)
      recipe = Provider.of<LookupUserNotifier>(context, listen: false)
          .usersCreations[index];
    if (widget.mode == 4)
      recipe = Provider.of<LookupUserNotifier>(context, listen: false)
          .favoriteRecipes[index];
    return recipe;
  }

  int getBatchSz() {
    int sz = 0;
    if (widget.mode == 0)
      sz = Provider.of<RecipeNotifier>(context, listen: false).batchSize;
    else if(widget.mode == 1 || widget.mode == 2)
      sz = Provider.of<FavoritesNotifier>(context, listen: false).bachSz;
    else if(widget.mode == 3 || widget.mode == 4)
      sz = Provider.of<LookupUserNotifier>(context, listen: false).batchSz;
    return sz;
  }

  bool shouldShowAd(index) {
    return index % getBatchSz() == 0 && index != 0;
  }

  AppUser getAppUser(String creatorsId) {
    if (widget.mode == 0)
      return Provider.of<RecipeNotifier>(context, listen: false)
          .posters[creatorsId];
    else if(widget.mode == 1)
      return AppUser.instance;
    else if(widget.mode == 2)
      return Provider.of<FavoritesNotifier>(context, listen: false)
          .posters[creatorsId];
    else if(widget.mode == 3)
      return Provider.of<LookupUserNotifier>(context, listen: false)
         .lookupUser;
    else if(widget.mode == 4)
      return Provider.of<LookupUserNotifier>(context, listen: false)
          .posters[creatorsId];
    else return null;
  }

  bool isLoading(){

    if(widget.mode == 0)
      return Provider.of<RecipeNotifier>(context, listen: false).isFetching;
    if(widget.mode == 1)
      return Provider.of<FavoritesNotifier>(context, listen: false).currentlyFetchingMyRecipes;
    if(widget.mode == 2)
      return Provider.of<FavoritesNotifier>(context, listen: false).currentlyFetchingFavorites;
    if(widget.mode == 3)
      return Provider.of<LookupUserNotifier>(context, listen: false).currentlyFetchingMyRecipes;
    if(widget.mode == 4)
      return Provider.of<LookupUserNotifier>(context, listen: false).currentlyFetchingFavorites;
    return false;
  }
  Widget headerBar(Recipe recipe) {
    return Container(
        padding: EdgeInsets.fromLTRB(10, 5, 10, 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                if(widget.mode == 0 )
                  Provider.of<LookupUserNotifier>(context,listen: false).lookupUser =  Provider.of<RecipeNotifier>(context, listen: false)
                .posters[recipe.createdBy];
                else if( widget.mode == 1)
                  Provider.of<LookupUserNotifier>(context,listen: false).lookupUser = AppUser.instance;

                else if( widget.mode == 2)
                  Provider.of<LookupUserNotifier>(context,listen: false).lookupUser =  Provider.of<FavoritesNotifier>(context, listen: false).
                  posters[recipe.createdBy];


                Provider.of<LookupUserNotifier>(context,listen: false).shouldRefresh(isMyRecipes: true);
                Provider.of<LookupUserNotifier>(context,listen: false).shouldRefresh(isMyRecipes: false);

                if(widget.mode ==0 || widget.mode == 1 || widget.mode == 2)
                Navigator.push(
                context,
                MaterialPageRoute(
                builder: (context) => ProfileViewer(
                appUser:   Provider.of<LookupUserNotifier>(context,listen: false).lookupUser
                )));

              },
              child: Container(
                color: Colors.transparent,
                  child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      child: (
                  getAppUser(recipe.createdBy) == null ||
                      ( getAppUser(recipe.createdBy).profileImagePath ==
                                  null ||
                              getAppUser(recipe.createdBy).profileImagePath ==
                                  ""))
                          ? Icon(
                              FontAwesomeIcons.userAstronaut,
                              color: Color(0XFF6D6D64),
                              size: 30.h,
                            )
                          : buildImage(
                              getAppUser(recipe.createdBy).profileImagePath,
                              height: 60.h,
                              width: 60.h,
                              wrapperWidth: 60.h,
                              radius: BorderRadius.circular(60.h),
                            )),
                  if(getAppUser(recipe.createdBy) != null) Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    width: MediaQuery.of(context).size.width - 125,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            child: Text(
                          getAppUser(recipe.createdBy).userName,
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.black, fontSize: 30.h),
                        )),
                        Text(
                          getAppUser(recipe.createdBy).aboutUser,
                          style: TextStyle(
                              color: Color(0XFF6D6D64), fontSize: 16.h),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                  setState(() {
                    activeRecipe = recipe;
                    openBottomMenu = true;
                  });
                },
                child: Container(
                  width: 30,
                  child: Icon(
                    MaterialIcons.more_vert,
                    color: Color(0XFF6D6D64),
                  ),
                )),
          ],
        ));
  }

  Future<void> showReportPopup(Recipe recipe) async {
    await Navigator.of(context).push(HeroDialogRoute(
        statusBarColor:
            Color.alphaBlend(Color(0x33FFFFFF), color_palette["white"]),
        bgColor: Colors.transparent,
        builder: (context) {
          return ReportPopup(
            recipe: recipe,
          );
        }));
  }

  Widget recipeImage(Recipe recipe) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => RecipeExpanded(recipe: recipe)));

        Future.delayed(Duration(milliseconds: 150), () {
          SystemChrome.setSystemUIOverlayStyle(
              SystemUiOverlayStyle(statusBarColor: color_palette["white"]));
        });
      },
      child: buildImage(recipe.recipeImageFromDB),
    );
  }

  Widget optionsRow(Recipe recipe) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: actionWidget(
              onTap: () {
                setState(() {
                  isHeartAnimating2 = true;
                  if (AppUser.instance.isUserSignedIn())
                    Provider.of<FavoritesNotifier>(context, listen: false)
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
                    iconColor: AppUser.instance.likedRecipes.contains(recipe.id)
                        ? Colors.cyanAccent
                        : Colors.grey[400],
                    bubblesColor: BubblesColor(
                        dotPrimaryColor: color_palette["text_color_dark"],
                        dotSecondaryColor: color_palette["text_color_dark"],
                        dotThirdColor: color_palette["text_color_dark"],
                        dotLastColor: color_palette["text_color_dark"]),
                    circleColor: CircleColor(
                        start: color_palette["text_color_alt"],
                        end: color_palette["text_color_alt"]),
                    onEnd: () => setState(() => isHeartAnimating2 = false),
                  )),
            ),
          ),
          Container(
            width: 1,
            height: 24.h,
            color: Colors.grey[400],
          ),
          Expanded(
            child: actionWidget(
              ctx: context,
              onTap: () async {
                await Navigator.of(context).push(HeroDialogRoute(
                    bgColor: Color(0x33FFFFFF),
                    builder: (context) {
                      return MealSharePopup(
                        recipe: recipe,
                      );
                    }));
              },
              child: Container(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  alignment: AlignmentDirectional.center,
                  child: Icon(AntDesign.calendar,
                      color: Colors.grey[400], size: 24.h)),
            ),
          ),
          Container(
            width: 1,
            height: 24.h,
            color: Colors.grey[400],
          ),
          Expanded(
            child: actionWidget(
              ctx: context,
              onTap: () async {
                await Navigator.of(context).push(HeroDialogRoute(
                    statusBarColor: Color.alphaBlend(
                        Color(0x33FFFFFF), color_palette["white"]),
                    bgColor: Colors.transparent,
                    builder: (context) {
                      return RecipeNutrition(
                        recipe: recipe,
                      );
                    }));
              },
              child: Container(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  alignment: AlignmentDirectional.center,
                  child: Icon(FontAwesomeIcons.fire,
                      color: Colors.grey[400], size: 24.h)),
            ),
          ),
        ],
      ),
    );
  }

  Widget messageBody(Recipe recipe) {
    List<String> tags = recipe.mealTimes + recipe.neededDiets;
    return Container(
      width: MediaQuery.of(context).size.width - 20,
      padding: EdgeInsets.fromLTRB(10, 10, 15, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            recipe.title,
            maxLines: 1,
            style: TextStyle(color: Color(0xFF0e1111), fontSize: 30.h),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            child: RichText(
              text: TextSpan(children: [
                TextSpan(
                  text: recipe.description,
                  style: TextStyle(color: Color(0xFF0e1111), fontSize: 22.h),
                ),
                TextSpan(
                  text: " #" + tags.join(" #"),
                  style: TextStyle(color: Color(0XFF6D6D64), fontSize: 16.h),
                )
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
