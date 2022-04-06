import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/material.dart';


final List<String> volumeMeasurements = [
  "Drop",
  "Smidgen",
  "Pinch",
  "Dash",
  "Tad",
  "Teaspoon",
  "Tablespoon",
  "Fluid Ounces",
  "Cups",
  "Pints",
  "Quarts",
  "Gallons",
  "MilliLiters",
  "Liter",
];
final List<String> weightMeasurements = [
  "micrograms",
  "milligrams",
  "Grams",
  "Ounces",
  "Kilograms",
  "Pounds",
  "% DVI"
];
final List<String> shoppingValues = [
  "Ct.",
  "Cups",
  "Doz.",
  "Gal.",
  "g",
  "Oz",
  "Pkt.",
  "Lbs.",
];
final List<String> energyMeasurements = ["kCal", "Joules"];
String converUOM2Long(String shortUOM) {
  /*
  * converts abbreviation of units of measurement to whole word
  *
  * */
  print("uom to be converted :" + shortUOM);
  switch (shortUOM) {
    case "gtt":
      return "Drop";
    case "pinch":
      return "Pinch";
    case "dash":
      return "Dash";
    case "tsp":
      return "Teaspoon";
    case "tbsp":
      return "Tablespoon";
    case "Fl Oz":
      return "Fluid Ounces";
    case "C":
      return "Cups";
    case "pt":
      return "Pints";
    case "qt":
      return "Quarts";
    case "gal":
      return "Gallons";
    case "ml":
      return "MilliLiters";
    case "L":
      return "Liters";
    case "mcg":
      return "micrograms";
    case "mg":
      return "milligrams";
    case "g":
      return "Grams";
    case "kg":
      return "Kilograms";
    case "oz":
      return "Ounces";
    case "lbs":
      return "Pounds";
    case "doz":
      return "Dozen";
    case "Cal":
      return "kCal";
    case "j":
      return "Joules";
    default:
      return shortUOM;
  }
}

String convertUOMLong2Short(String longUOM) {
  /*
  * returns abbreviation of units of measurement
  *
  * */
  print("uom to be converted :" + longUOM);
  switch (longUOM) {
    case "Drop":
      return "gtt";
    case "Pinch":
      return "pinch";
    case "Dash":
      return "dash";
    case "Teaspoon":
      return "tsp";
    case "Tablespoon":
      return "tbsp";
    case "Fluid Ounces":
      return "Fl Oz";
    case "Cups":
      return "C";
    case "Pints":
      return "pt";
    case "Quarts":
      return "qt";
    case "Gallons":
      return "gal";
    case "MilliLiters":
      return "ml";
    case "Liters":
      return "L";
    case "micrograms":
      return "mcg";
    case "milligrams":
      return "mg";
    case "Grams":
      return "g";
    case "Kilograms":
      return "kg";
    case "Ounces":
      return "oz";
    case "Pounds":
      return "lbs";
    case "Dozen":
      return "doz";
    case "kCal":
      return "Cal";
    case "Joules":
      return "J";
    default:
      return longUOM;
  }
}

String getNutritionOptionFromName(String name) {
  /*
  * return type of Units of Measurement
  * */
  if (volumeMeasurements.contains(name)) return "Volume";
  if (weightMeasurements.contains(name)) return "Weight";
  if (energyMeasurements.contains(name)) return "Energy";
  return "";
}

TimeOfDay timeConvert(String normTime) {
  /*
  * converts String representation of time to  TimeOfDay data type
  * */
  int hour;
  int minute;
  String ampm = normTime.substring(normTime.length - 2);
  String result = normTime.substring(0, normTime.indexOf(' '));
  if (ampm == 'AM' && int.parse(result.split(":")[1]) != 12) {
    hour = int.parse(result.split(':')[0]);
    if (hour == 12) hour = 0;
    minute = int.parse(result.split(":")[1]);
  } else {
    hour = int.parse(result.split(':')[0]) - 12;
    if (hour <= 0) {
      hour = 24 + hour;
    }
    minute = int.parse(result.split(":")[1]);
  }
  return TimeOfDay(hour: hour, minute: minute);
}

String toTitleCase(String ingredientName) {
  /*
  * @param ingredientName
  * @ returns a string with first letter of every word uppercased
  * */
  if (ingredientName == null) {
    return null;
  }

  if (ingredientName.length <= 1) {
    return ingredientName.toUpperCase();
  }

  // Split string into multiple words
  final List<String> words = ingredientName.split(' ');

  // Capitalize first letter of each words
  final capitalizedWords = words.map((word) {
    if (word.trim().isNotEmpty) {
      final String firstLetter = word.trim().substring(0, 1).toUpperCase();
      final String remainingLetters = word.trim().substring(1);

      return '$firstLetter$remainingLetters';
    }
    return '';
  });

  // Join/Merge all words back to one String
  return capitalizedWords.join(' ');
}

MemoryImage getBase64AsImage(Uint8List base64Image) {
  /*
  * @param base64Image
  * converts Uint8List image object to a memory image that can be displayed by app
  * */
  return MemoryImage(base64Image);
}

const List<String> DietTypes = [
  "Regular Diet",
  "5:2 Diet",
  "Alkaline Diet",
  "Atkins diet",
  "Blood Type O Diet",
  "Blood Type A Diet",
  "Blood Type B Diet",
  "Blood Type AB Diet",
  "Carnivore Diet",
  "Diabetic Diet",
  "Detox Diet",
  "Fat Free Diet",
  "Fruitarian Diet",
  "Gluten Free Diet",
  "High-protein Diet",
  "Intermittent fasting",
  "Juice Cleanse",
  "Ketogenic Diet",
  "Liquid Diet",
  "Low-FODMAP Diet",
  "Low Carb Diet",
  "Low Fat Diet",
  "Low-protein Diet",
  "Low sodium Diet",
  "Low-sulfur Diet",
  "Macrobiotic Diet",
  "Mediterranean Diet",
  "Monotrophic Diet",
  "No Carb Diet",
  "No Cheese Diet",
  "Paleo Diet",
  "Pescetarian Diet",
  "Pollotarian Diet",
  "Raw Food Diet",
  "Shangri-La Diet",
  "South Beach Diet",
  "Sugar Free Diet",
  "Ultra-Low-Fat Diet",
  "Vegan Diet",
  "Vegetarian Diet",
  "Weight Watchers Diet",
];

const List<String> MEALTYPES = [
  "Algerian",
  "African",
  "American",
  "Arabian",
  "Asian Fusion",
  "Australian",
  "Bakery",
  "Barbeque",
  "Belgian",
  "Brazilian",
  "Bulgarian",
  "Cajun",
  "Cambodian",
  "Canadian",
  "Caribbean",
  "Chinese",
  "Columbian",
  "Comfort",
  "Creole",
  "Cuban",
  "Cured",
  "Danish",
  "Dessert",
  "Dry aged",
  "Dutch",
  "Ecuadorian",
  "English",
  "Egyptian",
  "European",
  "Filipino",
  "Finnish",
  "French",
  "German",
  "Greek",
  "Haitian",
  "Halal",
  "Hawaiian",
  "Hungarian",
  "Indian",
  "Indonesian",
  "Irish",
  "Italian",
  "Jamaican",
  "Japanese",
  "Kashrut",
  "Korean",
  "Latin",
  "Lebanese",
  "Malaysian",
  "Mediterranean",
  "Middle Eastern",
  "Mexican",
  "Mongolian",
  "Moroccan",
  "Norwegian",
  "Panamanian",
  "Persian",
  "Polish",
  "Polynesian",
  "Portuguese",
  "Puerto Rican",
  "Russian",
  "Scottish",
  "Singaporean",
  "Soul",
  "Southern",
  "Spanish",
  "Swedish",
  "Swiss",
  "Taiwanese ",
  "Tibetan",
  "Thai",
  "Turkish",
  "Vietnamese",
];

Color randomColor() {
  /*
  * @param none
  * @returns random color
  * */
  return Color((math.Random().nextDouble() * 0xFFFFFF).toInt())
      .withOpacity(1.0);
}

const List<String> NUTRITION_LABELS = [
  "Calories",
  "Serving size",
  "Carbohydrates",
  "Fiber",
  "Sugars",
  "Protein",
  "Fat",
  "Cholesterol",
  "Vitamin A",
  "Vitamin B1",
  "Vitamin B2",
  "Vitamin B3",
  "Vitamin B5",
  "Vitamin B6",
  "Vitamin B9",
  "Vitamin B12",
  "Vitamin C",
  "Vitamin D",
  "Vitamin E",
  "Vitamin K",
  "Calcium",
  "Chloride",
  "Fluoride",
  "Iodine",
  "Iron",
  "Omega3",
  "Manganese",
  "Magnesium",
  "Phosphorus",
  "Potassium",
  "Sodium",
  "Sulfur",
  "Zinc"
];
class rdiTuple{
  String label;
  double value;
  rdiTuple(this.label,this.value);
}

Map<String,rdiTuple> dailyIntakeRDI = {
  "Sugars" : rdiTuple("g",50),
  "Cholesterol" : rdiTuple("mg",300),
  "Carbohydrates":rdiTuple("g",300),
  "Fiber" :  rdiTuple("g",28),
  "Fat" :  rdiTuple("g",78),
  "Protein" : rdiTuple("g",50),
  "Saturated fat" : rdiTuple("g",20),
  "Vitamin A" : rdiTuple("mcg",900),
  "Vitamin B1" : rdiTuple("mg",1.2),
  "Vitamin B2" : rdiTuple("mg",1.3),
  "Vitamin B3" : rdiTuple("mg",16),
  "Vitamin B5" : rdiTuple("mg",5),
  "Vitamin B6" : rdiTuple("mg",1.7),
  "Vitamin B7" : rdiTuple("mcg",30),
  "Vitamin B9" : rdiTuple("mcg",400),
  "Vitamin B12" : rdiTuple("mcg",2.4),
  "Vitamin C" : rdiTuple("mg",90),
  "Vitamin D" : rdiTuple("mcg",20),
  "Vitamin E" : rdiTuple("mg",15),
  "Vitamin K" : rdiTuple("mcg",120),
  "Calcium" : rdiTuple("mg",1300),
  "Chloride": rdiTuple("mg",2300),
  "Choline": rdiTuple("mg",550),
  "Chromium": rdiTuple("mcg",35),
  "Copper" : rdiTuple("mg",0.9),
  "Fluoride":rdiTuple("mg",2.9),
  "Iron" : rdiTuple("mg",18),
  "Iodine" : rdiTuple("mcg",150),
  "Magnesium" : rdiTuple("mg",420),
  "Manganese" : rdiTuple("mg",2.3),
  "Molybdenum": rdiTuple("mcg",45),
  "Omega3": rdiTuple("g",  1.1),
  "Phosphorus" : rdiTuple("mg",1250),
  "Potassium": rdiTuple("mg",4700),
  "Selenium	" : rdiTuple("mcg",55),
  "Sodium" : rdiTuple("mg",2300),
  "Sulfur" : rdiTuple("mg",1000),
  "Zinc" : rdiTuple("mg",11),

};
enum EquipmentState {
  FETCHING_EQUIPMENT,
  EQUIPMENT_LOADED,
  EQUIPMENT_NOT_FOUND,
  EQUIPMENT_REACHED_END
}
enum IngredientState {
  FETCHING_INGREDIENTS,
  INGREDIENTS_LOADED,
  INGREDIENTS_NOT_FOUND,
  INGREDIENTS_REACHED_END
}
enum ActiveRecipeState {
  LOADING,
  LOADED,
}
enum MenuType{
  INGREDIENTS,
  EQUIPMENT,
  NONE
}
enum SwipeEvent { SWIPE_EVENT_LEFT, SWIPE_EVENT_RIGHT, LOAD_RECIPE_EVENTS }
enum SwipeState {
  SWIPE_LOADED,
  RECIPE_LOADING,
  SWIPE_ERROR,
  SWIPE_REACHED_END,
  NO_RECIPES_FOUND
}
const Map<int,String> dayOfWeek = {
  1 : "Mon",
  2 : "Tue",
  3 : "Wed",
  4 : "Thur",
  5 : "Fri",
  6 : "Sat",
  7 : "Sun"
};
const Map<int,String>monthsOfYear= {
  1:"Jan",
  2:"Feb",
  3:"Mar",
  4:"Apr",
  5:"May",
  6:"Jun",
  7:"Jul",
  8:"Aug",
  9:"Sep",
  10:"Oct",
  11:"Nov",
  12:"Dec"
};
extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month
        && day == other.day;
  }
}

int compareTime(String time1, String time2){
  /*
  * Returns a negative value if this is ordered before other,
  * a positive value if this is ordered after other,
  * or zero if this and other are equivalent.
  * */
  List<String> time1List = time1.trim().split(" ");
  List<String> time2List = time2.trim().split(" ");

  int compareAMPM = time2List[1].toLowerCase().compareTo( time1List[1].toLowerCase());
  if(compareAMPM == 0){
    List<String> hoursMins = time1List[0].split(":");
    List<String> hoursMins2 = time2List[0].split(":");
    int compareHours = (int.parse(hoursMins2[0])).compareTo(int.parse(hoursMins[0]));
    if(compareHours == 0){
      return (int.parse(hoursMins2[1])).compareTo(int.parse((hoursMins[1])));
    }
    return compareHours;
  }else{
    return compareAMPM;
  }
}

