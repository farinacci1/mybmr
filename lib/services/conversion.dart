import 'package:mybmr/models/Ingredient.dart';
import 'package:mybmr/models/Recipe.dart';
import 'package:trotter/trotter.dart';

class Conversion {
  /*
  * This class is used to parse and interpret data types in alternative ways
  *
  * */
  static double convert2Calories(double energy, String uom) {
    switch (uom) {
      case "Cal":
        return energy;
      case "Joules":
        return energy / 4184.0;
      default:
        return 0.0;
    }
  }

  static double weight2Grams(double weight, String uom) {
    switch (uom) {
      case "mcg":
        double weightInGrams = weight / 1000000;
        return weightInGrams;
      case "mg":
        double weightInGrams = weight / 1000;
        return weightInGrams;
      case "kg":
        double weightInGrams = weight * 1000;
        return weightInGrams;
      case "g":
        return weight;
      case "oz":
        return weight * 28.35;
      case "lbs":
        return weight * 16 * 28.35;
      default:
        return 0.0;
    }
  }

  static double volume2FluidOz(double volume, String uom) {
    switch (uom) {
      case "Smidgen":
        return volume * 0.0052;
      case "Tad":
        return volume / 32;
      case "gtt":
        return volume / 591.0;
      case "pinch":
        return volume * .010;
      case "dash":
        return volume * .021;
      case "tsp":
        return volume / 6;
      case "tbsp":
        return volume / 2;
      case "Fl Oz":
        return volume;
      case "C":
        return volume * 8;
      case "pt":
        return volume * 16;
      case "qt":
        return volume * 32;
      case "gal":
        return volume * 128;
      case "ml":
        return volume / 29.574;
      case "L":
        return volume * 33.814;
      default:
        return 0.0;
    }
  }

  static int uomType(String uom) {
    // 0: volume 1: weight 2: energy -1: unknown
    switch (uom) {
      case "Smidgen":
      case "Tad":
      case "gtt":
      case "pinch":
      case "dash":
      case "tsp":
      case "tbsp":
      case "Fl Oz":
      case "C":
      case "pt":
      case "qt":
      case "gal":
      case "ml":
      case "L":
        return 0;
      case "mcg":
      case "mg":
      case "kg":
      case "g":
      case "oz":
      case "lbs":
        return 1;
      case "Cal":
      case "Joules":
        return 2;
      default:
        return -1;
    }
  }

  static Map<String, double> computeNutritionalValue(
      List<Ingredient> ingredientList,
      List<RecipeIngredient> recipeIngredients) {
    Map<String, double> nutritionTotal = {
      "totalCalories": 0,
      "totalFat": 0,
      "totalProtein": 0,
      "totalCarbohydrates": 0,
      "totalSugars": 0,
      "totalFiber": 0,
      "totalCholesterol": 0,
      "totalVitaminA": 0,
      "totalVitaminB1": 0,
      "totalVitaminB2": 0,
      "totalVitaminB3": 0,
      "totalVitaminB5": 0,
      "totalVitaminB6": 0,
      "totalVitaminB9": 0,
      "totalVitaminB12": 0,
      "totalVitaminC": 0,
      "totalVitaminD": 0,
      "totalVitaminE": 0,
      "totalVitaminK": 0,
      "totalCalcium": 0,
      "totalChloride": 0,
      "totalFluoride": 0,
      "totalIron": 0,
      "totalIodine": 0,
      "totalManganese": 0,
      "totalMagnesium": 0,
      "totalOmega3": 0,
      "totalPhosphorus": 0,
      "totalPotassium": 0,
      "totalSodium": 0,
      "totalSulfur": 0,
      "totalZinc": 0,
    };
    List<String> servingTags = ["ServingSize", "ServingSizeUOM"];
    List<List<String>> keyPairs = [
      ["Carbohydrates", "CarbohydratesUOM"],
      ["Fiber", "FiberUOM"],
      ["Sugars", "SugarsUOM"],
      ["Protein", "ProteinUOM"],
      ["Fat", "FatUOM"],
      ["Cholesterol", "CholesterolUOM"],
      ["VitaminA", "VitaminAUOM"],
      ["VitaminB1", "VitaminB1UOM"],
      ["VitaminB2", "VitaminB2UOM"],
      ["VitaminB3", "VitaminB3UOM"],
      ["VitaminB5", "VitaminB5UOM"],
      ["VitaminB6", "VitaminB6UOM"],
      ["VitaminB9", "VitaminB9UOM"],
      ["VitaminB12", "VitaminB12UOM"],
      ["VitaminC", "VitaminCUOM"],
      ["VitaminD", "VitaminDUOM"],
      ["VitaminE", "VitaminEUOM"],
      ["VitaminK", "VitaminKUOM"],
      ["Calcium", "CalciumUOM"],
      ["Chloride", "ChlorideUOM"],
      ["Fluoride", "FluorideUOM"],
      ["Iodine", "IodineUOM"],
      ["Iron", "IronUOM"],
      ["Manganese", "ManganeseUOM"],
      ["Magnesium", "MagnesiumUOM"],
      ["Omega3", "Omega3UOM"],
      ["Phosphorus", "PhosphorusUOM"],
      ["Potassium", "PotassiumUOM"],
      ["Sodium", "SodiumUOM"],
      ["Sulfur", "SulfurUOM"],
      ["Zinc", "ZincUOM"],
    ];
    for (RecipeIngredient recipeIngredient in recipeIngredients) {
      Ingredient ingredient =
          _lookupIngredient(recipeIngredient.ingredientId, ingredientList);
      if (ingredient != null) {
        nutritionTotal["totalCalories"] +=
            _computeCalories(ingredient, recipeIngredient);
        Map<String, dynamic> ingredientMap = ingredient.toJSON();

        for (List<String> keyPair in keyPairs) {
          nutritionTotal["total" + keyPair[0]] += _computeNutritionalValue(
              ingredientMap[servingTags[0]],
              ingredientMap[servingTags[1]],
              ingredientMap[keyPair[0]],
              ingredientMap[keyPair[1]],
              recipeIngredient);
        }
      }
    }
    return nutritionTotal;
  }

  static double _computeCalories(
      Ingredient ingredient, RecipeIngredient recipeIngredient) {
    double servingSize = ingredient.nutritionData.servingSize;
    String servingSizeUOM = ingredient.nutritionData.uom[1];
    double portion = recipeIngredient.amountOfIngredient;
    String portionUOM = recipeIngredient.unitOfMeasurement;
    double sf = _computeScaleFactor(
        servingSize: servingSize,
        servingSizeUOM: servingSizeUOM,
        portion: portion,
        portionUOM: portionUOM);
    double caloriesPerIngredientServing = convert2Calories(
        ingredient.nutritionData.calories, ingredient.nutritionData.uom[0]);

    return caloriesPerIngredientServing * sf;
  }

  static double _computeNutritionalValue(
      double servingSize,
      String servingSizeUOM,
      double nutritionalValue,
      String nutritionalUOM,
      RecipeIngredient recipeIngredient) {
    double portion = recipeIngredient.amountOfIngredient;
    String portionUOM = recipeIngredient.unitOfMeasurement;
    double sf = _computeScaleFactor(
        servingSize: servingSize,
        servingSizeUOM: servingSizeUOM,
        portion: portion,
        portionUOM: portionUOM);
    double valueInGrams = weight2Grams(nutritionalValue, nutritionalUOM);
    return valueInGrams * sf;
  }

  static double _computeScaleFactor(
      {double servingSize,
      String servingSizeUOM,
      double portion,
      String portionUOM}) {
    int servingType = Conversion.uomType(servingSizeUOM);
    int portionType = Conversion.uomType(portionUOM);
    // if any Unit of Measurement is invalid skip computation for this ingredient
    if (servingType == -1 || portionType == -1) return 0.0;
    //servings and portion should use same units of measurement. any of volume,weight, calories
    if (servingType != portionType) return 0.0;

    double sf = 1.0;
    // convert data to general type
    if (servingType == 0) {
      //if volume
      double flozInIngredientServing =
          volume2FluidOz(servingSize, servingSizeUOM);
      double flozInRecipeServing = volume2FluidOz(portion, portionUOM);
      sf = flozInRecipeServing / flozInIngredientServing;
    } else if (servingType == 1) {
      //if weight
      double gramsInIngredientServing =
          weight2Grams(servingSize, servingSizeUOM);
      double gramsInRecipeServing = weight2Grams(portion, portionUOM);
      sf = gramsInRecipeServing / gramsInIngredientServing;
    } else if (servingType == 2) {
      //if energy
      double caloriesPerIngredientServing =
          convert2Calories(servingSize, servingSizeUOM);
      double calsInRecipeServing = convert2Calories(portion, portionUOM);
      sf = calsInRecipeServing / caloriesPerIngredientServing;
    }

    return sf;
  }

  static Ingredient _lookupIngredient(
      String ingredientId, List<Ingredient> ingredientList) {
    final index = ingredientList
        .indexWhere((ingredient) => ingredient.id == ingredientId);
    if (index != -1)
      return ingredientList[index];
    else
      return null;
  }

  static List<bool> getValidPopupState(String label) {
    /*
    * [volume,weight,energy]
    * */

    switch (label) {
      case "Calories":
        return [false, false, true];
      case "Serving size":
        return [true, true, false];
      case "Carbohydrates":
      case "Protein":
      case "Fat":
      case "Fiber":
      case "Sugars":
      case "Cholesterol":
      case "Vitamin A":
      case "Vitamin B1":
      case "Vitamin B2":
      case "Vitamin B3":
      case "Vitamin B5":
      case "Vitamin B6":
      case "Vitamin B9":
      case "Vitamin B12":
      case "Vitamin C":
      case "Vitamin D":
      case "Vitamin E":
      case "Vitamin K":
      case "Calcium":
      case "Fluoride":
      case "Iron":
      case "Manganese":
      case "Magnesium":
      case "Phosphorus":
      case "Potassium":
      case "Sodium":
      case "Zinc":
        return [false, true, false];
      default:
        return [true, true, true];
    }
  }

  static String prepTimeShort(String preptime) {
    String out = "";
    List<String> tokens = preptime.split(" ");
    int days = int.parse(tokens[0]);
    int hours = int.parse(tokens[2]);
    int minutes = int.parse(tokens[4]);
    if (days > 0) out += "${days}d";
    if (hours > 0) out += "${hours}h";
    if (minutes > 0) out += "${minutes}m";

    if (out.length == 0) out += "0m";
    return out;
  }

  static double computePercentageValue(double numerator, double denominator) {
    if (denominator == 0.0) return 33.333;

    double output = (numerator / denominator) * 100;
    return double.parse(output.toStringAsPrecision(3));
  }

  static List<DateTime> getDaysInBetween(DateTime startDate, DateTime endDate) {
    List<DateTime> days = [];
    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      days.add(startDate.add(Duration(days: i)));
    }
    return days;
  }

  static int prepTimeToInt(String preptime) {
    List<String> tokens = preptime.split(" ");
    try {
      int days = int.parse(tokens[0]);
      int hours = int.parse(tokens[2]);
      int minutes = int.parse(tokens[4]);

      int totalMinutes = (days * 60 * 24) + (hours * 60) + minutes;
      return totalMinutes;
    } catch (e) {
      return 0;
    }
  }

  static String prepTimeFromInt(int totalMinutes) {
    //  String totalTime = "0 Days 0 Hours 0 Minutes";
    int year =
        (totalMinutes / 525600).floor(); // our app doesn't use years **yet
    int remainingMinutes = totalMinutes % 525600;
    int days = (remainingMinutes / 1440).floor();
    remainingMinutes = remainingMinutes % 1440;
    int hours = (remainingMinutes / 60).floor();
    int minutes = remainingMinutes % 60;

    return days.toString() +
        " Days " +
        hours.toString() +
        " Hours " +
        minutes.toString() +
        " Minutes";
  }

  static String nFormatter(int num, int digits) {
    const lookup = [
      {"value": 1e18, "symbol": "E"},
      {"value": 1e15, "symbol": "P"},
      {"value": 1e12, "symbol": "T"},
      {"value": 1e9, "symbol": "G"},
      {"value": 1e6, "symbol": "M"},
      {"value": 1e3, "symbol": "k"},
      {"value": 1, "symbol": ""},
    ];

    String symbol = "";
    for (Map<String, dynamic> map in lookup) {
      if (num > map["value"]) {
        symbol = map["symbol"];
        break;
      }
    }
    if (digits > 1000)
    return num.toStringAsFixed(digits) + symbol;
    else
      return num.toString() +symbol;
  }

  static String prepString(String str) {
    return str
        .toLowerCase()
        .replaceAll(
            RegExp("[&\/\\#,\+\(\)\$~%!\.„'\":\*‚^_¤?<>|@ª{«»§}©®™ ]"), ' ')
        .trim()
        .replaceAll(RegExp(r"\s+"), " ");
  }

  static List<String> tokenizeByWordChar(String name) {
    List<String> buildString = [];
    List<String> tokens = prepString(name).split(new RegExp('\\s+'));
    tokens = tokens.toSet().toList();
    String phrase = ""; // building sentence
    String phrase3 = "";
    for (String token in tokens) {
      String phrase2 = ""; //building word
      token.split('').forEach((ch) {
        phrase = phrase + ch;
        phrase2 = phrase2 + ch;
        phrase3 = phrase3 + ch;
        buildString.add(phrase);
        buildString.add(phrase2);
        buildString.add(phrase3);
      });
      phrase = phrase + " ";
      phrase3 = phrase3 + " ";
      List<String> phrase3Split = phrase3.split(" ");
      if (phrase3Split.length == 3) {
        phrase3Split.removeAt(0);
        phrase3 = phrase3Split.join(" ");
      }
    }
    return buildString.toSet().toList();
  }

  static List<String> tokenizeByPermutations(String name) {
    List<String> tokens = prepString(name).split(new RegExp('\\s+'));

    tokens = tokens.toSet().toList();
    /* ensure that all values are unique up to this point, we dont want to have
    "garlic garlic" as a potential query string*/

    List<String> allPossibleStrings = [];

    // create a list of all possible sublists
    List<List<String>> combinations = _getAllSubsets(tokens);
    //obtain permutations of each sublist
    combinations.forEach((List<String> sublist) {
      Permutations permutations = sublist.permutations();
      for (List<String> permutation in permutations()) {
        String token = permutation.join("||");
        allPossibleStrings.add(token);
      }
    });

    //return sorted list of unique values
    allPossibleStrings.add(
        ""); //need to add empty list in case list doesnt already contain it
    List<String> uniqueValues =
        allPossibleStrings.toSet().toList(); //ensure only unique fields
    uniqueValues.sort((a, b) => a.length.compareTo(b.length));
    return uniqueValues.reversed.toList(); // return list in decesending order
  }

  static List<List<String>> _getAllSubsets(List<String> l) =>
      l.fold<List<List<String>>>([[]], (subLists, element) {
        return subLists
            .map((subList) => [
                  subList,
                  subList + [element]
                ])
            .expand((element) => element)
            .toList();
      });
  static bool isInteger(num value) =>
      value is int || value == value.roundToDouble();
}
