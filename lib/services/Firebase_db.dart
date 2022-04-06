import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:mybmr/models/AppUser.dart';
import 'package:mybmr/models/MealPlan.dart';
import 'package:mybmr/models/ShoppingList.dart';
import 'package:mybmr/models/UserNote.dart';
import 'package:mybmr/services/conversion.dart';
import 'package:path/path.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mybmr/models/Equipment.dart';
import 'package:mybmr/models/Ingredient.dart';
import 'package:mybmr/models/Recipe.dart';

import '../models/Task.dart';

class FirebaseDB {
  /*
  * Primary class that should handle all interactions with firebase.
  * Other classed that need to communicate with firebase should not make calls directly and instead leverage functions from this class
  * */

  static Future<DocumentSnapshot> createUserIfNotExists(String uid) async {
    CollectionReference users = FirebaseFirestore.instance.collection('Users');
    DocumentSnapshot ds = await users.doc(uid).get();
    if(!ds.exists){
      await users.doc(uid).set({
        "myCreationIds" :[],
        "mealPlanIds" : [],
        "likedRecipesIds": [],
        "reportedRecipesIds":[],
        "myFriends" : [],
        "userName": uid,
        "profileImage":null,
        "aboutUser" : "",
        "following" : [],
        "followedBy" : 0

      });
      await FirebaseFirestore.instance.collection('Aggregate').doc('Stats').collection('Users').doc('stats').update({
        "count" : FieldValue.increment(1)
      });
    }
    return ds;
  }
  static Future<bool> isUsernameAvailable(String username) async {
    final result = await FirebaseFirestore.instance
        .collection('Users')
        .where('userName', isEqualTo: username)
        .get();
    return result.size == 0;
  }



  static Future<void> _addToCreations(String recipeId,String userId) async {
    await FirebaseFirestore.instance.collection('Users').doc(userId).update({
      "myCreationIds" : FieldValue.arrayUnion([recipeId])
    });
  }
  static Future<void> likeRecipe(String recipeId,String userId) async {
    await FirebaseFirestore.instance.collection('Users').doc(userId).update({
      "likedRecipesIds" : FieldValue.arrayUnion([recipeId])
    });
  }
  static Future<void> unlikeRecipe(String recipeId,String userId) async {
    await FirebaseFirestore.instance.collection('Users').doc(userId).update({
      "likedRecipesIds" : FieldValue.arrayRemove([recipeId])
    });
  }



  static Future<DocumentSnapshot> insertIngredient(
      Ingredient ingredient,{String creatorsId}) async {
    int createdOn = DateTime.now().millisecondsSinceEpoch;
    CollectionReference ingredients =
        FirebaseFirestore.instance.collection('Ingredients');
    Map<String, dynamic> ingredMap = ingredient.toJSON();
    String imagePath = await _uploadImage(ingredMap["IngredientImage"]);
    String ingredientName = ingredMap["IngredientName"].toString().toLowerCase();
    ingredMap.remove("IngredientImage");
    ingredMap.update("IngredientName", (value) => ingredientName);
    ingredMap.addAll({
      "PossibleNames":Conversion.tokenizeByWordChar(ingredMap["IngredientName"]),
      "IngredientImage": imagePath,
      "createdOn": createdOn,
      "usedIn": 0,
      "createdBy": creatorsId
    });
    DocumentReference ref = await ingredients.add(ingredMap);
    await FirebaseFirestore.instance.collection('Aggregate').doc('Stats').collection('Ingredients').doc('stats').update({
      "count" : FieldValue.increment(1)
    });
    return ref.get();
  }
  static Future<String> insertRecipe(Recipe recipe, {String creatorsId}) async {
    Map<String, dynamic> recipeMap = recipe.toJSON();
    CollectionReference recipes =
    FirebaseFirestore.instance.collection('Recipes');
    String imagePath = await _uploadImage(recipeMap["recipeImage"]);
    List<String> keywords = Conversion.tokenizeByPermutations(recipeMap["recipeName"]);
    recipeMap.remove("recipeImage");
    int createdOn = DateTime.now().millisecondsSinceEpoch;
    recipeMap.addAll({
      "RecipeImage": imagePath,
      "usedIn": 0,
      "createdOn": createdOn,
      "PossibleNames": keywords,
      "containsPii_Flag": 0,
      "isNSFW_Flag": 0,
      "isViolentOrOffensive_Flag": 0,
      "invalidRecipe_Flag": 0,
      "adminDown": false,
      "createdBy": creatorsId,
      "caloriesPerServ" : recipeMap["totalCalories"] / recipeMap["peopleServed"],
      "updatedOn" : createdOn,
      "numLikes" : 0

    });
    DocumentReference ref = await recipes.add(recipeMap);


    await FirebaseFirestore.instance.collection('Aggregate').doc('Stats').collection('Recipes').doc('stats').update({
      "count" : FieldValue.increment(1)
    });
    await _addToCreations(ref.id,creatorsId);
    for (String id in recipeMap["neededEquipment"]) {
      await updateEquipmentCounter(id);
    }
    for (Map<String, dynamic> ri in recipeMap["recipeIngredients"]) {
      await (updateIngredientCounter(ri["ingredientId"]));
    }
    return ref.id;
  }
  static Future<String> insertShoppingList( ShoppingList shoppingList,{String creatorsId}) async{
    Map<String,dynamic> map =shoppingList.toJSON();
    map.addAll({
      "createdOn": DateTime.now().millisecondsSinceEpoch,
      "updatedOn" : DateTime.now().millisecondsSinceEpoch,
      "createdBy": creatorsId
    });
    DocumentReference ref =await FirebaseFirestore.instance.collection('UserLists').doc(creatorsId).collection("AllList").add(map);
    DocumentSnapshot orderSnapshot = await FirebaseFirestore.instance.collection('UserLists').doc(creatorsId).collection("AllList").doc("order").get();
    if(orderSnapshot.exists){
      FirebaseFirestore.instance.collection('UserLists').doc(creatorsId).collection("AllList").doc("order").update(
          {
            "priorityOrder" : FieldValue.arrayUnion([ref.id]) // priority order if a reversed list
          });
    }else{
      FirebaseFirestore.instance.collection('UserLists').doc(creatorsId).collection("AllList").doc("order").set(
          {
            "priorityOrder" : [ref.id] // priority order if a reversed list
          });
    }

    return ref.id;
  }
  static Future<String> insertUserTask( UserTask task,{String creatorsId}) async{
    Map<String,dynamic> map =task.toJSON();
    map.addAll({
      "createdOn": DateTime.now().millisecondsSinceEpoch,
      "updatedOn" : DateTime.now().millisecondsSinceEpoch,
      "createdBy": creatorsId
    });
    DocumentReference ref =await FirebaseFirestore.instance.collection('UserLists').doc(creatorsId).collection("AllList").add(map);
    DocumentSnapshot orderSnapshot = await FirebaseFirestore.instance.collection('UserLists').doc(creatorsId).collection("AllList").doc("order").get();
    if(orderSnapshot.exists){
      FirebaseFirestore.instance.collection('UserLists').doc(creatorsId).collection("AllList").doc("order").update(
          {
            "priorityOrder" : FieldValue.arrayUnion([ref.id]) // priority order if a reversed list
          });
    }else{
      FirebaseFirestore.instance.collection('UserLists').doc(creatorsId).collection("AllList").doc("order").set(
          {
            "priorityOrder" : [ref.id] // priority order if a reversed list
          });
    }

    return ref.id;
  }
  static Future<String> insertUserNote( UserNote userNote,{String creatorsId}) async{
    Map<String,dynamic> map =userNote.toJSON();
    map.addAll({
      "createdOn": DateTime.now().millisecondsSinceEpoch,
      "updatedOn" : DateTime.now().millisecondsSinceEpoch,
      "createdBy": creatorsId
    });
    DocumentReference ref =await FirebaseFirestore.instance.collection('UserLists').doc(creatorsId).collection("AllList").add(map);
    DocumentSnapshot orderSnapshot = await FirebaseFirestore.instance.collection('UserLists').doc(creatorsId).collection("AllList").doc("order").get();
    if(orderSnapshot.exists){
      FirebaseFirestore.instance.collection('UserLists').doc(creatorsId).collection("AllList").doc("order").update(
          {
            "priorityOrder" : FieldValue.arrayUnion([ref.id]) // priority order if a reversed list
          });
    }else{
      FirebaseFirestore.instance.collection('UserLists').doc(creatorsId).collection("AllList").doc("order").set(
          {
            "priorityOrder" : [ref.id] // priority order if a reversed list
          });
    }

    return ref.id;
  }
  static Future<String> insertMealPlan(String uid, MealPlan mealPlan) async{

    DocumentReference ref =await FirebaseFirestore.instance.collection('MealPlans').doc(uid).collection("PlannedRecipes").add(mealPlan.toJson());
    return ref.id;
  }
  static Future<DocumentSnapshot> insertEquipment(Equipment equip,{String creatorsId}) async {
    CollectionReference equipment =
    FirebaseFirestore.instance.collection('Equipment');
    Map<String, dynamic> equipMap = equip.toJson();
    String imagePath = await _uploadImage(equipMap["equipmentImage"]);

    int createdOn = DateTime.now().millisecondsSinceEpoch;
    DocumentReference ref = await equipment.add({
      "equipmentName": equipMap["equipmentName"].toString().toLowerCase(),
      "equipmentImage": imagePath,
      "PossibleNames": Conversion.tokenizeByWordChar(equipMap["equipmentName"]),
      "createdOn": createdOn,
      "usedIn": 0,
      "createdBy": creatorsId
    });
    await FirebaseFirestore.instance.collection('Aggregate').doc('Stats').collection('Equipment').doc('stats').update({
      "count" : FieldValue.increment(1)
    });
    return ref.get();
  }

  static Future<String> updateUserProfile({String username, String userId,File profileImage,String aboutMe}) async {
    String imagePath = AppUser.instance.profileImagePath;

    if(profileImage != null){
      if(imagePath == null || imagePath.length == 0)
       imagePath = await _uploadImage(profileImage, );
      else
        imagePath = await _uploadImage(profileImage,path: imagePath );
    }
   await FirebaseFirestore.instance.collection('Users').doc(userId).update({
     "userName": username,
     "aboutUser" :aboutMe,
     "profileImage" : imagePath
   });
    return imagePath;

  }
  static Future<void> updateRecipe(
      {Recipe updatedRecipe,
        List<String> newEquipmentIds,
        List<String> newIngredientIds}) async {
    Map<String, dynamic> recipeMap = updatedRecipe.toJSON();
    recipeMap.addAll({
      "PossibleNames" : Conversion.tokenizeByPermutations(recipeMap["recipeName"]),
      "updatedOn" : DateTime.now().millisecondsSinceEpoch,
      "caloriesPerServ" : recipeMap["totalCalories"] / recipeMap["peopleServed"]
    });
    if (recipeMap["recipeImage"] != null) {

      String imagePath = await _uploadImage(recipeMap["recipeImage"], path: updatedRecipe.recipeImageFromDB);
      recipeMap.addAll({
        "RecipeImage": imagePath,
      });
    }

    recipeMap.remove("recipeImage");
    //update recipe entry
    await FirebaseFirestore.instance
        .collection('Recipes')
        .doc(updatedRecipe.id)
        .update(recipeMap);

    if(newEquipmentIds != null){
      for (String id in newEquipmentIds) {
        await updateEquipmentCounter(id);
      }
    }
    if(newIngredientIds != null){
      for (String id in newIngredientIds) {
        await (updateIngredientCounter(id));
      }
    }


  }
  static Future<void> updateListOrder(List<String> order,{String creatorsId }) async {
    await FirebaseFirestore.instance.collection('UserLists').doc(creatorsId).collection("AllList").doc("order").update(
        {
          "priorityOrder" : order.reversed.toList() // priority order if a reversed list
        });
  }

  static Future<void> updateShoppingList( ShoppingList shoppingList,{String creatorsId}) async{
    Map<String,dynamic> map =shoppingList.toJSON();
    map.addAll({
      "updatedOn" : DateTime.now().millisecondsSinceEpoch,
    });

    return await FirebaseFirestore.instance.collection('UserLists').doc(creatorsId).collection("AllList").doc(shoppingList.listId).update(map);
  }
  static Future<void> updateUserNote( UserNote userNote,{String creatorsId}) async{
    Map<String,dynamic> map =userNote.toJSON();
    map.addAll({
      "updatedOn" : DateTime.now().millisecondsSinceEpoch,
    });

    return await FirebaseFirestore.instance.collection('UserLists').doc(creatorsId).collection("AllList").doc(userNote.noteId).update(map);
  }
  static Future<void> updateUserTask( UserTask userTask,{String creatorsId}) async{
    Map<String,dynamic> map =userTask.toJSON();
    map.addAll({
      "updatedOn" : DateTime.now().millisecondsSinceEpoch,
    });

    return await FirebaseFirestore.instance.collection('UserLists').doc(creatorsId).collection("AllList").doc(userTask.id).update(map);
  }
  static Future<void> updateIngredientCounter(String ingredientId) async {
    CollectionReference ingredients =
        FirebaseFirestore.instance.collection('Ingredients');
    await ingredients
        .doc(ingredientId)
        .update({"usedIn": FieldValue.increment(1)});
  }
  static Future<void> updateRecipeCounter(String recipeId) async {
    CollectionReference recipes =
        FirebaseFirestore.instance.collection('Recipes');
    await recipes.doc(recipeId).update({"usedIn": FieldValue.increment(1)});
  }
  static Future<void> updateEquipmentCounter(String equipmentId) async {
    CollectionReference equipment =
        FirebaseFirestore.instance.collection('Equipment');
    await equipment
        .doc(equipmentId)
        .update({"usedIn": FieldValue.increment(1)});
  }
  static Future<void> updateRecipeFlags(String recipeId, int flag,{String flaggersId}) async {


    CollectionReference recipes =
    FirebaseFirestore.instance.collection('Recipes');
    if (flag == 1)
      await recipes
          .doc(recipeId)
          .update({"containsPii_Flag": FieldValue.increment(1)});
    if (flag == 2)
      await recipes
          .doc(recipeId)
          .update({"isNSFW_Flag": FieldValue.increment(1)});
    if (flag == 3)
      await recipes
          .doc(recipeId)
          .update({"isViolentOrOffensive_Flag": FieldValue.increment(1)});
    if (flag == 4)
      await recipes
          .doc(recipeId)
          .update({"invalidRecipe_Flag": FieldValue.increment(1)});
    await FirebaseFirestore.instance.collection('Users').doc(flaggersId).update({
      "reportedRecipesIds" : FieldValue.arrayUnion([recipeId])
    });
  }
  static Future<DocumentSnapshot> fetchAppStats() async{
    return await FirebaseFirestore.instance.collection("Aggregate").doc('Stats').collection('App').doc('Stats').get();
  }
  static Future<DocumentSnapshot> fetchUserById(String userId) async{
     return await FirebaseFirestore.instance.collection('Users').doc(userId).get();
  }

  static Future<QuerySnapshot> fetchRecipesByTitle(String title, double calories, {int limit = 5,DocumentSnapshot lastDoc})async{
    Query q =  FirebaseFirestore.instance.collection("Recipes")
        .where("PossibleNames", arrayContains: title)
        .where("caloriesPerServ", isLessThanOrEqualTo:  calories)
        .orderBy("caloriesPerServ")
        .orderBy("createdOn",descending: true);

    if(lastDoc != null){
      q = q.startAfterDocument(lastDoc);
    }
    return await q.limit(limit).get();
  }
  static Future<QuerySnapshot> fetchRecipesByCuisine(String cuisine, double calories, {int limit = 5,DocumentSnapshot lastDoc})async{
    Query q =  FirebaseFirestore.instance.collection("Recipes")
        .where("mealTimes", arrayContains: cuisine)
        .where("caloriesPerServ", isLessThanOrEqualTo:  calories)
        .orderBy("caloriesPerServ")
        .orderBy("createdOn",descending: true);
    if(lastDoc != null){
      q = q.startAfterDocument(lastDoc);
    }
    return await q.limit(limit).get();
  }

  static Future<QuerySnapshot> fetchRecipeByDiet(String diet, double calories, {int limit = 5,DocumentSnapshot lastDoc})async{
    Query q =  FirebaseFirestore.instance.collection("Recipes")
        .where("diets", arrayContains: diet)
        .where("caloriesPerServ", isLessThanOrEqualTo:  calories)
        .orderBy("caloriesPerServ")
        .orderBy("createdOn",descending: true);
    if(lastDoc != null){
      q = q.startAfterDocument(lastDoc);
    }
    return await q.limit(limit).get();
  }
  static Future<QuerySnapshot> fetchRecipesByNew( {int limit = 5,DocumentSnapshot lastDoc})async{
    Query q =  FirebaseFirestore.instance.collection("Recipes")
        .orderBy("createdOn",descending: true);
    if(lastDoc != null){
      q = q.startAfterDocument(lastDoc);
    }
    return await q.limit(limit).get();
  }


  static Future<DocumentSnapshot> fetchRecipeById(String reference) async {
    CollectionReference recipes =
        FirebaseFirestore.instance.collection('Recipes');
    DocumentReference ref = recipes.doc(reference);
    return await ref.get();
  }
  static Future<DocumentSnapshot> fetchUserListIds(String userId) async {
    return await FirebaseFirestore.instance.collection('UserLists').doc(userId).collection("AllList").doc("order").get();
  }
  static Future<DocumentSnapshot> fetchUserListById(String listId,{String creatorsId}) async{
    return await FirebaseFirestore.instance.collection('UserLists').doc(creatorsId).collection("AllList").doc(listId).get();

  }

  static Future<DocumentSnapshot> fetchIngredientsById(String reference) async {
    CollectionReference ingredients =
        FirebaseFirestore.instance.collection('Ingredients');
    DocumentReference ref = ingredients.doc(reference);
    return await ref.get();
  }

  static Future<QuerySnapshot> fetchIngredientByContains({
    String possibleName,
    DocumentSnapshot documentSnapshot,
    int limit
  })async{
    String searchTerm = possibleName.toLowerCase();
    CollectionReference ingredients =
    FirebaseFirestore.instance.collection('Ingredients');
    Query query = ingredients
        .where('PossibleNames',
        arrayContains: searchTerm)
        .orderBy("IngredientName", descending: false)
        .orderBy("usedIn", descending: true);

    if (documentSnapshot != null) {
      query = query.startAfterDocument(documentSnapshot);
    }
    return await query.limit(limit).get();
  }


  static Future<QuerySnapshot<Map<String, dynamic>>>fetchMealPlans(String uid,{int numDaysBack = 7}) async{

    DateTime nowDate = DateTime.now();
    int startDate = DateTime(nowDate.year,nowDate.month,nowDate.day).subtract(Duration(days: numDaysBack)).millisecondsSinceEpoch;
    return await FirebaseFirestore.instance.collection('MealPlans').doc(uid).collection("PlannedRecipes").where("dateMillis",isGreaterThanOrEqualTo:startDate ).get();
  }

  static Future<DocumentSnapshot> fetchEquipmentById(String reference) async {
    CollectionReference equipment =
        FirebaseFirestore.instance.collection('Equipment');
    DocumentReference ref = equipment.doc(reference);
    return await ref.get();
  }


  static Future<QuerySnapshot> fetchEquipmentByContains({
    String possibleName,
    DocumentSnapshot documentSnapshot,
    int limit
  })async{
    String searchTerm = possibleName.toLowerCase();
    CollectionReference ingredients =
    FirebaseFirestore.instance.collection('Equipment');
    Query query = ingredients
        .where('PossibleNames',
        arrayContains: searchTerm)
        .orderBy("equipmentName", descending: false)
        .orderBy("usedIn", descending: true);

    if (documentSnapshot != null) {
      query = query.startAfterDocument(documentSnapshot);
    }
    return await query.limit(limit).get();
  }

  static Future<void> deleteMealPlan(String uid, String mealPlanId)async{
    await FirebaseFirestore.instance.collection('MealPlans').doc(uid).collection("PlannedRecipes").doc(mealPlanId).delete();
  }

  static Future<void> deleteListItem(String listItemId,{String creatorsId}) async{

    await FirebaseFirestore.instance.collection('UserLists').doc(creatorsId).collection("AllList").doc("order").update(
        {
          "priorityOrder" : FieldValue.arrayRemove([listItemId]) // priority order if a reversed list
        });

    return await FirebaseFirestore.instance.collection('UserLists').doc(creatorsId).collection("AllList").doc(listItemId).delete();


  }

  static Future<String> _uploadImage(File _image, {String path}) async {
    /*
    * @Params: imageFile
    * uploads image to firebase's storage database
    * @returns a string representation of path to image
    * */

    Reference ref;
    if(path == null)
     ref = FirebaseStorage.instance
        .ref()
        .child(basename(_image.path) + DateTime.now().toString());
    else{
      String bucket = path.split('/').last;
      ref = FirebaseStorage.instance
          .ref()
          .child(bucket);
    }

    Uint8List imageData = await _testCompressFile(_image);
    UploadTask uploadTask = ref.putData(imageData);
    TaskSnapshot snapshot = await uploadTask;
    return snapshot.ref.getDownloadURL();
  }


  static Future<Uint8List> _testCompressFile(File file) async {
    return await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      minWidth: 256,
      minHeight: 256,
      quality: 94,
    );

  }







}
