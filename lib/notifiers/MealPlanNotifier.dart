import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mybmr/models/AppUser.dart';
import 'package:mybmr/models/MealPlan.dart';
import 'package:mybmr/models/Recipe.dart';
import 'package:mybmr/services/Firebase_db.dart';


class MealPlanNotifier extends ChangeNotifier {
  /*
  * fetch meal plans from local database or add meal plan
  *
  * */
  List<MealPlan> _mealPlans = [];
  List<Recipe> _recipesInMealPlans = [];

  DateTime _startOfDay = DateTime.now();
  bool isFetching = false;

  List<MealPlan> get mealPlans => this._mealPlans;
  List<Recipe> get recipesInMealPlans => this._recipesInMealPlans;
  DateTime get startOfDay => this._startOfDay;

  set mealPlans(List<MealPlan> mealPlans) {
    this._mealPlans = mealPlans;
  }



  void setStartOfDay(DateTime startOfDay,{bool shouldNotify = true}) {

    this._startOfDay = startOfDay;
    if(shouldNotify)notifyListeners();
  }

  void clear(){
    _mealPlans.clear();
    _recipesInMealPlans.clear();

    _startOfDay = DateTime.now();

  }

  double obtainCaloriesForDate() {
    double totalCal = 0.0;
    List<MealPlan> filter = _mealPlans
        .where((mealPlan) =>
            DateTime(mealPlan.date.year, mealPlan.date.month, mealPlan.date.day) ==
            _startOfDay)
        .toList();
    for (MealPlan mealplan in filter) {
      Recipe recipe = _recipesInMealPlans
          .firstWhere((element) => mealplan.recipeId == element.id, orElse:() => null);
      if(recipe != null)
      totalCal += (recipe.nutritionalValue["totalCalories"] / recipe.peopleServed);
    }
    return totalCal;
  }

  List<MealPlan> filterByDate(DateTime date){
    List<MealPlan> filter = _mealPlans
        .where((mealPlan) =>
    DateTime(mealPlan.date.year, mealPlan.date.month, mealPlan.date.day) ==
        _startOfDay).toList();
      return filter;
  }

  void removePlan(MealPlan plan) {

    FirebaseDB.deleteMealPlan(AppUser.instance.uuid, plan.id).whenComplete((){
      this._mealPlans.remove(plan);
      notifyListeners();
    }).catchError((err) {
      print(err);
    });

  }

  void getMealPlansFromDB() {

      isFetching = true;
      FirebaseDB.fetchMealPlans(AppUser.instance.uuid).then((
          QuerySnapshot<Map<String, dynamic>> querySnapshot) {
        if (querySnapshot.size > 0) {
          this._mealPlans = querySnapshot.docs.map((
              QueryDocumentSnapshot queryDocumentSnapshot) => MealPlan.fromJson(
              queryDocumentSnapshot.data(), queryDocumentSnapshot.id))
              .toList();
          for (MealPlan plan in mealPlans) {
            String recipeId = plan.recipeId;
            FirebaseDB.fetchRecipeById(recipeId)
                .then((DocumentSnapshot documentSnapshot) {
              if (documentSnapshot.exists) {
                Recipe newRecipe = Recipe.fromJson(
                    recipeRecords: documentSnapshot.data(), recipeId: recipeId);
                _recipesInMealPlans.add(newRecipe);
              }
            }).catchError((_) {

            });
          }
        }
      }).catchError((err) {
        print(err);
      }).whenComplete(() {
        isFetching = false;
        notifyListeners();
      });

  }

  void createMealPlan(MealPlan mealPlan, Recipe recipe) {


          FirebaseDB.insertMealPlan(AppUser.instance.uuid, mealPlan).then((String planId){
            this.recipesInMealPlans.add(recipe);
            mealPlan.id = planId;
            this.mealPlans.add(mealPlan);

          }).whenComplete(() => notifyListeners());

  }


}
