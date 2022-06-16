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
