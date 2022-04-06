

import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/services.dart';

enum PlatformType{
  IOS,
  ANDROID,
  OTHER
}
class PlatformManager{

  static PlatformType getPlatformType() {
    if(Platform.isIOS) return PlatformType.IOS;
    if(Platform.isAndroid) return PlatformType.ANDROID;
    return PlatformType.OTHER;
  }

  static Future<String> getDeviceId() async {
    String identifier = "";
    final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        var build = await deviceInfoPlugin.androidInfo;
        identifier = build.androidId;
      }
      else if (Platform.isIOS) {
        var data = await deviceInfoPlugin.iosInfo;
        identifier = data.identifierForVendor;
      }
    }on PlatformException {
      print('Failed to get platform version');

    }
    return identifier;
  }
}