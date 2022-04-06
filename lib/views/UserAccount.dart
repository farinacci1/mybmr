import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mybmr/notifiers/FavoritesNotifier.dart';
import 'package:mybmr/constants/messages/en_messages.dart';
import 'package:mybmr/models/AppUser.dart';
import 'package:mybmr/models/Recipe.dart';
import 'package:mybmr/services/hero_dialog_route.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../constants/Themes.dart';
import 'creationMenus/popups/FavoritePopup.dart';
import 'creationMenus/popups/UserSettings.dart';

class UserAccount extends StatefulWidget {
  @override
  _UserAccountState createState() => _UserAccountState();
}

class _UserAccountState extends State<UserAccount> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final RefreshController _refreshController2 =
      RefreshController(initialRefresh: false);
  @override
  void dispose() {
    if (_refreshController != null) _refreshController.dispose();
    if (_refreshController2 != null) _refreshController2.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    FavoritesNotifier favoritesNotifier =
        Provider.of<FavoritesNotifier>(context, listen: true);
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
    return Container(
        width: pageWidth,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: color_palette["text_color_dark"],
          gradient: color_palette["gradient"],
          boxShadow: [
            BoxShadow(
              color: color_palette["overlay"],
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Stack(alignment: AlignmentDirectional.topEnd, children: [
          Column(children: [
            Expanded(
                flex: 4,
                child: Container(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AutoSizeText(
                          "${en_messages["welcome"]}\n${AppUser.instance.userName}",
                          style: TextStyle(
                              color: color_palette["white"], fontSize: 32.h),
                          textAlign: TextAlign.center,
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
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(
                                                  width: 2,
                                                  color: color_palette[
                                                      "white"]))),
                                      child: TabBar(
                                          labelColor: color_palette["text_color_dark"],
                                          unselectedLabelColor:
                                              color_palette["white"],
                                          indicatorSize:
                                              TabBarIndicatorSize.label,
                                          indicator: BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(10),
                                                  topRight:
                                                      Radius.circular(10)),
                                              color: color_palette[
                                                  "white"]),
                                          tabs: [
                                            Tab(
                                              child: Align(
                                                alignment: Alignment.center,
                                                child: AutoSizeText(
                                                  "${en_messages["my_recipes"]}\n ${AppUser.instance.myCreationIds.length}",
                                                  maxLines: 2,
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                            Tab(
                                              child: Align(
                                                alignment: Alignment.center,
                                                child: AutoSizeText(
                                                    "${en_messages["my_favorites"]}\n ${AppUser.instance.likedRecipesIds.length}",
                                                    maxLines: 2,
                                                    textAlign:
                                                        TextAlign.center),
                                              ),
                                            ),
                                          ])),
                                  Expanded(
                                      child: TabBarView(children: [
                                    Container(

                                      decoration: BoxDecoration(
                                          color: color_palette["tone"],

                                      ),
                                      padding: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: margin / 2),
                                      child: favoritesNotifier
                                                  .myCreations.length >
                                              0
                                          ? SmartRefresher(
                                              enablePullDown: false,
                                              enablePullUp: true,
                                              onLoading: () {
                                                return _onLoading(context,
                                                    isFavorite: false);
                                              },
                                              footer: const ClassicFooter(
                                                  loadStyle: LoadStyle
                                                      .ShowWhenLoading),
                                              controller: _refreshController,
                                              child: GridView.count(
                                                  shrinkWrap: true,
                                                  crossAxisCount:
                                                      maxObjectsPerRow,
                                                  childAspectRatio: 1.3,
                                                  crossAxisSpacing:
                                                      horizontalSpacer,
                                                  mainAxisSpacing: 10,
                                                  children: favoritesNotifier
                                                      .myCreations
                                                      .map((Recipe recipe) {
                                                    return GestureDetector(
                                                        onTap: () async {
                                                          await Navigator.of(
                                                                  context)
                                                              .push(HeroDialogRoute(
                                                                  builder:
                                                                      (context) {
                                                            return FavoritePopup(
                                                              recipe: recipe,
                                                              isOwnedByUser:
                                                                  true,
                                                              isDeletable:
                                                                  false,
                                                            );
                                                          }));
                                                        },
                                                        child:
                                                            drawRecipe(recipe));
                                                  }).toList()))
                                          : Center(
                                              child: favoritesNotifier
                                                      .currentlyFetchingMyRecipes
                                                  ? JumpingDotsProgressIndicator(
                                                      color: color_palette[
                                                          "white"],
                                                      fontSize: 20,
                                                    )
                                                  : AutoSizeText(
                                                      en_messages[
                                                          "creations_is_empty"],
                                                      textAlign:
                                                          TextAlign.center,
                                                      maxLines: 5,
                                                      style: TextStyle(
                                                        fontSize: 23.h,
                                                        color: color_palette[
                                                            "white"],
                                                      ),
                                                    )),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          color: color_palette["tone"],
                                          //gradient: color_palette["gradient_inverse"]
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: margin / 2),
                                      child: favoritesNotifier
                                                  .favoriteRecipes.length >
                                              0
                                          ? SmartRefresher(
                                              enablePullDown: false,
                                              enablePullUp: true,
                                              onLoading: () {
                                                return _onLoading(context,
                                                    isFavorite: true);
                                              },
                                              footer: const ClassicFooter(
                                                  loadStyle: LoadStyle
                                                      .ShowWhenLoading),
                                              controller: _refreshController2,
                                              child: GridView.count(
                                                  shrinkWrap: true,
                                                  crossAxisCount:
                                                      maxObjectsPerRow,
                                                  childAspectRatio: 1.3,
                                                  crossAxisSpacing:
                                                      horizontalSpacer,
                                                  mainAxisSpacing: 10,
                                                  children: favoritesNotifier
                                                      .favoriteRecipes
                                                      .map((Recipe recipe) {
                                                    return GestureDetector(
                                                        onTap: () async {
                                                          await Navigator.of(
                                                                  context)
                                                              .push(HeroDialogRoute(
                                                                  builder:
                                                                      (context) {
                                                            return FavoritePopup(
                                                              recipe: recipe,
                                                              isOwnedByUser:
                                                                  false,
                                                              isDeletable: true,
                                                            );
                                                          }));
                                                        },
                                                        child:
                                                            drawRecipe(recipe));
                                                  }).toList()))
                                          : Center(
                                              child: favoritesNotifier
                                                      .currentlyFetchingFavorites
                                                  ? JumpingDotsProgressIndicator(
                                                      color: color_palette[
                                                          "white"],
                                                      fontSize: 20,
                                                    )
                                                  : AutoSizeText(
                                                      en_messages[
                                                          "favorites_is_empty"],
                                                      maxLines: 5,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 23.h,
                                                        color: color_palette[
                                                            "white"],
                                                      ),
                                                    )),
                                    ),
                                  ])),
                                ]))))),
          ]),
          Container(
              margin: EdgeInsets.only(right: 0),
              child: GestureDetector(
                  onTap: () async {
                    await Navigator.of(context)
                        .push(HeroDialogRoute(builder: (context) {
                      return SettingsPopup();
                    }));
                  },
                  child: Container(
                    padding: EdgeInsets.fromLTRB(
                        0,
                        MediaQuery.of(context).padding.top + 20,
                        MediaQuery.of(context).padding.right + 20,
                        0),
                    child: Icon(
                      FontAwesomeIcons.cogs,
                      size: 26.5.h,
                      color: color_palette["white"],
                    ),
                  )))
        ]));
  }
  void _onLoading(
      BuildContext context, {
        bool isFavorite = false,
      }) async {
    if (!isFavorite) {
      Provider.of<FavoritesNotifier>(context, listen: false).fetchRecipes(
          offset: Provider.of<FavoritesNotifier>(context, listen: false)
              .myCreations
              .length,
          fetchFavorites: isFavorite);
    } else {
      Provider.of<FavoritesNotifier>(context, listen: false).fetchRecipes(
          offset: Provider.of<FavoritesNotifier>(context, listen: false)
              .favoriteRecipes
              .length,
          fetchFavorites: isFavorite);
    }

    if (!isFavorite) _refreshController.loadComplete();
    if (isFavorite) _refreshController2.loadComplete();
  }

  Widget drawRecipe(Recipe recipe, {isMyCreation = false}) {
    return Container(
      alignment: AlignmentDirectional.bottomStart,
      decoration: BoxDecoration(
        color: color_palette["white"],
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: NetworkImage(recipe.recipeImageFromDB),
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
        ),
      ),
      child: Container(
        height: 30,
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 4),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
            color: Color.fromRGBO(255, 255, 255, 0.8)),
        child: Text(
          recipe.title.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.clip,
          style: TextStyle(fontSize: 16, color: Colors.black38),
        ),
      ),
    );
  }
}
