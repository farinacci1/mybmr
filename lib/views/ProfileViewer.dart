import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mybmr/notifiers/LookupUserNotifier.dart';
import 'package:mybmr/services/Firebase_db.dart';

import 'package:mybmr/services/helper.dart';
import 'package:mybmr/services/toast.dart';
import 'package:mybmr/views/RecipePageView.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/Themes.dart';
import '../models/AppUser.dart';

import '../services/conversion.dart';

class ProfileViewer extends StatefulWidget {
  final AppUser appUser;

  const ProfileViewer({Key key, @required this.appUser}) : super(key: key);
  @override
  _ProfileViewerState createState() => _ProfileViewerState();
}

class _ProfileViewerState extends State<ProfileViewer>
    with SingleTickerProviderStateMixin {
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
    Provider.of<LookupUserNotifier>(context, listen: true);
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
            "Viewing Profile",
            style: TextStyle(fontSize: 40.h, color: color_palette["white"]),
          ),
          actions: [
            GestureDetector(
              onTap: () {
                if(AppUser.instance.isUserSignedIn()){
                  if(AppUser.instance.following.contains(widget.appUser.uuid)){
                    FirebaseDB.followUser(AppUser.instance.uuid, widget.appUser.uuid).then((_) {
                      setState(() {
                        AppUser.instance.addFollow(widget.appUser.uuid);
                      });
                    });
                  }else{
                    FirebaseDB.unfollowUser(AppUser.instance.uuid, widget.appUser.uuid).then((_) {
                      setState(() {
                        AppUser.instance.unFollow(widget.appUser.uuid);
                      });
                    });
                  }
                }
              },
              child: Container(
                  padding: EdgeInsets.only(right: 15),
                  child: Icon(
                    AntDesign.book,
                    size: 38.h,
                    color: AppUser.instance.following.contains(widget.appUser.uuid) ? Colors.tealAccent : color_palette["white"],
                  )),
            )
          ],
          bottom: PreferredSize(
              preferredSize: Size.fromHeight( 125.w + 68.h + 90 ),

            child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                        height: 105.h,
                        width: 105.h,
                        decoration: BoxDecoration(
                            color: color_palette["overlay"],
                            borderRadius: BorderRadius.circular(105.h / 2)),
                        child: (widget.appUser.profileImagePath == null ||
                                widget.appUser.profileImagePath == "")
                            ? Container(
                                width: 105.h,
                                height: 105.h,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(60.h),
                                    color: Color(0XFF6D6D64)),
                                child: Icon(
                                  FontAwesomeIcons.userAstronaut,
                                  color: color_palette["white"],
                                  size: 30.h,
                                ))
                            : buildImage(
                                widget.appUser.profileImagePath,
                                height: 105.h,
                                width: 105.h,
                                boxFit: BoxFit.cover,
                                radius: BorderRadius.circular(105.h),
                              )),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      alignment: AlignmentDirectional.center,
                      padding: EdgeInsets.only(top: 15, bottom: 10),
                      child: SelectableText(
                        '@' + widget.appUser.userName,
                        style: TextStyle(
                            color: color_palette["white"], fontSize: 28.h),
                        onTap: () {
                          Clipboard.setData(
                                  ClipboardData(text: widget.appUser.userName))
                              .then((_) {
                            CustomToast(
                                "Username has been copied to clipboard.");
                          });
                        },
                      ),
                    ),
                    Container(
                      height: 125.w * 1.2 + 5,
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
                    widget.appUser.aboutUser ?? "",
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
                            "Created\n${Conversion.nFormatter(widget.appUser.numCreated ?? 0, 1)}",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 26.h,
                                color: color_palette["white"],
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Liked\n${Conversion.nFormatter(widget.appUser.numLiked ?? 0, 1)}",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 26.h,
                                color: color_palette["white"],
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Followers\n${Conversion.nFormatter(widget.appUser.numFollowedBy ?? 0, 1)}",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 26.h,
                                color: color_palette["white"],
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Following\n${Conversion.nFormatter(widget.appUser.numFollowing ?? 0, 1)}",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 26.h,
                                color: color_palette["white"],
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ))),
            ])),
      ),
      if (widget.appUser.hasWebLinks())
        SliverToBoxAdapter(
            child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                alignment: AlignmentDirectional.topStart,
                child: Text(
                  "Sites",
                  maxLines: 1,
                  style: TextStyle(
                      fontSize: 24.h,
                      color: color_palette["background_color"],
                      fontWeight: FontWeight.bold),
                ),
              ),
              if (widget.appUser.businessUrl != "")
                Container(
                    margin: EdgeInsets.symmetric(vertical: 2, horizontal: 14),
                    alignment: AlignmentDirectional.topStart,
                    child: Linkify(
                      onOpen: (link) async {
                        if (await canLaunchUrl(Uri.parse(link.url))) {
                          await launchUrl(Uri.parse(link.url));
                        } else {
                          throw 'Could not launch $link';
                        }
                      },
                      text: "Business: " + widget.appUser.businessUrl,
                      style: TextStyle(
                        color: color_palette["background_color"],
                        fontSize: 22.h,
                      ),
                      linkStyle: TextStyle(
                        fontSize: 30.h,
                      ),
                    )),
              if (widget.appUser.youtubeUrl != "")
                Container(
                    margin: EdgeInsets.symmetric(vertical: 2, horizontal: 14),
                    alignment: AlignmentDirectional.topStart,
                    child: Linkify(
                      onOpen: (link) async {
                        if (await canLaunchUrl(Uri.parse(link.url))) {
                          await launchUrl(Uri.parse(link.url));
                        } else {
                          throw 'Could not launch $link';
                        }
                      },
                      text: "Youtube: " + widget.appUser.youtubeUrl,
                      style: TextStyle(
                        color: color_palette["background_color"],
                        fontSize: 22.h,
                      ),
                      linkStyle: TextStyle(
                        fontSize: 30.h,
                      ),
                    )),
              if (widget.appUser.tiktokUrl != "")
                Container(
                    margin: EdgeInsets.symmetric(vertical: 2, horizontal: 14),
                    alignment: AlignmentDirectional.topStart,
                    child: Linkify(
                      onOpen: (link) async {
                        if (await canLaunchUrl(Uri.parse(link.url))) {
                          await launchUrl(Uri.parse(link.url));
                        } else {
                          throw 'Could not launch $link';
                        }
                      },
                      text: "Tiktok: " + widget.appUser.tiktokUrl,
                      style: TextStyle(
                        color: color_palette["background_color"],
                        fontSize: 22.h,
                      ),
                      linkStyle: TextStyle(
                        fontSize: 30.h,
                      ),
                    )),
            ],
          ),
        ))
    ]);
  }

  Widget showCreationsPage() {
    return RecipePageView(mode: 3);
  }

  Widget showFavoritesPage() {
    return RecipePageView(mode: 4);
  }
}
