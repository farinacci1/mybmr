import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mybmr/notifiers/FavoritesNotifier.dart';
import 'package:mybmr/notifiers/MealPlanNotifier.dart';
import 'package:mybmr/notifiers/RecipeNotifier.dart';
import 'package:mybmr/notifiers/UserListNotifier.dart';
import 'package:mybmr/notifiers/UserNotifier.dart';
import 'package:mybmr/constants/messages/en_messages.dart';
import 'package:mybmr/models/AppUser.dart';
import 'package:mybmr/services/toast.dart';
import 'package:mybmr/views/Login.dart';
import 'package:mybmr/views/MealPlannerDisplay.dart';
import 'package:mybmr/views/RecipePageView.dart';
import 'package:mybmr/views/UserLists.dart';
import 'package:mybmr/views/creationMenus/builders/RecipeBuilder.dart';

import 'package:provider/provider.dart';

import '../constants/Themes.dart';
import 'UserAccount.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int activeView = 1;
  Widget actionButton(
      {Function callback,
      IconData iconData,
      double size,
      Color color,
        String msg ='',
      Color bgColor = Colors.black}) {
    return GestureDetector(
      onTap: () {
        callback();
        setState(() {});
      },
      behavior: HitTestBehavior.translucent,
      child: Container(
         margin: EdgeInsets.symmetric(vertical: 3),
          padding: EdgeInsets.symmetric(horizontal: 3),

          width: (MediaQuery.of(context).size.width - 50) / 5,
          alignment: AlignmentDirectional.center,
          child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children:[Stack(
            children: <Widget>[
              Positioned(
                left: 1.0,
                top: 2.0,
                child: Icon(
                  iconData,
                  size: size,
                  color: bgColor,
                ),
              ),
              Icon(
                iconData,
                size: size,
                color: color,
              )
            ],
          ),
            Container(
              margin: EdgeInsets.only(top: 3),
              child:
            AutoSizeText(msg,maxLines: 1,minFontSize: 8,style: TextStyle(fontSize: 14.h,color: Color(0XFFF5F5F5),)),)
          ])),
    );
  }

  Widget getPage(BuildContext context) {
    switch (activeView) {
      case 1:
        return
          RecipePageView();


      case 2:
        MealPlanNotifier mealPlanNotifier =
            Provider.of<MealPlanNotifier>(context, listen: false);

        if (AppUser.instance.uuid != null &&
            AppUser.instance.uuid != "") {
          if(mealPlanNotifier.mealPlans.length == 0 &&
              mealPlanNotifier.isFetching == false)
          mealPlanNotifier.getMealPlansFromDB();
        }
        if(AppUser.instance.uuid == null ||
            AppUser.instance.uuid == ""){
          CustomToast(en_messages["sign_in_required"]);
        }
        return MealPlannerDisplay();
      case 3:
        if(AppUser.instance.uuid == null ||
            AppUser.instance.uuid == ""){
          CustomToast(en_messages["sign_in_required"]);
        }
        return RecipeBuilder();
      case 4:
        if(AppUser.instance.uuid == null ||
            AppUser.instance.uuid == ""){
          CustomToast(en_messages["sign_in_required"]);
        }else{
          if(Provider.of<UserListNotifier>(context,listen:false).isCurrentlyFetching == false && Provider.of<UserListNotifier>(context,listen:false).listIds.length == 0)
            Provider.of<UserListNotifier>(context,listen:false).fetchUsersListIds();
        }
        return UserList();
      case 5:
        if (AppUser.instance.uuid == null || AppUser.instance.uuid == "") {
          return LoginScreen();
        } else {
          FavoritesNotifier favoritesNotifier =
              Provider.of<FavoritesNotifier>(context, listen: false);
          if (!favoritesNotifier.currentlyFetchingMyRecipes &&
              favoritesNotifier.myCreations.length == 0) {
            favoritesNotifier.fetchRecipes(fetchFavorites: false);
          }
          if (!favoritesNotifier.currentlyFetchingFavorites &&
              favoritesNotifier.favoriteRecipes.length == 0) {
            favoritesNotifier.fetchRecipes( fetchFavorites: true);
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


    RecipeNotifier recipeNotifier =
        Provider.of<RecipeNotifier>(context, listen: false);
    if (recipeNotifier.recipes.length == 0)
      Provider.of<RecipeNotifier>(context, listen: false).fetchRecipes();
    DateTime nowDate = DateTime.now();
    DateTime startDate = DateTime(nowDate.year,nowDate.month,nowDate.day);
    Provider.of<MealPlanNotifier>(context, listen: false).setStartOfDay(startDate,shouldNotify: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<UserNotifier>(context, listen: true);
    Provider.of<RecipeNotifier>(context, listen: true);
    ScreenUtil.init(
        BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width,
            maxHeight: MediaQuery.of(context).size.height),
        designSize: Size(2400, 1080),
        context: context,
        minTextAdapt: true,
        orientation: Orientation.portrait);
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.black,
        body: Container(
          child: Column(
            children: [
              Expanded(
                child: Container(child: getPage(context)),
              ),
              Container(
                color:color_palette["text_color_dark"],
                height: 65.h,

                padding: EdgeInsets.symmetric(horizontal: 25),
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    actionButton(
                        callback: () {
                          activeView = 1;
                        },
                        size: 0.4 * 58.h,
                        iconData: Icons.house,
                        color: activeView == 1
                            ? Colors.orangeAccent
                            : Colors.white,
                      msg: "Discover"
                    ),
                    actionButton(
                        callback: () {
                          activeView = 2;
                        },
                        size:0.4 * 58.h,
                        iconData: FontAwesome5.calendar_alt,
                        color: activeView == 2
                            ? Colors.orangeAccent
                            : Colors.white,
                        msg: "Meal Plan"),
                    actionButton(
                        callback: () {
                          activeView = 3;
                        },
                        size: 0.55 * 58.h,
                        iconData: Icons.my_library_add,
                        color: activeView == 3
                            ? Colors.orangeAccent
                            : Colors.white,
                        msg: "Create"),
                    actionButton(
                        callback: () {
                          activeView = 4;
                        },
                        size: 0.4 * 58.h,
                        iconData: FontAwesome5.list_alt,
                        color: activeView == 4
                            ? Colors.orangeAccent
                            : Colors.white,
                        msg: "Lists"),
                    actionButton(
                        callback: () {
                          activeView = 5;
                        },
                        size: 0.4 * 58.h,
                        iconData: FontAwesome5.user,
                        color: activeView == 5
                            ? Colors.orangeAccent
                            : Colors.white,
                        msg: "Account"),
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
