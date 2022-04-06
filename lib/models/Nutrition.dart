



class Nutrition {
  /*
  * Nutrition model being used by ingredients
  * */
  Nutrition({
    this.calories = 0.0,
    this.servingSize = 0.0,
    this.carbohydrates = 0.0,
    this.sugar = 0.0,
    this.protein = 0.0,
    this.cholesterol =0.0,
    this.saturatedFat = 0.0,
    this.transFat = 0.0,
    this.fat = 0.0,
    this.fiber = 0.0,
    this.vitaminA = 0.0,
    this.vitaminB1 = 0.0,
    this.vitaminB2 = 0.0,
    this.vitaminB3 = 0.0,
    this.vitaminB5 = 0.0,
    this.vitaminB6 = 0.0,
    this.vitaminB9 = 0.0,
    this.vitaminB12 = 0.0,
    this.vitaminC = 0.0,
    this.vitaminD = 0.0,
    this.vitaminE = 0.0,
    this.vitaminK = 0.0,
    this.calcium = 0.0,
    this.copper = 0.0,
    this.cobalt = 0.0,
    this.chloride = 0.0,
    this.fluoride = 0.0,
    this.iodine = 0.0,
    this.iron = 0.0,
    this.manganese = 0.0,
    this.magnesium = 0.0,
    this.molybdenum = 0.0,
    this.omega3 = 0.0,
    this.phosphorus = 0.0,
    this.potassium = 0.0,
    this.selenium = 0.0,
    this.sodium = 0.0,
    this.sulfur =0.0,
    this.zinc = 0.0,
    String caloriesUom = "Cal",
    String cholesterolUOM = "g",
    String servingSizeUOM ="g",
    String proteinUOM = "g",
    String carbohydratesUOM = "g",
    String fatUOM = "g",
    String fiberUOM = "g",
    String sugarUOM = "g",
    String saturatedFatUOM = "g",
    String transFatUOM = "g",
    String vitaminAUOM = "mcg",
    String vitaminB1UOM = "mcg",
    String vitaminB2UOM = "mcg",
    String vitaminB3UOM = "mcg",
    String vitaminB5UOM = "mcg",
    String vitaminB6UOM = "mcg",
    String vitaminB9UOM = "mcg",
    String vitaminB12UOM = "mcg",
    String vitaminCUOM = "mcg",
    String vitaminDUOM = "mcg",
    String vitaminEUOM = "mcg",
    String vitaminKUOM = "mcg",
    String calciumUOM = "mg",
    String chlorideUOM = "mg",
    String copperUOM = "mg",
    String cobaltUOM = "mg",
    String cholineUPM = "mg",
    String fluorideUOM = "mg",
    String iodineUOM = "mg",
    String ironUOM = "mg",
    String manganeseUOM = "mg",
    String magnesiumUOM = "mg",
    String molybdenumUOM = "mg",
    String omega3UOM = "mg",
    String phosphorusUOM = "mg",
    String potassiumUOM = "mg",
    String seleniumUOM = "mg",
    String sodiumUOM = "mg",
    String sulfurUOM = "mg",
    String zincUOM = "mg"
  }){
    this.uom = [
      caloriesUom, servingSizeUOM,carbohydratesUOM, fiberUOM,sugarUOM,proteinUOM,fatUOM,cholesterolUOM ,vitaminAUOM,vitaminB1UOM,vitaminB2UOM,
      vitaminB3UOM, vitaminB5UOM,vitaminB6UOM,vitaminB9UOM, vitaminB12UOM,vitaminCUOM,vitaminDUOM,vitaminEUOM,vitaminKUOM,
      calciumUOM,chlorideUOM, fluorideUOM,iodineUOM,ironUOM,manganeseUOM,magnesiumUOM,omega3UOM,phosphorusUOM,potassiumUOM,sodiumUOM,sulfurUOM,zincUOM
    ];
  }
  //energy stats
  double calories;
  double servingSize;
  double carbohydrates;
  double sugar;
  double cholesterol;
  double protein;
  double fat;
  double saturatedFat;
  double transFat;
  double fiber;
  //vitamins
  double vitaminA;
  double vitaminB1;
  double vitaminB2;
  double vitaminB3;
  double vitaminB5;
  double vitaminB6;
  double vitaminB9;
  double vitaminB12;
  double vitaminC;
  double vitaminD;
  double vitaminE;
  double vitaminK;
  //minerals
  double calcium;
  double chloride;
  double cobalt;
  double copper;
  double fluoride;
  double iodine;
  double iron;
  double omega3;
  double manganese;
  double magnesium;
  double phosphorus;
  double potassium;
  double selenium;
  double sodium;
  double sulfur;
  double zinc;
  double molybdenum;

  List<String> uom=[];


  double fetchValueByName(String nutritionLabel) {
    switch (nutritionLabel) {
      case "Calories":
        return calories;
      case "Serving size":
        return servingSize;
      case "Carbohydrates":
        return carbohydrates;
      case "Sugars":
        return sugar;
      case "Cholesterol":
        return cholesterol;
      case "Protein":
        return protein;
      case "Fat":
        return fat;
      case "Fiber":
        return fiber;
      case "Vitamin A":
        return vitaminA;
      case "Vitamin B1":
        return vitaminB1;
      case "Vitamin B2":
        return vitaminB2;
      case "Vitamin B3":
        return vitaminB3;
      case "Vitamin B5":
        return vitaminB5;
      case "Vitamin B6":
        return vitaminB6;
      case "Vitamin B9":
        return vitaminB9;
      case "Vitamin B12":
        return vitaminB12;
      case "Vitamin C":
        return vitaminC;
      case "Vitamin D":
        return vitaminD;
      case "Vitamin E":
        return vitaminE;
      case "Vitamin K":
        return vitaminK;
      case "Calcium":
        return calcium;
      case "Chloride":
        return chloride;
      case "Fluoride":
        return fluoride;
      case "Iodine":
        return iodine;
      case "Iron":
        return iron;
      case "Manganese":
        return manganese;
      case "Magnesium":
        return magnesium;
      case "Omega3":
        return omega3;
      case "Phosphorus":
        return phosphorus;
      case "Potassium":
        return potassium;
      case "Sodium":
        return sodium;
      case "Sulfur":
        return sulfur;
      case "Zinc":
        return zinc;
      default:
        return 0.0;
    }
  }

  void setValueByLabel(String nutritionLabel, double value) {
    switch (nutritionLabel) {
      case "Calories":
        calories = value;
        break;
      case "Serving size":
        servingSize = value;
        break;
      case "Carbohydrates":
        carbohydrates = value;
        break;
      case "Cholesterol":
        cholesterol = value;
        break;
      case "Sugars":
        sugar = value;
        break;
      case "Protein":
        protein = value;
        break;
      case "Fat":
        fat = value;
        break;
      case "Fiber":
        fiber = value;
        break;
      case "Vitamin A":
        vitaminA = value;
        break;
      case "Vitamin B1":
        vitaminB1 = value;
        break;
      case "Vitamin B2":
        vitaminB2 = value;
        break;
      case "Vitamin B3":
        vitaminB3 = value;
        break;
      case "Vitamin B5":
        vitaminB5 = value;
        break;
      case "Vitamin B6":
        vitaminB6 = value;
        break;
      case "Vitamin B9":
        vitaminB9 = value;
        break;
      case "Vitamin B12":
        vitaminB12 = value;
        break;
      case "Vitamin C":
        vitaminC = value;
        break;
      case "Vitamin D":
        vitaminD = value;
        break;
      case "Vitamin E":
        vitaminE = value;
        break;
      case "Vitamin K":
        vitaminK = value;
        break;
      case "Calcium":
        calcium = value;
        break;
      case "Chloride":
        chloride = value;
        break;
      case "Fluoride":
        fluoride = value;
        break;
      case "Iodine":
        iodine=  value;
         break;
      case "Iron":
        iron = value;
        break;
      case "Manganese":
        manganese = value;
        break;
      case "Magnesium":
        magnesium = value;
        break;
      case "Omega3":
         omega3= value;
         break;
      case "Phosphorus":
        phosphorus = value;
        break;
      case "Potassium":
        potassium = value;
        break;
      case "Sodium":
        sodium = value;
        break;
      case "Sulfur":
        sulfur = value;
        break;
      case "Zinc":
        zinc = value;
        break;
      default:
        break;
    }
  }
}
