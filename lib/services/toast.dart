import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mybmr/services/PlatformManager.dart';

class CustomToast {
  /*
  * used to invoke platform default toast method and render message box overlaid on screen
  * */
  CustomToast(String message) {
    _showToast(message);
  }

  static const platform = const MethodChannel('toast.flutter.io/toast');

  void _showToast(String message)  {

    if (PlatformManager.getPlatformType() ==PlatformType.ANDROID)
    platform.invokeMethod('showToast', {'message': message});
    else Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
    );
  }
}