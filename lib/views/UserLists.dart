import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mybmr/notifiers/UserListNotifier.dart';

import 'package:provider/provider.dart';
import '../constants/Constants.dart';
import '../constants/Themes.dart';
import '../models/Equipment.dart';
import '../models/Ingredient.dart';
import '../models/ShoppingItem.dart';
import '../notifiers/EquipmentNotifier.dart';
import '../notifiers/IngredientNotifier.dart';
import '../notifiers/SearchNotifier.dart';
import '../services/hero_dialog_route.dart';
import '../services/toast.dart';
import '../widgets/OverlaySearch.dart';
import 'creationMenus/popups/TaskPopup.dart';

class UserList extends StatefulWidget {
  const UserList({Key key}) : super(key: key);
  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  int activeState = 0;


  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: color_palette["background_color"],
      systemNavigationBarColor: color_palette["background_color"],
      systemNavigationBarDividerColor: color_palette["background_color"],
    ));
    UserListNotifier userListNotifier = Provider.of<UserListNotifier>(context, listen: true);
    ScreenUtil.init(
      context,
      designSize: Size(2400, 1080),
      minTextAdapt: true,
    );
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(children: [
          Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              height: double.infinity,
              decoration:
                  BoxDecoration(color: color_palette["background_color"]),
              child: Column(children: [
                Container(
                  padding: EdgeInsets.fromLTRB(10, 20, 0, 0),
                  decoration:
                      BoxDecoration(color: color_palette["background_color"]),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 15),
                        alignment: AlignmentDirectional.center,
                        child: AutoSizeText(
                          "My Lists",
                          maxLines: 1,
                          style: TextStyle(
                              color: color_palette["white"], fontSize: 50.4.h),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.only(bottom: 9),
                        alignment: AlignmentDirectional.topStart,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: 10),
                              child: Text(
                                "Categories".toUpperCase(),
                                style: TextStyle(
                                    fontSize: 18.h,
                                    color: color_palette["offWhite"]),
                              ),
                            ),
                            Container(
                                width: MediaQuery.of(context).size.width,
                                height: 125.h + 10,
                                margin: EdgeInsets.only(bottom: 10),
                                alignment: AlignmentDirectional.centerStart,
                                child: NotificationListener<
                                    OverscrollIndicatorNotification>(
                                  onNotification: (overscroll) {
                                    overscroll.disallowIndicator();
                                    return;
                                  },
                                  child: ListView(
                                    itemExtent: 210.h,
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    children: [
                                      listOption(
                                          height: 120.h ,
                                          primaryLabel: "Tasks",
                                          secondaryLabel: userListNotifier.taskList == null ? "0 of 0 Done":
                                              "${userListNotifier.taskList.hasCompleted.where((e) => e == true).length} of ${userListNotifier.taskList.subtasks.length} Done",
                                          bgColor: color_palette["overlay"],
                                          onTap: () {
                                            setState(() {
                                              activeState = 0;
                                            });
                                          }),
                                      listOption(
                                          height: 120.h ,
                                          primaryLabel: "Groceries",
                                          secondaryLabel: "${userListNotifier.groceryList.shoppingItems.length} Items",
                                          bgColor: color_palette["overlay"],
                                          onTap: () {
                                            setState(() {
                                              activeState = 1;
                                            });
                                          }),

                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                    child: Container(
                  color: color_palette["semi_transparent"],
                  child: Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        child: Text(
                          (activeState == 0)
                              ? "MY TASKS"
                              : (activeState == 1)
                                  ? "MY GROCERIES"
                                  : "MY EVENTS",
                          style: TextStyle(
                              color: color_palette["offWhite"], fontSize: 18.h),
                        ),
                      ),
                      (activeState == 0) ? taskPage() :  shoppingPage()
                    ],
                  ),
                )),
              ])),
        ]));
  }

  Widget listOption(
      {double height = 100,
      String primaryLabel = "To Do",
      String secondaryLabel = "Tasks",
      Color bgColor = Colors.grey,
      VoidCallback onTap}) {
    return GestureDetector(
        onTap: () {
          if (onTap != null) onTap();
        },
        child: Container(
          height: height  ,
          margin: EdgeInsets.only(top: 5, right: 15),
          padding: EdgeInsets.fromLTRB(10, 18, 10, 5),
          decoration: BoxDecoration(
              color: bgColor, borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: Text(secondaryLabel,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 18.h, color: color_palette["offWhite"])
                ),
              ),
              Text(
                primaryLabel,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 35.h, color: Colors.white),
              )
            ],
          ),
        ));
  }

  Widget taskPage() {
    UserListNotifier userListNotifier = Provider.of<UserListNotifier>(context,listen: false);
    return Expanded(
      child: Container(
        child: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (overscroll) {
              overscroll.disallowIndicator();
              return;
            },
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                    child: Container(
                  child: Column(
                    children: [
                      Expanded(
                          child: Container(
                        child:userListNotifier.taskList != null && userListNotifier.taskList.subtasks.length > 0
                            ? Column(
                                children: List.generate(userListNotifier.taskList.subtasks.length,
                                    (int idx) {
                                return Dismissible(
                                    key: UniqueKey(),
                                    confirmDismiss:
                                        (DismissDirection direction) async {
                                      if (direction ==
                                          DismissDirection.endToStart) {
                                        userListNotifier.removeFromTaskList(idx);
                                        return true;
                                      }
                                      return false;
                                    },
                                    child: Container(
                                        child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Transform.scale(
                                            scale: 1.5,
                                            child: Theme(
                                                data:
                                                    Theme.of(context).copyWith(
                                                  unselectedWidgetColor:
                                                      color_palette["white"],
                                                ),
                                                child: Checkbox(
                                                  value: userListNotifier.taskList.hasCompleted[idx],
                                                  checkColor: color_palette[
                                                      "text_color_dark"],
                                                  activeColor:
                                                      color_palette["white"],
                                                  shape: CircleBorder(),
                                                  onChanged: (newValue) {
                                                    userListNotifier.changeTaskState(idx);

                                                  },
                                                ))),
                                        AnimatedContainer(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                80,
                                            duration:
                                                Duration(milliseconds: 800),
                                            child: Text(
                                              userListNotifier.taskList.subtasks[idx],
                                              textAlign: TextAlign.justify,
                                              maxLines: null,
                                              style: TextStyle(
                                                  color: ! userListNotifier.taskList.hasCompleted[idx]
                                                      ? color_palette["white"]
                                                      : color_palette[
                                                          "text_color_alt"],
                                                  fontSize: 34.h),
                                            )),
                                      ],
                                    )));
                              }
                                    // some widgets here
                                    ).toList())
                            : Container(),
                      )),
                      Container(
                          width: MediaQuery.of(context).size.width,
                          height: 70.h,
                          margin: EdgeInsets.fromLTRB(10, 10, 10, 3),
                          child: ElevatedButton(
                            onPressed: () async {
                              Map<String, dynamic> out =
                                  await Navigator.of(context)
                                      .push(HeroDialogRoute(builder: (context) {
                                return TaskPopup();
                              }));
                              if (out != null && out.containsKey("value")) {
                                userListNotifier.addTaskToList(out["value"]);
                              }
                            },
                            child: Text("Add Task"),
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                                elevation: 8,
                                primary: color_palette["overlay"]),
                          )),
                    ],
                  ),
                )),
              ],
            )),
      ),
    );
  }

  Widget shoppingPage() {
    UserListNotifier userListNotifier = Provider.of<UserListNotifier>(context,listen: false);
    return Expanded(
      child: Container(
        child: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (overscroll) {
              overscroll.disallowIndicator();
              return;
            },
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                    child: Container(
                  child: Column(
                    children: [
                      Expanded(
                          child: Container(
                        child: userListNotifier.groceryList.shoppingItems.length > 0
                            ? Column(
                                children: List.generate(userListNotifier.groceryList.shoppingItems.length,
                                    (int idx) {
                                return Dismissible(
                                    key: UniqueKey(),
                                    confirmDismiss:
                                        (DismissDirection direction) async {
                                      if (direction ==
                                          DismissDirection.endToStart) {
                                        userListNotifier.removeGroceryItem(idx);
                                        return true;
                                      }
                                      return false;
                                    },
                                    child: Container(
                                        padding:
                                            EdgeInsets.fromLTRB(15, 0, 15, 4),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Padding(
                                                padding:
                                                    EdgeInsets.only(right: 8),
                                                child: CircleAvatar(
                                                    radius: 39.75.h / 2,
                                                    backgroundImage:
                                                        NetworkImage(
                                                            userListNotifier.groceryList.shoppingItems[idx]
                                                                .image))),
                                            Expanded(
                                                child: Text(
                                                    userListNotifier.groceryList.shoppingItems[idx].name,
                                                    style: TextStyle(
                                                        color: color_palette[
                                                            "white"],
                                                        fontSize: 32.h)))
                                          ],
                                        )));
                              }
                                    // some widgets here
                                    ).toList())
                            : Container(),
                      )),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 70.h,
                        margin: EdgeInsets.fromLTRB(0, 10, 0, 3),
                        child: Row(
                          children: [ingredientButton(), equipmentButton()],
                        ),
                      )
                    ],
                  ),
                )),
              ],
            )),
      ),
    );
  }

  void resetIllusion() {
    Provider.of<SearchNotifier>(context, listen: false).searchMode =
        MenuType.NONE;
    Provider.of<EquipmentNotifier>(context, listen: false).optionSelected =
        false;
    Provider.of<IngredientNotifier>(context, listen: false).optionSelected =
        false;
  }

  Widget ingredientButton() {
    UserListNotifier userListNotifier = Provider.of<UserListNotifier>(context,listen: false);
    return GestureDetector(
        onTap: () async {
          resetIllusion();
          Provider.of<SearchNotifier>(context, listen: false).searchMode =
              MenuType.INGREDIENTS;
          Map<String, dynamic> data = await Navigator.of(context)
              .push(HeroDialogRoute(builder: (context) {
            return OverlaySearch(
              title: "Ingredient",
              inShopping: true,
            );
          }));

          if (data != null && data.containsKey("ingredient")) {
            Ingredient ingredient = data["ingredient"];
            ShoppingItem shoppingItem = userListNotifier.groceryList.shoppingItems.firstWhere((item) {
              return (item.id == ingredient.id && item.isIngredient == true);
            }, orElse: () {
              return null;
            });
            if (shoppingItem == null) {
              userListNotifier.groceryList.shoppingItems.add(ShoppingItem(
                  id: ingredient.id,
                  amount: 0,
                  valueType: shoppingValues[0],
                  image: ingredient.ingredientImageFromDB,
                  name: ingredient.ingredientName,
                  isEquipment: false,
                  isIngredient: true));
              setState(() {});
            } else {
              CustomToast("Item already exists in list");
            }
          }
        },
        child: Container(
          width: MediaQuery.of(context).size.width / 2,
          height: (MediaQuery.of(context).size.width / 7.5),
          alignment: AlignmentDirectional.center,
          decoration: BoxDecoration(
              color: color_palette["semi_transparent"],
              border: Border(
                  right: BorderSide(width: 0.5, color: color_palette["tone"]))),
          child: Text(
            "Add Ingredient",
            style: TextStyle(color: color_palette["white"], fontSize: 25.h),
          ),
        ));
  }

  Widget equipmentButton() {
    UserListNotifier userListNotifier = Provider.of<UserListNotifier>(context,listen: false);
    return GestureDetector(
        onTap: () async {
          resetIllusion();
          Provider.of<SearchNotifier>(context, listen: false).searchMode =
              MenuType.EQUIPMENT;

          Map<String, dynamic> data = await Navigator.of(context)
              .push(HeroDialogRoute(builder: (context) {
            return OverlaySearch(title: "Equipment", inShopping: true);
          }));
          if (data != null && data.containsKey("equipment")) {
            Equipment equipmentItem = data["equipment"];
            ShoppingItem shoppingItem = userListNotifier.groceryList.shoppingItems.firstWhere((item) {
              return (item.id == equipmentItem.id && item.isEquipment == true);
            }, orElse: () {
              return null;
            });
            if (shoppingItem == null) {
              ShoppingItem shoppingItem =ShoppingItem(
                  id: equipmentItem.id,
                  amount: 0,
                  valueType: shoppingValues[0],
                  image: equipmentItem.equipmentImageFromDb,
                  name: equipmentItem.name,
                  isEquipment: true,
                  isIngredient: false);
              userListNotifier.addGroceryItem(shoppingItem);
            } else {
              CustomToast("Item already exists in list");
            }
          }
        },
        child: Container(
          width: MediaQuery.of(context).size.width / 2,
          height: (MediaQuery.of(context).size.width / 7.5),
          alignment: AlignmentDirectional.center,
          decoration: BoxDecoration(
              color: color_palette["semi_transparent"],
              border: Border(
                  left: BorderSide(width: 0.5, color: color_palette["tone"]))),
          child: Text(
            "Add Equipment",
            style: TextStyle(color: color_palette["white"], fontSize: 25.h),
          ),
        ));
  }


}
