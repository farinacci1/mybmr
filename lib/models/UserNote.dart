

import '../abstractions/UserListItem.dart';

class UserNote implements ListItem{

  String noteId;
  String title;
  String bodyText;

  UserNote({this.title,this.bodyText});

  UserNote.fromJSON(Map<String,dynamic> data,String id){
    noteId = id;
    title = data["title"];
    bodyText = data["body"];
  }
  @override
  Map<String,dynamic> toJSON({bool isShared = false}){
    Map<String,dynamic> data = {
      "title" : title,
      "body" : bodyText
    };
    if(isShared){
      data.addAll({
        "id" : noteId
      });
    }
    return data;
  }
}