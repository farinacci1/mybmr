import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:mybmr/constants/Constants.dart';
import 'package:mybmr/models/AppUser.dart';
import 'package:mybmr/models/Equipment.dart';
import 'package:mybmr/services/Firebase_db.dart';
import 'package:mybmr/services/conversion.dart';


class EquipmentNotifier extends ChangeNotifier {
  /*
  * EquipmentNotifier used by recipeBuilder to obtain equipment from remote database and/or assign them to recipe being built
  *
  * */
  EquipmentState _equipmentState = EquipmentState.EQUIPMENT_LOADED;
  List<Equipment> _equipmentList_found = [];
  List<Equipment> _equipmentList_recentlyUsed = [];
  List<Equipment> _equipmentList_inUse = [];

  bool _optionSelected = false;




  set state(EquipmentState state) {
    _equipmentState = state;
    notifyListeners();
  }
  set optionSelected(bool select){
    this._optionSelected = select;
  }
  bool get optionSelected => this._optionSelected;

  EquipmentState get equipmentState => this._equipmentState;
  List<Equipment> get equipmentList_found => this._equipmentList_found;
  List<Equipment> get EquipmentList_recentlyUsed =>
      this._equipmentList_recentlyUsed;
  List<Equipment> get equipmentList_inUse => this._equipmentList_inUse;
  DocumentSnapshot _lastDocument;
  void clear() {
    this._equipmentState = EquipmentState.EQUIPMENT_LOADED;
    this._equipmentList_found.clear();
    this._equipmentList_inUse.clear();

  }
  void removeEquipmentFromRecipe(Equipment e){
    _equipmentList_inUse.remove(e);
    notifyListeners();
  }


  void addEquipmentToRecipe(Equipment equipment) {
    bool notContainsEquipment =  equipmentList_inUse.where((element) => element.id == equipment.id).isEmpty;
    bool notContainsEquipmentInRecent=  _equipmentList_recentlyUsed.where((element) => element.id == equipment.id).isEmpty;
    if(notContainsEquipment){
      equipmentList_inUse.add(equipment);
    }
    if(notContainsEquipmentInRecent) _equipmentList_recentlyUsed.add(equipment);
    if (_equipmentList_recentlyUsed.length > 20)
      _equipmentList_recentlyUsed.removeAt(0);
    notifyListeners();
  }

  void filterEquipmentOnline(String filter, int quantity,
      {bool isRestart = false}) {
    if (isRestart == true) {
      _lastDocument = null;
      _equipmentList_found = [];
    }
    String matchString = Conversion.prepString(filter);
    if (_equipmentState != EquipmentState.EQUIPMENT_REACHED_END &&
        _equipmentState != EquipmentState.EQUIPMENT_NOT_FOUND) {
        FirebaseDB.fetchEquipmentByContains(
                possibleName: matchString,
                documentSnapshot: _lastDocument,
                limit: quantity)
            .then((QuerySnapshot snapshot) {
          if (snapshot.docs.length == 0 && _equipmentList_found.length == 0)
            _equipmentState = EquipmentState.EQUIPMENT_NOT_FOUND;
          else if (snapshot.docs.length < quantity)
            _equipmentState = EquipmentState.EQUIPMENT_REACHED_END;
          else
            _equipmentState = EquipmentState.EQUIPMENT_LOADED;
          snapshot.docs.forEach((QueryDocumentSnapshot record) {

            Equipment equipment = Equipment.fromJson(record.data());
            equipment.id = record.id;
            _equipmentList_found.add(equipment);
          });
          _lastDocument = snapshot.docs.last;
        }).catchError((error) {
          if(_equipmentList_found.length > 0)_equipmentState = EquipmentState.EQUIPMENT_REACHED_END;
          else _equipmentState = EquipmentState.EQUIPMENT_NOT_FOUND;
          print(error.toString());

        }).whenComplete(() => notifyListeners());

    }
  }

  List<Equipment> filterEquipmentListRecentlyUsed(String filter) {
    return _equipmentList_recentlyUsed.where((Equipment equipment) {
      return equipment.name.toLowerCase().contains(filter);
    }).toList();
  }

  void createEquipment(Equipment equipment, {isForRecipe = true}) {
    FirebaseDB.insertEquipment(equipment).then((DocumentSnapshot record) {
      if(record != null){
          Equipment newEquipment = Equipment.fromJson(record.data());
          newEquipment.id = record.id;
          if(isForRecipe)this.addEquipmentToRecipe(newEquipment);
          else{
            this._equipmentList_recentlyUsed.add(newEquipment);
            notifyListeners();
          }
      }

    }).catchError((error) {
      print(error.toString());
    });
  }




  void getEquipmentList(List<String> ids){
    for(String id in ids){
      FirebaseDB.fetchEquipmentById(id).then((equipmentMap){
        Equipment fetchedEquipment = Equipment.fromJson(equipmentMap.data());
        fetchedEquipment.id = equipmentMap.id;
        _equipmentList_inUse.add(fetchedEquipment);
      }).whenComplete(() {
        if (id == ids[ids.length - 1]) notifyListeners();
      });
    }

  }

}
