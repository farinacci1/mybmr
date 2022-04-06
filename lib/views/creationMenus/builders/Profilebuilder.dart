import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mybmr/models/AppUser.dart';
import 'package:mybmr/services/Firebase_db.dart';

import '../../../constants/Themes.dart';
import '../../../constants/messages/en_messages.dart';
import '../../../services/toast.dart';
import '../../../widgets/HeaderBar.dart';
import '../../../widgets/ImageCropper.dart';

class ProfileBuilder extends StatefulWidget {
  @override
  _ProfileBuilderState createState() => _ProfileBuilderState();
}

class _ProfileBuilderState extends State<ProfileBuilder> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _aboutMeController = TextEditingController();
  File imageFile;
  ImagePicker _picker;
  @override
  void initState() {
    _picker = ImagePicker();
    if (AppUser.instance.userName != null)
      _usernameController.text = AppUser.instance.userName;
    if (AppUser.instance.aboutUser != null)
      _aboutMeController.text = AppUser.instance.aboutUser;
    super.initState();
  }

  Future<Null> _cropImage() async {
    Map<String, dynamic> output = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ImageCropper(
                  imageFile: imageFile,
                  aspectRatio: 1.0,
                )));
    imageFile = null;
    if (output != null) {
      if (output.containsKey("imageFile")) {
        imageFile = output["imageFile"];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
        BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width,
            maxHeight: MediaQuery.of(context).size.height),
        designSize: Size(2400, 1080),
        context: context,
        minTextAdapt: true,
        orientation: Orientation.portrait);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            gradient: color_palette["gradient"]
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            HeaderBar(
              popWidget: Icon(
                Icons.arrow_back,
                color: color_palette["white"],
                size: 31.8.h,
              ),
              onPopCallback: (){

              },
              title: "Profile Builder",

              submitWidget: Text(
                "Save",
                textScaleFactor: 1.0,
                style: TextStyle(color: color_palette["white"], fontSize: 20.h),

              ),
              submitColor: color_palette["text_color_dark"],
              submitCallback: () async {
                String username = _usernameController.value.text.trim();
                String aboutMe = _aboutMeController.value.text.trim();
                bool isAvailable = true;
                if (username != AppUser.instance.userName) {
                  isAvailable =
                      await FirebaseDB.isUsernameAvailable(username);
                }
                if (isAvailable) {
                  String imagePath = await FirebaseDB.updateUserProfile(
                      userId: AppUser.instance.uuid,
                      username: username,
                      aboutMe: aboutMe,
                      profileImage: imageFile);
                  AppUser.instance.profileImagePath = imagePath;
                  AppUser.instance.userName = username;
                  AppUser.instance.aboutUser = aboutMe;
                  Navigator.pop(context);
                } else {
                  CustomToast("Username already taken!");
                }
              },
            ),

            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          try {
                            XFile pickedFile = await _picker.pickImage(
                                source: ImageSource.gallery,
                                maxHeight: 1024,
                                maxWidth: 1024);
                            if (pickedFile != null) {
                              imageFile = File(pickedFile.path);
                              await _cropImage();
                              setState(() {});
                            }
                          } catch (_) {}
                        },
                        child: Container(
                            margin: EdgeInsets.symmetric(vertical: 20),
                            height: 200.h,
                            width: 200.h,
                            decoration: BoxDecoration(
                                color: color_palette["overlay"],
                                border:
                                    Border.all(color: color_palette["white"]),
                                borderRadius: BorderRadius.circular(200.h / 2)),
                            child: imageFile != null
                                ? CircleAvatar(
                                    backgroundImage: FileImage(imageFile),
                                    radius: 100.h,
                                  )
                                : AppUser.instance.profileImagePath != null
                                    ? CircleAvatar(
                                        backgroundImage: NetworkImage(
                                            AppUser.instance.profileImagePath),
                                        radius: 100.h,
                                      )
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                            Icon(
                                              Icons.add_a_photo,
                                              size: 47.5.h,
                                              color: color_palette["white"],
                                            ),
                                            Container(
                                              height: 2,
                                            ),
                                            Text(
                                              en_messages["photo_label"],
                                              style: TextStyle(
                                                  color: color_palette["white"],
                                                  fontSize: 17.225.h),
                                            )
                                          ])),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            en_messages["username_label"],
                            textScaleFactor: 1.0,
                            style: TextStyle(
                                color: color_palette["white"],
                                fontSize: 23.85.h,
                                fontWeight: FontWeight.bold),
                          ),
                          Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: 10),

                              child: TextField(
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(50),
                                ],
                                style: TextStyle(
                                    color: color_palette["white"], fontSize: 30.h,height:1.5),
                                controller: _usernameController,
                                onChanged: (str){
                                  setState(() {});
                                },

                                decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(vertical: 30.h/2,horizontal: 15.h),
                                    isDense: true,
                                    filled: true,
                                    fillColor: Colors.black54,
                                    hintText: "Username...",
                                    hintStyle: TextStyle(
                                      color: color_palette["white"],
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8.0),

                                        borderSide: BorderSide(
                                            color: color_palette["white"])),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8.0),

                                        borderSide: BorderSide(
                                            color: color_palette["white"]))),
                              )),

                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 15,
                          ),
                          Text(
                            en_messages["about_label"],
                            textScaleFactor: 1.0,
                            style: TextStyle(
                                color: color_palette["white"],
                                fontSize: 23.85.h,
                                fontWeight: FontWeight.bold),
                          ),
                          Container(
                              margin: EdgeInsets.only(top: 10),
                              child: TextField(
                                controller: _aboutMeController,
                                style: TextStyle(
                                    color: color_palette["white"], fontSize: 23.85.h),
                                maxLines: null,
                                autofocus: false,
                                textInputAction: TextInputAction.done,
                                decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.black54,
                                    hintText:
                                        "Add a description about yourself or your business...",
                                    hintStyle: TextStyle(
                                      color: color_palette["white"],
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: color_palette["white"])),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: color_palette["white"]))),
                              ))
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
