
import '../abstractions/UserListItem.dart';

class ShoppingItem{
  String id;
  double amount;
  String valueType;
  String image;
  String name;
  bool isIngredient;
  bool isEquipment;
  bool hasObtained = false;
  ShoppingItem({this.id,this.amount,this.valueType,this.image,this.name,this.isEquipment,this.isIngredient});
  ShoppingItem.fromJSON(Map<String,dynamic> data){
    id = data["id"];
    amount = data["amount"];
    valueType = data["valueType"];
    image = data["image"];
    name = data["name"];
    isIngredient = data["isIngredient"];
    isEquipment = data["isEquipment"];
    hasObtained  = data["hasObtained"];
  }
  Map<String,dynamic> toJson(){
    Map<String,dynamic> out ={
      "id" :id,
      "amount":amount,
      "valueType" :valueType,
      "image":image,
      "name": name,
      "isIngredient" : isIngredient,
      "isEquipment" : isEquipment,
      "hasObtained" : hasObtained
    };


    return out;
  }
}

class ShoppingList  implements ListItem{
  String listId;
  String title;
  List<ShoppingItem> shoppingItems;

  int createdOn;
  int updatedOn;
  List<String> sharedWith;
  ShoppingList(this.title,this.shoppingItems,this.sharedWith);


  ShoppingList.fromJSON(Map<String,dynamic> data, String listId){
    this.listId = listId;
    this.createdOn = data["createdOn"];
    this.updatedOn = data["updatedOn"];
    this.title = data["title"];
    this.sharedWith = List.from(data["sharedWith"]);

    this.shoppingItems = (data["shoppingItems"] as List).map((e) {
      Map<String, dynamic> shoppingItem = (e as Map<String, dynamic>);
      return ShoppingItem.fromJSON(shoppingItem);
    }).toList();

  }
  @override
  Map<String,dynamic> toJSON({bool isShared = false}){
    Map<String,dynamic> data ={
      "title": this.title,
      "sharedWith" : this.sharedWith ?? [],
      "shoppingItems" : this.shoppingItems.map((e) => e.toJson()).toList()
    };
    if(isShared){
      data.addAll({
        "id" : listId
      });
    }
    return data;
  }
}