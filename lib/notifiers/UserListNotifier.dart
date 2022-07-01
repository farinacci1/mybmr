import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:mybmr/models/AppUser.dart';
import 'package:mybmr/models/ShoppingItem.dart';
import 'package:mybmr/models/TaskList.dart';

import 'package:mybmr/models/ShoppingList.dart';
import 'package:mybmr/services/Firebase_db.dart';



class UserListNotifier extends ChangeNotifier {
  bool isCurrentlyFetching = false;
  ShoppingList _groceryList =ShoppingList([], []);
  TaskList _taskList = TaskList(subtasks: [],hasCompleted: []);


  ShoppingList get groceryList => _groceryList;

  TaskList get taskList => _taskList;

  void clear(){
    _groceryList = ShoppingList([], []);
    _taskList =  TaskList(subtasks: [],hasCompleted: []);

  }
  void removeFromTaskList(int idx){
    if(AppUser.instance.isUserSignedIn()){
    _taskList.subtasks.removeAt(idx);
    _taskList.hasCompleted.removeAt(idx);
    FirebaseDB.updateUserTaskList(_taskList);
    notifyListeners();
    }
  }
  void addTaskToList(String task){
    if(AppUser.instance.isUserSignedIn()) {
      _taskList.subtasks.add(task);
      _taskList.hasCompleted.add(false);
      FirebaseDB.updateUserTaskList(_taskList);
      notifyListeners();
    }
  }
  void changeTaskState(int idx){
    if(AppUser.instance.isUserSignedIn()) {
      _taskList.hasCompleted[idx] = !_taskList.hasCompleted[idx];
      FirebaseDB.updateUserTaskList(_taskList);
      notifyListeners();
    }
  }
  void removeGroceryItem(int idx){
    if(AppUser.instance.isUserSignedIn()){
      _groceryList.shoppingItems.removeAt(idx);
      FirebaseDB.updateShoppingList(_groceryList);
      notifyListeners();
    }

  }
  void addGroceryItem(ShoppingItem shoppingItem){
    if(AppUser.instance.isUserSignedIn()){
      _groceryList.shoppingItems.add(shoppingItem);
      FirebaseDB.updateShoppingList(_groceryList);
      notifyListeners();
    }

  }

  void fetchUserList(){
    isCurrentlyFetching = true;
    FirebaseDB.fetchUserShoppingList().then((DocumentSnapshot record){
      if(record != null) _groceryList = ShoppingList.fromJSON(record.data());
    }).whenComplete(() {
      FirebaseDB.fetchUserTaskList().then((DocumentSnapshot record) {
        if(record != null)_taskList = TaskList.fromJSON(record.data());
      }).whenComplete((){
        isCurrentlyFetching = false;
        notifyListeners();
      } );
    });

  }


}