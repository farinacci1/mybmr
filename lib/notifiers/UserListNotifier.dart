import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mybmr/abstractions/UserListItem.dart';
import 'package:mybmr/models/AppUser.dart';
import 'package:mybmr/models/Task.dart';
import 'package:mybmr/models/UserNote.dart';
import 'package:mybmr/models/ShoppingList.dart';
import 'package:mybmr/services/Firebase_db.dart';

class UserListNotifier extends ChangeNotifier {
  bool isCurrentlyFetching = false;
  List<String> listIds = [];
  List<ListItem> userLists = [];
  static const int batchSz = 5;
  void clear(){
    userLists.clear();
    listIds.clear();
  }

  void fetchUsersListIds(){
    isCurrentlyFetching = true;

    FirebaseDB.fetchUserListIds(AppUser.instance.uuid).then((DocumentSnapshot documentSnapshot){
      Map<String,dynamic> data = documentSnapshot.data();
      listIds = List<String>.from(data["priorityOrder"]).reversed.toList();
      fetchListWithLimit(limit:batchSz);
    }).catchError((_){
    }).whenComplete((){

      isCurrentlyFetching = false;
    });
  }
  void reorderLists(int oldIdx, int newIdx){
    var listItem =  userLists[oldIdx];
    var listItemId = listIds[oldIdx];
    userLists.removeAt(oldIdx);
    listIds.removeAt(oldIdx);

    userLists.insert(newIdx, listItem);
    listIds.insert(newIdx, listItemId);
    FirebaseDB.updateListOrder(listIds,creatorsId: AppUser.instance.uuid).whenComplete(() => notifyListeners());

  }
  void createShoppingList(ShoppingList shoppingList){

    FirebaseDB.insertShoppingList(shoppingList, creatorsId: AppUser.instance.uuid).then((String listId) {
      shoppingList.listId = listId;
      userLists.insert(0,shoppingList);
      listIds.insert(0,listId);

    }).whenComplete(() {

      notifyListeners();
    });
  }
  void createNote(UserNote userNote){
    FirebaseDB.insertUserNote(userNote,creatorsId: AppUser.instance.uuid).then((String id) {
      userNote.noteId = id;
      userLists.insert(0,userNote);
      listIds.insert(0,id);
    }).catchError((err){
      print(err);
    }).whenComplete(() {
      notifyListeners();
    });
  }
  void createTask(UserTask userTask){
    FirebaseDB.insertUserTask(userTask,creatorsId: AppUser.instance.uuid).then((String id) {
      userTask.id = id;
      userLists.insert(0,userTask);
      listIds.insert(0,id);
    }).whenComplete(() {
      notifyListeners();
    });
  }
  void updateShoppingList(ShoppingList shoppingList){
    FirebaseDB.updateShoppingList(shoppingList).whenComplete(() {
      int changeIdx = listIds.indexOf(shoppingList.listId);
      userLists.removeAt(changeIdx);
      userLists.insert(changeIdx, shoppingList);
      notifyListeners();
    });
  }
  void updateNote(UserNote userNote){
    FirebaseDB.updateUserNote(userNote).whenComplete(() {
      int changeIdx = listIds.indexOf(userNote.noteId);
      userLists.removeAt(changeIdx);
      userLists.insert(changeIdx, userNote);
      notifyListeners();
    });
  }
  void updateTask(UserTask userTask){
    FirebaseDB.updateUserTask(userTask,creatorsId: AppUser.instance.uuid).whenComplete((){
      int changeIdx = listIds.indexOf(userTask.id);
      userLists.removeAt(changeIdx);
      userLists.insert(changeIdx, userTask);
      notifyListeners();
    });
  }
  void removeListItem(String itemId){
    FirebaseDB.deleteListItem(itemId,creatorsId: AppUser.instance.uuid).whenComplete(() {
      int idx = listIds.indexOf(itemId);
      listIds.removeAt(idx);
      userLists.removeAt(idx);
      notifyListeners();
    });

  }

  void fetchListWithLimit( {int limit = batchSz}){
    int fetchCount = max(min( listIds.length - userLists.length, limit),0);
    int offset = userLists.length;
    List<String> idTokens = listIds.sublist(offset,offset + fetchCount);
    if (idTokens.length > 0){
      Future.forEach(idTokens, (idToken) async{
        print("fetching token ${idToken}");
        DocumentSnapshot documentSnapshot = await FirebaseDB.fetchUserListById(idToken,creatorsId:AppUser.instance.uuid );
        if(documentSnapshot.exists){
          Map<String,dynamic> data = documentSnapshot.data();
          if(data.containsKey("body")){
            UserNote userNote = UserNote.fromJSON(data, documentSnapshot.id);
            userLists.add(userNote);

          }else if(data.containsKey("shoppingItems")){
            ShoppingList shoppingList = ShoppingList.fromJSON(data, documentSnapshot.id);
            userLists.add(shoppingList);
          }
        }
      }).whenComplete(() {
        notifyListeners();
      });
    }

  }

}