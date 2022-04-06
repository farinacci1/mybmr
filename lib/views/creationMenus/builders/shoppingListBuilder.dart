import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mybmr/notifiers/EquipmentNotifier.dart';
import 'package:mybmr/notifiers/IngredientNotifier.dart';
import 'package:mybmr/notifiers/SearchNotifier.dart';
import 'package:mybmr/notifiers/UserListNotifier.dart';
import 'package:mybmr/constants/Constants.dart';
import 'package:mybmr/models/AppUser.dart';
import 'package:mybmr/models/Equipment.dart';
import 'package:mybmr/models/Ingredient.dart';
import 'package:mybmr/models/ShoppingList.dart';
import 'package:mybmr/services/hero_dialog_route.dart';
import 'package:mybmr/services/toast.dart';
import 'package:mybmr/views/creationMenus/popups/QuantitySetter.dart';
import 'package:mybmr/widgets/OverlaySearch.dart';
import 'package:provider/provider.dart';

import '../../../constants/Themes.dart';
import '../../../widgets/ActionDialogue.dart';
import '../../../widgets/HeaderBar.dart';

class ShoppingListBuilder extends StatefulWidget {
  final ShoppingList shoppingList;

  const ShoppingListBuilder({Key key, this.shoppingList}) : super(key: key);

  @override
  _ShoppingListBuilderState createState() => _ShoppingListBuilderState();
}

class _ShoppingListBuilderState extends State<ShoppingListBuilder> {
  TextEditingController _titleController = new TextEditingController();
  List<ShoppingItem> shoppingItems = [];
  @override
  void initState() {
    if (widget.shoppingList != null) buildFromExisting();
    super.initState();
  }

  void makeOrUpdateShoppingList(ShoppingList shoppingList) {
    if (AppUser.instance.uuid == null || AppUser.instance.uuid == "") {
      CustomToast("User not signed in. Unable to submit list");
    } else {
      if (widget.shoppingList != null)
        Provider.of<UserListNotifier>(context, listen: false)
            .updateShoppingList(shoppingList);
      else
        Provider.of<UserListNotifier>(context, listen: false)
            .createShoppingList(shoppingList);
      Navigator.pop(context);
    }
  }

  void buildFromExisting() {
    _titleController.text = widget.shoppingList.title;
    shoppingItems = List.from(widget.shoppingList.shoppingItems);
  }

  void resetIllusion() {
    Provider.of<SearchNotifier>(context, listen: false).searchMode =
        MenuType.NONE;
    Provider.of<EquipmentNotifier>(context, listen: false).optionSelected =
        false;
    Provider.of<IngredientNotifier>(context, listen: false).optionSelected =
        false;
  }

  Widget drawItem(ShoppingItem item) {
    return Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.only(top: 10),
        child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    return await
                    ActionDialogue(
                      message: 'Are you sure you want to remove this item from the shopping list?',
                      approveAction: (){
                        shoppingItems.remove(item);
                      },
                    ).build(context).whenComplete(() => setState(() {}));


                  },
                  child: Container(
                    width: 26.5.h,
                    height: 39.75.h,
                    margin: EdgeInsets.only(right: 5),
                    alignment: AlignmentDirectional.center,
                    child: Icon(
                      MaterialIcons.remove_circle,
                      color: color_palette["white"],
                      size: 23.85.h,
                    ),
                  ),
                ),
                Container(
                  width: 39.75.h,
                  height: 39.75.h,
                  margin: EdgeInsets.only(right: 5),
                  decoration: BoxDecoration(
                      image: DecorationImage(image: NetworkImage(item.image))),
                ),
                Container(
                  width: 132.5.h,
                  height: 39.75.h,
                  child: TextFormField(
                    initialValue: item.amount.toString(),
                    style: TextStyle(color: color_palette["white"]),
                    readOnly: true,
                    onTap: () async {
                      Map<String, dynamic> out = await Navigator.of(context)
                          .push(HeroDialogRoute(builder: (context) {
                        return QuantitySetterPopup(
                          value: 0.0,
                          itemName: item.name,
                        );
                      }));
                      if (out != null && out.containsKey("amount")) {
                        item.amount = out["amount"];
                        setState(() {});
                      }
                    },
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.black54,
                        disabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 1, color: color_palette["white"])),
                        enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: color_palette["white"])),
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: color_palette["white"]))),
                  ),
                ),
                Container(
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    height:39.75.h,
                    child: DropdownButton(
                      value: item.valueType,
                      alignment: AlignmentDirectional.bottomCenter,
                      iconSize: 0.0,
                      style: TextStyle(
                          color: color_palette["white"], fontSize: 21.2.h),
                      dropdownColor: Colors.lightBlueAccent,
                      isDense: true,
                      iconEnabledColor: color_palette["white"],
                      onChanged: (String newValue) {
                        setState(() {
                          item.valueType = newValue;
                        });
                      },
                      items: shoppingValues
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    )),
                Container(
                  constraints: BoxConstraints(minHeight: 39.75.h),
                  child: Text(
                    item.name.toUpperCase(),
                    style: TextStyle(
                        color: color_palette["white"],
                        fontSize: 23.85.h,
                        height: 1.66),
                  ),
                )
              ],
            )));
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
    return Scaffold(
      body: Container(
          decoration: BoxDecoration(gradient: color_palette["gradient"]),
          child: NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (overscroll) {
                overscroll.disallowIndicator();
                return;
              },
              child: CustomScrollView(slivers: [
                SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      children: [
                        HeaderBar(
                          popWidget: Icon(
                            Icons.arrow_back,
                            color: color_palette["white"],
                            size: 31.8.h,
                          ),
                          onPopCallback: () {},
                          title:  _titleController.text.length > 0 ?  _titleController.value.text :  "Shopping List",
                          submitColor: color_palette["text_color_dark"],
                          submitWidget: Text(
                            "Save",
                            textScaleFactor: 1.0,
                            style: TextStyle(color: color_palette["white"], fontSize: 20.h),
                          ),
                          submitCallback: () {
                            String newTitle =
                                _titleController.value.text.trim();
                            if (newTitle.length == 0) {
                              CustomToast("Title cannot be empty");
                            } else {
                              if (shoppingItems.length == 0) {
                                CustomToast(
                                    "There are no items in this shopping list. Please add some to continue");
                              } else {
                                ShoppingList newShoppingList =
                                    ShoppingList(newTitle, shoppingItems, []);
                                if (widget.shoppingList != null)
                                  newShoppingList.listId =
                                      widget.shoppingList.listId;
                                makeOrUpdateShoppingList(newShoppingList);
                              }
                            }
                          },
                        ),
                        Container(
                            width: MediaQuery.of(context).size.width - 30,
                            margin: EdgeInsets.fromLTRB(15, 10, 15, 0),
                            child: Text(
                              "Title",
                              textAlign: TextAlign.left,
                              textScaleFactor: 1.0,
                              style: TextStyle(
                                  color: color_palette["white"],
                                  fontSize: 23.5.h,
                                  fontWeight: FontWeight.bold),
                            )),
                        Container(
                            margin: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),

                            child: TextField(
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(50),
                              ],
                              style: TextStyle(
                                  color: color_palette["white"], fontSize: 30.h,height:1.5),
                              controller: _titleController,
                              onChanged: (str){
                                setState(() {});
                              },

                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(vertical: 30.h/2,horizontal: 15.h),
                                  isDense: true,
                                  filled: true,
                                  fillColor: Colors.black54,
                                  hintText: "Add A Title...",
                                  hintStyle: TextStyle(
                                    color: color_palette["white"],
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),

                                      borderSide: BorderSide(
                                          color: color_palette["white"])),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),

                                      borderSide: BorderSide(
                                          color: color_palette["white"]))),
                            )),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 15),
                            child: Column(
                              children: [
                                Container(
                                    alignment: AlignmentDirectional.topStart,
                                    child: Text(
                                      "Items",
                                      textScaleFactor: 1.0,
                                      style: TextStyle(
                                          color: color_palette["white"],
                                          fontSize: 23.5.h,
                                          fontWeight: FontWeight.bold),
                                    )),
                                ...shoppingItems.map((item) {
                                  return drawItem(item);
                                }).toList(),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          child: Row(
                            children: [ingredientButton(), equipmentButton()],
                          ),
                        )
                      ],
                    ))
              ]))),
    );
  }

  Widget ingredientButton() {
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
            ShoppingItem shoppingItem = shoppingItems.firstWhere((item) {
              return (item.id == ingredient.id && item.isIngredient == true);
            }, orElse: () {
              return null;
            });
            if (shoppingItem == null) {
              shoppingItems.add(ShoppingItem(
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
          height: (MediaQuery.of(context).size.width / 7.5) ,
          alignment: AlignmentDirectional.center,
          decoration: BoxDecoration(
              color: color_palette["semi_transparent"],
            border: Border(
              right: BorderSide(width: 0.5,color: color_palette["text_color_dark"])
            )
          ),
          child: Text(
            "Add Ingredient",
            style: TextStyle(color: color_palette["white"],fontSize: 25.h),
          ),
        ));
  }

  Widget equipmentButton() {
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
            ShoppingItem shoppingItem = shoppingItems.firstWhere((item) {
              return (item.id == equipmentItem.id && item.isEquipment == true);
            }, orElse: () {
              return null;
            });
            if (shoppingItem == null) {
              shoppingItems.add(ShoppingItem(
                  id: equipmentItem.id,
                  amount: 0,
                  valueType: shoppingValues[0],
                  image: equipmentItem.equipmentImageFromDb,
                  name: equipmentItem.name,
                  isEquipment: true,
                  isIngredient: false));
              setState(() {});
            } else {
              CustomToast("Item already exists in list");
            }
          }
        },
        child: Container(
          width: MediaQuery.of(context).size.width / 2,
          height: (MediaQuery.of(context).size.width / 7.5) ,

          alignment: AlignmentDirectional.center,
          decoration: BoxDecoration(
            color: color_palette["semi_transparent"],
              border: Border(
                  left: BorderSide(width: 0.5,color: color_palette["text_color_dark"])
              )
          ),
          child: Text(
            "Add Equipment",
            style: TextStyle(color: color_palette["white"],fontSize: 25.h),
          ),
        ));
  }
}
