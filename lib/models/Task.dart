import '../abstractions/UserListItem.dart';

class UserTask implements ListItem{

  String id;
  String title;
  List<String> subtasks;
  List<bool> hasCompleted;


  UserTask({this.id,this.title,this.subtasks,this.hasCompleted});

  UserTask.fromJSON(Map<String,dynamic> data,String taskId){
    id = taskId;
    title = data["title"];
    subtasks = List.from(data["subtasks"]);
    hasCompleted = List.from(data["hasCompleted"]);
  }


  @override
  Map<String,dynamic> toJSON({bool isShared = false}){
    Map<String,dynamic> data = {
      "title" :title,
      "subtasks" : subtasks,
      "hasCompleted" :hasCompleted
    };
    if(isShared){
      data.addAll({
        "id" : id
      });
    }
    return data;
  }
}