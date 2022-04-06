import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:mybmr/constants/messages/en_messages.dart';
import 'package:mybmr/models/AppUser.dart';
import 'package:mybmr/models/Recipe.dart';
import 'package:mybmr/services/Firebase_db.dart';
import 'package:mybmr/services/toast.dart';
class FavoritesNotifier extends ChangeNotifier {
  /*
  * FavoritesNotifier keeps track of all recipes created by user and all recipes that user likes
  *
  * */



  List<Recipe> _favoriteRecipes = [];
  List<Recipe> _myCreations = [];
  Recipe activeRecipe;
  bool currentlyFetchingMyRecipes = false;
  bool currentlyFetchingFavorites = false;


  List<Recipe> get favoriteRecipes =>this._favoriteRecipes;
  List<Recipe> get myCreations =>this._myCreations;


  void clear(){
    _favoriteRecipes.clear();
    _myCreations.clear();
    activeRecipe = null;
    currentlyFetchingMyRecipes = false;
    currentlyFetchingFavorites = false;

  }



  void handleLikeEvent(String recipeId, {Recipe recipe}) {


    if (!AppUser.instance.likedRecipesIds.contains(recipeId)) {

      FirebaseDB.likeRecipe(recipeId, AppUser.instance.uuid).then((_) {
        if(recipe != null)_favoriteRecipes.insert(0, recipe);
        AppUser.instance.likedRecipesIds.add(recipeId);
        notifyListeners();
      }).catchError((_){});

    } else {



      FirebaseDB.unlikeRecipe(recipeId, AppUser.instance.uuid).then((_){
        _favoriteRecipes.removeWhere((element) => element.id == recipeId);
        AppUser.instance.likedRecipesIds.remove(recipeId);
        notifyListeners();
      }).catchError((_){});

    }
  }




  void updateRecipe({Recipe oldRecipe,Recipe newRecipe}){
    newRecipe.id = oldRecipe.id;
    if(newRecipe.recipeImage == null) newRecipe.recipeImageFromDB = oldRecipe.recipeImageFromDB;

    int idx = _myCreations.indexWhere((element) => element.id == newRecipe.id);
    List<String> newEquipment = newRecipe.neededEquipmentIds.toSet().difference(oldRecipe.neededEquipmentIds.toSet()).toList();
    List<String> newIngredients = newRecipe.recipeIngredients.map((e) => e.ingredientId).toSet().difference(oldRecipe.recipeIngredients.map((e) => e.ingredientId).toSet()).toList();

    _myCreations.removeAt(idx);
    FirebaseDB.updateRecipe(updatedRecipe: newRecipe,
      newEquipmentIds: newEquipment, newIngredientIds: newIngredients
    ).then((_) {
      FirebaseDB.fetchRecipeById(newRecipe.id).then((documentSnapshot) {
        Recipe fetchedRecipe = Recipe.fromJson(recipeRecords: documentSnapshot.data(), recipeId: documentSnapshot.id);
        _myCreations.insert(idx, fetchedRecipe);
        notifyListeners();
      });

      CustomToast(en_messages["recipe_update_success"]);


    }).catchError((err){
      print(err);
      CustomToast(en_messages["recipe_update_fail"]);

    }).whenComplete(() {
      notifyListeners();
    });
  }
  void addRecipe(Recipe recipe){
    FirebaseDB.insertRecipe(recipe,creatorsId: AppUser.instance.uuid).then((String recipeId) {
      CustomToast(en_messages["recipe_create_success"]);
      FirebaseDB.fetchRecipeById(recipeId).then((DocumentSnapshot documentSnapshot) {
        Recipe createdRecipe = Recipe.fromJson(recipeRecords: documentSnapshot.data(),recipeId: documentSnapshot.id);
        AppUser.instance.myCreationIds.insert(0, recipeId);
        _myCreations.insert(0, createdRecipe);
      }).whenComplete(() {
        notifyListeners();
      });




    }).catchError((err){
      CustomToast(en_messages["recipe_create_fail"]);

    });
  }


  void fetchRecipes({int offset = 0,int limit = 6, bool fetchFavorites = true}){
    List<String> subsetRecipes = [];
    int fetchCount = 0;
    if(fetchFavorites){
       fetchCount = max(min( AppUser.instance.likedRecipesIds.length - offset, limit),0);
       if(fetchCount > 0){
         currentlyFetchingFavorites = true;
         subsetRecipes = AppUser.instance.likedRecipesIds.sublist(offset,offset + fetchCount);
       }
    }
    else{
      fetchCount = max(min( AppUser.instance.myCreationIds.length - offset, limit),0);
      if(fetchCount > 0){
        currentlyFetchingMyRecipes = true;
        subsetRecipes = AppUser.instance.myCreationIds.sublist(offset,offset +fetchCount);
      }
    }
    if(subsetRecipes.length > 0){
      Future.forEach<String>(subsetRecipes, (String recipeId) async {
       DocumentSnapshot documentSnapshot = await FirebaseDB.fetchRecipeById(recipeId);
       if(documentSnapshot.exists){
         Recipe fetchedRecipe = Recipe.fromJson(recipeRecords: documentSnapshot.data(), recipeId: documentSnapshot.id);
         if(fetchFavorites)
           _favoriteRecipes.add(fetchedRecipe);
         else
           _myCreations.add(fetchedRecipe);

       }
      }).whenComplete(() {

        if(fetchFavorites) currentlyFetchingFavorites = false;
        else currentlyFetchingMyRecipes = false;
        notifyListeners();
      });


    }

  }

}
