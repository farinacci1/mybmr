import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mybmr/models/Task.dart';
import 'package:mybmr/notifiers/UserListNotifier.dart';
import 'package:mybmr/constants/messages/en_messages.dart';
import 'package:mybmr/models/ShoppingList.dart';
import 'package:mybmr/models/UserNote.dart';
import 'package:mybmr/views/creationMenus/builders/NoteBuilder.dart';
import 'package:mybmr/views/creationMenus/builders/TaskBuilder.dart';
import 'package:mybmr/widgets/ActionDialogue.dart';
import 'package:mybmr/widgets/CornerListView.dart';
import 'package:mybmr/widgets/CustomTile.dart';
import 'package:provider/provider.dart';

import '../constants/Themes.dart';
import 'creationMenus/builders/shoppingListBuilder.dart';

class UserList extends StatefulWidget {
  const UserList({Key key}) : super(key: key);
  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  @override
  Widget build(BuildContext context) {
    Provider.of<UserListNotifier>(context, listen: true);
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
        body: Stack(children: [
          Container(
              width: MediaQuery.of(context).size.width,
              height: double.infinity,
              decoration: BoxDecoration(gradient: color_palette["gradient"]),
              child: Column(children: [
                Container(
                    width: MediaQuery.of(context).size.width,
                    alignment: AlignmentDirectional.center,
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + 8, bottom: 7),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: Icon(
                                FontAwesomeIcons.solidListAlt,
                                color: color_palette["white"],
                                size: 31.8.h,
                              )),
                          AutoSizeText(
                            en_messages["my_lists"],
                            maxLines: 1,
                            style: TextStyle(
                                fontSize: 42.4.h,
                                color: color_palette["white"]),
                          ),
                        ])),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: Column(children: [
                      Expanded(
                        child: Container(
                            margin: EdgeInsets.fromLTRB(10, 15, 10, 5),
                            alignment: AlignmentDirectional.topCenter,
                            child: Provider.of<UserListNotifier>(context,
                                            listen: false)
                                        .listIds
                                        .length >
                                    0
                                ? NotificationListener<
                                        OverscrollIndicatorNotification>(
                                    onNotification: (overscroll) {
                                      overscroll.disallowIndicator();
                                      return;
                                    },
                                    child: Theme(
                                        data: ThemeData(
                                            canvasColor: Colors.transparent),
                                        child: ReorderableListView.builder(
                                          itemCount:
                                              Provider.of<UserListNotifier>(
                                                      context,
                                                      listen: false)
                                                  .userLists
                                                  .length,
                                          onReorder: ((oldIndex, newIndex) {
                                            if (newIndex > oldIndex) {
                                              newIndex -= 1;
                                            }
                                            Provider.of<UserListNotifier>(
                                                    context,
                                                    listen: false)
                                                .reorderLists(
                                                    oldIndex, newIndex);
                                          }),
                                          itemBuilder: (context, index) {
                                            var item =
                                                Provider.of<UserListNotifier>(
                                                        context,
                                                        listen: false)
                                                    .userLists[index]
                                                    .toJSON(isShared: true);
                                            bool isShoppingList = item
                                                .containsKey("shoppingItems");
                                            bool isNote =
                                                item.containsKey("body");
                                            bool isTask =
                                            item.containsKey("subtasks");
                                            Widget model;
                                            if (isShoppingList) {
                                              model = CustomTile(
                                                height: 50,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    40,
                                                color: color_palette["overlay"],
                                                title: AutoSizeText(
                                                  item["title"],
                                                  style: TextStyle(
                                                      color: color_palette[
                                                          "white"]),
                                                ),
                                                radius:
                                                    BorderRadius.circular(20),
                                                subtitle: AutoSizeText(
                                                  "Number of Items: " +
                                                      List.from(item[
                                                              "shoppingItems"])
                                                          .length
                                                          .toString(),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color: color_palette[
                                                          "text_color_alt"]),
                                                ),
                                                preceding: AutoSizeText("🛒",
                                                    style: TextStyle(
                                                        color: color_palette[
                                                            "white"],
                                                        fontSize: 28)),
                                                trailing: Icon(
                                                  FontAwesomeIcons.solidListAlt,
                                                  color: color_palette["white"],
                                                  size: 24,
                                                ),
                                              );
                                            }
                                            else if (isNote) {
                                              model = CustomTile(
                                                height: 50,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    40,
                                                color: color_palette["overlay"],
                                                title: AutoSizeText(
                                                  item["title"],
                                                  style: TextStyle(
                                                      color: color_palette[
                                                          "white"]),
                                                ),
                                                radius:
                                                    BorderRadius.circular(20),
                                                subtitle: AutoSizeText(
                                                  item["body"],
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color: color_palette[
                                                          "text_color_alt"]),
                                                ),
                                                preceding: AutoSizeText("📝",
                                                    style: TextStyle(
                                                        color: color_palette[
                                                            "white"],
                                                        fontSize: 28)),
                                                trailing: Icon(
                                                  FontAwesomeIcons.minus,
                                                  color: color_palette["white"],
                                                  size: 24,
                                                ),
                                              );
                                            }
                                            else if(isTask){
                                              model = CustomTile(
                                                height: 50,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                    40,
                                                color: color_palette["overlay"],
                                                title: AutoSizeText(
                                                  item["title"],
                                                  style: TextStyle(
                                                      color: color_palette[
                                                      "white"]),
                                                ),
                                                radius:
                                                BorderRadius.circular(20),
                                                subtitle: AutoSizeText(
                                                 "Completed ${item["hasCompleted"].where((e) => e == true).length.toString()} of ${item["subtasks"].length.toString()}" ,
                                                  maxLines: 1,
                                                  overflow:
                                                  TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color: color_palette[
                                                      "text_color_alt"]),
                                                ),
                                                preceding: AutoSizeText("✓",
                                                    style: TextStyle(
                                                        color: color_palette[
                                                        "white"],
                                                        fontSize: 28)),
                                                trailing: Icon(
                                                  FontAwesomeIcons.minus,
                                                  color: color_palette["white"],
                                                  size: 24,
                                                ),
                                              );
                                            }
                                            return Dismissible(
                                                key: ValueKey(item["id"]),
                                                confirmDismiss:
                                                    (DismissDirection
                                                        direction) async {
                                                  if (direction ==
                                                      DismissDirection
                                                          .endToStart) {
                                                    return await
                                                           ActionDialogue(
                                                            message: isShoppingList
                                                                ? en_messages[
                                                            "remove_shoppingList_question"]
                                                                :isNote ? en_messages[
                                                            "remove_note_question"]:
                                                             en_messages["remove_task_question"],
                                                            approveAction: (){
                                                              Provider.of<UserListNotifier>(
                                                                  context,
                                                                  listen:
                                                                  false)
                                                                  .removeListItem(
                                                                  item["id"]);
                                                            },

                                                          ).build(context);
                                                       
                                                  }
                                                  return null;
                                                },
                                                child: GestureDetector(
                                                    onTap: () async {
                                                      if (isShoppingList) {
                                                        await Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) {
                                                          return ShoppingListBuilder(
                                                            shoppingList:
                                                                ShoppingList
                                                                    .fromJSON(
                                                                        item,
                                                                        item[
                                                                            "id"]),
                                                          );
                                                        }));
                                                      } else if(isNote){
                                                        await Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) {
                                                          return NoteBuilder(
                                                            note: UserNote
                                                                .fromJSON(item,
                                                                    item["id"]),
                                                          );
                                                        }));
                                                      }else{
                                                        await Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) {
                                                                  return TaskBuilder(
                                                                    task: UserTask
                                                                        .fromJSON(item,
                                                                        item["id"]),
                                                                  );
                                                                }));
                                                      }
                                                    },
                                                    child: model));
                                          },
                                        )))
                                : Center(
                                    child: AutoSizeText(
                                    en_messages["no_lists_found"],
                                    maxLines: 3,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 23.h),
                                  ))),
                      ),
                    ]),
                  ),
                ),
              ])),
          CornerActionList(
            radius: 66.25.h,
            duration: Duration(milliseconds: 1000),
          )
        ]));
  }
}
