import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mybmr/constants/Themes.dart';
import 'package:mybmr/notifiers/UserNotifier.dart';
import 'package:mybmr/constants/messages/en_messages.dart';
import 'package:mybmr/services/PlatformManager.dart';
import 'package:mybmr/services/toast.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {


  @override
  void initState() {


    super.initState();
  }

  @override
  void dispose() {

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
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(

        statusBarColor: color_palette["background_color"],
        systemNavigationBarColor: color_palette["background_color"],
        systemNavigationBarDividerColor: color_palette["background_color"]));
    return Scaffold(
      backgroundColor: color_palette["white"],
      resizeToAvoidBottomInset: false,
      body: Stack(children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              color:    color_palette["background_color"],),

        ),
        Container(
          width: MediaQuery.of(context).size.width ,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration( color: color_palette["semi_transparent"]),
          padding: EdgeInsets.fromLTRB(
              20 , MediaQuery.of(context).size.height * .08,  20 , 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 304.75.h,
                width: 304.75.h,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(
                          "assets/images/MyBMR.png",
                        ),
                        fit: BoxFit.fill)),
              ),
              Spacer(),
              Container(

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 13.25.h),
                      child: Text(
                        en_messages["login_with"],
                        style: TextStyle(fontSize: 28.h, color: color_palette["semi_transparent"]),
                      ),
                    ),
                    Container(
                        height: 66.25.h,
                        width: MediaQuery.of(context).size.width - 53.h,
                        child: ElevatedButton.icon(
                          icon: Icon(FontAwesomeIcons.google),
                          style: ElevatedButton.styleFrom(
                              primary: Color(0XFFFBBC05),
                              onPrimary: Colors.white),
                          label: Text(
                            "Sign in with Google",
                            textScaleFactor: 1.0,
                            style: TextStyle(fontSize: 20.h),
                          ),
                          onPressed: () async {
                            Provider.of<UserNotifier>(context, listen: false)
                                .signInWithGoogle();
                          },
                        )),
                    Container(
                        margin: EdgeInsets.only(top: 19.875.h),
                        height: 66.25.h,
                        width: MediaQuery.of(context).size.width - 53.h,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              primary: Colors.black, onPrimary: Colors.white),
                          icon: Icon(FontAwesomeIcons.apple),
                          label: Text(
                            "Sign in with Apple",
                            textScaleFactor: 1.0,
                            style: TextStyle(fontSize: 20.h),
                          ),
                          onPressed: () async {
                            if (PlatformManager.getPlatformType() ==
                                PlatformType.IOS) {
                              Provider.of<UserNotifier>(context, listen: false)
                                  .signInWithApple();
                            } else {
                              CustomToast(en_messages["non_ios_platform"]);
                            }
                          },
                        ))
                  ],
                ),
              ),
            ],
          ),
        )
      ]),
    );
  }
}
