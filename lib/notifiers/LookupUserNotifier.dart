
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import 'package:mybmr/models/AppUser.dart';
import 'package:mybmr/models/Recipe.dart';
import 'package:mybmr/services/Firebase_db.dart';
class LookupUserNotifier extends ChangeNotifier {
  /*
  * FavoritesNotifier keeps track of all recipes created by user and all recipes that user likes
  *
  * */



  List<Recipe> _favoriteRecipes = [];
  List<Recipe> _userCreations = [];
  Recipe activeRecipe;
  bool currentlyFetchingMyRecipes = false;
  bool currentlyFetchingFavorites = false;
  bool outOfFavoriteRecipes = false;
  bool outOfMyCreations = false;

  DocumentSnapshot lastCreatedDoc;
  DocumentSnapshot lastFavoriteDoc;
  int batchSz = 5;



  int creationsCurrPage = 0;
  int favCurrPage = 0;

  Map<String,AppUser> posters = {};
  AppUser lookupUser = null;



  List<Recipe> get favoriteRecipes =>this._favoriteRecipes;
  List<Recipe> get usersCreations =>this._userCreations;

  void shouldRefresh({bool isMyRecipes = false}){
    if(isMyRecipes){
      _userCreations.clear();
      creationsCurrPage = 0;
      currentlyFetchingMyRecipes = false;
      lastCreatedDoc = null;

      outOfMyCreations = false;
      fetchRecipes(fetchFavorites: false);

    }
    else{
      _favoriteRecipes.clear();
      favCurrPage = 0;
      currentlyFetchingMyRecipes = false;
      outOfFavoriteRecipes = false;
      lastFavoriteDoc = null;
      fetchRecipes();
    }

  }




  void clear(){
    _favoriteRecipes.clear();
    _userCreations.clear();
    activeRecipe = null;
    currentlyFetchingMyRecipes = false;
    currentlyFetchingFavorites = false;
    outOfFavoriteRecipes = false;
    outOfMyCreations = false;
    lastCreatedDoc = null;
    lastFavoriteDoc = null;
    creationsCurrPage = 0;
    favCurrPage = 0;

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


  void fetchRecipes({bool fetchFavorites = true}){

    if(fetchFavorites){
      currentlyFetchingFavorites = true;
      FirebaseDB.fetchRecipesByLiked(lookupUser.uuid, limit: batchSz,lastDoc: lastFavoriteDoc)
          .then((QuerySnapshot queryDocumentSnapshot) {
        if (queryDocumentSnapshot.docs.length > 0) {
          queryDocumentSnapshot.docs.forEach((
              QueryDocumentSnapshot queryDocumentSnapshot) async {
            Recipe fetchedRecipe = Recipe.fromJson(
                recipeRecords: queryDocumentSnapshot.data(),
                recipeId: queryDocumentSnapshot.id);
            _favoriteRecipes.add(fetchedRecipe);
            await fetchOwner(fetchedRecipe.createdBy);
            if(fetchedRecipe.likedBy.contains(AppUser.instance.uuid) )AppUser.instance.addLikeRecipe(fetchedRecipe.id);
          });
          lastFavoriteDoc = queryDocumentSnapshot.docs.last;
          if(queryDocumentSnapshot.docs.length < batchSz)outOfFavoriteRecipes = true;
        }
      }).whenComplete(() {
        currentlyFetchingFavorites = false;
        notifyListeners();
      });
    }
    else {
      currentlyFetchingMyRecipes = true;
      FirebaseDB.fetchRecipesByOwner(lookupUser.uuid, limit: batchSz,lastDoc: lastCreatedDoc)
          .then((QuerySnapshot queryDocumentSnapshot) {
        if (queryDocumentSnapshot.docs.length > 0) {
          queryDocumentSnapshot.docs.forEach((
              QueryDocumentSnapshot queryDocumentSnapshot) async {
            Recipe fetchedRecipe = Recipe.fromJson(
                recipeRecords: queryDocumentSnapshot.data(),
                recipeId: queryDocumentSnapshot.id);
            _userCreations.add(fetchedRecipe);
            if(fetchedRecipe.likedBy.contains(AppUser.instance.uuid) )AppUser.instance.addLikeRecipe(fetchedRecipe.id);


          });
          lastCreatedDoc = queryDocumentSnapshot.docs.last;
          if(queryDocumentSnapshot.docs.length < batchSz)outOfMyCreations = true;
        }
      }).whenComplete(() {
        currentlyFetchingMyRecipes = false;
        notifyListeners();
      });
    }

  }

}
