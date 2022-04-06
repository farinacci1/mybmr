import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mybmr/models/AppUser.dart';

import 'package:mybmr/services/custom_rect_twenn.dart';
import 'package:mybmr/views/creationMenus/builders/Profilebuilder.dart';
import 'package:provider/provider.dart';

import '../../../constants/Themes.dart';
import '../../../notifiers/EquipmentNotifier.dart';
import '../../../notifiers/FavoritesNotifier.dart';
import '../../../notifiers/IngredientNotifier.dart';
import '../../../notifiers/MealPlanNotifier.dart';
import '../../../notifiers/UserListNotifier.dart';
import '../../../notifiers/UserNotifier.dart';

class SettingsPopup extends StatefulWidget {
  @override
  _SettingsPopupState createState() => _SettingsPopupState();
}

class _SettingsPopupState extends State<SettingsPopup> {
  static const String _SettingsPopup = "SETTINGS_POPUP";
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
    return Center(
        child: Hero(
            tag: _SettingsPopup,
            createRectTween: (begin, end) {
              return CustomRectTween(begin: begin, end: end);
            },
            child: Container(
                width: 344.5.h,
                child: Material(
                  elevation: 3,
                  color: color_palette["alternative"],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                            width: 304.75.h,
                            padding: EdgeInsets.only(bottom: 6, top: 3),
                            alignment: AlignmentDirectional.center,
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: color_palette["white"],
                                        width: 2))),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(FontAwesomeIcons.userCog,
                                      color: color_palette["white"],
                                    size: 37.1.h,
                                  ),
                                  Container(
                                    width: 15,
                                  ),
                                  Text(
                                    "Settings",
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 37.1.h,
                                      color: color_palette["white"],
                                    ),
                                  )
                                ])),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: color_palette["white"],
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(3)),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 304.75.h,
                                height: 59.625.h,
                                child: ElevatedButton(
                                    onPressed: () async {
                                      await Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return ProfileBuilder();
                                      }));
                                    },
                                    style: ElevatedButton.styleFrom(
                                        fixedSize: Size(304.75.h, 53.h),
                                        primary: color_palette["alternative"],
                                        onPrimary: color_palette["white"],
                                        shape: ContinuousRectangleBorder(),
                                        alignment:
                                            AlignmentDirectional.centerStart),
                                    child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Icon(FontAwesomeIcons.unlock,size: 21.2.h,),
                                          Text(
                                            " Edit Profile",
                                            style: TextStyle(
                                                fontSize: 23.85.h,
                                                color: Colors.white),
                                          )
                                        ])),
                              ),

                              Container(
                                width: 304.75.h,
                                height:59.625.h,
                                decoration: BoxDecoration(
                                    border: Border(
                                        top: BorderSide(
                                          color:Color(0xFFF9F6EE),
                                          width: 3,
                                        ))),
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
                                        fixedSize: Size(304.75.h, 53.h),
                                        primary: color_palette["alternative"],
                                        onPrimary: color_palette["white"],
                                        shape: ContinuousRectangleBorder(),
                                        alignment:
                                            AlignmentDirectional.centerStart),
                                    child:
                                    Row(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Icon(FontAwesomeIcons.signOutAlt,size: 21.2.h,),
                                          Text(
                                            " Logout",
                                            style: TextStyle(
                                                fontSize: 23.85.h,
                                                color: Colors.white),
                                          )
                                        ])
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ))));
  }
}
