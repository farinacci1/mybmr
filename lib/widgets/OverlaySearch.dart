import 'dart:async';
import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mybmr/notifiers/EquipmentNotifier.dart';
import 'package:mybmr/notifiers/IngredientNotifier.dart';
import 'package:mybmr/notifiers/SearchNotifier.dart';
import 'package:mybmr/constants/Constants.dart';
import 'package:mybmr/constants/messages/en_messages.dart';
import 'package:mybmr/models/Equipment.dart';
import 'package:mybmr/models/Ingredient.dart';
import 'package:mybmr/services/conversion.dart';
import 'package:mybmr/services/hero_dialog_route.dart';
import 'package:mybmr/views/creationMenus/builders/ingredientBuilder.dart';
import 'package:mybmr/views/creationMenus/popups/eduipmentPopup.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:provider/provider.dart';

import '../constants/Themes.dart';

class OverlaySearch extends StatefulWidget {
  /*
  * Search widget for fetching ingredients and equipment by similar names
  * leverage both ingredientNotifier and equipmentNotifier and display to user options returned from database
  * with option to fetch more
  *
  * */
  final String title;
  final String hintText;
  final inShopping;


  const OverlaySearch(
      {Key key, this.title = "Overlay Search", this.hintText = "Search ...", this.inShopping = false})
      : super(key: key);
  @override
  _OverlaySearchState createState() => _OverlaySearchState();
}

class _OverlaySearchState extends State<OverlaySearch> {
  String filter = "";
  Timer _timer;

  TextEditingController controller = new TextEditingController();


@override void dispose() {
  controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {

    MenuType searchMode =
        Provider.of<SearchNotifier>(context, listen: false).searchMode;
    IngredientNotifier ingredientNotifier =
        Provider.of<IngredientNotifier>(context, listen: true);
    EquipmentNotifier equipmentNotifier =
        Provider.of<EquipmentNotifier>(context, listen: true);

    ScreenUtil.init(
        BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width,
            maxHeight: MediaQuery.of(context).size.height),
        designSize: Size(2400, 1080),
        context: context,
        minTextAdapt: true,
        orientation: Orientation.portrait);
    return Container(
        width: MediaQuery.of(context).size.height,
        height: MediaQuery.of(context).size.width,
        color: Colors.transparent,
        child: Material(
          color: Colors.transparent,
          child: Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: [
              GestureDetector(
                onTap: () {
                  this.clearContent();
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: double.infinity,
                  color: Colors.transparent,
                ),
              ),
              Container(

                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                decoration: BoxDecoration(
                    color: Color(0XFFF5F5F5),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(79.5.h)),
                  boxShadow: [
                    BoxShadow(
                        color: color_palette["background_color"],
                        spreadRadius: 2,
                        blurRadius: 2,
                        offset: Offset(0, 0))
                  ]
                ),
                child:SingleChildScrollView(child:  Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      alignment: AlignmentDirectional.center,
                      width: double.infinity,
                      margin: EdgeInsets.fromLTRB(13.25.h, 13.25.h, 13.25.h, 0),
                      height: 53.h,

                      child: AutoSizeText(
                        widget.title,
                        maxLines: 1,
                        style: TextStyle(color: color_palette["background_color"], fontSize: 31.8.h),
                        minFontSize: 8,
                      ),
                    ),
                    Container(
                      height: 66.25.h,
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: TextField(
                        controller: controller,
                        onChanged: (String str) {
                          searchCallback(str);

                        },

                        inputFormatters: [
                          LengthLimitingTextInputFormatter(15),
                        ],
                        style: TextStyle(fontSize: 26.5.h,color: color_palette["background_color"]),
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.search,
                            color:color_palette["text_color_alt"],
                          ),
                          suffixIcon:
                          filter.length > 0 ? Container(
                              child:IconButton(
                                onPressed:(){
                                  setState(() {
                                    filter = "";
                                    controller.clear();
                                  });


                                },
                                  icon: Icon(Icons.clear,color: color_palette["background_color"],)                              )): null,

                          contentPadding:
                              EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: color_palette["background_color"]),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: color_palette["background_color"]),
                          ),
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: color_palette["background_color"]),
                          ),
                          hintText: widget.hintText,
                          hintStyle: TextStyle(color: color_palette["background_color"])
                        ),
                      ),
                    ),
                   Container(
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 7),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AutoSizeText(
                                  "${widget.title}",
                                  minFontSize: 8,
                                  maxLines: 1,
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 15.9.h),
                                ),
                                Container(
                                  height: 116.6.h,
                                  alignment: AlignmentDirectional.center,
                                  child: searchMode == MenuType.INGREDIENTS
                                      ? ingredientNotifier.ingredientState ==
                                              IngredientState
                                                  .FETCHING_INGREDIENTS
                                          ? JumpingDotsProgressIndicator(
                                              fontSize: 26.5.h,
                                              color: color_palette["background_color"],
                                            )
                                          : ingredientNotifier
                                                      .ingredientState ==
                                                  IngredientState
                                                      .INGREDIENTS_NOT_FOUND
                                              ? AutoSizeText(en_messages["no_ingredients_found"],maxLines: 1, minFontSize: 8,)
                                              : ListView.builder(

                                                  scrollDirection: Axis.horizontal,
                                                  itemCount: ingredientNotifier.ingredientList_found.length + 1,
                                                  itemBuilder: (BuildContext context, int index) {
                                                    {
                                                      return (index == ingredientNotifier.ingredientList_found.length ) ?
                                                          Container(
                                                            child: (ingredientNotifier.ingredientState != IngredientState.INGREDIENTS_REACHED_END && ingredientNotifier.ingredientList_found.length >= 1)
                                                                ? MaterialButton(
                                                              onPressed: (){ingredientNotifier.filterIngredientsOnline(filter, 8);},
                                                              child: Icon(Icons.add,size: 15,),
                                                            ) : null
                                                          )

                                                      : renderIngredient(
                                                          ingredientNotifier
                                                              .ingredientList_found[index]);
                                                    }
                                                  }


                                                )
                                      : searchMode == MenuType.EQUIPMENT
                                          ? equipmentNotifier.equipmentState ==
                                                  EquipmentState
                                                      .FETCHING_EQUIPMENT
                                              ? JumpingDotsProgressIndicator(
                                                  fontSize: 20.0,
                                                  color: color_palette["background_color"],
                                                )
                                              : equipmentNotifier
                                                          .equipmentState ==
                                                      EquipmentState
                                                          .EQUIPMENT_NOT_FOUND
                                                  ? AutoSizeText(en_messages["no_equipment_found"],maxLines: 1, minFontSize: 8,)
                                                  : ListView.builder(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      itemCount: equipmentNotifier
                                                          .equipmentList_found.length + 1,
                                                      itemBuilder: (BuildContext context, int index) {
                                                        return (index == equipmentNotifier.equipmentList_found.length ) ?
                                                        Container(
                                                            child: (equipmentNotifier.equipmentState != EquipmentState.EQUIPMENT_REACHED_END && equipmentNotifier.equipmentList_found.length >= 1)? MaterialButton(
                                                              onPressed: (){equipmentNotifier.filterEquipmentOnline(filter, 8);},
                                                              child: Icon(Icons.add,size: 19.875,),
                                                            ) : null
                                                        )
                                                            : renderEquipment(equipmentNotifier.equipmentList_found[index]);
                                                      },

                                                    )
                                          : [],
                                ),
                                AutoSizeText(
                                  en_messages["item_recently_used"],
                                  maxLines: 1,
                                  minFontSize: 8,
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 15.9.h),
                                ),
                                Container(
                                  height: 116.6.h,
                                  child: ListView(

                                    scrollDirection: Axis.horizontal,
                                    children: searchMode == MenuType.INGREDIENTS
                                        ? Provider.of<IngredientNotifier>(
                                                context)
                                            .filterIngredientListRecentlyUsed(
                                                filter)
                                            .map((Ingredient ingredient) {
                                            return renderIngredient(ingredient);
                                          }).toList()
                                        : searchMode == MenuType.EQUIPMENT
                                            ? Provider.of<EquipmentNotifier>(
                                                    context)
                                                .filterEquipmentListRecentlyUsed(
                                                    filter)
                                                .map((Equipment equipment) {
                                                print(equipment.name);
                                                return renderEquipment(
                                                    equipment);
                                              }).toList()
                                            : [],
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  height: 16.h,
                                  padding: EdgeInsets.only(bottom: 2),
                                  alignment: AlignmentDirectional.center,
                                  child: AutoSizeText(
                                    en_messages["item_not_found"],
                                    minFontSize: 8,
                                    maxLines: 1,
                                    style: TextStyle(
                                        fontSize: 10.6.h, color: Colors.grey[400]),
                                  ),
                                ),

                                GestureDetector(
                                    onTap: () async {
                                      if (searchMode == MenuType.INGREDIENTS) {
                                        Map<String, dynamic> out =
                                            await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        IngredientBuilder(inShopping: widget.inShopping,)));
                                        if (out != null &&
                                            out["create"] == true) {
                                          this.clearContent();
                                        }
                                      } else if (searchMode ==
                                          MenuType.EQUIPMENT) {
                                        Map<String, dynamic> out =
                                            await Navigator.of(context).push(
                                                HeroDialogRoute(
                                                    builder: (context) {
                                          return EquipmentPopup(inShopping: widget.inShopping,);
                                        }));
                                        if (out != null &&
                                            out["create"] == true) {
                                          this.clearContent();
                                        }
                                      }
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      height: 40.h,
                                      margin: EdgeInsets.only(bottom: min(MediaQuery.of(context).padding.bottom+5,10.0)),
                                      alignment: AlignmentDirectional.center,
                                      decoration: BoxDecoration(
                                          color: color_palette["background_color"],
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: AutoSizeText(
                                        "Build ${widget.title}",
                                        minFontSize: 8,
                                        maxLines: 1,
                                        style: TextStyle(
                                            fontSize: 26.5.h,
                                            color:  color_palette["white"],
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )),
                              ],
                            ))
                  ],
                )),
              )
            ],
          ),
        ));
  }

  Widget renderEquipment(Equipment equipment) {
    return GestureDetector(
        onTap: () async {
          Map<String, dynamic> out = await Navigator.of(context)
              .push(HeroDialogRoute(builder: (context) {
            return EquipmentPopup(
              equipment: equipment,
              inShopping: widget.inShopping,
            );
          }));
          if (out != null && out["use"] == true) {
            if(!widget.inShopping)
               this.clearContent();
            else
              Navigator.pop(context,{"equipment" : out["equipment"]});
          }
        },
        child: Container(
          alignment: AlignmentDirectional.center,
          margin: EdgeInsets.only(top: 10, right: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: 53.h,
                  height: 53.h,
                  decoration: BoxDecoration(
                      color: color_palette["text_color_alt"],
                      borderRadius: BorderRadius.all(
                        Radius.circular(100),
                      ),
                      border: Border.all(
                        width: 1,
                        color: color_palette["text_color_alt"],
                        style: BorderStyle.solid,
                      ),
                      image: (equipment == null ||
                          equipment.equipmentImageFromDb == null ||
                          equipment.equipmentImageFromDb.length <= 0)
                          ? DecorationImage(
                          image: AssetImage("assets/images/BMRLogo.png"),
                          fit: BoxFit.fill)
                          : DecorationImage(
                          image:
                          NetworkImage(equipment.equipmentImageFromDb),
                          fit: BoxFit.fill))),
              AutoSizeText(
                "${equipment.name}",
                minFontSize: 8,
                maxLines: 1,
                style: TextStyle(fontSize: 18.55.h, color: color_palette["background_color"]),
              ),
              AutoSizeText(
                "⚡ "+Conversion.nFormatter(equipment.usedIn, 1),
                minFontSize: 8,
                maxLines: 1,
                style: TextStyle(fontSize: 10.6.h, color:color_palette["text_color_alt"]),
              )
            ],
          ),
        ));
  }

  Widget renderIngredient(Ingredient ingredient) {
    return GestureDetector(
        onTap: () async {
          Map<String,dynamic> out = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => IngredientBuilder(
                    ingredient: ingredient,
                    shouldBuild: false,
                    inShopping: widget.inShopping,

                  )));
          if(out != null && out["inUse"] == true){
            if(!widget.inShopping)
            this.clearContent();
            else{
              Navigator.pop(context,{"ingredient" : out["ingredient"]});
            }
          }
        },
        child: Container(
          alignment: AlignmentDirectional.center,
          margin: EdgeInsets.only(top: 10, right: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: 53.h,
                  height: 53.h,
                  decoration: BoxDecoration(
                      color: color_palette["text_color_alt"],
                      borderRadius: BorderRadius.all(
                        Radius.circular(100),
                      ),
                      image: (ingredient == null ||
                          ingredient.ingredientImageFromDB == null ||
                          ingredient.ingredientImageFromDB.length <= 0)
                          ? DecorationImage(
                          image: AssetImage("assets/images/BMRLogo.png"),
                          fit: BoxFit.fill)
                          : DecorationImage(
                          image: NetworkImage(
                            ingredient.ingredientImageFromDB,
                          ),
                          fit: BoxFit.fill))),
              AutoSizeText(
                "${ingredient.ingredientName}",
                maxLines: 1,
                style: TextStyle(fontSize: 18.55.h, color: color_palette["background_color"]),
                minFontSize: 8,
              ),
              AutoSizeText(
                "⚡ "+Conversion.nFormatter(ingredient.usedIn, 1),
                maxLines: 1,
                style: TextStyle(fontSize: 10.6.h, color: color_palette["text_color_alt"]),
                minFontSize: 8,
              )
            ],
          ),
        ));
  }
  void clearContent() {
    Navigator.pop(context);
  }
  void searchCallback(String str) {
    filter = str;
    setState(() {});
    if (_timer != null) _timer.cancel();
    if(filter.length > 0){
      _timer = new Timer(const Duration(milliseconds: 500), () {
        MenuType menu =
            Provider.of<SearchNotifier>(context, listen: false).searchMode;
        if (menu == MenuType.INGREDIENTS) {
          Provider.of<IngredientNotifier>(context, listen: false).state =
              IngredientState.FETCHING_INGREDIENTS;
          Provider.of<IngredientNotifier>(context, listen: false)
              .filterIngredientsOnline(str, 8, isRestart: true);
        } else if (menu == MenuType.EQUIPMENT) {
          Provider.of<EquipmentNotifier>(context, listen: false).state =
              EquipmentState.FETCHING_EQUIPMENT;
          Provider.of<EquipmentNotifier>(context, listen: false).filterEquipmentOnline(str, 8, isRestart: true);
        }
      });
    }

  }

}
