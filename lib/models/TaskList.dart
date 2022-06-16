import '../abstractions/UserListItem.dart';

class TaskList implements ListItem{

  List<String> subtasks;
  List<bool> hasCompleted;


  TaskList({this.subtasks,this.hasCompleted});

  TaskList.fromJSON(Map<String,dynamic> data){
    subtasks = List.from(data["subtasks"]);
    hasCompleted = List.from(data["hasCompleted"]);
  }


  @override
  Map<String,dynamic> toJSON({bool isShared = false}){
    Map<String,dynamic> data = {
      "subtasks" : subtasks,
      "hasCompleted" :hasCompleted
    };
    return data;
  }
}