import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:mybmr/notifiers/IngredientNotifier.dart';
import 'package:mybmr/constants/messages/en_messages.dart';
import 'package:mybmr/services/conversion.dart';
import 'package:mybmr/services/hero_dialog_route.dart';
import 'package:mybmr/constants/Constants.dart';
import 'package:mybmr/models/Ingredient.dart';
import 'package:mybmr/models/Recipe.dart';
import 'package:mybmr/views/creationMenus/popups/nutritionPopup.dart';
import 'package:provider/provider.dart';

import '../constants/Themes.dart';


class SelectedIngredient extends StatefulWidget {

  /*
  * SelectedIngredient is a vertical list that contains that shows all ingredients selected for use in recipe
  * and possess the ability to remove them from the list
  *  used by class recipebuilder
  * */
  const SelectedIngredient({Key key}) : super(key: key);
  @override
  _SelectedIngredientState createState() => _SelectedIngredientState();
}

class _SelectedIngredientState extends State<SelectedIngredient> {


  List<Widget> drawIngredients({List<Ingredient> selectedIngredients}) {
    List<RecipeIngredient> recipeIngredients = Provider.of<IngredientNotifier>(context,listen:false).recipeIngredients;
    List<Widget> out = [];
    for (Ingredient selectedIngredient in selectedIngredients) {
      RecipeIngredient recipeIngredient = recipeIngredients.firstWhere((RecipeIngredient recipeIngredient) => recipeIngredient.ingredientId == selectedIngredient.id,orElse:() => null);
      Widget child = Dismissible(
          key: UniqueKey(),
          confirmDismiss: (DismissDirection direction) async {
            if (direction == DismissDirection.endToStart) {
              return await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                        title:  Text(en_messages["delete_confirmation"],maxLines: 1,),
                        content:  Text(
                            en_messages["remove_ingredient_question"],maxLines: 5,),
                        actions: <Widget>[
                          ElevatedButton(
                              onPressed: () {
                                Provider.of<IngredientNotifier>(context,listen:false).removeIngredientFromRecipe(selectedIngredient);
                                Navigator.of(context).pop(true);
                              },
                              child:  Text(en_messages["delete"],maxLines: 1,)),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child:  Text(en_messages["cancel"],maxLines: 1,),
                          ),
                        ]);
                  });
            }
            return null;
          },
          child: Container(
            padding: EdgeInsets.only(left: 8,bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100.0),
                    border: Border.all(color: Colors.blueGrey,),
                    image: DecorationImage(
                        image: NetworkImage(
                          selectedIngredient.ingredientImageFromDB,
                        ),
                        fit: BoxFit.fill)
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 10),
                ),
                AutoSizeText(
                  recipeIngredient.amountOfIngredient.toString() +
                      recipeIngredient.unitOfMeasurement +
                      " ",
                  maxLines: 1,
                  style:
                      TextStyle(fontSize: 16, color: Colors.lightGreenAccent),
                ),
                Expanded(child:Text(
                  toTitleCase(selectedIngredient.ingredientName),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(fontSize: 20, color: Colors.white),
                )),
                Spacer(),
                GestureDetector(
                  onTap: () async {
                    int currUom = Conversion.uomType(recipeIngredient.unitOfMeasurement);
                    int validUom =Conversion.uomType(selectedIngredient.nutritionData.uom[1]);
                    if(currUom != validUom){
                      recipeIngredient.unitOfMeasurement =selectedIngredient.nutritionData.uom[1];
                    }
                    String uomLong = converUOM2Long(recipeIngredient.unitOfMeasurement);
                    Map<String, dynamic> out = await Navigator.of(context)
                        .push(HeroDialogRoute(builder: (context) {
                      return NutritionPopup(
                        fieldName: selectedIngredient.ingredientName,
                        val: recipeIngredient.amountOfIngredient,
                        uom: uomLong,
                        validDataTypes: validUom == 0 ? [true,false,false] : [false,true,false],
                      );
                    }));
                    if(out != null){
                      recipeIngredient.unitOfMeasurement =  convertUOMLong2Short(out["uom"]);
                      recipeIngredient.amountOfIngredient = out["value"];
                      setState(() {

                      });
                    }
                  },
                  child: Icon(
                    Icons.edit,
                    color: color_palette["white"],
                    size: 18,
                  ),
                )
              ],
            ),
          ));

      out.add(child);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    IngredientNotifier ingredientNotifier = Provider.of<IngredientNotifier>(context, listen: true);
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: drawIngredients(selectedIngredients:ingredientNotifier.ingredientList_inUse),
      ),
    );
  }
}
