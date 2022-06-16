


import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

class MyImageCropper {
 static Future<File> cropImage(File imageFile) async {
   File croppedFile = await ImageCropper().cropImage(
       sourcePath: imageFile.path,
       aspectRatioPresets: [
         CropAspectRatioPreset.square,
         CropAspectRatioPreset.ratio3x2,
         CropAspectRatioPreset.original,
         CropAspectRatioPreset.ratio4x3,
         CropAspectRatioPreset.ratio16x9
       ],
       androidUiSettings: AndroidUiSettings(
           toolbarTitle: 'Cropper',
           toolbarColor: Colors.deepOrange,
           toolbarWidgetColor: Colors.white,
           initAspectRatio: CropAspectRatioPreset.original,
           lockAspectRatio: false),
       iosUiSettings: IOSUiSettings(
         minimumAspectRatio: 1.0,
       )
   );
   return croppedFile;
 }




}
