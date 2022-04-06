import 'package:flutter/cupertino.dart';
import 'package:mybmr/constants/Constants.dart';




class SearchNotifier extends ChangeNotifier{
  /*
  * Used to control OverlaySearch and toggle between possible states of ingredients and equipment
  *
  * */
  MenuType _searchIn = MenuType.NONE;

  void reset(){
    _searchIn = MenuType.NONE;
  }


  MenuType get searchMode => _searchIn;
  set searchMode (MenuType searchMode){
    _searchIn = searchMode;
    notifyListeners();
  }

}