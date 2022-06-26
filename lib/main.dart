import 'dart:async';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mybmr/notifiers/LookupUserNotifier.dart';
import 'package:mybmr/notifiers/RecipeNotifier.dart';
import 'package:mybmr/services/AdService.dart';
import 'package:mybmr/services/AppManager.dart';
import 'package:mybmr/services/Firebase_db.dart';
import 'package:mybmr/views/Home.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import 'package:mybmr/notifiers/EquipmentNotifier.dart';
import 'package:mybmr/notifiers/FavoritesNotifier.dart';
import 'package:mybmr/notifiers/IngredientNotifier.dart';
import 'package:mybmr/notifiers/MealPlanNotifier.dart';
import 'package:mybmr/notifiers/RecipeFieldsNotifier.dart';
import 'package:mybmr/notifiers/SearchNotifier.dart';
import 'package:mybmr/notifiers/UserListNotifier.dart';
import 'package:mybmr/notifiers/UserNotifier.dart';

import 'constants/Themes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AdService.createInterstitialAd();

    return MultiProvider(
        providers: [
          ChangeNotifierProvider<RecipeNotifier>(
              create: (_) => RecipeNotifier()),
          ChangeNotifierProvider<UserNotifier>(create: (_) => UserNotifier()),
          ChangeNotifierProvider<IngredientNotifier>(
              create: (_) => IngredientNotifier()),
          ChangeNotifierProvider<RecipeFieldsNotifier>(
              create: (_) => RecipeFieldsNotifier()),
          ChangeNotifierProvider<EquipmentNotifier>(
              create: (_) => EquipmentNotifier()),
          ChangeNotifierProvider<SearchNotifier>(
              create: (_) => SearchNotifier()),
          ChangeNotifierProvider<MealPlanNotifier>(
              create: (_) => MealPlanNotifier()),
          ChangeNotifierProvider<FavoritesNotifier>(
              create: (_) => FavoritesNotifier()),
          ChangeNotifierProvider<UserListNotifier>(
              create: (_) => UserListNotifier()),
          ChangeNotifierProvider<LookupUserNotifier>(
              create: (_) => LookupUserNotifier()),
        ],
        child: MaterialApp(
          title: 'Flutter Demo',
          debugShowCheckedModeBanner: false,

          theme: ThemeData(
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              scaffoldBackgroundColor: Colors.black38,
              fontFamily: "Araboto"),
          home: AnimatedSplashScreen.withScreenFunction(
            splash: "assets/images/MyBMR.png",
            splashIconSize: 230,
            backgroundColor: Colors.black38,
            screenFunction: () async {

              SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
                  statusBarColor: Colors.black38,
                  systemNavigationBarColor: Colors.black38,
                  systemNavigationBarDividerColor: Colors.black38
              ));
              await SystemChrome.setPreferredOrientations([
                DeviceOrientation.portraitUp,
                DeviceOrientation.portraitDown,
              ]);
              await Firebase.initializeApp();

              MobileAds.instance.initialize();
              bool isSupportedAppVersion = await AppManager.isValidAppVersion();
              if (isSupportedAppVersion)
                return Home();
              else
                return Scaffold(
                  body: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 256,
                        margin: EdgeInsets.only(bottom: 10),
                        child: Image.asset("assets/images/MyBMR.png",fit: BoxFit.fitHeight,),
                      ),
                      Text(
                        "A new version of the app is available. To proceed please update to latest app version.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: color_palette["error_color"],fontSize: 16),
                      ),
                      Container(height: 15,),
                      Text("Minimum Supported version ${AppManager.supportedVersion}v${AppManager.supportedCode}",style: TextStyle(color: color_palette["error_color"],fontSize: 16),),
                      Text("Device version ${AppManager.appVersion}v${AppManager.appCode}",style: TextStyle(color: color_palette["error_color"],fontSize: 16),)

                    ],
                  ),
                );
            },
            pageTransitionType: PageTransitionType.bottomToTop,
            splashTransition: SplashTransition.slideTransition,
          ),
        ));
  }
}
