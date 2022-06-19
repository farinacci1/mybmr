import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:mybmr/constants/Constants.dart';
import 'package:mybmr/models/AppUser.dart';
import 'package:mybmr/models/Ingredient.dart';
import 'package:mybmr/models/Recipe.dart';
import 'package:mybmr/services/Firebase_db.dart';
import 'package:mybmr/services/conversion.dart';



class IngredientNotifier extends ChangeNotifier {
  /*
  * IngredientNotifier used by recipeBuilder to obtain ingredient from remote database and/or assign them to recipe being built
  *
  * */
  IngredientState _ingredientState = IngredientState.INGREDIENTS_LOADED;
  List<Ingredient> _ingredientList_found = [];
  List<Ingredient> _ingredientList_recentlyUsed = [];
  List<Ingredient> _ingredientList_inUse = [];
  List<RecipeIngredient> _recipeIngredients = [];

  DocumentSnapshot _lastDocument;
  bool optionSelected;
  set state(IngredientState state) {
    _ingredientState = state;
    notifyListeners();
  }

  IngredientState get ingredientState => this._ingredientState;
  List<Ingredient> get ingredientList_found => this._ingredientList_found;
  List<Ingredient> get ingredientList_recentlyUsed =>
      this._ingredientList_recentlyUsed;
  List<Ingredient> get ingredientList_inUse => this._ingredientList_inUse;
  List<RecipeIngredient> get recipeIngredients =>this._recipeIngredients;

  void clear() {
    this._ingredientState = IngredientState.INGREDIENTS_LOADED;
    this._ingredientList_found.clear();
    this._ingredientList_inUse.clear();
    this._recipeIngredients.clear();

  }


  void addIngredientToRecipe(Ingredient ingredient) {
    if(!ingredientList_inUse.contains(ingredient)){

      ingredientList_inUse.add(ingredient);
      _recipeIngredients.add(RecipeIngredient(ingredientId: ingredient.id,unitOfMeasurement: ingredient.nutritionData.uom[1]));
    }
    if(!ingredientList_recentlyUsed.contains(ingredient)) ingredientList_recentlyUsed.add(ingredient);
    if (ingredientList_recentlyUsed.length > 20)
      ingredientList_recentlyUsed.removeAt(0);
    notifyListeners();
  }
  void removeIngredientFromRecipe(Ingredient ingredient){
    _recipeIngredients.removeWhere((element) => element.ingredientId == ingredient.id);
    ingredientList_inUse.remove(ingredient);
    notifyListeners();
  }

  void filterIngredientsOnline(String filter, int quantity,
      {bool isRestart = false}) {
    if (isRestart == true) {
      _lastDocument = null;
      _ingredientList_found = [];
    }
    String matchString = Conversion.prepString(filter);

    if (_ingredientState != IngredientState.INGREDIENTS_REACHED_END && _ingredientState != IngredientState.INGREDIENTS_NOT_FOUND) {
      FirebaseDB.fetchIngredientByContains(possibleName: matchString, documentSnapshot: _lastDocument,limit: quantity)
          .then((QuerySnapshot snapshot) {
        if (snapshot.docs.length == 0 && _ingredientList_found.length == 0){
          _ingredientState = IngredientState.INGREDIENTS_NOT_FOUND;
        }

        else if (snapshot.docs.length < quantity)
          _ingredientState = IngredientState.INGREDIENTS_REACHED_END;
        else _ingredientState = IngredientState.INGREDIENTS_LOADED;
        snapshot.docs.forEach((QueryDocumentSnapshot record) {
          Ingredient ingredient = Ingredient.fromJson(record.data());
          ingredient.id = record.id;
          _ingredientList_found.add(ingredient);
        });
        this._lastDocument = snapshot.docs.last;

        notifyListeners();
      }).catchError((error){
        if(_ingredientList_found.length > 0) _ingredientState = IngredientState.INGREDIENTS_REACHED_END;
        else _ingredientState = IngredientState.INGREDIENTS_NOT_FOUND;
        notifyListeners();
      });
    }
  }

  List<Ingredient> filterIngredientListRecentlyUsed(String filter) {
    return _ingredientList_recentlyUsed.where((Ingredient ingredient) {
      return ingredient.ingredientName.toLowerCase().contains(filter);
    }).toList();
  }




  void createIngredient(Ingredient ingredient) {



    FirebaseDB.insertIngredient(ingredient).then((DocumentSnapshot record) {
      Ingredient newIngredient = Ingredient.fromJson(record.data());
      newIngredient.id = record.id;
      _ingredientList_recentlyUsed.add(newIngredient);
      notifyListeners();
    }).catchError((err){
      notifyListeners();
    });

  }

  set recipeIngredients(List<RecipeIngredient> allIngredients){
    this._recipeIngredients = allIngredients;
    List<String> ids = allIngredients.map((e) => e.ingredientId).toList();
    this.getIngredientList(ids);
  }
  void getIngredientList(List<String> ids){
    for(String id in ids){
      FirebaseDB.fetchIngredientsById(id).then((ingredientMap){
        Ingredient fetchedIngredient = Ingredient.fromJson(ingredientMap.data());
        fetchedIngredient.id = ingredientMap.id;
        _ingredientList_inUse.add(fetchedIngredient);
      }).whenComplete(() {
        if (id == ids[ids.length - 1]) notifyListeners();
      });
    }

  }
}
