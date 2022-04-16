import 'dart:io';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mybmr/notifiers/FavoritesNotifier.dart';
import 'package:mybmr/constants/messages/en_messages.dart';
import 'package:mybmr/models/AppUser.dart';
import 'package:mybmr/models/Recipe.dart';
import 'package:mybmr/services/hero_dialog_route.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../constants/Themes.dart';
import '../widgets/ImageCropper.dart';
import 'creationMenus/popups/FavoritePopup.dart';

class UserAccount extends StatefulWidget {
  @override
  _UserAccountState createState() => _UserAccountState();
}

class _UserAccountState extends State<UserAccount> {
  File imageFile;
  ImagePicker _picker;
  int tabIdx = 0;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    _picker = ImagePicker();

    super.initState();
  }

  @override
  void dispose() {
    if (_refreshController != null) _refreshController.dispose();

    super.dispose();
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

  Widget counterDisplay(
      {VoidCallback onTap,
      String value,
      String label,
      EdgeInsets padding = EdgeInsets.zero}) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Container(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(color: color_palette["white"], fontSize: 20),
            ),
            Text(
              label,
              style: TextStyle(color: color_palette["white"], fontSize: 16),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    FavoritesNotifier favoritesNotifier =
        Provider.of<FavoritesNotifier>(context, listen: true);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarDividerColor: Colors.white
    ));

    ScreenUtil.init(
        BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width,
            maxHeight: MediaQuery.of(context).size.height),
        designSize: Size(2400, 1080),
        context: context,
        minTextAdapt: true,
        orientation: Orientation.portrait);
    double pageWidth = MediaQuery.of(context).size.width;
    double cellWidth = pageWidth / 2;
    int maxObjectsPerRow = cellWidth > 300 ? 3 : 2;
    double margin = 20;
    double horizontalSpacer =
        max(pageWidth - ((cellWidth * maxObjectsPerRow) + margin), 10.0);

    return Container(
      child: Column(
        children: [
          Container(
            height:  (MediaQuery.of(context).padding.top + 80.h),
            color: Colors.white,

          ),
          Expanded(child:
          Container(
          width: pageWidth,

          decoration: BoxDecoration(
            color: color_palette["text_color_dark"],
            gradient: color_palette["gradient"],
            boxShadow: [
              BoxShadow(
                color: color_palette["overlay"],
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (overscroll) {
                overscroll.disallowIndicator();
                return;
              },
              child: SmartRefresher(
                  enablePullDown: false,
                  enablePullUp: true,
                  onLoading: () {
                    return _onLoading(context, isFavorite: tabIdx == 1);
                  },
                  footer:
                  const ClassicFooter(loadStyle: LoadStyle.ShowWhenLoading),
                  controller: _refreshController,
                  child: CustomScrollView(
                    primary: false,
                    slivers: [
                      SliverToBoxAdapter(
                        child: Container(
                            margin: EdgeInsets.only(top: 20),
                            alignment: AlignmentDirectional.center,
                            child: Stack(
                                alignment: AlignmentDirectional.bottomEnd,
                                children: [
                                  GestureDetector(
                                      onTap: () async {
                                        try {
                                          XFile pickedFile =
                                          await _picker.pickImage(
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
                                          height: 150.h,
                                          width: 150.h,
                                          decoration: BoxDecoration(
                                              color: color_palette["overlay"],
                                              border: Border.all(
                                                  color: color_palette["white"]),
                                              borderRadius: BorderRadius.circular(
                                                  150.h / 2)),
                                          child: imageFile != null
                                              ? CircleAvatar(
                                            backgroundImage:
                                            FileImage(imageFile),
                                            radius: 75.h,
                                          )
                                              : AppUser.instance
                                              .profileImagePath !=
                                              null
                                              ? CircleAvatar(
                                            backgroundImage:
                                            NetworkImage(AppUser
                                                .instance
                                                .profileImagePath),
                                            radius: 75.h,
                                          )
                                              : Column(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .center,
                                              crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .center,
                                              children: [
                                                Icon(
                                                  Icons.add_a_photo,
                                                  size: 47.5.h,
                                                  color: color_palette[
                                                  "white"],
                                                ),
                                                Container(
                                                  height: 2,
                                                ),
                                                Text(
                                                  en_messages[
                                                  "photo_label"],
                                                  style: TextStyle(
                                                      color:
                                                      color_palette[
                                                      "white"],
                                                      fontSize:
                                                      17.225.h),
                                                )
                                              ]))),
                                  Container(
                                      width: 35.h,
                                      height: 35.h,
                                      alignment: AlignmentDirectional.center,
                                      decoration: BoxDecoration(
                                          color: color_palette["text_color_alt"],
                                          borderRadius:
                                          BorderRadius.circular(35.h / 2),
                                          border: Border.all(
                                              color: color_palette["white"],
                                              width: 2)),
                                      margin: EdgeInsets.only(
                                        bottom: 20.h,
                                      ),
                                      child: Icon(
                                        FontAwesomeIcons.plus,
                                        size: 10.6.h,
                                        color: color_palette["white"],
                                      )),
                                ])),
                      ),
                      SliverToBoxAdapter(
                        child: Container(
                            margin: EdgeInsets.only(top: 10),
                            child: AutoSizeText(
                              "@${AppUser.instance.userName}",
                              style: TextStyle(
                                  color: color_palette["white"], fontSize: 24.h),
                              textAlign: TextAlign.center,
                            )),
                      ),
                      SliverToBoxAdapter(
                        child: Container(
                            margin: EdgeInsets.symmetric(vertical: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                counterDisplay(
                                    onTap: () {},
                                    value: "0",
                                    label: "Following",
                                    padding: EdgeInsets.only(right: 15)),
                                Container(
                                  height: 15,
                                  width: 1,
                                  color: Colors.grey[400],
                                ),
                                counterDisplay(
                                    onTap: () {},
                                    value: "0",
                                    label: "Followers",
                                    padding:
                                    EdgeInsets.symmetric(horizontal: 15)),
                                Container(
                                  height: 15,
                                  width: 1,
                                  color: Colors.grey[400],
                                ),
                                counterDisplay(
                                    onTap: () {},
                                    value: "0",
                                    label: "Favorites",
                                    padding: EdgeInsets.only(left: 15)),
                              ],
                            )),
                      ),
                      SliverToBoxAdapter(
                        child: InkWell(
                            onTap: () {},
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 15),
                              width: min(
                                  MediaQuery.of(context).size.width * 0.9, 600),
                              height: 58.h,
                              decoration: BoxDecoration(
                                  color: color_palette["white"],
                                  borderRadius: BorderRadius.circular(26.h)),
                              alignment: AlignmentDirectional.center,
                              child: Text(
                                "Edit Profile",
                                style: TextStyle(
                                  fontSize: 28.h,
                                  color: color_palette["background_color"],
                                ),
                              ),
                            )),
                      ),
                      SliverToBoxAdapter(
                        child: Container(
                          child: Row(
                              children: [
                                tabSelector(
                                    label: "My Creations",
                                    value: AppUser.instance.myCreationIds.length),
                                tabSelector(
                                    label: "My Favorites",
                                    value: AppUser.instance.likedRecipesIds.length)
                              ]
                                  .asMap()
                                  .map((int idx, Widget child) {
                                return MapEntry(
                                    idx,
                                    Expanded(
                                        child: Container(
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  tabIdx = idx;
                                                });
                                              },
                                              child: child,
                                            ))));
                              })
                                  .values
                                  .toList()),
                        ),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.symmetric(
                            vertical: 10, horizontal: margin / 2),
                        sliver: SliverGrid.count(
                            crossAxisSpacing: horizontalSpacer,
                            childAspectRatio: 1.3,
                            mainAxisSpacing: 10,
                            crossAxisCount: maxObjectsPerRow,
                            children: tabIdx == 0
                                ? favoritesNotifier.myCreations
                                .map((Recipe recipe) {
                              return GestureDetector(
                                  onTap: () async {
                                    await Navigator.of(context).push(
                                        HeroDialogRoute(builder: (context) {
                                          return FavoritePopup(
                                            recipe: recipe,
                                            isOwnedByUser: true,
                                            isDeletable: false,
                                          );
                                        }));
                                  },
                                  child: drawRecipe(recipe));
                            }).toList()
                                : favoritesNotifier.favoriteRecipes
                                .map((Recipe recipe) {
                              return GestureDetector(
                                  onTap: () async {
                                    await Navigator.of(context).push(
                                        HeroDialogRoute(builder: (context) {
                                          return FavoritePopup(
                                            recipe: recipe,
                                            isOwnedByUser: false,
                                            isDeletable: true,
                                          );
                                        }));
                                  },
                                  child: drawRecipe(recipe));
                            }).toList()),
                      )
                    ],
                  )))))
        ],
      ),
    );

  }

  void _onLoading(
    BuildContext context, {
    bool isFavorite = false,
  }) async {
    if (!isFavorite) {
      Provider.of<FavoritesNotifier>(context, listen: false).fetchRecipes(
          offset: Provider.of<FavoritesNotifier>(context, listen: false)
              .myCreations
              .length,
          fetchFavorites: isFavorite);
    } else {
      Provider.of<FavoritesNotifier>(context, listen: false).fetchRecipes(
          offset: Provider.of<FavoritesNotifier>(context, listen: false)
              .favoriteRecipes
              .length,
          fetchFavorites: isFavorite);
    }

    _refreshController.loadComplete();
  }

  Widget tabSelector({String label, int value}) {
    return Container(
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(width: 2, color: color_palette["white"]))),
        padding: EdgeInsets.only(top: 20, bottom: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value.toString(),
              maxLines: 1,
              style: TextStyle(color: color_palette["white"], fontSize: 22.h),
            ),
            Text(
              label,
              maxLines: 1,
              style: TextStyle(color: color_palette["white"], fontSize: 22.h),
            ),
          ],
        ));
  }

  Widget drawRecipe(Recipe recipe, {isMyCreation = false}) {
    return Container(
      alignment: AlignmentDirectional.bottomStart,
      decoration: BoxDecoration(
        color: color_palette["white"],
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: NetworkImage(recipe.recipeImageFromDB),
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
        ),
      ),
      child: Container(
        height: 30,
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 4),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
            color: Color.fromRGBO(255, 255, 255, 0.8)),
        child: Text(
          recipe.title.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.clip,
          style: TextStyle(fontSize: 16, color: Colors.black38),
        ),
      ),
    );
  }
}
