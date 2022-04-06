import 'dart:io';

import 'package:mybmr/models/Nutrition.dart';

class Ingredient {
  /*
  * Model class for Ingredients
  * @requires ingredient id, image of ingredient, and number of times that equipment has been used in recipes and the the nutritional value of the ingredient
  * */
  String _id;
  String ingredientName;
  File ingredientImage;
  String ingredientImageFromDB;
  Nutrition nutritionData;
  int usedIn;
  Ingredient(
      {
        this.ingredientName,
        this.ingredientImage,
        this.nutritionData,
      });

  String get id => _id;
  set id(String id) {
    this._id = id;
  }

  Ingredient.fromJson(Map ingredientJson) {
    ingredientName = ingredientJson["IngredientName"];
    ingredientImageFromDB = ingredientJson["IngredientImage"];
    usedIn = ingredientJson["usedIn"];
    nutritionData = Nutrition(
        calories: ingredientJson["Calories"] !=null ?  ingredientJson["Calories"].toDouble() : 0.0,
        caloriesUom: ingredientJson["CaloriesUOM"] !=null ? ingredientJson["CaloriesUOM"] : "g",
        servingSize: ingredientJson["ServingSize"] != null ?ingredientJson["ServingSize"].toDouble() : 0.0,
        servingSizeUOM: ingredientJson["ServingSizeUOM"] != null  ?ingredientJson["ServingSizeUOM"] : "g",
        carbohydrates: ingredientJson["Carbohydrates"] != null  ?ingredientJson["Carbohydrates"].toDouble() : 0.0,
        carbohydratesUOM: ingredientJson["CarbohydratesUOM"] != null  ?ingredientJson["CarbohydratesUOM"] : "g",
        sugar: ingredientJson["Sugars"] != null  ?ingredientJson["Sugars"].toDouble() : 0.0,
        sugarUOM: ingredientJson["SugarsUOM"] != null  ?ingredientJson["SugarsUOM"]: "g",
        protein: ingredientJson["Protein"] != null  ?ingredientJson["Protein"].toDouble() : 0.0,
        proteinUOM: ingredientJson["ProteinUOM"] != null  ?ingredientJson["ProteinUOM"]: "g",
        fat: ingredientJson["Fat"] != null  ?ingredientJson["Fat"].toDouble() : 0.0,
        fatUOM: ingredientJson["FatUOM"] != null  ?ingredientJson["FatUOM"] : "g",
        fiber: ingredientJson["Fiber"] != null  ?ingredientJson["Fiber"].toDouble() : 0.0,
        fiberUOM: ingredientJson["FiberUOM"] != null  ?ingredientJson["FiberUOM"] : "g",
        cholesterol : ingredientJson["Cholesterol"] != null  ?ingredientJson["Cholesterol"].toDouble() : 0.0,
        cholesterolUOM: ingredientJson["CholesterolUOM"] != null  ?ingredientJson["CholesterolUOM"] : "g",
        vitaminA: ingredientJson["VitaminA"] != null  ?ingredientJson["VitaminA"].toDouble(): 0.0,
        vitaminAUOM: ingredientJson["VitaminAUOM"] != null  ?ingredientJson["VitaminAUOM"] : "mg",
        vitaminB1: ingredientJson["VitaminB1"] != null  ?ingredientJson["VitaminB1"].toDouble(): 0.0,
        vitaminB1UOM: ingredientJson["VitaminB1UOM"] != null  ?ingredientJson["VitaminB1UOM"]: "mg",
        vitaminB2: ingredientJson["VitaminB2"] != null  ?ingredientJson["VitaminB2"].toDouble(): 0.0,
        vitaminB2UOM: ingredientJson["VitaminB2UOM"] != null  ?ingredientJson["VitaminB2UOM"]: "mg",
        vitaminB3: ingredientJson["VitaminB3"] != null  ?ingredientJson["VitaminB3"].toDouble(): 0.0,
        vitaminB3UOM: ingredientJson["VitaminB3UOM"] != null  ?ingredientJson["VitaminB3UOM"]: "mg",
        vitaminB5: ingredientJson["VitaminB5"] != null  ?ingredientJson["VitaminB5"].toDouble(): 0.0,
        vitaminB5UOM: ingredientJson["VitaminB5UOM"] != null  ?ingredientJson["VitaminB5UOM"]: "mg",
        vitaminB6: ingredientJson["VitaminB6"] != null  ?ingredientJson["VitaminB6"].toDouble(): 0.0,
        vitaminB6UOM: ingredientJson["VitaminB6UOM"] != null  ?ingredientJson["VitaminB6UOM"]: "mg",
        vitaminB9: ingredientJson["VitaminB9"] != null  ?ingredientJson["VitaminB9"].toDouble(): 0.0,
        vitaminB9UOM: ingredientJson["VitaminB9UOM"] != null  ?ingredientJson["VitaminB9UOM"]: "mg",
        vitaminB12: ingredientJson["VitaminB12"] != null  ?ingredientJson["VitaminB12"].toDouble() : 0.0,
        vitaminB12UOM: ingredientJson["VitaminB12UOM"] != null  ?ingredientJson["VitaminB12UOM"]: "mg",
        vitaminC: ingredientJson["VitaminC"] != null  ?ingredientJson["VitaminC"].toDouble(): 0.0,
        vitaminCUOM: ingredientJson["VitaminCUOM"] != null  ?ingredientJson["VitaminCUOM"]: "mg",
        vitaminD: ingredientJson["VitaminD"] != null  ?ingredientJson["VitaminD"].toDouble(): 0.0,
        vitaminDUOM: ingredientJson["VitaminDUOM"] != null  ?ingredientJson["VitaminDUOM"]: "mg",
        vitaminE: ingredientJson["VitaminE"] != null  ?ingredientJson["VitaminE"].toDouble(): 0.0,
        vitaminEUOM: ingredientJson["VitaminEUOM"] != null  ?ingredientJson["VitaminEUOM"]: "mg",
        vitaminK: ingredientJson["VitaminK"] != null  ?ingredientJson["VitaminK"].toDouble(): 0.0,
        vitaminKUOM: ingredientJson["VitaminKUOM"] != null  ?ingredientJson["VitaminKUOM"]: "mg",
        calcium: ingredientJson["Calcium"] != null  ?ingredientJson["Calcium"].toDouble(): 0.0,
        calciumUOM: ingredientJson["CalciumUOM"] != null  ?ingredientJson["CalciumUOM"]: "mg",
        chloride: ingredientJson["Chloride"] != null  ?ingredientJson["Chloride"].toDouble(): 0.0,
        chlorideUOM: ingredientJson["ChlorideUOM"] != null  ?ingredientJson["ChlorideUOM"]: "mg",
        fluoride: ingredientJson["Fluoride"] != null  ?ingredientJson["Fluoride"].toDouble(): 0.0,
        fluorideUOM: ingredientJson["FluorideUOM"] != null  ?ingredientJson["FluorideUOM"]: "mg",
        iodine: ingredientJson["Iodine"] != null  ?ingredientJson["Iodine"].toDouble(): 0.0,
        iodineUOM: ingredientJson["IodineUOM"] != null  ?ingredientJson["IodineUOM"]: "mg",
        iron: ingredientJson["Iron"] != null  ?ingredientJson["Iron"].toDouble(): 0.0,
        ironUOM: ingredientJson["IronUOM"] != null  ?ingredientJson["IronUOM"]: "mg",
        magnesium: ingredientJson["Magnesium"] != null  ?ingredientJson["Magnesium"].toDouble(): 0.0,
        magnesiumUOM: ingredientJson["MagnesiumUOM"] != null  ?ingredientJson["MagnesiumUOM"]: "mg",
        manganese: ingredientJson["Manganese"] != null  ?ingredientJson["Manganese"].toDouble(): 0.0,
        manganeseUOM: ingredientJson["ManganeseUOM"] != null  ?ingredientJson["ManganeseUOM"]: "mg",
        omega3: ingredientJson["Omega3"] != null  ?ingredientJson["Omega3"].toDouble(): 0.0,
        omega3UOM: ingredientJson["Omega3UOM"] != null  ?ingredientJson["Omega3UOM"]: "mg",
        phosphorus: ingredientJson["Phosphorus"] != null  ?ingredientJson["Phosphorus"].toDouble(): 0.0,
        phosphorusUOM: ingredientJson["PhosphorusUOM"] != null  ?ingredientJson["PhosphorusUOM"]: "mg",
        potassium: ingredientJson["Potassium"] != null  ?ingredientJson["Potassium"].toDouble(): 0.0,
        potassiumUOM: ingredientJson["PotassiumUOM"] != null  ?ingredientJson["PotassiumUOM"]: "mg",
        sodium: ingredientJson["Sodium"] != null  ?ingredientJson["Sodium"].toDouble(): 0.0,
        sodiumUOM: ingredientJson["SodiumUOM"] != null  ?ingredientJson["SodiumUOM"]: "mg",
        sulfur: ingredientJson["Sulfur"] != null  ?ingredientJson["Sulfur"].toDouble(): 0.0,
        sulfurUOM: ingredientJson["SulfurUOM"] != null  ?ingredientJson["SulfurUOM"]: "mg",
        zinc: ingredientJson["Zinc"] != null  ?ingredientJson["Zinc"].toDouble(): 0.0,
        zincUOM: ingredientJson["ZincUOM"]!= null ? ingredientJson["ZincUOM"] : "mg"
    );

  }
  Map<String, dynamic> toJSON() {

    Map<String, dynamic> map = {
      "IngredientName": ingredientName,
      "IngredientImage": ingredientImage,
      "Calories": nutritionData.calories,
      "CaloriesUOM": nutritionData.uom[0],
      "ServingSize": nutritionData.servingSize,
      "ServingSizeUOM": nutritionData.uom[1],
      "Carbohydrates": nutritionData.carbohydrates,
      "CarbohydratesUOM": nutritionData.uom[2],
      "Fiber": nutritionData.fiber,
      "FiberUOM": nutritionData.uom[3],
      "Sugars": nutritionData.sugar,
      "SugarsUOM": nutritionData.uom[4],
      "Protein": nutritionData.protein,
      "ProteinUOM": nutritionData.uom[5],
      "Fat": nutritionData.fat,
      "FatUOM": nutritionData.uom[6],
      "Cholesterol":nutritionData.cholesterol,
      "CholesterolUOM":nutritionData.uom[7],
      "VitaminA": nutritionData.vitaminA,
      "VitaminAUOM": nutritionData.uom[8],
      "VitaminB1": nutritionData.vitaminB1,
      "VitaminB1UOM": nutritionData.uom[9],
      "VitaminB2": nutritionData.vitaminB2,
      "VitaminB2UOM": nutritionData.uom[10],
      "VitaminB3": nutritionData.vitaminB3,
      "VitaminB3UOM": nutritionData.uom[11],
      "VitaminB5": nutritionData.vitaminB5,
      "VitaminB5UOM": nutritionData.uom[12],
      "VitaminB6": nutritionData.vitaminB6,
      "VitaminB6UOM": nutritionData.uom[13],
      "VitaminB9": nutritionData.vitaminB9,
      "VitaminB9UOM": nutritionData.uom[14],
      "VitaminB12": nutritionData.vitaminB12,
      "VitaminB12UOM": nutritionData.uom[15],
      "VitaminC": nutritionData.vitaminC,
      "VitaminCUOM": nutritionData.uom[16],
      "VitaminD": nutritionData.vitaminD,
      "VitaminDUOM": nutritionData.uom[17],
      "VitaminE": nutritionData.vitaminE,
      "VitaminEUOM": nutritionData.uom[18],
      "VitaminK": nutritionData.vitaminK,
      "VitaminKUOM": nutritionData.uom[19],
      "Calcium": nutritionData.calcium,
      "CalciumUOM": nutritionData.uom[20],
      "Chloride": nutritionData.chloride,
      "ChlorideUOM": nutritionData.uom[21],
      "Fluoride": nutritionData.fluoride,
      "FluorideUOM": nutritionData.uom[22],
      "Iodine": nutritionData.iodine,
      "IodineUOM": nutritionData.uom[23],
      "Iron": nutritionData.iron,
      "IronUOM": nutritionData.uom[24],
      "Manganese": nutritionData.manganese,
      "ManganeseUOM": nutritionData.uom[25],
      "Magnesium": nutritionData.magnesium,
      "MagnesiumUOM": nutritionData.uom[26],
      "Omega3": nutritionData.omega3,
      "Omega3UOM": nutritionData.uom[27],
      "Phosphorus": nutritionData.phosphorus,
      "PhosphorusUOM": nutritionData.uom[28],
      "Potassium": nutritionData.potassium,
      "PotassiumUOM": nutritionData.uom[29],
      "Sodium": nutritionData.sodium,
      "SodiumUOM": nutritionData.uom[30],
      "Sulfur": nutritionData.sulfur,
      "SulfurUOM": nutritionData.uom[31],
      "Zinc": nutritionData.zinc,
      "ZincUOM": nutritionData.uom[32],
    };
    return map;
  }
}
