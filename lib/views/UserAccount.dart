import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mybmr/services/helper.dart';
import 'package:mybmr/views/RecipePageView.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../constants/Themes.dart';
import '../constants/messages/en_messages.dart';
import '../models/AppUser.dart';
import '../services/conversion.dart';
import 'creationMenus/builders/Profilebuilder.dart';

class UserAccount extends StatefulWidget {
  @override
  _UserAccountState createState() => _UserAccountState();
}

class _UserAccountState extends State<UserAccount>
    with SingleTickerProviderStateMixin {
  File imageFile;
  TabController _tabController;
  int tabIdx = 0;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    if (_refreshController != null) _refreshController.dispose();

    super.dispose();
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
        backgroundColor: color_palette["white"],
        appBar: AppBar(
          backgroundColor: color_palette["background_color"],
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: color_palette["background_color"],
          ),
          toolbarHeight: 0.0,
          bottom: PreferredSize(
              preferredSize: Size.fromHeight(325.h),
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 30),
                      alignment: AlignmentDirectional.center,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                                onTap: () async {
                                  await Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                        return ProfileBuilder();
                                      }));

                                },
                                child:
                            Container(
                              width: 30,
                              child: Icon(MaterialIcons.more_vert,
                                  color: color_palette["white"]),
                            )),
                            Text(
                              "My Profile",
                              style: TextStyle(
                                  fontSize: 40.h,
                                  color: color_palette["white"]),
                            ),
                            Container(
                              width: 30,
                              child: Icon(MaterialIcons.search,
                                  color: color_palette["white"]),
                            ),
                          ]),
                    ),
                    Container(
                        height: 105.h,
                        width: 105.h,
                        decoration: BoxDecoration(
                            color: color_palette["overlay"],
                            borderRadius: BorderRadius.circular(105.h / 2)),
                        child: imageFile != null
                            ? CircleAvatar(
                                backgroundImage: FileImage(imageFile),
                                radius: 105.h,
                              )
                            : AppUser.instance.profileImagePath != null
                                ? buildImage(
                                    AppUser.instance.profileImagePath,
                                    height: 105.h,
                                    width: 105.h,
                                    boxFit: BoxFit.cover,
                                    radius: BorderRadius.circular(105.h),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                    Container(
                      width: MediaQuery.of(context).size.width,
                      alignment: AlignmentDirectional.center,
                      padding: EdgeInsets.only(top: 15, bottom: 10),
                      child: Text(
                        '@' +AppUser.instance.userName,
                        style: TextStyle(
                            color: color_palette["white"], fontSize: 28.h),
                      ),
                    ),
                    Container(
                      height: 48.h,
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      margin: EdgeInsets.only(bottom: 2),
                      child: TabBar(
                        indicatorColor: Colors.white70,
                        controller: _tabController,
                        onTap: (int idx) {
                          setState(() {
                            tabIdx = idx;

                          });
                        },
                        tabs: [
                          Container(
                            width: MediaQuery.of(context).size.width / 3 - 10,
                            alignment: AlignmentDirectional.center,
                            child: Text(
                              'About',
                              style: TextStyle(
                                  color: color_palette['white'],
                                  fontSize: 125.w),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 3 - 10,
                            alignment: AlignmentDirectional.center,
                            child: Text('Creations',
                                style: TextStyle(
                                    color: color_palette['white'],
                                    fontSize: 125.w)),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 3 - 10,
                            alignment: AlignmentDirectional.center,
                            child: Text(
                              'Favorites',
                              style: TextStyle(
                                  color: color_palette['white'],
                                  fontSize: 125.w),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              )),
        ),
        body: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (overscroll) {
              overscroll.disallowIndicator();
              return;
            },
            child: TabBarView(
              controller: _tabController,
              children: [
                showAboutPage(),
                showCreationsPage(),
                showFavoritesPage()
              ],
            )));
  }

  Widget showAboutPage() {

    return CustomScrollView(primary: false, slivers: [
      SliverToBoxAdapter(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                alignment: AlignmentDirectional.topStart,
                child: Text(
                  "About",
                  maxLines: 1,
                  style: TextStyle(
                      fontSize: 24.h,
                      color: color_palette["background_color"],
                      fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                  margin: EdgeInsets.symmetric(vertical: 2, horizontal: 14),
                  alignment: AlignmentDirectional.topStart,
                  child: Text(
                    AppUser.instance.aboutUser ?? "",
                    style: TextStyle(
                        fontSize: 28.h,
                        color: color_palette["background_color"]),
                  )),
            ],
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                alignment: AlignmentDirectional.topStart,
                child: Text(
                  "Stats",
                  maxLines: 1,
                  style: TextStyle(
                      fontSize: 24.h,
                      color: color_palette["background_color"],
                      fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: Container(
                      height: 90.h,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                          color: color_palette["background_color"],
                          borderRadius: BorderRadius.circular(3)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Created\n${Conversion.nFormatter(AppUser.instance.numCreated ?? 0, 1)}",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 26.h,
                                color: color_palette["white"],
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Liked\n${Conversion.nFormatter(AppUser.instance.numLiked ?? 0, 1)}",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 26.h,
                                color: color_palette["white"],
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Followers\n${Conversion.nFormatter(AppUser.instance.numFollowedBy ?? 0, 1)}",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 26.h,
                                color: color_palette["white"],
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Following\n${Conversion.nFormatter(AppUser.instance.numFollowing ?? 0, 1)}",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 26.h,
                                color: color_palette["white"],
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      )))
            ])),
      ),
    ]);
  }

  Widget showCreationsPage() {

   return RecipePageView(mode: 1);
  }

  Widget showFavoritesPage() {

    return RecipePageView(mode: 2);
  }
}
