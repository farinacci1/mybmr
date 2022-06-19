import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mybmr/models/AppUser.dart';
import 'package:provider/provider.dart';

import '../../../constants/Themes.dart';
import '../../../constants/messages/en_messages.dart';

import '../../../notifiers/EquipmentNotifier.dart';
import '../../../notifiers/FavoritesNotifier.dart';
import '../../../notifiers/IngredientNotifier.dart';
import '../../../notifiers/MealPlanNotifier.dart';
import '../../../notifiers/UserListNotifier.dart';
import '../../../notifiers/UserNotifier.dart';
import '../../../services/Firebase_db.dart';
import '../../../services/helper.dart';
import '../../../services/toast.dart';
import '../../../widgets/ImageCropper.dart';

class ProfileBuilder extends StatefulWidget {
  @override
  _ProfileBuilderState createState() => _ProfileBuilderState();
}

class _ProfileBuilderState extends State<ProfileBuilder> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _aboutMeController = TextEditingController();
  TextEditingController _businessUrlController = TextEditingController();
  TextEditingController _youtubeUrlController = TextEditingController();
  TextEditingController _tiktokUrlController = TextEditingController();
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
      appBar:    AppBar(


        backgroundColor:  color_palette["background_color"] ,

        title: Text( "My Account",style: TextStyle(
            fontSize: 34.45.h,
            color: Colors.white,
            fontWeight: FontWeight.bold
        ),),
        actions: [
          IconButton(
            icon: Icon(MaterialIcons.send,),
            onPressed: ()async {
              String username = _usernameController.value.text.trim();
              String aboutMe = _aboutMeController.value.text.trim();
              String youtubeUrl = _youtubeUrlController.value.text.trim();
              String tiktoktUrl = _tiktokUrlController.value.text.trim();
              String websiteUrl = _businessUrlController.value.text.trim();
              bool isAvailable = true;
              if( username.length <= 2)         CustomToast("Username is to short!");
              else if (username != AppUser.instance.userName ) {
                isAvailable =
                await FirebaseDB.isUsernameAvailable(username);
              }
              if (isAvailable) {
                if(websiteUrl.startsWith( "https://"))AppUser.instance.businessUrl = websiteUrl;
                if(youtubeUrl.startsWith("https://www.youtube.com/watch?v="))AppUser.instance.youtubeUrl = youtubeUrl;
                if(tiktoktUrl.startsWith( "https://vm.tiktok.com/") || tiktoktUrl.startsWith( "https://www.tiktok.com/") )AppUser.instance.tiktokUrl = tiktoktUrl;
                String imagePath = await FirebaseDB.updateUserProfile(
                    username: username,
                    aboutMe: aboutMe,
                    profileImage: imageFile,
                  businessUrl: AppUser.instance.businessUrl,
                  tiktokUrl:  AppUser.instance.tiktokUrl,
                  youtubeUrl:  AppUser.instance.youtubeUrl
                );
                AppUser.instance.profileImagePath = imagePath;
                AppUser.instance.userName = username;
                AppUser.instance.aboutUser = aboutMe;


                Navigator.pop(context);
              } else {

                CustomToast("Username already taken!");
              }
            },
          ),
        ],

        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor:  color_palette["background_color"],
        ),

      ),

      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: color_palette["background_color"],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
                              imageFile = await MyImageCropper.cropImage(File(pickedFile.path));

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
                                    ? buildImage(
                              AppUser.instance.profileImagePath,
                              height: 200.h,
                              width: 200.h,
                              boxFit: BoxFit.cover,
                              radius: BorderRadius.circular(200.h),
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
                                    contentPadding: EdgeInsets.symmetric(vertical: 30.h/2,horizontal: 15.h),

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
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 15,
                          ),
                          Text(
                            "Business URL",
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
                                controller: _businessUrlController,
                                style: TextStyle(
                                    color: color_palette["white"], fontSize: 23.85.h),
                                maxLines: null,
                                autofocus: false,
                                textInputAction: TextInputAction.done,
                                decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(vertical: 30.h/2,horizontal: 15.h),

                                    filled: true,
                                    fillColor: Colors.black54,
                                    hintText:
                                    "https://",
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
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 15,
                          ),
                          Text(
                            "Youtube Channel",
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
                                controller: _youtubeUrlController,
                                style: TextStyle(
                                    color: color_palette["white"], fontSize: 23.85.h),
                                maxLines: null,
                                autofocus: false,
                                textInputAction: TextInputAction.done,
                                decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(vertical: 30.h/2,horizontal: 15.h),

                                    filled: true,
                                    fillColor: Colors.black54,
                                    hintText:
                                    "https://www.youtube.com/watch?v=",
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
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 15,
                          ),
                          Text(
                            "Tiktok Page",
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
                                controller: _tiktokUrlController,
                                style: TextStyle(
                                    color: color_palette["white"], fontSize: 23.85.h),
                                maxLines: null,
                                autofocus: false,
                                textInputAction: TextInputAction.done,
                                decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(vertical: 30.h/2,horizontal: 15.h),

                                    filled: true,
                                    fillColor: Colors.black54,
                                    hintText:
                                    "https://vm.tiktok.com/",
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
                      Container(
                        margin: EdgeInsets.only(top: 30),
                        height:59.625.h,
                        width: double.infinity,

                        child: ElevatedButton(
                            onPressed: () {
                              AppUser.instance.uuid = "";
                              Provider.of<EquipmentNotifier>(context,
                                  listen: false)
                                  .clear();
                              Provider.of<IngredientNotifier>(context,
                                  listen: false)
                                  .clear();
                              Provider.of<FavoritesNotifier>(context,
                                  listen: false)
                                  .clear();
                              Provider.of<MealPlanNotifier>(context,
                                  listen: false)
                                  .clear();
                              Provider.of<UserListNotifier>(context,
                                  listen: false)
                                  .clear();
                              Provider.of<UserNotifier>(context,
                                  listen: false)
                                  .logout();
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(

                                primary: color_palette["white"],
                                onPrimary: color_palette["background_color"],
                                shape: ContinuousRectangleBorder(),
                                alignment:
                                AlignmentDirectional.center),
                            child:
                            Text(
                              " Logout",
                              style: TextStyle(
                                fontSize: 23.85.h,
                                fontWeight: FontWeight.bold
                              ),
                            )
                        ),
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
