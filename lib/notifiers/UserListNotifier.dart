import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:mybmr/models/AppUser.dart';
import 'package:mybmr/models/ShoppingItem.dart';
import 'package:mybmr/models/TaskList.dart';

import 'package:mybmr/models/ShoppingList.dart';
import 'package:mybmr/services/Firebase_db.dart';

import '../models/Event.dart';

class UserListNotifier extends ChangeNotifier {
  bool isCurrentlyFetching = false;
  ShoppingList _groceryList =ShoppingList([], []);
  TaskList _taskList = TaskList(subtasks: [],hasCompleted: []);
  List<MyEvent> _eventList = [];
  bool isGroceryDirty = false;
  bool isTaskDirty = false;

  ShoppingList get groceryList => _groceryList;
  List<MyEvent> get eventList=> _eventList;
  TaskList get taskList => _taskList;

  void clear(){
    _groceryList = ShoppingList([], []);
    _taskList =  TaskList(subtasks: [],hasCompleted: []);
    _eventList = [];
  }
  void removeFromTaskList(int idx){
    _taskList.subtasks.removeAt(idx);
    _taskList.hasCompleted.removeAt(idx);
    isTaskDirty = true;
    notifyListeners();
  }
  void addTaskToList(String task){

    _taskList.subtasks.add(task);
    _taskList.hasCompleted.add(false);
    isTaskDirty = true;
    notifyListeners();
  }
  void changeTaskState(int idx){
    _taskList.hasCompleted[idx] = !_taskList.hasCompleted[idx];
    isTaskDirty = true;
    notifyListeners();
  }
  void removeGroceryItem(int idx){
    _groceryList.shoppingItems.removeAt(idx);
    isGroceryDirty = true;
    notifyListeners();
  }
  void addGroceryItem(ShoppingItem shoppingItem){
    _groceryList.shoppingItems.add(shoppingItem);
    isGroceryDirty = true;
    notifyListeners();
  }
  void addEvent(MyEvent myEvent){
    FirebaseDB.insertEvent(AppUser.instance.uuid, myEvent).then((String id) {
      myEvent.id = id;
      _eventList.add(myEvent);
      notifyListeners();
    });
  }
  void removeEvent(int idx){
    FirebaseDB.deleteEvent(AppUser.instance.uuid, _eventList.elementAt(idx).id).then((_) {
      _eventList.removeAt(idx);
      notifyListeners();
    });
  }
  void fetchUserList(){
    isCurrentlyFetching = true;
    FirebaseDB.fetchUserShoppingList(creatorsId: AppUser.instance.uuid).then((DocumentSnapshot record){
      _groceryList = ShoppingList.fromJSON(record.data());
    }).whenComplete(() {
      FirebaseDB.fetchUserTaskList(creatorsId: AppUser.instance.uuid).then((DocumentSnapshot record) {
        _taskList = TaskList.fromJSON(record.data());
      }).whenComplete((){
        isCurrentlyFetching = false;
        notifyListeners();
      } );
    });

  }

  
  void updateLists(ShoppingList shoppingList){

      if(isGroceryDirty){
        isGroceryDirty = false;
        FirebaseDB.updateShoppingList(_groceryList,creatorsId: AppUser.instance.uuid);
      }
      if(isTaskDirty){
        isTaskDirty = false;
        FirebaseDB.updateUserTaskList(_taskList,creatorsId: AppUser.instance.uuid);
      }
  }


}