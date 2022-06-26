
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:mybmr/models/AppUser.dart';
import 'package:mybmr/models/Recipe.dart';
import 'package:mybmr/services/Firebase_db.dart';

import '../services/helper.dart';


class RecipeNotifier extends ChangeNotifier {

  int _batchSize = 5;
  String _title = "";
  String _cuisine;
  String _diet;
  double _calories = 4000;

  //Discover Recipe
  RecipeSortBy _sortedBy = RecipeSortBy.NEW;
  int currPage = 0;
  bool isFetching = false;
  DocumentSnapshot _lastDoc;
  bool _canFetchRecipes = true;
  List<Recipe> _recipes = [];




  Map<String,AppUser> posters = {};
  List<Recipe> get recipes => this._recipes;


  int get batchSize => this._batchSize;
  bool get canFetchRecipes => this._canFetchRecipes;
  void shouldRefresh(){

    _recipes.clear();
    currPage = 0;
    isFetching = false;
    _lastDoc = null;
    _canFetchRecipes = true;
    fetchRecipes();
  }
  void sortBy(RecipeSortBy choice, {String title, String cuisine, String diet,double calories}){
    _sortedBy = choice;
    _recipes.clear();
    _title = title ?? "";
    _cuisine = cuisine ?? "";
    _diet = diet ?? "";
    _calories = calories ?? 4000;
    currPage = 0;
    isFetching = false;
    _lastDoc = null;
    _canFetchRecipes = true;
    fetchRecipes();
  }

  Future<bool> fetchOwner(String ownerId) async {
    DocumentSnapshot documentSnapshot = await FirebaseDB.fetchUserById(ownerId);
    AppUser appUser =AppUser.fromJSON(documentSnapshot.data());
    appUser.uuid = ownerId;
    posters.update(ownerId,
            (value) => appUser,
            ifAbsent: () =>appUser
    );
    return true;
  }
  void fetchRecipes(){
    isFetching = true;
    switch(_sortedBy){
      case RecipeSortBy.TITLE:
        FirebaseDB.fetchRecipesByTitle(_title,_calories,limit: _batchSize,lastDoc: _lastDoc).then((QuerySnapshot querySnapshot) async {
          if(querySnapshot.docs.isNotEmpty){
            for(QueryDocumentSnapshot queryDocumentSnapshot in querySnapshot.docs){
              Recipe newRecipe = Recipe.fromJson(recipeRecords: queryDocumentSnapshot.data(),recipeId: queryDocumentSnapshot.id);
              _recipes.add(newRecipe);

              await fetchOwner(newRecipe.createdBy);
              if(  AppUser.instance.isUserSignedIn() && newRecipe.likedBy.contains(AppUser.instance.uuid)){
                AppUser.instance.addLikeRecipe(newRecipe.id);
              }

            }
            _lastDoc = querySnapshot.docs.last;
          }
          if(querySnapshot.docs.length < _batchSize) _canFetchRecipes = false;

        }).whenComplete(() {
          isFetching = false;
          notifyListeners();
        });
        break;
      case RecipeSortBy.CUISINE:
        FirebaseDB.fetchRecipesByCuisine(_cuisine,_calories,limit: _batchSize,lastDoc: _lastDoc).then((QuerySnapshot querySnapshot) async {
          if(querySnapshot.docs.isNotEmpty){
            for(QueryDocumentSnapshot queryDocumentSnapshot in querySnapshot.docs){
              Recipe newRecipe = Recipe.fromJson(recipeRecords: queryDocumentSnapshot.data(),recipeId: queryDocumentSnapshot.id);
              _recipes.add(newRecipe);


              await fetchOwner(newRecipe.createdBy);
              if(  AppUser.instance.isUserSignedIn() && newRecipe.likedBy.contains(AppUser.instance.uuid)){
                AppUser.instance.addLikeRecipe(newRecipe.id);
              }
            }
            _lastDoc = querySnapshot.docs.last;
          }
          if(querySnapshot.docs.length < _batchSize) _canFetchRecipes = false;

        }).whenComplete(() {
          isFetching = false;
          notifyListeners();
        });
        break;
      case RecipeSortBy.DIETS:
        FirebaseDB.fetchRecipeByDiet(_diet,_calories,limit: _batchSize,lastDoc: _lastDoc).then((QuerySnapshot querySnapshot) async {
          if(querySnapshot.docs.isNotEmpty){
            for(QueryDocumentSnapshot queryDocumentSnapshot in querySnapshot.docs){
              Recipe newRecipe = Recipe.fromJson(recipeRecords: queryDocumentSnapshot.data(),recipeId: queryDocumentSnapshot.id);
              _recipes.add(newRecipe);
              await fetchOwner(newRecipe.createdBy);
              if(  AppUser.instance.isUserSignedIn() && newRecipe.likedBy.contains(AppUser.instance.uuid)){
                AppUser.instance.addLikeRecipe(newRecipe.id);
              }
            }
            _lastDoc = querySnapshot.docs.last;

          }
          if(querySnapshot.docs.length < _batchSize) _canFetchRecipes = false;

        }).whenComplete(() {
          isFetching = false;
          notifyListeners();
        });
        break;
      case RecipeSortBy.NEW:
        FirebaseDB.fetchRecipesByNew(limit: _batchSize, lastDoc: _lastDoc).then((QuerySnapshot querySnapshot) async {
          if(querySnapshot.docs.isNotEmpty){
            for(QueryDocumentSnapshot queryDocumentSnapshot in querySnapshot.docs){
              Recipe newRecipe = Recipe.fromJson(recipeRecords: queryDocumentSnapshot.data(),recipeId: queryDocumentSnapshot.id);
              _recipes.add(newRecipe);
              await fetchOwner(newRecipe.createdBy);
              if(  AppUser.instance.isUserSignedIn() && newRecipe.likedBy.contains(AppUser.instance.uuid)){
                AppUser.instance.addLikeRecipe(newRecipe.id);
              }
            }
            _lastDoc = querySnapshot.docs.last;
          }
          if(querySnapshot.docs.length < _batchSize) _canFetchRecipes = false;
        }).whenComplete(() {
          isFetching = false;
          notifyListeners();
        });
        break;

    }
  }

}