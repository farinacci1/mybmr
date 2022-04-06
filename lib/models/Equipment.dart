
import 'dart:io';


class Equipment{
  /*
  * Model class for equipment
  * @requires equipment id, equipment, image of equipment, and number of times that equipment has been used in recipes
  * */
  String _id;
  String name;
  File image;
  int usedIn;
  String equipmentImageFromDb;
Equipment({this.name,this.image,this.usedIn =0});

  Equipment.fromJson(Map equipmentJson ){
    this.name = equipmentJson["equipmentName"];
    this.equipmentImageFromDb = equipmentJson["equipmentImage"];
    this.usedIn = equipmentJson["usedIn"];

  }

  Map<String, Object> toJson()  {

    Map<String, dynamic> res = {
      "equipmentName" : name,
      "equipmentImage" :image ,
    };
    return res;
  }
  String get id => _id;
  set id(String id) {this._id = id;}

}