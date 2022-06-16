
import '../abstractions/UserListItem.dart';
import 'ShoppingItem.dart';


class ShoppingList  implements ListItem{
  List<ShoppingItem> shoppingItems;

  int createdOn;
  int updatedOn;
  List<String> sharedWith;
  ShoppingList(this.shoppingItems,this.sharedWith);


  ShoppingList.fromJSON(Map<String,dynamic> data){
    this.createdOn = data["createdOn"];
    this.updatedOn = data["updatedOn"];
    this.sharedWith = List.from(data["sharedWith"]);

    this.shoppingItems = (data["shoppingItems"] as List).map((e) {
      Map<String, dynamic> shoppingItem = (e as Map<String, dynamic>);
      return ShoppingItem.fromJSON(shoppingItem);
    }).toList();

  }
  @override
  Map<String,dynamic> toJSON({bool isShared = false}){
    Map<String,dynamic> data ={
      "sharedWith" : this.sharedWith ?? [],
      "shoppingItems" : this.shoppingItems.map((e) => e.toJson()).toList()
    };

    return data;
  }
}