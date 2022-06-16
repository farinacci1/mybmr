

import 'dart:ui';

class Dimensions{

  double _idealWidth;
  double _idealHeight;
  double _deviceWidth;
  double _deviceHeight;
  static Dimensions _instance;
  Dimensions._();
  static Dimensions get instance => _instance ??= Dimensions._();


  Dimensions({
    double deviceWidth,
    double deviceHeight,
    Size designSize
}){
    _idealWidth = designSize.width;
    _idealHeight = designSize.height;
    _deviceHeight = deviceHeight;
    _deviceWidth = deviceWidth;
  }

  double get h{
    return _deviceHeight / _idealHeight;
  }
  double get w{
    return _deviceWidth / _idealWidth;
  }
}