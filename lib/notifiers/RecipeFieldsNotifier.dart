import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:mybmr/constants/Constants.dart';
import 'package:mybmr/models/Equipment.dart';
import 'package:mybmr/models/Ingredient.dart';

import 'package:mybmr/models/Recipe.dart';
import 'package:mybmr/services/Firebase_db.dart';



class RecipeFieldsNotifier extends ChangeNotifier {
/*
* RecipeFieldsNotifier is used by RecipeExpanded class to obtain information about recipe that is in focus from remote database
* */

  Recipe _activeRecipe;
  ActiveRecipeState _recipeState = ActiveRecipeState.LOADING;
  List<Ingredient> _ingredientsForActiveRecipe = [];
  List<Equipment> _equipmentForActiveRecipe = [];
  List<String> _myNotes = [];


  Recipe get activeRecipe => this._activeRecipe;
  List<Equipment> get equipmentForActiveRecipe => this._equipmentForActiveRecipe;
  List<Ingredient> get ingredientsForActiveRecipe => this._ingredientsForActiveRecipe;
  ActiveRecipeState get recipeState => this._recipeState;



  void reset(){
    _activeRecipe = null;
    _recipeState = ActiveRecipeState.LOADING;
    _ingredientsForActiveRecipe.clear();
    _equipmentForActiveRecipe.clear();
    _myNotes.clear();
  }

  set recipeState (ActiveRecipeState state){
    this._recipeState = state;
  }



  set activeRecipe(Recipe recipe) {
    this._equipmentForActiveRecipe = [];
    this._ingredientsForActiveRecipe = [];
    this._myNotes = [];
    this._activeRecipe = recipe;
    Future.forEach<RecipeIngredient>(recipe.recipeIngredients, (recipeIngredient) async {
      DocumentSnapshot record = await  FirebaseDB.fetchIngredientsById(recipeIngredient.ingredientId);
      if(record.exists) {
        Ingredient newIngredient = Ingredient.fromJson(record.data());
        newIngredient.id = record.id;
        _ingredientsForActiveRecipe.add(newIngredient);
      }
      _recipeState = ActiveRecipeState.LOADED;



    }).whenComplete(() {
      notifyListeners();
    });
    Future.forEach<String>(recipe.neededEquipmentIds, (equipmentId) async {
      DocumentSnapshot record = await  FirebaseDB.fetchEquipmentById(equipmentId);
      if(record.exists){
        Equipment equipment = Equipment.fromJson(record.data());
        equipment.id = record.id;
        _equipmentForActiveRecipe.add(equipment);
      }
      _recipeState = ActiveRecipeState.LOADED;



    }).whenComplete(() {
      notifyListeners();
    });

  }
}
