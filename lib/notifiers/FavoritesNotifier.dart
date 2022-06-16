
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
  bool outOfFavoriteRecipes = false;
  bool outOfMyCreations = false;

  DocumentSnapshot lastCreatedDoc;
  DocumentSnapshot lastFavoriteDoc;
  int bachSz = 5;



  int myCurrPage = 0;
  int favCurrPage = 0;

  Map<String,AppUser> posters = {};




  List<Recipe> get favoriteRecipes =>this._favoriteRecipes;
  List<Recipe> get myCreations =>this._myCreations;

  void shouldRefresh({bool isMyRecipes = false}){
    if(isMyRecipes){
      _myCreations.clear();
      myCurrPage = 0;
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
    _myCreations.clear();
    activeRecipe = null;
    currentlyFetchingMyRecipes = false;
    currentlyFetchingFavorites = false;
    outOfFavoriteRecipes = false;
    outOfMyCreations = false;
    lastCreatedDoc = null;
    lastFavoriteDoc = null;

  }

  Future<bool> fetchOwner(String ownerId) async {
    DocumentSnapshot documentSnapshot = await FirebaseDB.fetchUserById(ownerId);
    AppUser appUser =AppUser.fromJSON(documentSnapshot.data());
    posters.update(ownerId,
            (value) => appUser,
        ifAbsent: () =>appUser
    );
    return true;
  }

  void handleLikeEvent(String recipeId, {Recipe recipe}) {


    if ( !AppUser.instance.likedRecipes.contains(recipe.id)) {

      FirebaseDB.likeRecipe(recipeId, AppUser.instance.uuid).then((_) async {
        recipe.likedBy.add(AppUser.instance.uuid);
        _favoriteRecipes.add(recipe);
        await fetchOwner(recipe.createdBy);
        AppUser.instance.addLikeRecipe(recipe.id);

      }).catchError((_){}).whenComplete(() =>    notifyListeners());

    } else {



      FirebaseDB.unlikeRecipe(recipeId, AppUser.instance.uuid).then((_){
        recipe.likedBy.remove(AppUser.instance.uuid);
        _favoriteRecipes.removeWhere((rec) => rec.id == recipeId);
           AppUser.instance.removeLikedRecipe(recipe.id);
      }).catchError((_){}).whenComplete(() =>    notifyListeners());

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
        _myCreations.insert(0, createdRecipe);
      }).whenComplete(() {
        notifyListeners();
      });




    }).catchError((err){
      CustomToast(en_messages["recipe_create_fail"]);

    });
  }


  void fetchRecipes({ bool fetchFavorites = true}){

    if(fetchFavorites){
      currentlyFetchingFavorites = true;
      FirebaseDB.fetchRecipesByLiked(AppUser.instance.uuid, limit: bachSz,lastDoc: lastFavoriteDoc)
          .then((QuerySnapshot queryDocumentSnapshot) {
        if (queryDocumentSnapshot.docs.length > 0) {
          queryDocumentSnapshot.docs.forEach((
              QueryDocumentSnapshot queryDocumentSnapshot) async {
            Recipe fetchedRecipe = Recipe.fromJson(
                recipeRecords: queryDocumentSnapshot.data(),
                recipeId: queryDocumentSnapshot.id);
            _favoriteRecipes.add(fetchedRecipe);
            await fetchOwner(fetchedRecipe.createdBy);
            AppUser.instance.addLikeRecipe(fetchedRecipe.id);


          });
          lastFavoriteDoc = queryDocumentSnapshot.docs.last;
          if(queryDocumentSnapshot.docs.length < bachSz)outOfFavoriteRecipes = true;
        }
      }).whenComplete(() {
        currentlyFetchingMyRecipes = false;
        notifyListeners();
      });
    }
    else {
      currentlyFetchingMyRecipes = true;
      FirebaseDB.fetchRecipesByOwner(AppUser.instance.uuid, limit: bachSz,lastDoc: lastCreatedDoc)
          .then((QuerySnapshot queryDocumentSnapshot) {
        if (queryDocumentSnapshot.docs.length > 0) {
          queryDocumentSnapshot.docs.forEach((
              QueryDocumentSnapshot queryDocumentSnapshot) async {
            Recipe fetchedRecipe = Recipe.fromJson(
                recipeRecords: queryDocumentSnapshot.data(),
                recipeId: queryDocumentSnapshot.id);
            _myCreations.add(fetchedRecipe);
            await fetchOwner(fetchedRecipe.createdBy);
            if(fetchedRecipe.likedBy.contains(AppUser.instance.uuid) )AppUser.instance.addLikeRecipe(fetchedRecipe.id);


          });
          lastCreatedDoc = queryDocumentSnapshot.docs.last;
          if(queryDocumentSnapshot.docs.length < bachSz)outOfMyCreations = true;
        }
      }).whenComplete(() {
        currentlyFetchingMyRecipes = false;
        notifyListeners();
      });
    }

  }

}
