import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mybmr/models/AppUser.dart';
import 'package:mybmr/notifiers/IngredientNotifier.dart';
import 'package:mybmr/constants/messages/en_messages.dart';
import 'package:mybmr/services/conversion.dart';
import 'package:mybmr/services/hero_dialog_route.dart';
import 'package:mybmr/services/toast.dart';
import 'package:mybmr/constants/Constants.dart';
import 'package:mybmr/models/Ingredient.dart';
import 'package:mybmr/models/Nutrition.dart';
import 'package:mybmr/views/creationMenus/popups/RuleConfirmation.dart';
import 'package:mybmr/views/creationMenus/popups/nutritionPopup.dart';
import 'package:mybmr/widgets/ExpandedSection.dart';
import 'package:provider/provider.dart';

import '../../../constants/Themes.dart';


class IngredientBuilder extends StatefulWidget {
  final Ingredient ingredient;
  final bool shouldBuild;
  final bool inShopping;

  const IngredientBuilder(
      {Key key,
      this.ingredient,
      this.shouldBuild = true,
      this.inShopping = false})
      : super(key: key);
  @override
  _IngredientBuilderState createState() => _IngredientBuilderState();
}

class _IngredientBuilderState extends State<IngredientBuilder> {
  bool _expandEnergy = false;
  bool _expandVitamins = false;
  bool _expandMinerals = false;
  Nutrition _nutritionInfo = Nutrition();
  final ImagePicker _picker = ImagePicker();
  TextEditingController _controller;
  File imageFile;
  String onlineImagePath;
  @override
  void initState() {
    _controller = TextEditingController();
    if (widget.ingredient != null) {
      _controller.text = widget.ingredient.ingredientName;
      _nutritionInfo = widget.ingredient.nutritionData;
      if (widget.ingredient.ingredientImage != null)
        imageFile = widget.ingredient.ingredientImage;
      if (widget.ingredient.ingredientImageFromDB != null)
        onlineImagePath = widget.ingredient.ingredientImageFromDB;
    }
    super.initState();
  }

  Future<void> createIngredient(Ingredient ingredient) async {
    if(!AppUser.instance.isUserSignedIn()){
      CustomToast(en_messages["sign_in_required"]);
    }
    else if (ingredient != null) {
      Map<String, dynamic> out =
          await Navigator.of(context).push(HeroDialogRoute(builder: (context) {
        return RuleConfirmationPopup();
      }));
      if (out != null && out["confirmed"] == true) {
        Provider.of<IngredientNotifier>(context, listen: false)
            .createIngredient(ingredient);
        Navigator.pop(context, {"create": true});
      }
    }
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
      resizeToAvoidBottomInset: false,
      backgroundColor: color_palette["background_color"],
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor:  color_palette["background_color"],
        ),
        backgroundColor:  color_palette["background_color"],
        title: Text( widget.shouldBuild
            ? "Ingredient Builder"
            : "Ingredient Selector",style: TextStyle(
            fontSize: 34.45.h,
            color: Colors.white,
            fontWeight: FontWeight.bold
        ),),

        actions: [
          IconButton(
            icon: Icon( widget.shouldBuild? MaterialIcons.send : MaterialIcons.check),
            onPressed: ()
            {
            if (widget.shouldBuild) {
            String title = _controller.value.text;
            title = title.trim();
            title = title.replaceAll(RegExp('\\s+'), " ");
            if (title.length > 0 && _nutritionInfo.servingSize > 0.0) {
            Ingredient ingredient;
            if (imageFile != null) {
            ingredient = new Ingredient(
            ingredientName: title,
            nutritionData: _nutritionInfo,
            ingredientImage: imageFile);
            createIngredient(ingredient);
            } else {
            CustomToast(en_messages["ingredient_missing_image"]);
            }
            } else {
            if (title.length == 0)
            CustomToast(en_messages["ingredient_missing_title"]);
            else if (_nutritionInfo.servingSize <= 0.0)
            CustomToast(
            en_messages["ingredient_invalid_serving_size"]);
            }
            } else {
            if (!widget.inShopping) {
            Provider.of<IngredientNotifier>(context, listen: false)
                .addIngredientToRecipe(widget.ingredient);
            Navigator.pop(context, {"inUse": true});
            } else {
            Navigator.pop(context,
            {"inUse": true, "ingredient": widget.ingredient});
            }
            }


            },
          ),
        ],
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,

        child: Container(
            decoration: BoxDecoration(
              color: color_palette["tone"],
            ),
            child:Column(
          children: [

            Expanded(
              child: NotificationListener<OverscrollIndicatorNotification>(
                  onNotification: (overscroll) {
                    overscroll.disallowIndicator();
                    return;
                  },
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(15, 10, 15, 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AutoSizeText(
                          "Title",
                          maxLines: 1,
                          style: TextStyle(
                              color: color_palette["white"],
                              fontSize: 26.5.h,
                              fontWeight: FontWeight.bold),
                        ),
                        Container(
                            margin: EdgeInsets.only(top: 10),

                            child: TextField(
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(50),
                              ],
                              style: TextStyle(
                                  color: color_palette["white"], fontSize: 30.h,height:1.5),
                              controller: _controller,
                              enabled: widget.shouldBuild,
                              onChanged: (str){
                                setState(() {
                                });
                              },
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(vertical: 30.h/2,horizontal: 15.h),
                                  isDense: true,
                                  filled: true,
                                  fillColor: Colors.black54,
                                  hintText: "Ingredient name",
                                  hintStyle: TextStyle(
                                    color: color_palette["offWhite"],
                                  ),
                                  suffixIcon: _controller.value.text.length > 0 && widget.shouldBuild == true? IconButton(
                                    onPressed: (){
                                      _controller.clear();
                                      setState(() {

                                      });
                                    },
                                    icon: Icon(Icons.clear,color: color_palette["white"],size: 23.85.h,),
                                  ) : null,
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),

                                      borderSide: BorderSide(
                                          color: color_palette["white"])),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),

                                      borderSide: BorderSide(
                                          color: color_palette["white"]))),
                            )),
                        GestureDetector(
                          onTap: () async {
                            if (widget.shouldBuild) {
                              print("Request for image");
                              XFile pickedFile = await _picker.pickImage(
                                  source: ImageSource.gallery,
                                  maxHeight: 1024,
                                  maxWidth: 1024);
                              if (pickedFile != null) {
                                imageFile = File(pickedFile.path);
                                setState(() {});
                              }
                            }
                          },
                          child: Container(
                            margin: EdgeInsets.only(top: 20, bottom: 20),
                            height: 150.h,
                            decoration: BoxDecoration(
                                color: Colors.black38,
                                border:
                                    Border.all(color: color_palette["white"]),
                                borderRadius: BorderRadius.circular(8)),
                            child: imageFile != null
                                ? Image.file(
                                    imageFile,
                                    fit: BoxFit.cover,
                                  )
                                : (onlineImagePath == null ||
                                        onlineImagePath.length <= 0)
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                            Icon(
                                              Icons.add_a_photo,
                                              size: 48.h,
                                              color: color_palette["white"],
                                            ),
                                            Container(
                                              height: 2,
                                            ),
                                            AutoSizeText(
                                              "Add a photo",
                                              maxLines: 1,
                                              style: TextStyle(
                                                  color: color_palette["white"],
                                                  fontSize: 23.85.h),
                                            )
                                          ])
                                    : Image.network(onlineImagePath,
                                        fit: BoxFit.cover),
                          ),
                        ),
                        Container(
                          height: 20,
                        ),
                        AutoSizeText(
                          "Nutrition Facts",
                          maxLines: 1,
                          style: TextStyle(color: color_palette["white"], fontSize: 26.5.h),
                        ),
                        Divider(
                          color: color_palette["white"],
                        ),
                        Column(children: [
                          GestureDetector(
                              onTap: () {
                                setState(() {
                                  _expandEnergy = !_expandEnergy;
                                });
                              },
                              child: Container(
                                  constraints: BoxConstraints(minHeight: 30),
                                  color: Colors.transparent,
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        AutoSizeText(
                                          "Energy",
                                          maxLines: 1,
                                          style: TextStyle(
                                              color: color_palette["white"],
                                              fontSize: 26.25.h),
                                        ),
                                        Icon(
                                          !_expandEnergy
                                              ? FontAwesomeIcons.caretDown
                                              : FontAwesomeIcons.minus,
                                          color: color_palette["white"],
                                          size: 26.25.h,
                                        )
                                      ]))),
                          ExpandedSection(
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 15),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: mapEnergy(),
                              ),
                            ),
                            expand: _expandEnergy,
                          )
                        ]),
                        Column(mainAxisSize: MainAxisSize.min, children: [
                          GestureDetector(
                              onTap: () {
                                setState(() {
                                  _expandVitamins = !_expandVitamins;
                                });
                              },
                              child: Container(
                                  constraints: BoxConstraints(minHeight: 30),
                                  color: Colors.transparent,
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        AutoSizeText("Vitamins",
                                            maxLines: 1,
                                            style: TextStyle(
                                                color: color_palette["white"],
                                                fontSize:  26.25.h)),
                                        Icon(
                                          !_expandVitamins
                                              ? FontAwesomeIcons.caretDown
                                              : FontAwesomeIcons.minus,
                                          color:color_palette["white"],
                                          size: 26.25.h,
                                        )
                                      ]))),
                          ExpandedSection(
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 15),
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: mapVitamins()),
                            ),
                            expand: _expandVitamins,
                          )
                        ]),
                        Column(mainAxisSize: MainAxisSize.min, children: [
                          GestureDetector(
                              onTap: () {
                                setState(() {
                                  _expandMinerals = !_expandMinerals;
                                });
                              },
                              child: Container(
                                  constraints: BoxConstraints(minHeight: 30),
                                  color: Colors.transparent,
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        AutoSizeText("Minerals",
                                            maxLines: 1,
                                            style: TextStyle(
                                                color: color_palette["white"],
                                                fontSize:  26.25.h)),
                                        Icon(
                                          !_expandMinerals
                                              ? FontAwesomeIcons.caretDown
                                              : FontAwesomeIcons.minus,
                                          color: color_palette["white"],
                                          size: 26.25.h,
                                        )
                                      ]))),
                          ExpandedSection(
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 15),
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: mapMinerals()),
                            ),
                            expand: _expandMinerals,
                          )
                        ]),
                      ],
                    ),
                  )),
            )
          ],
        )),
      ),
    );
  }

  List<Widget> mapEnergy() {
    List<String> energy = NUTRITION_LABELS.sublist(0, 8);
    List<Widget> children = [];
    List<String> uom = _nutritionInfo.uom.sublist(0, 8);
    energy.asMap().forEach((index, label) {
      double energyVal = _nutritionInfo.fetchValueByName(label);
      String measure = uom[index];
      List<bool> supportedNutritionTypes = Conversion.getValidPopupState(label);
      String labelTitle = "- $label";
      if (["Fiber", "Sugars"].contains(label)) {
        labelTitle = "   - $label";
      }
      Widget element = Padding(
          padding: EdgeInsets.symmetric(vertical: 2.5),
          child: Row(
            children: [
              Text(
                labelTitle,
                style: TextStyle(color: color_palette["white"], fontSize: 23.85.h),
              ),
              Container(
                width: 12,
              ),
              AutoSizeText(
                "$energyVal$measure",
                maxLines: 1,
                style: TextStyle(color: Colors.greenAccent, fontSize: 23.85.h),
              ),
              Container(
                width: 12,
              ),
              if (label != "Calories" && widget.shouldBuild)
                GestureDetector(
                  onTap: () async {
                    String uomLong = converUOM2Long(measure);
                    Map<String, dynamic> out = await Navigator.of(context)
                        .push(HeroDialogRoute(builder: (context) {
                      return NutritionPopup(
                        fieldName: label,
                        val: energyVal,
                        uom: uomLong,
                        validDataTypes: supportedNutritionTypes,
                      );
                    }));

                    if (out != null) {
                      _nutritionInfo.uom[index] =
                          convertUOMLong2Short(out["uom"]);
                      _nutritionInfo.setValueByLabel(label, out["value"]);
                      if (label == "Protein" ||
                          label == "Carbohydrates" ||
                          label == "Fat" ||
                          label == "Fiber") {
                        double carbs = Conversion.weight2Grams(
                            _nutritionInfo.carbohydrates,
                            _nutritionInfo.uom[2]);
                        double fat = Conversion.weight2Grams(
                            _nutritionInfo.fat, _nutritionInfo.uom[6]);
                        double protein = Conversion.weight2Grams(
                            _nutritionInfo.protein, _nutritionInfo.uom[5]);
                        double fiber = Conversion.weight2Grams(
                            _nutritionInfo.fiber, _nutritionInfo.uom[3]);
                        carbs -= fiber;
                        _nutritionInfo.calories =
                            carbs * 4 + protein * 4 + fat * 9 + fiber * 1.5;
                      }
                      setState(() {});
                    }
                  },
                  child: Icon(
                    Icons.edit,
                    size:  23.85.h,
                    color: color_palette["white"],
                  ),
                )
            ],
          ));
      children.add(element);
    });
    return children;
  }

  List<Widget> mapVitamins() {
    List<String> vitamins = NUTRITION_LABELS.sublist(8, 20);
    List<String> uom = _nutritionInfo.uom.sublist(8, 20);
    List<Widget> children = [];

    vitamins.asMap().forEach((index, label) {
      double energyVal = _nutritionInfo.fetchValueByName(label);
      List<bool> supportedNutritionTypes = Conversion.getValidPopupState(label);
      String measure = uom[index];
      Widget element = Padding(
          padding: EdgeInsets.symmetric(vertical: 2.5),
          child: Row(
            children: [
              AutoSizeText(
                "- $label",
                maxLines: 1,
                style: TextStyle(color: color_palette["white"], fontSize: 23.85.h),
              ),
              Container(
                width: 12,
              ),
              AutoSizeText(
                "$energyVal$measure",
                maxLines: 1,
                style: TextStyle(color: Colors.greenAccent, fontSize: 23.85.h),
              ),
              Container(
                width: 12,
              ),
              widget.shouldBuild
                  ? GestureDetector(
                      onTap: () async {
                        String uomLong = converUOM2Long(measure);
                        Map<String, dynamic> out = await Navigator.of(context)
                            .push(HeroDialogRoute(builder: (context) {
                          return NutritionPopup(
                            fieldName: label,
                            val: energyVal,
                            uom: uomLong,
                            validDataTypes: supportedNutritionTypes,
                            supportsRDI: true,
                          );
                        }));

                        if (out != null) {
                          if (out["uom"] == "% DVI") {
                            double rdiPercentAsDec = num.parse(
                                (out["value"] / 100.0).toStringAsFixed(3));
                            rdiTuple tuple = dailyIntakeRDI[label];
                            _nutritionInfo.uom[index + 8] = tuple.label;
                            _nutritionInfo.setValueByLabel(
                                label, tuple.value * rdiPercentAsDec);
                          } else {
                            _nutritionInfo.uom[index + 8] =
                                convertUOMLong2Short(out["uom"]);
                            _nutritionInfo.setValueByLabel(label, out["value"]);
                          }

                          setState(() {});
                        }
                      },
                      child: Icon(
                        Icons.edit,
                        size: 23.85.h,
                        color: color_palette["white"],
                      ),
                    )
                  : Container()
            ],
          ));
      children.add(element);
    });
    return children;
  }

  List<Widget> mapMinerals() {
    List<String> vitamins = NUTRITION_LABELS.sublist(20);
    List<Widget> children = [];
    List<String> uom = _nutritionInfo.uom.sublist(20);
    vitamins.asMap().forEach((index, label) {
      List<bool> supportedNutritionTypes = Conversion.getValidPopupState(label);
      double energyVal = _nutritionInfo.fetchValueByName(label);

      String measure = uom[index];

      Widget element = Padding(
          padding: EdgeInsets.symmetric(vertical: 2.5),
          child: Row(
            children: [
              AutoSizeText(
                "- $label",
                maxLines: 1,
                style: TextStyle(color: color_palette["white"], fontSize: 23.85.h),
              ),
              Container(
                width: 12,
              ),
              AutoSizeText(
                "$energyVal$measure",
                maxLines: 1,
                style: TextStyle(color: Colors.greenAccent, fontSize: 23.85.h),
              ),
              Container(
                width: 12,
              ),
              widget.shouldBuild
                  ? GestureDetector(
                      onTap: () async {
                        String uomLong = converUOM2Long(measure);
                        Map<String, dynamic> out = await Navigator.of(context)
                            .push(HeroDialogRoute(builder: (context) {
                          return NutritionPopup(
                            fieldName: label,
                            val: energyVal,
                            uom: uomLong,
                            validDataTypes: supportedNutritionTypes,
                            supportsRDI: true,
                          );
                        }));

                        if (out != null) {
                          if (out["uom"] == "% DVI") {
                            double rdiPercentAsDec = num.parse(
                                (out["value"] / 100.0).toStringAsFixed(3));
                            rdiTuple tuple = dailyIntakeRDI[label];
                            _nutritionInfo.uom[index + 20] = tuple.label;
                            _nutritionInfo.setValueByLabel(
                                label, tuple.value * rdiPercentAsDec);
                          } else {
                            _nutritionInfo.uom[index + 20] =
                                convertUOMLong2Short(out["uom"]);
                            _nutritionInfo.setValueByLabel(label, out["value"]);
                          }

                          setState(() {});
                        }
                      },
                      child: Icon(
                        Icons.edit,
                        size: 23.85.h,
                        color: color_palette["white"],
                      ),
                    )
                  : Container()
            ],
          ));
      children.add(element);
    });
    return children;
  }
}
