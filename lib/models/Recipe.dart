import 'dart:io';
import 'package:mybmr/services/conversion.dart';

class RecipeIngredient {
  String ingredientId;
  double amountOfIngredient;
  String unitOfMeasurement;
  RecipeIngredient(
      {this.ingredientId,
      this.amountOfIngredient = 0.0,
      this.unitOfMeasurement = "g"});
  Map<String, dynamic> toJSON() {
    return {
      "ingredientId": ingredientId,
      "amountOfIngredient": amountOfIngredient,
      "unitOfMeasurement": unitOfMeasurement
    };
  }
}

class Recipe {
  String _id;
  String title;
  String description;
  File recipeImage;
  String recipeImageFromDB;
  List<RecipeIngredient> recipeIngredients;
  List<String> neededEquipmentIds;
  List<String> neededDiets;
  List<String> mealTimes;
  List<String> steps;
  double peopleServed;
  String prepTime;
  String createdBy;
  int usedIn;
  int commentCount;
  List<String> likedBy = [];
  Map<String, int> flags = {};
  Map<String, double> nutritionalValue;
  get id => _id;
  set id(String id) {
    this._id = id;
  }

  Recipe({
    this.title,
    this.description,
    this.recipeImage,
    this.recipeIngredients,
    this.neededEquipmentIds,
    this.neededDiets,
    this.mealTimes,
    this.steps,
    this.createdBy,
    this.peopleServed = 0.0,
    this.prepTime = "0 Days 0 Hrs 0 Min",
    this.commentCount = 0
  });

  Recipe.fromJson({Map<String, Object> recipeRecords, String recipeId}) {
    this.id = recipeId;
    this.title = recipeRecords["recipeName"] ?? "";
    this.description = recipeRecords["description"] ?? "";
    this.prepTime = Conversion.prepTimeFromInt(recipeRecords["prepTime"]);
    this.peopleServed = (recipeRecords["peopleServed"] as num) as double;
    this.recipeImageFromDB = recipeRecords["RecipeImage"];
    this.neededEquipmentIds = List.from(recipeRecords["neededEquipment"]);
    this.neededDiets = List.from(recipeRecords["diets"]);
    this.mealTimes = List.from(recipeRecords["mealTimes"]);
    this.likedBy = recipeRecords["likedBy"] != null ? List.from(recipeRecords["likedBy"]) : [];
    this.steps = List.from(recipeRecords["steps"]);
    this.usedIn = recipeRecords["usedIn"];
    this.createdBy = recipeRecords["createdBy"];
    this.commentCount =recipeRecords["commentCount"] ?? 0;
    this.recipeIngredients =
        (recipeRecords["recipeIngredients"] as List).map((e) {
      Map<String, dynamic> recipeIngredientObject = (e as Map<String, dynamic>);
      return RecipeIngredient(
          ingredientId: recipeIngredientObject["ingredientId"],
          amountOfIngredient: recipeIngredientObject["amountOfIngredient"],
          unitOfMeasurement: recipeIngredientObject["unitOfMeasurement"]);
    }).toList();

    this.nutritionalValue = {
      "totalCalories": double.parse(
          (recipeRecords["totalCalories"] as num).toStringAsFixed(2)),
      "totalCarbohydrates": recipeRecords["totalCarbohydrates"] ?? 0.0,
      "totalProtein": recipeRecords["totalProtein"] ?? 0.0,
      "totalFat": recipeRecords["totalFat"] ?? 0.0,
      "totalFiber": recipeRecords["totalFiber"] ?? 0.0,
      "totalCholesterol": recipeRecords["totalCholesterol"] ?? 0.0,
      "totalSugars": recipeRecords["totalSugars"] ?? 0.0,
      "totalVitaminA": recipeRecords["totalVitaminA"] ?? 0.0,
      "totalVitaminB1": recipeRecords["totalVitaminB1"] ?? 0.0,
      "totalVitaminB2": recipeRecords["totalVitaminB2"] ?? 0.0,
      "totalVitaminB3": recipeRecords["totalVitaminB3"] ?? 0.0,
      "totalVitaminB5": recipeRecords["totalVitaminB5"] ?? 0.0,
      "totalVitaminB6": recipeRecords["totalVitaminB6"] ?? 0.0,
      "totalVitaminB9": recipeRecords["totalVitaminB9"] ?? 0.0,
      "totalVitaminB12": recipeRecords["totalVitaminB12"] ?? 0.0,
      "totalVitaminC": recipeRecords["totalVitaminC"] ?? 0.0,
      "totalVitaminD": recipeRecords["totalVitaminD"] ?? 0.0,
      "totalVitaminE": recipeRecords["totalVitaminE"] ?? 0.0,
      "totalVitaminK": recipeRecords["totalVitaminK"] ?? 0.0,
      "totalCalcium": recipeRecords["totalCalcium"] ?? 0.0,
      "totalChloride": recipeRecords["totalChloride"] ?? 0.0,
      "totalFluoride": recipeRecords["totalFluoride"] ?? 0.0,
      "totalIodine": recipeRecords["totalIodine"] ?? 0.0,
      "totalIron": recipeRecords["totalIron"] ?? 0.0,
      "totalManganese": recipeRecords["totalManganese"] ?? 0.0,
      "totalMagnesium": recipeRecords["totalMagnesium"] ?? 0.0,
      "totalOmega3": recipeRecords["totalOmega3"] ?? 0.0,
      "totalPhosphorus": recipeRecords["totalPhosphorus"] ?? 0.0,
      "totalPotassium": recipeRecords["totalPotassium"] ?? 0.0,
      "totalSodium": recipeRecords["totalSodium"] ?? 0.0,
      "totalSulfur": recipeRecords["totalSulfur"] ?? 0.0,
      "totalZinc": recipeRecords["totalZinc"] ?? 0.0
    };

    this.flags = {
      "containsPii_Flag": recipeRecords["containsPii_Flag"] ?? 0,
      "isNSFW_Flag": recipeRecords["isNSFW_Flag"] ?? 0,
      "isViolentOrOffensive_Flag":
          recipeRecords["isViolentOrOffensive_Flag"] ?? 0,
      "invalidRecipe_Flag": recipeRecords["invalidRecipe_Flag"] ?? 0,
      "adminDown": recipeRecords["adminDown"] == true ? 1 : 0
    };
  }
  Map<String, Object> toJSON() {
    Map<String, Object> map = {
      "recipeName": this.title,
      "description": this.description,
      "recipeImage": this.recipeImage,
      "recipeIngredients":
          this.recipeIngredients.map((e) => e.toJSON()).toList(),
      "neededEquipment": this.neededEquipmentIds,
      "diets": this.neededDiets,
      "mealTimes": this.mealTimes,
      "prepTime": Conversion.prepTimeToInt(this.prepTime),
      "peopleServed": this.peopleServed,
      "steps": this.steps,
      "totalCalories": double.parse(
          this.nutritionalValue["totalCalories"].toStringAsFixed(2)),
      "totalCarbohydrates": this.nutritionalValue["totalCarbohydrates"],
      "totalProtein": this.nutritionalValue["totalProtein"],
      "totalFat": this.nutritionalValue["totalFat"],
      "totalFiber": this.nutritionalValue["totalFiber"],
      "totalSugars": this.nutritionalValue["totalSugars"],
      "totalCholesterol": this.nutritionalValue["totalCholesterol"],
      "totalVitaminA": this.nutritionalValue["totalVitaminA"],
      "totalVitaminB1": this.nutritionalValue["totalVitaminB1"],
      "totalVitaminB2": this.nutritionalValue["totalVitaminB2"],
      "totalVitaminB3": this.nutritionalValue["totalVitaminB3"],
      "totalVitaminB5": this.nutritionalValue["totalVitaminB5"],
      "totalVitaminB6": this.nutritionalValue["totalVitaminB6"],
      "totalVitaminB9": this.nutritionalValue["totalVitaminB9"],
      "totalVitaminB12": this.nutritionalValue["totalVitaminB12"],
      "totalVitaminC": this.nutritionalValue["totalVitaminC"],
      "totalVitaminD": this.nutritionalValue["totalVitaminD"],
      "totalVitaminE": this.nutritionalValue["totalVitaminE"],
      "totalVitaminK": this.nutritionalValue["totalVitaminK"],
      "totalCalcium": this.nutritionalValue["totalCalcium"],
      "totalChloride": this.nutritionalValue["totalChloride"],
      "totalFluoride": this.nutritionalValue["totalFluoride"],
      "totalIodine": this.nutritionalValue["totalIodine"],
      "totalIron": this.nutritionalValue["totalIron"],
      "totalManganese": this.nutritionalValue["totalManganese"],
      "totalMagnesium": this.nutritionalValue["totalMagnesium"],
      "totalOmega3": this.nutritionalValue["totalOmega3"],
      "totalPhosphorus": this.nutritionalValue["totalPhosphorus"],
      "totalPotassium": this.nutritionalValue["totalPotassium"],
      "totalSodium": this.nutritionalValue["totalSodium"],
      "totalSulfur": this.nutritionalValue["totalSulfur"],
      "totalZinc": this.nutritionalValue["totalZinc"],
    };
    return map;
  }
}
