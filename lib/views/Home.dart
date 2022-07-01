import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mybmr/notifiers/FavoritesNotifier.dart';
import 'package:mybmr/notifiers/MealPlanNotifier.dart';
import 'package:mybmr/notifiers/RecipeNotifier.dart';
import 'package:mybmr/notifiers/UserListNotifier.dart';
import 'package:mybmr/notifiers/UserNotifier.dart';
import 'package:mybmr/models/AppUser.dart';
import 'package:mybmr/views/Login.dart';
import 'package:mybmr/views/MealPlannerDisplay.dart';
import 'package:mybmr/views/RecipePageView.dart';
import 'package:mybmr/views/UserLists.dart';
import 'package:mybmr/views/creationMenus/builders/RecipeBuilder.dart';

import 'package:provider/provider.dart';

import '../constants/Themes.dart';
import '../widgets/Flashy_tab_bar.dart';
import 'UserAccount.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  int activeView = 0;


  Widget getPage(BuildContext context) {
    switch (activeView) {
      case 0:
        return RecipePageView();

      case 1:
        MealPlanNotifier mealPlanNotifier =
            Provider.of<MealPlanNotifier>(context, listen: false);

        if (AppUser.instance.isUserSignedIn()) {
          if (mealPlanNotifier.mealPlans.length == 0 &&
              mealPlanNotifier.isFetching == false)
            mealPlanNotifier.getMealPlansFromDB();
        }

        return MealPlannerDisplay();
      case 2:
        return RecipeBuilder();
      case 3:
        if (AppUser.instance.isUserSignedIn()) {
          if (Provider.of<UserListNotifier>(context, listen: false)
                      .isCurrentlyFetching ==
                  false &&
              Provider.of<UserListNotifier>(context, listen: false)
                      .groceryList ==
                  null &&
              Provider.of<UserListNotifier>(context, listen: false).taskList ==
                  null)
            Provider.of<UserListNotifier>(context, listen: false)
                .fetchUserList();
        }
        return UserList();
      case 4:
        if (!AppUser.instance.isUserSignedIn()) {
          return LoginScreen();
        } else {
          Provider.of<RecipeNotifier>(context, listen: false)
              .recipes
              .forEach((rec) {
            if (rec.likedBy.contains(AppUser.instance.uuid))
              AppUser.instance.addLikeRecipe(rec.id);
          });

          FavoritesNotifier favoritesNotifier =
              Provider.of<FavoritesNotifier>(context, listen: false);
          if (!favoritesNotifier.currentlyFetchingMyRecipes &&
              favoritesNotifier.myCreations.length == 0) {
            favoritesNotifier.fetchRecipes(fetchFavorites: false);
          }
          if (!favoritesNotifier.currentlyFetchingFavorites &&
              favoritesNotifier.favoriteRecipes.length == 0) {
            favoritesNotifier.fetchRecipes(fetchFavorites: true);
          }

          return UserAccount();
        }
        return Container();

      default:
        return Container();
    }
  }

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: color_palette["background_color"],
        systemNavigationBarColor: color_palette["background_color"],
        systemNavigationBarDividerColor: color_palette["background_color"]));
    RecipeNotifier recipeNotifier =
        Provider.of<RecipeNotifier>(context, listen: false);
    if (recipeNotifier.recipes.length == 0)
      Provider.of<RecipeNotifier>(context, listen: false).fetchRecipes();
    DateTime nowDate = DateTime.now();
    DateTime startDate = DateTime(nowDate.year, nowDate.month, nowDate.day);
    Provider.of<MealPlanNotifier>(context, listen: false)
        .setStartOfDay(startDate, shouldNotify: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<UserNotifier>(context, listen: true);
    Provider.of<RecipeNotifier>(context, listen: true);

    ScreenUtil.init(
      context,
      designSize: Size(2400, 1080),
      minTextAdapt: true,
    );
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: this.activeView == 0
            ? color_palette["white"]
            : color_palette["background_color"],
        elevation: 0.0,
        actionsIconTheme: IconThemeData(opacity: 0.0),
        systemOverlayStyle:
            SystemUiOverlayStyle(statusBarColor: Colors.transparent),
        flexibleSpace: FlexibleSpaceBar(
          stretchModes: [StretchMode.fadeTitle],
        ),
      ),
      bottomNavigationBar: FlashyTabBar(
        animationCurve: Curves.linear,
        selectedIndex: activeView,
        iconSize: 30.h,
        height: min(max(80.h, 55), 100),
        showElevation: true,
        backgroundColor: color_palette["background_color"],
        onItemSelected: (index)  async {
          if (index != 2) {
            setState(() {
              this.activeView = index;
            });

          } else if (this.activeView != 4 ||
              AppUser.instance.isUserSignedIn()) {
             await showModalBottomSheet(
                context: context,
                elevation: 6.0,
                backgroundColor: Colors.transparent,
                barrierColor: Colors.transparent,
                 isScrollControlled: true,
                 shape: RoundedRectangleBorder(
                   borderRadius: BorderRadius.vertical(
                     top: Radius.circular(40),
                   ),
                 ),

                 builder: (BuildContext context) {
                        return Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                            decoration: BoxDecoration(
                              color: color_palette["background_color"],
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black,
                                    blurRadius: 2,
                                    spreadRadius: 2),
                              ],
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(40)),
                            ),
                            child: SingleChildScrollView(

                              child: Column(
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width - 20,
                                    margin: EdgeInsets.symmetric(horizontal: 15),
                                    alignment: AlignmentDirectional.center,
                                    padding: EdgeInsets.only(bottom: 8),
                                    child: Text(
                                      "Create",
                                      style:
                                      TextStyle(color: color_palette["white"], fontSize: 32.h),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => RecipeBuilder()));

                                    },
                                    child: Container(
                                      width: double.infinity,
                                      alignment: AlignmentDirectional.center,
                                      padding: EdgeInsets.symmetric(vertical: 10),
                                      margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                                      decoration: BoxDecoration(
                                          color: color_palette["alternative"],
                                          borderRadius: BorderRadius.circular(8)),
                                      child: Text("Share Recipe",
                                          style: TextStyle(
                                              color: color_palette["white"], fontSize: 22.h)),
                                    ),
                                  ),
                                ],
                              ),
                            ));

                });
          }
        },
        items: [
          FlashyTabBarItem(
            activeColor: color_palette["white"],
            inactiveColor: color_palette["white"],
            icon: Icon(AntDesign.home),
            title: Text(
              'Discover',
            ),
          ),
          FlashyTabBarItem(
            activeColor: color_palette["white"],
            inactiveColor: color_palette["white"],
            icon: Icon(AntDesign.calendar),
            title: Text('Meal Plans'),
          ),
          FlashyTabBarItem(
            activeColor: color_palette["white"],
            inactiveColor: color_palette["white"],
            icon: Icon(AntDesign.pluscircleo),
            title: Text('Create'),
          ),
          FlashyTabBarItem(
            activeColor: color_palette["white"],
            inactiveColor: color_palette["white"],
            icon: Icon(MaterialIcons.filter_list),
            title: Text('Lists'),
          ),
          FlashyTabBarItem(
            activeColor: color_palette["white"],
            inactiveColor: color_palette["white"],
            icon: Icon(AntDesign.user),
            title: Text('Profile'),
          ),
        ],
      ),
      body: Container(
          child:   getPage(context))
    );
  }
}
