import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

enum RecipeSortBy{
  TITLE,
  CUISINE,
  DIETS,
  NEW
}

Widget buildImage(String recipeImageFromDB,
    {double height = 400, double width = 300, aspect = 0.75,
      double wrapperWidth = double.infinity,
      BorderRadius radius = BorderRadius.zero,
      BoxFit boxFit = BoxFit.fitWidth,
      EdgeInsets margin = EdgeInsets.zero
    }) {
  return  Container(
    margin: margin,
    height: height,
    width:wrapperWidth,
    child: ClipRRect(
      borderRadius: radius,
        child: FancyShimmerImage(
          imageUrl: recipeImageFromDB,
          boxFit: boxFit,
          width: width,

        )),

  );
}
Widget buildAdWidget({BannerAd ad, double height = 200,
  EdgeInsets padding =  EdgeInsets.zero}){
  return Container(
      height: height,
      padding: padding,
      child: AdWidget(
        ad: ad,
        key: UniqueKey(),
      ));
}
Color lighten(Color color, [double amount = .1]) {
  assert(amount >= 0 && amount <= 1);

  final hsl = HSLColor.fromColor(color);
  final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

  return hslLight.toColor();
}
void changeUiOverlayStyle({
  Color statusBarColor =  Colors.blueGrey,
  Color systemNavigationBarColor =  Colors.blueGrey,
  Color systemNavigationBarDividerColor =  Colors.blueGrey,
}){
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: statusBarColor,
    systemNavigationBarColor: systemNavigationBarColor,
    systemNavigationBarDividerColor: systemNavigationBarDividerColor,
  ));
}

Widget actionWidget({BuildContext ctx,
    Widget child,
    double size,
    Color iconColor = const Color(0XFF6D6D64),
    EdgeInsets padding = EdgeInsets.zero,
    VoidCallback onTap
}){
return Container(child:
  GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () =>  onTap(),
      child: Container(
        padding: padding,
        alignment: AlignmentDirectional.center,
        child: child
      )
  ));

}
