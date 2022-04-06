import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mybmr/constants/messages/en_messages.dart';
import 'package:mybmr/models/Recipe.dart';
import 'package:mybmr/services/Firebase_db.dart';
import 'package:mybmr/services/hero_dialog_route.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../constants/Themes.dart';
import '../services/AdService.dart';
import 'creationMenus/popups/FavoritePopup.dart';

class ProfileViewer extends StatefulWidget {
  final String userId;

  const ProfileViewer({Key key, this.userId}) : super(key: key);
  @override
  _ProfileViewerState createState() => _ProfileViewerState();
}

class _ProfileViewerState extends State<ProfileViewer> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final RefreshController _refreshController2 =
      RefreshController(initialRefresh: false);

  String userName = "";
  List<String> theirCreations = [];
  List<String> theirFavorites = [];
  List<Recipe> createdRecipes = [];
  List<Recipe> favoriteRecipes = [];
  bool currentlyFetchingFavorites = false;
  bool currentlyFetchingMyRecipes = false;
  bool hasInit = false;

  @override
  void initState() {
    lookUpUser();
    super.initState();
  }

  @override
  void dispose() {
    if(_refreshController!=null)_refreshController.dispose();
    if(_refreshController2!=null)_refreshController2.dispose();
    super.dispose();
  }

  void lookUpUser() {
    FirebaseDB.fetchUserById(widget.userId)
        .then((DocumentSnapshot documentSnapshot) {
      Map<String, dynamic> data = documentSnapshot.data();
      userName = data["userName"];
      theirCreations = List.from(data["myCreationIds"]);
      theirFavorites = List.from(data["likedRecipesIds"]);
      theirCreations = theirCreations.toSet().toList();
      theirFavorites = theirFavorites.toSet().toList();
      hasInit = true;
      fetchRecipes(fetchFavorites: true);
      fetchRecipes(fetchFavorites: false);
    });
  }

  void fetchRecipes(
      {int offset = 0, int limit = 6, bool fetchFavorites = true}) {
    List<String> subsetRecipes = [];
    int fetchCount = 0;
    if (fetchFavorites) {
      fetchCount = max(min(theirFavorites.length - offset, limit), 0);
      if (fetchCount > 0) {
        currentlyFetchingFavorites = true;
        subsetRecipes = theirFavorites.sublist(offset, offset + fetchCount);
      }
    } else {
      fetchCount = max(min(theirCreations.length - offset, limit), 0);
      if (fetchCount > 0) {
        currentlyFetchingMyRecipes = true;
        subsetRecipes = theirCreations.sublist(offset, offset + fetchCount);
      }
    }
    if (subsetRecipes.length > 0) {
      Future.forEach<String>(subsetRecipes, (String recipeId) async {
        DocumentSnapshot documentSnapshot =
            await FirebaseDB.fetchRecipeById(recipeId);
        if (documentSnapshot.exists) {
          Recipe fetchedRecipe = Recipe.fromJson(
              recipeRecords: documentSnapshot.data(),
              recipeId: documentSnapshot.id);
          if (fetchFavorites) {
            Recipe containedRecipe = favoriteRecipes.firstWhere(
                (element) => element.id == fetchedRecipe.id,
                orElse: () => null);
            if (containedRecipe == null) favoriteRecipes.add(fetchedRecipe);
          } else {
            Recipe containedRecipe = createdRecipes.firstWhere(
                (element) => element.id == fetchedRecipe.id,
                orElse: () => null);
            if (containedRecipe == null) createdRecipes.add(fetchedRecipe);
          }
        }
      }).whenComplete(() {
        if (fetchFavorites)
          currentlyFetchingFavorites = false;
        else
          currentlyFetchingMyRecipes = false;
        setState(() {});
      });
    }
  }

  void _onLoading(
    BuildContext context, {
    bool isFavorite = false,
  }) async {
    if (AdService.shouldShowAd(adProbability: 0.08)) {
      AdService.showInterstitialAd(() {
        if (!isFavorite) {
          fetchRecipes(
              offset: createdRecipes.length, fetchFavorites: isFavorite);
        } else {
          fetchRecipes(
              offset: favoriteRecipes.length, fetchFavorites: isFavorite);
        }

        if (!isFavorite) _refreshController.loadComplete();
        if (isFavorite) _refreshController2.loadComplete();
      });
    } else {
      if (!isFavorite) {
        fetchRecipes(offset: createdRecipes.length, fetchFavorites: isFavorite);
      } else {
        fetchRecipes(
            offset: favoriteRecipes.length, fetchFavorites: isFavorite);
      }

      if (!isFavorite) _refreshController.loadComplete();
      if (isFavorite) _refreshController2.loadComplete();
    }
  }

  Widget drawRecipe(Recipe recipe) {

    return Container(

      alignment: AlignmentDirectional.bottomStart,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.9.h),
        image: DecorationImage(
          image: NetworkImage(recipe.recipeImageFromDB),
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
        ),
      ),
      child: Container(
        height: 39.75.h,
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 6.625.h, vertical: 5.3.h),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(15.9.h)),
            color: Color.fromRGBO(255, 255, 255, 0.8)),
        child: Text(
          recipe.title.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.clip,
          style: TextStyle(fontSize: 21.2.h, color: Colors.black38),
        ),
      ),
    );
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

    double pageWidth = MediaQuery.of(context).size.width;
    double cellWidth = pageWidth / 2;
    int maxObjectsPerRow = cellWidth > 300  ? 3 : 2;
    double margin = 20;
    double horizontalSpacer = max(
        pageWidth - ((cellWidth * maxObjectsPerRow) + margin),
        10.0);
    return Scaffold(
        body: Container(
            width: pageWidth,

            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: color_palette["text_color_dark"],
              gradient: color_palette["gradient"],),
            child: Stack(children: [
              (hasInit == true)
                  ? Column(
                      children: [
                        Expanded(
                            flex: 4,
                            child: Container(
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(children: [
                                        TextSpan(
                                          text:
                                              "${en_messages["viewing_label"]}\n",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 23.85.h),
                                        ),
                                        TextSpan(
                                          text: "${userName}",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 23.85.h),
                                        ),
                                      ]),
                                    ),
                                  ]),
                            )),
                        Expanded(
                            flex: 6,
                            child: Container(
                                alignment: AlignmentDirectional.center,
                                child: Container(
                                    child: DefaultTabController(
                                        length: 2,
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                  decoration: BoxDecoration(
                                                      border: Border(
                                                          bottom: BorderSide(
                                                              width: 2,
                                                              color: color_palette[
                                                                  "white"]))),
                                                  child: TabBar(
                                                      labelColor:color_palette["text_color_dark"],
                                                      labelStyle: TextStyle(fontSize: 18.h),
                                                      unselectedLabelColor:
                                                          color_palette[
                                                              "white"],
                                                      indicatorSize:
                                                          TabBarIndicatorSize
                                                              .label,
                                                      indicator: BoxDecoration(
                                                          borderRadius: BorderRadius.only(
                                                              topLeft: Radius.circular(
                                                                  10),
                                                              topRight:
                                                                  Radius.circular(
                                                                      10)),
                                                          color: color_palette[
                                                              "white"]),
                                                      tabs: [
                                                        Tab(
                                                          child: Align(
                                                            alignment: Alignment
                                                                .center,
                                                            child: AutoSizeText(
                                                              "${en_messages["creations_label"]}\n ${theirCreations.length}",
                                                              maxLines: 2,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ),
                                                        ),
                                                        Tab(
                                                          child: Align(
                                                            alignment: Alignment
                                                                .center,
                                                            child: AutoSizeText(
                                                                "${en_messages["favorites_label"]}\n ${theirFavorites.length}",
                                                                maxLines: 2,

                                                                textAlign:
                                                                    TextAlign
                                                                        .center),
                                                          ),
                                                        ),
                                                      ])),
                                              Expanded(
                                                  child: TabBarView(children: [
                                                Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 13.125.h,
                                                            horizontal: margin /
                                                                2.65.h),
                                                    child: SmartRefresher(
                                                        enablePullDown: false,
                                                        enablePullUp: true,
                                                        onLoading: () {
                                                          return _onLoading(
                                                              context,
                                                              isFavorite:
                                                                  false);
                                                        },
                                                        footer: const ClassicFooter(
                                                            loadStyle: LoadStyle
                                                                .ShowWhenLoading),
                                                        controller:
                                                            _refreshController,
                                                        child: GridView.count(
                                                            shrinkWrap: true,
                                                            crossAxisCount:
                                                                maxObjectsPerRow,
                                                            childAspectRatio: 1.3,
                                                            crossAxisSpacing:
                                                                horizontalSpacer,
                                                            mainAxisSpacing: 13.125.h,
                                                            children:
                                                                createdRecipes
                                                                    .map((Recipe
                                                                        recipe) {
                                                              return GestureDetector(
                                                                  onTap:
                                                                      () async {
                                                                    await Navigator.of(
                                                                            context)
                                                                        .push(HeroDialogRoute(builder:
                                                                            (context) {
                                                                      return FavoritePopup(
                                                                        recipe:
                                                                            recipe,
                                                                        isOwnedByUser:
                                                                            false,
                                                                        isDeletable:
                                                                            false,
                                                                      );
                                                                    }));
                                                                  },
                                                                  child: drawRecipe(
                                                                      recipe));
                                                            }).toList()))),
                                                Container(
                                                    color: Colors.transparent,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 13.125.h,
                                                            horizontal:
                                                                margin / 2.65.h),
                                                    child:favoriteRecipes.length != 0 ?SmartRefresher(
                                                        enablePullDown: false,
                                                        enablePullUp: true,
                                                        onLoading: () {
                                                          return _onLoading(
                                                              context,
                                                              isFavorite: true);
                                                        },
                                                        footer: const ClassicFooter(
                                                            loadStyle: LoadStyle
                                                                .ShowWhenLoading),
                                                        controller:
                                                            _refreshController2,
                                                        child: GridView.count(
                                                            shrinkWrap: true,
                                                            crossAxisCount:
                                                                maxObjectsPerRow,
                                                            childAspectRatio:
                                                                1.3,
                                                            crossAxisSpacing:
                                                                horizontalSpacer,
                                                            mainAxisSpacing: 13.125.h,
                                                            children:
                                                                favoriteRecipes
                                                                    .map((Recipe
                                                                        recipe) {
                                                              return GestureDetector(
                                                                  onTap:
                                                                      () async {
                                                                    await Navigator.of(
                                                                            context)
                                                                        .push(HeroDialogRoute(builder:
                                                                            (context) {
                                                                      return FavoritePopup(
                                                                        recipe:
                                                                            recipe,
                                                                        isOwnedByUser:
                                                                            false,
                                                                        isDeletable:
                                                                            false,
                                                                      );
                                                                    }));
                                                                  },
                                                                  child: drawRecipe(
                                                                      recipe));
                                                            }).toList())) : Center(
                                                      child: Text("😢 My Favorites is Empty",style: TextStyle(
                                                        color: color_palette[
                                                        "white"],
                                                        fontSize: 24.h
                                                      ),),
                                                    )
                                              ),
                                              ])),
                                            ])))))
                      ],
                    )
                  : Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
              GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                      width: 66.25.h,
                      height: 66.25.h,
                      margin: EdgeInsets.fromLTRB(
                          10,
                          MediaQuery.of(context).padding.top > 0
                              ? MediaQuery.of(context).padding.top
                              : 13.125.h,
                          0,
                          0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(33.125.h)),
                          gradient: color_palette["gradient"]
                      ),
                      alignment: AlignmentDirectional.center,
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      )))
            ])));
  }
}
