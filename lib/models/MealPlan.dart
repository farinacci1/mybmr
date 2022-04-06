


class MealPlan {
  /*
  * Model class for MealPlans
  * @requires mealplan id, name of meal, when meal will take place hour and date, and recipeid for meal being enjoyed
  * */
  String _id;
  String _title;
  String _timeOfDay;
  DateTime _date;
  String _recipeId;



  String get id => this._id;
  set id(String newId) {
    this._id = newId;
  }
  String get recipeId => this._recipeId;
  String get title=> this._title;
  String get timeOfDay => this._timeOfDay;
  DateTime get date => this._date;

  MealPlan({String title,String timeOfDay,DateTime date,String recipeId}){
    this._timeOfDay = timeOfDay;
    this._date = date;
    this._title = title;
    this._recipeId = recipeId;

  }

  MealPlan.fromJson(Map map, String id) {
    this._id = id;
    this._title = map["mealName"];
    this._timeOfDay = map["time"];
    this._date = DateTime.fromMillisecondsSinceEpoch( map["dateMillis"]);
    this._recipeId = map["recipeId"];

  }




  Map<String, dynamic> toJson() {
    Map<String, dynamic> res = {
      "mealName": this._title,
      "time": this._timeOfDay,
      "dateMillis": this._date.millisecondsSinceEpoch,
      "recipeId": this._recipeId,
    };
    return res;
  }
}
