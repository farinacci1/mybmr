
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mybmr/services/Firebase_db.dart';
import 'package:package_info_plus/package_info_plus.dart';


class AppManager{
  static String appVersion;
  static String appCode;
  static String supportedVersion;
  static String supportedCode;

  static Future<bool> isValidAppVersion() async {
    DocumentSnapshot documentSnapshot = await FirebaseDB.fetchAppStats();
    Map<String,dynamic> data = documentSnapshot.data();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appVersion = packageInfo.version;
    appCode = packageInfo.buildNumber;
    supportedCode = data['minimumCode'];
    supportedVersion = data['minimumSupportedVersion'];
    if(appVersion.compareTo(supportedVersion) < 0 && appCode.compareTo(supportedCode) < 0){
      return false;
    }else{
      return true;
    }

  }
}