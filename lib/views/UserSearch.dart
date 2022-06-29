import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mybmr/models/AppUser.dart';
import 'package:mybmr/services/Firebase_db.dart';
import 'package:provider/provider.dart';

import '../constants/Themes.dart';
import '../notifiers/LookupUserNotifier.dart';
import '../services/helper.dart';
import 'ProfileViewer.dart';

class UserSearch extends StatefulWidget {
  @override
  _UserSearchState createState() => _UserSearchState();
}

class _UserSearchState extends State<UserSearch> {
  Timer _timer;
  List<AppUser> foundUsers = [];
  Future<void> lookupUser(String userKey) async {
    if (_timer != null) _timer.cancel();
    if (userKey.length > 0) {
      _timer = new Timer(const Duration(milliseconds: 500), () {
        FirebaseDB.fetchUserByStartsWith(userKey)
            .then((QuerySnapshot querySnapshot) {
          foundUsers.clear();
          for (QueryDocumentSnapshot queryDocumentSnapshot
              in querySnapshot.docs) {
            AppUser appUser = AppUser.fromJSON(queryDocumentSnapshot.data());
            appUser.uuid = queryDocumentSnapshot.id;
            foundUsers.add(appUser);
          }
          setState(() {});
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: Size(2400, 1080),
      minTextAdapt: true,
    );
    return Scaffold(
      backgroundColor: color_palette["white"],
      appBar: AppBar(
        backgroundColor: color_palette["background_color"],
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: color_palette["background_color"],
        ),
        title: Text(
          "User Finder",
          style: TextStyle(fontSize: 28.h),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size(MediaQuery.of(context).size.width, 50.h + 16),
          child: Container(
            height: 50.h,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
            child: TextField(
              style: TextStyle(fontSize: 25.h),
              onChanged: (String newKey) {
                lookupUser(newKey);
              },
              decoration: InputDecoration(
                  filled: true,
                  fillColor: color_palette["white"],
                  hintText: "Search For Username...",
                  prefixIcon: Icon(Icons.search,
                      color: Theme.of(context).iconTheme.color),
                  contentPadding: EdgeInsets.only(
                    bottom: 50.h / 2 - 12.5.h, // HERE THE IMPORTANT PART
                  ),
                  hintStyle: TextStyle(
                    color: color_palette["background_color"],
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide:
                          BorderSide(color: color_palette["background_color"])),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(
                          color: color_palette["background_color"]))),
            ),
          ),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: ListView.builder(
            itemCount: foundUsers.length,
            itemBuilder: (BuildContext ctx, int idx) {
              return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    Provider.of<LookupUserNotifier>(context,listen: false).lookupUser = foundUsers[idx];
                    Provider.of<LookupUserNotifier>(context,listen: false).shouldRefresh(isMyRecipes: true);
                    Provider.of<LookupUserNotifier>(context,listen: false).shouldRefresh(isMyRecipes: false);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfileViewer(
                                appUser:   Provider.of<LookupUserNotifier>(context,listen: false).lookupUser
                            )));
                  },
                  child: Container(
                    height: 60.h + 20,
                    width: MediaQuery.of(ctx).size.width,
                    padding: EdgeInsets.fromLTRB(10, 10, 5, 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        (foundUsers[idx].profileImagePath == null ||
                                foundUsers[idx].profileImagePath == "")
                            ? Container(
                          width: 60.h,
                              height: 60.h,
                              decoration: BoxDecoration(
                                borderRadius:  BorderRadius.circular(60.h),
                                color:  Color(0XFF6D6D64)
                              ),
                            child:Icon(
                                FontAwesomeIcons.userAstronaut,
                                color: color_palette["white"],
                                size: 30.h,
                              ))
                            : buildImage(
                                foundUsers[idx].profileImagePath,
                                wrapperWidth: 60.h,
                                height: 60.h,
                                width: 60.h,
                                boxFit: BoxFit.cover,
                                radius: BorderRadius.circular(60.h),
                              ),
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text(foundUsers[idx].userName,
                              style: TextStyle(fontSize: 28.h)),
                        )
                      ],
                    ),
                  ));
            }),
      ),
    );
  }
}
