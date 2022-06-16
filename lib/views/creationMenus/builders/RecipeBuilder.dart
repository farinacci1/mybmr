import 'dart:io';
import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_select_flutter/bottom_sheet/multi_select_bottom_sheet.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';
import 'package:mybmr/services/helper.dart';
import 'package:mybmr/widgets/ImageCropper.dart';

import 'package:provider/provider.dart';
import 'package:mybmr/notifiers/EquipmentNotifier.dart';
import 'package:mybmr/notifiers/FavoritesNotifier.dart';
import 'package:mybmr/notifiers/IngredientNotifier.dart';
import 'package:mybmr/notifiers/SearchNotifier.dart';

import 'package:mybmr/constants/Constants.dart';
import 'package:mybmr/constants/messages/en_messages.dart';
import 'package:mybmr/models/Ingredient.dart';

import 'package:mybmr/services/conversion.dart';
import 'package:mybmr/services/hero_dialog_route.dart';
import 'package:mybmr/models/Recipe.dart';
import 'package:mybmr/models/RecipeStep.dart';
import 'package:mybmr/views/creationMenus/popups/RuleConfirmation.dart';
import 'package:mybmr/views/creationMenus/popups/recipeImporter.dart';
import 'package:mybmr/widgets/OverlaySearch.dart';
import 'package:mybmr/views/creationMenus/popups/RecipeTime.dart';
import 'package:mybmr/views/creationMenus/popups/stepPopup.dart';
import 'package:mybmr/widgets/SelectedEquipment.dart';
import 'package:mybmr/widgets/SelectedIngredients.dart';
import 'package:mybmr/widgets/illusionTextfield.dart';
import 'package:mybmr/widgets/showSteps.dart';

import '../../../constants/Themes.dart';
import '../../../models/Equipment.dart';
import '../../../services/toast.dart';


class RecipeBuilder extends StatefulWidget {
  final Recipe recipe;
  final bool shouldClone;
  const RecipeBuilder({Key key, this.recipe, this.shouldClone = false})
      : super(key: key);
  @override
  _RecipeBuilderState createState() => _RecipeBuilderState();
}

class _RecipeBuilderState extends State<RecipeBuilder> {
  ImagePicker _picker;
  TextEditingController _titleController;
  TextEditingController _servesController;
  TextEditingController _descriptionController;
  String imageFromDb;
  File imageFile;
  List<String> activeMeals = [];
  List<String> activeDiets = [];
  List<RecipeStep> steps = [];

  List<String> invalidIngredients = [];

  String totalTime = "0 Days 0 Hours 0 Minutes";



  @override
  void initState() {
    _picker = ImagePicker();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _servesController = TextEditingController();
    _servesController.text = (0).toString();

    recipeProvided();
    super.initState();
  }

  void clearRecipe() {
    _titleController.clear();
    _descriptionController.clear();
    _servesController.text = (0).toString();
    resetIllusion();
    totalTime = "0 Days 0 Hours 0 Minutes";
    steps.clear();
    imageFromDb = null;
    imageFile = null;
    activeMeals.clear();
    activeDiets.clear();
    invalidIngredients.clear();
    Provider.of<IngredientNotifier>(context, listen: false)
        .ingredientList_inUse
        .clear();
    Provider.of<EquipmentNotifier>(context, listen: false)
        .equipmentList_inUse
        .clear();
    setState(() {});
  }



  @override
  Widget build(BuildContext context) {
    Provider.of<EquipmentNotifier>(context, listen: true);
    Provider.of<IngredientNotifier>(context, listen: true);
    ScreenUtil.init(
        BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width,
            maxHeight: MediaQuery.of(context).size.height),
        designSize: Size(2400, 1080),
        context: context,
        minTextAdapt: true,
        orientation: Orientation.portrait);
    return WillPopScope(
        onWillPop: () async {
          clearRecipe();

          return true;
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
         systemOverlayStyle: SystemUiOverlayStyle(
           statusBarColor:  color_palette["background_color"],
         ),
            backgroundColor:  color_palette["background_color"],
            title: Text( en_messages["recipe_builder"],style: TextStyle(
                fontSize: 34.45.h,
                color: Colors.white,
                fontWeight: FontWeight.bold
            ),),

            actions: [
              IconButton(
                  icon: Icon(MaterialIcons.send),
                onPressed: ()
                {
                  String title = _titleController.value.text ?? "";
                  title = title.trim();
                  title = title.replaceAll(RegExp('\\s+'), " ");
                  String description =
                      _descriptionController.value.text ?? "";
                  description = description.trim();
                  description = description.replaceAll(RegExp('\\s+'), " ");

                  if (title.length == 0 ||
                      description.length == 0 ||
                      Provider.of<IngredientNotifier>(context, listen: false)
                          .ingredientList_inUse
                          .length ==
                          0 ||
                      Provider.of<EquipmentNotifier>(context, listen: false)
                          .equipmentList_inUse
                          .length ==
                          0 ||
                      activeMeals.length == 0 ||
                      activeDiets.length == 0 ||
                      steps.length == 0 ||
                      _servesController.value.text.length == 0) {
                    CustomToast(en_messages["recipe_empty_fields_found"]);
                  } else if (activeMeals.length > 3) {
                    CustomToast(en_messages["recipe_max_cuisine"]);
                  } else if (activeDiets.length > 6) {
                    CustomToast(en_messages["recipe_max_diets"]);
                  } else {
                    Recipe recipe;
                    List<String> instructions =
                    steps.map((RecipeStep step) => step.string).toList();
                    if (imageFile != null || imageFromDb != null) {
                      double servings =
                      double.parse(_servesController.value.text);
                      if (servings <= 0)
                        CustomToast(
                            en_messages["recipe_invalid_serving_size"]);
                      else {
                        if (invalidIngredients.length > 0) {
                          CustomToast(
                              en_messages["recipe_invalid_ingredients"]);
                        } else {
                          recipe = Recipe(
                              title: title,
                              description: description,
                              recipeImage: imageFile,
                              recipeIngredients: List.from(
                                  Provider.of<IngredientNotifier>(context,
                                      listen: false)
                                      .recipeIngredients),
                              neededEquipmentIds: List.from(
                                  Provider.of<EquipmentNotifier>(context,
                                      listen: false)
                                      .equipmentList_inUse
                                      .map((Equipment equip) => equip.id)
                                      .toList()),
                              prepTime: totalTime,
                              peopleServed: servings,
                              steps: instructions,
                              neededDiets: List.from(activeDiets),
                              mealTimes: List.from(activeMeals));
                          if (widget.recipe == null ||
                              widget.shouldClone == true)
                            createRecipe(recipe);
                          else
                            updateRecipe(recipe);
                        }
                      }
                    } else
                      CustomToast(en_messages["recipe_missing_image"]);
                  }
                },
              ),
            ],
          ),
          body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color:  color_palette["background_color"],
            child: Column(
              children: [


                Expanded(
                    child: Container(
                        color:  color_palette["semi_transparent"],
                        child: NotificationListener<
                                OverscrollIndicatorNotification>(
                            onNotification: (overscroll) {
                              overscroll.disallowIndicator();
                              return;
                            },
                            child: SingleChildScrollView(
                                padding: EdgeInsets.fromLTRB(15, 10, 15, 0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          en_messages["title_label"],
                                          textScaleFactor: 1.0,
                                          style: TextStyle(
                                              color: color_palette["white"],
                                              fontSize: max(23.85.h, 18),
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Spacer(),
                                        Container(
                                          height: 26.5.h,
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              Map<String, dynamic> out =
                                                  await Navigator.of(context)
                                                      .push(HeroDialogRoute(

                                                          builder: (context) {
                                                return RecipeImporter();
                                              }));
                                              if (out != null) {
                                                setFromImported(out);
                                              }
                                              SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
                                                  statusBarColor: Colors.transparent
                                                 ));
                                            },
                                            child: Text(
                                              en_messages["import_label"],
                                              textScaleFactor: 1.0,

                                            ),
                                            style: ElevatedButton.styleFrom(
                                                primary: color_palette[
                                                    "text_color_dark"],
                                                onPrimary:
                                                    color_palette["white"],
                                                elevation: 20,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          18.0),
                                                ),
                                                textStyle: TextStyle(
                                                    fontSize: 18.55.h)),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                        margin: EdgeInsets.only(top: 10),

                                        alignment: AlignmentDirectional.center,
                                        child: TextField(
                                          inputFormatters: [
                                            LengthLimitingTextInputFormatter(
                                                50),
                                          ],

                                          textInputAction: TextInputAction.done,
                                            style: TextStyle(
                                                color: color_palette["white"], fontSize: 28.h,height:1.5),
                                          controller: _titleController,

                                            decoration: InputDecoration(
                                                contentPadding: EdgeInsets.symmetric(vertical: 30.h/2,horizontal: 15.h),

                                                isDense: true,
                                                filled: true,
                                                fillColor: Colors.black54,
                                                hintText: "Add A Title...",
                                                hintStyle: TextStyle(
                                                  color: color_palette["offWhite"],
                                                ),
                                                enabledBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                    borderSide: BorderSide(
                                                        color: color_palette["white"])),
                                                focusedBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                    borderSide: BorderSide(
                                                        color: color_palette["white"])))
                                        )),
                                    GestureDetector(
                                      onTap: () async {
                                        try {
                                          XFile pickedFile =
                                              await _picker.pickImage(
                                                  source: ImageSource.gallery,
                                                  maxHeight: 1024,
                                                  maxWidth: 1024);
                                          if (pickedFile != null) {
                                            imageFile = await MyImageCropper.cropImage(File(pickedFile.path));

                                            setState(() {});
                                          }
                                        } catch (_) {}
                                      },
                                      child: Container(
                                          margin: EdgeInsets.only(
                                              top: 20, bottom: 20),
                                          height: 150.h,
                                          decoration: BoxDecoration(
                                              color: Colors.black38,
                                              border: Border.all(
                                                  color:
                                                      color_palette["white"]),
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          child: imageFile != null
                                              ? Image.file(
                                                  imageFile,
                                                  fit: BoxFit.cover,
                                                )
                                              : imageFromDb != null
                                                  ? Image.network(imageFromDb,
                                                      fit: BoxFit.cover)
                                                  : Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                          Icon(
                                                            Icons.add_a_photo,
                                                            size: 47.5.h,
                                                            color:
                                                                color_palette[
                                                                    "white"],
                                                          ),
                                                          Container(
                                                            height: 2,
                                                          ),
                                                          Text(
                                                            en_messages[
                                                                "photo_label"],
                                                            style: TextStyle(
                                                                color:
                                                                    color_palette[
                                                                        "white"],
                                                                fontSize:
                                                                    17.225.h),
                                                          )
                                                        ])),
                                    ),
                                    Text(
                                      en_messages["description_label"],
                                      textScaleFactor: 1.0,
                                      style: TextStyle(
                                          color: color_palette["white"],
                                          fontSize: max(23.85.h, 18),
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Container(
                                        height: 120.h,
                                        decoration: BoxDecoration(
                                            color: Colors.black54,
                                            border: Border.all(
                                                color: color_palette["white"]),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        margin: EdgeInsets.only(
                                            top: 10, bottom: 10),
                                        child: TextField(
                                          controller: _descriptionController,
                                          inputFormatters: [
                                            LengthLimitingTextInputFormatter(
                                                128),
                                          ],
                                          textInputAction: TextInputAction.done,
                                          style: TextStyle(
                                              height: 1.0,
                                              fontSize: max(21.2.h, 16),
                                              color: color_palette["white"]),
                                          maxLength: null,
                                          maxLines: null,
                                          expands: true,
                                          keyboardType: TextInputType.multiline,
                                          textAlign: TextAlign.start,
                                          decoration: InputDecoration(
                                            contentPadding:
                                                const EdgeInsets.all(8.0),
                                            border: InputBorder.none,
                                            hintText:
                                                "Please enter a brief introduction of recipe...",
                                            hintStyle: TextStyle(
                                                fontSize: 23.85.h,
                                                color: color_palette["offWhite"]),
                                          ),
                                        )),
                                    Text(
                                      en_messages["total_time_label"],
                                      textScaleFactor: 1.0,
                                      style: TextStyle(
                                          color: color_palette["white"],
                                          fontSize: max(23.85.h, 18),
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Container(
                                      margin: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 10),
                                      child: Row(
                                        children: [
                                          Text(
                                            totalTime,
                                            textScaleFactor: 1.0,
                                            style: TextStyle(
                                                color: color_palette["neutral"],
                                                fontSize: max(23.85.h, 18)),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(left: 10),
                                          ),
                                          GestureDetector(
                                            onTap: () async {
                                              Map<String, dynamic> out =
                                                  await Navigator.of(context)
                                                      .push(HeroDialogRoute(
                                                          builder: (context) {
                                                return RecipeTime();
                                              }));
                                              if (out != null &&
                                                  out["hasResult"] == true) {
                                                totalTime = out["result"];
                                                setState(() {});
                                              }
                                            },
                                            child: Icon(Icons.edit,
                                                size: max(23.85.h, 18),
                                                color: color_palette[
                                                    "white"]),
                                          )
                                        ],
                                      ),
                                    ),
                                    Text(
                                      en_messages["num_serv_label"],
                                      textScaleFactor: 1.0,
                                      style: TextStyle(
                                          color: color_palette["white"],
                                          fontSize: max(23.85.h, 18),
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Container(
                                        margin: EdgeInsets.only(
                                            top: 10, bottom: 10),
                                        alignment: AlignmentDirectional.center,

                                        child: TextField(
                                          keyboardType: TextInputType.number,
                                          textInputAction: TextInputAction.done,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r"[0-9.]")),
                                            TextInputFormatter.withFunction(
                                                (oldValue, newValue) {
                                              try {
                                                final text = newValue.text;
                                                if (text.isNotEmpty)
                                                  double.parse(text);
                                                return newValue;
                                              } catch (e) {}
                                              return oldValue;
                                            }),
                                            LengthLimitingTextInputFormatter(
                                                10),
                                          ],

                                          controller: _servesController,
                                            style: TextStyle(
                                                color: color_palette["white"], fontSize: 28.h,height:1.5),
                                            decoration: InputDecoration(
                                                contentPadding: EdgeInsets.symmetric(vertical: 30.h/2,horizontal: 15.h),

                                                isDense: true,
                                                filled: true,
                                                fillColor: Colors.black54,
                                                hintText: "0",
                                                hintStyle: TextStyle(
                                                  color: color_palette["offWhite"],
                                                ),
                                                enabledBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                    borderSide: BorderSide(
                                                        color: color_palette["white"])),
                                                focusedBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                    borderSide: BorderSide(
                                                        color: color_palette["white"])))
                                        )),
                                    Text(
                                      en_messages["ingredients_label"],
                                      textScaleFactor: 1.0,
                                      style: TextStyle(
                                          color: color_palette["white"],
                                          fontSize: max(23.85.h, 18),
                                          fontWeight: FontWeight.bold),
                                    ),
                                    IllusionTextField(
                                      width: double.infinity,
                                      height: 63.6.h,
                                      onTap: () async {
                                        resetIllusion();
                                        Provider.of<SearchNotifier>(context,
                                                listen: false)
                                            .searchMode = MenuType.INGREDIENTS;
                                        await Navigator.of(context).push(
                                            HeroDialogRoute(builder: (context) {
                                          return OverlaySearch(
                                            title: "Ingredient",
                                          );
                                        }));
                                      },
                                    ),
                                    invalidIngredients.length > 0
                                        ? showImportedIngredients()
                                        : Container(),
                                    if (Provider.of<IngredientNotifier>(context,
                                                listen: false)
                                            .ingredientList_inUse
                                            .length >
                                        0)
                                      SelectedIngredient(),
                                    Text(
                                      "Equipment",
                                      textScaleFactor: 1.0,
                                      style: TextStyle(
                                          color: color_palette["white"],
                                          fontSize: max(23.85.h, 18),
                                          fontWeight: FontWeight.bold),
                                    ),
                                    IllusionTextField(
                                      hiddenText: "<Select Equipment>",
                                      width: double.infinity,
                                      height: 63.6.h,
                                      onTap: () async {
                                        resetIllusion();
                                        Provider.of<SearchNotifier>(context,
                                                listen: false)
                                            .searchMode = MenuType.EQUIPMENT;
                                        await Navigator.of(context).push(
                                            HeroDialogRoute(builder: (context) {
                                          return OverlaySearch(
                                            title: "Equipment",
                                          );
                                        }));
                                      },
                                    ),
                                    if (Provider.of<EquipmentNotifier>(context,
                                                listen: false)
                                            .equipmentList_inUse
                                            .length >
                                        0)
                                      SelectedEquipment(),
                                    Text(
                                      en_messages["diets_label"],
                                      textScaleFactor: 1.0,
                                      style: TextStyle(
                                          color: color_palette["white"],
                                          fontSize: max(23.85.h, 18),
                                          fontWeight: FontWeight.bold),
                                    ),
                                    IllusionTextField(
                                      hiddenText: "<Select Diets>",
                                      width: double.infinity,
                                      height: 63.6.h,
                                      onTap: () async {
                                        _showDietPicker(context);
                                      },
                                    ),
                                    if (activeDiets.length > 0)
                                      Container(
                                        margin: EdgeInsets.only(bottom: 10),
                                        height: 20,
                                        child: ListView(
                                          scrollDirection: Axis.horizontal,
                                          children: activeDiets.map((diet) {
                                            return GestureDetector(
                                                onTap: () {
                                                  activeDiets.remove(diet);
                                                  setState(() {});
                                                },
                                                child: Container(
                                                  margin: EdgeInsets.only(
                                                      right: 10),
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 8),
                                                  alignment:
                                                      AlignmentDirectional
                                                          .center,
                                                  decoration: BoxDecoration(
                                                      color: color_palette[
                                                          "neutral"],
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  20))),
                                                  child: AutoSizeText(
                                                    diet,
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                        color: color_palette[
                                                            "text_color_dark"],
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ));
                                          }).toList(),
                                        ),
                                      ),
                                    Text(
                                      en_messages["cuisine_label"],
                                      textScaleFactor: 1.0,
                                      style: TextStyle(
                                          color: color_palette["white"],
                                          fontSize: max(23.85.h, 18),
                                          fontWeight: FontWeight.bold),
                                    ),
                                    IllusionTextField(
                                      hiddenText: "<Select Cuisines>",
                                      width: double.infinity,
                                      height: 63.6.h,
                                      onTap: () async {
                                        _showMealPicker(context);
                                      },
                                    ),
                                    if (activeMeals.length > 0)
                                      Container(
                                        margin: EdgeInsets.only(bottom: 10),
                                        height: 20,
                                        child: ListView(
                                          scrollDirection: Axis.horizontal,
                                          children: activeMeals.map((mealtime) {
                                            return GestureDetector(
                                                onTap: () {
                                                  activeMeals.remove(mealtime);

                                                  setState(() {});
                                                },
                                                child: Container(
                                                  margin: EdgeInsets.only(
                                                      right: 10),
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 8),
                                                  alignment:
                                                      AlignmentDirectional
                                                          .center,
                                                  decoration: BoxDecoration(
                                                      color: color_palette[
                                                          "neutral"],
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  20))),
                                                  child: AutoSizeText(
                                                    mealtime,
                                                    style: TextStyle(
                                                        color: color_palette[
                                                            "text_color_dark"],
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ));
                                          }).toList(),
                                        ),
                                      ),
                                    Text(
                                      en_messages["steps_label"],
                                      textScaleFactor: 1.0,
                                      style: TextStyle(
                                          color: color_palette["white"],
                                          fontSize: max(23.85.h, 18),
                                          fontWeight: FontWeight.bold),
                                    ),
                                    if (steps.length > 0)
                                      ShowSteps(
                                        steps: steps,
                                        indexColor: color_palette["neutral"],
                                        onRemove: (RecipeStep rp) {
                                          int idx = rp.stepNum;
                                          steps.removeAt(idx);
                                          for (int iter = idx;
                                              iter < steps.length;
                                              iter++) {
                                            steps[iter].stepNum -= 1;
                                          }
                                          setState(() {});
                                        },
                                        onUpdate: (String step, int prevIdx,
                                            int currIdx) {
                                          RecipeStep rp = RecipeStep(
                                              string: step, stepNum: currIdx);
                                          if (currIdx == prevIdx)
                                            steps[currIdx] = rp;
                                          else {
                                            if (prevIdx < currIdx) {
                                              steps.insert(currIdx + 1, rp);
                                              steps.removeAt(prevIdx);
                                            } else {
                                              steps.insert(currIdx, rp);
                                              steps.removeAt(prevIdx + 1);
                                            }
                                          }
                                          for (int idx = 0;
                                              idx < steps.length;
                                              idx++) {
                                            steps[idx].stepNum = idx;
                                          }

                                          setState(() {});
                                        },
                                      ),
                                    Container(
                                      height: 47.7.h,
                                      margin:
                                      EdgeInsets.symmetric(vertical: 10),
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          Map<String, dynamic> out =
                                          await Navigator.of(context).push(
                                              HeroDialogRoute(
                                                  builder: (context) {
                                                    return StepPopup(
                                                      stepIndex: steps.length + 1,
                                                      stepRange: steps.length + 1,
                                                    );
                                                  }));
                                          if (out != null) {
                                            String step = out["step"];
                                            if (step.length > 0) {
                                              int stepNum = out["stepNum"];
                                              if (step.length > 0) {
                                                steps.insert(
                                                    stepNum - 1,
                                                    RecipeStep(
                                                        string: step,
                                                        stepNum: stepNum - 1));
                                                for (int i = stepNum;
                                                i < steps.length;
                                                i++) {
                                                  steps[i].stepNum = i + 1;
                                                }
                                              }
                                              setState(() {});
                                            }
                                          }
                                        },
                                        child: Text(
                                          en_messages["add_step_label"],
                                          textScaleFactor: 1.0,
                                          style: TextStyle(fontSize: 23.85.h),

                                        ),
                                        style: ElevatedButton.styleFrom(
                                            primary: color_palette[
                                            "text_color_dark"],
                                            onPrimary:
                                            color_palette["white"],
                                            elevation: 20,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(
                                                  18.0),
                                            ),
                                            textStyle: TextStyle(
                                                fontSize: 18.55.h)),
                                      ),
                                    ),

                                  ],
                                )))))
              ],
            ),
          ),
        ));
  }


  void recipeProvided() {
    if (widget.recipe != null) {
      Provider.of<IngredientNotifier>(context, listen: false).clear();
      Provider.of<EquipmentNotifier>(context, listen: false).clear();
      _titleController.text = widget.recipe.title;
      _servesController.text = widget.recipe.peopleServed.toString();
      _descriptionController.text = widget.recipe.description;
      activeMeals = List.from(widget.recipe.mealTimes);
      activeDiets = List.from(widget.recipe.neededDiets);
      totalTime = widget.recipe.prepTime;
      for (int idx = 0; idx < widget.recipe.steps.length; idx++) {
        RecipeStep step =
        RecipeStep(stepNum: idx, string: widget.recipe.steps[idx]);
        steps.add(step);
      }
      if (widget.shouldClone == false)
        imageFromDb = widget.recipe.recipeImageFromDB;

      Provider.of<IngredientNotifier>(context, listen: false)
          .recipeIngredients = List.from(widget.recipe.recipeIngredients);
      Provider.of<EquipmentNotifier>(context, listen: false)
          .getEquipmentList(List.from(widget.recipe.neededEquipmentIds));
    }
  }

  Widget showImportedIngredients() {
    return Dismissible(
        key: UniqueKey(),
        confirmDismiss: (DismissDirection direction) async {
          if (direction == DismissDirection.endToStart) {
            invalidIngredients.clear();
            return true;
          }
          return false;
        },
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: invalidIngredients.map((e) {
              return Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Text(
                    e,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ));
            }).toList()));
  }

  void setFromImported(Map<String, dynamic> jsonData) {
    Provider.of<IngredientNotifier>(context, listen: false).clear();
    Provider.of<EquipmentNotifier>(context, listen: false).clear();
    _servesController.text = jsonData["serving size"] == null
        ? "0.0"
        : jsonData["serving size"].toString();
    totalTime = jsonData["totalTime"] ?? "0 Days 0 Hours 0 Minutes";
    if (jsonData["steps"] != null && jsonData["steps"].length > 0) {
      for (int idx = 0; idx < jsonData["steps"].length; idx++) {
        RecipeStep step =
        RecipeStep(stepNum: idx, string: jsonData["steps"][idx]);
        steps.add(step);
      }
    }

    invalidIngredients = List.from(jsonData["ingredients"]);
    setState(() {});
  }

  void resetIllusion() {
    Provider.of<SearchNotifier>(context, listen: false).searchMode =
        MenuType.NONE;
    Provider.of<EquipmentNotifier>(context, listen: false).optionSelected =
    false;
    Provider.of<IngredientNotifier>(context, listen: false).optionSelected =
    false;
  }

  Future<void> createRecipe(Recipe recipe) async {
    List<Ingredient> ingredients =
        Provider.of<IngredientNotifier>(context, listen: false)
            .ingredientList_inUse;
    recipe.nutritionalValue = Conversion.computeNutritionalValue(
        ingredients, recipe.recipeIngredients);
    Map<String, dynamic> out =
    await Navigator.of(context).push(HeroDialogRoute(builder: (context) {
      return RuleConfirmationPopup();
    }));
    if (out != null && out["confirmed"] == true) {
      Provider.of<FavoritesNotifier>(context, listen: false).addRecipe(recipe);
      clearRecipe();
      if (widget.recipe != null) Navigator.pop(context, {"isCreated": true});
    }
  }

  Future<void> updateRecipe(Recipe newRecipe) async {
    List<Ingredient> ingredients =
        Provider.of<IngredientNotifier>(context, listen: false)
            .ingredientList_inUse;
    newRecipe.nutritionalValue = Conversion.computeNutritionalValue(
        ingredients, newRecipe.recipeIngredients);
    Map<String, dynamic> out =
    await Navigator.of(context).push(HeroDialogRoute(builder: (context) {
      return RuleConfirmationPopup();
    }));
    if (out != null && out["confirmed"] == true) {
      Provider.of<FavoritesNotifier>(context, listen: false)
          .updateRecipe(oldRecipe: widget.recipe, newRecipe: newRecipe);
      clearRecipe();
      if (widget.recipe != null) Navigator.pop(context, {"isUpdated": true});
    }
  }
  void _showDietPicker(BuildContext context) async {
    await showModalBottomSheet(
      isScrollControlled: true, // required for min/max child size
      context: context,
      backgroundColor: color_palette["white"],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(40),
        ),
      ),
      elevation: 10.0,

      builder: (ctx) {
        ScreenUtil.init(
            BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width,
                maxHeight: MediaQuery.of(context).size.height),
            designSize: Size(2400, 1080),
            context: ctx,
            minTextAdapt: true,
            orientation: Orientation.portrait);
        return MultiSelectBottomSheet(
          items: DietTypes.map((e) => MultiSelectItem(e, e)).toList(),
          unselectedColor:  lighten( Colors.lightBlueAccent,0.1),
          selectedColor: color_palette["text_color_dark"],
          itemsTextStyle: TextStyle(
              color: color_palette["text_color_dark"],
              fontSize: 21.h
          ),
          selectedItemsTextStyle: TextStyle(
              color: color_palette["white"],
              fontSize: 21.h
          ),
          listType: MultiSelectListType.CHIP,
          initialValue: activeDiets,
          title: Expanded(
            child: AutoSizeText(
              "  Diet Picker\n Choose up to 6",
              maxLines: 2,
              style: TextStyle(
                  color: color_palette["background_color"], fontSize: 26.85.h),
              textAlign: TextAlign.center,
            ),
          ),
          cancelText: Text("Cancel",style: TextStyle(fontSize: 23.h,color: color_palette["background_color"]),),
          confirmText: Text("Ok",style: TextStyle(fontSize: 23.h,color: color_palette["background_color"]),),
          onConfirm: (values) {
            activeDiets = values;
            setState(() {});
          },
          maxChildSize: 0.8,
        );
      },
    );
  }

  void _showMealPicker(BuildContext context) async {
    await showModalBottomSheet(
      isScrollControlled: true, // required for min/max child size
      context: context,
      backgroundColor: color_palette["white"],
      elevation: 10.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(40),
        ),
      ),
      builder: (ctx) {
        ScreenUtil.init(
            BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width,
                maxHeight: MediaQuery.of(context).size.height),
            designSize: Size(2400, 1080),
            context: ctx,
            minTextAdapt: true,
            orientation: Orientation.portrait);
        return MultiSelectBottomSheet(
          items: MEALTYPES.map((e) => MultiSelectItem(e, e)).toList(),
          unselectedColor:  lighten( Colors.lightBlueAccent,0.1),
          selectedColor: color_palette["text_color_dark"],
          itemsTextStyle: TextStyle(
              color: color_palette["background_color"],
              fontSize: 21.h
          ),
          selectedItemsTextStyle: TextStyle(
              color: color_palette["white"],
              fontSize: 21.h
          ),
          listType: MultiSelectListType.CHIP,
          initialValue: activeMeals,
          title: Expanded(
            child: AutoSizeText(
              "  Meal Picker\n Choose up to 3",
              maxLines: 2,
              style: TextStyle(
                  color: color_palette["background_color"], fontSize: 26.85.h),
              textAlign: TextAlign.center,
            ),
          ),
          cancelText: Text("Cancel",style: TextStyle(fontSize: 23.h,color: color_palette["background_color"]),),
          confirmText: Text("Ok",style: TextStyle(fontSize: 23.h,color: color_palette["background_color"]),),
          onConfirm: (values) {
            activeMeals = values;
            setState(() {});
          },
          maxChildSize: 0.8,
        );
      },
    );
  }
}
