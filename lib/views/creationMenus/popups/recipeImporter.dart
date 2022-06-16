import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mybmr/constants/Themes.dart';
import 'package:mybmr/services/RecipeScraper.dart';
import 'package:mybmr/services/custom_rect_twenn.dart';

class RecipeImporter extends StatefulWidget {
  const RecipeImporter({
    Key key,
  }) : super(key: key);
  @override
  _RecipeImporterState createState() => _RecipeImporterState();
}

class _RecipeImporterState extends State<RecipeImporter> {
  final List<String> fairPracticeRules = [
    "▸ By clicking 'search' you confirm that prior to importing the creative works of others that you have obtained the owners permission to do so.",
    "▸ By clicking 'search' button you showcase that you understand that while applicable law(s) may treat a collection of recipe steps and ingredients as facts any recipe that goes beyond mere steps may be considered a literary work and may be copyrighted. ",
    "▸ Per the reason listed above, you agree that you will modify recipe title, description and steps to be simple enough to avoid going beyond the scope of \"facts\" and unintentionally infringing on any copyrights",
    "▸ By utilizing the recipe being searched as a template for your own, you agree that as a gesture of goodwill you will add a last step where you provide proper attribution to the author of the original recipe content, and give thanks to them.",
    "▸ You acknowledge that any recipes you have posted deemed to not be in compliance with rules above, may be removed from the system",
    "▸ You acknowledge the fact that at the discretion of MyBMR team, you may lost the ability to share recipes if you are found to not be in compliance with these rules. ",
  ];
  TextEditingController _controller = TextEditingController();
  static const String _IMPORTER_POPUP = "IMPORTER_POPUP";
  @override
  void dispose() {
    _controller.dispose();
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
    return Center(
        child: Hero(
            tag: _IMPORTER_POPUP,
            createRectTween: (begin, end) {
              return CustomRectTween(begin: begin, end: end);
            },
            child: Container(
                width: 380.h,
                margin: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Material(
                  color: color_palette["white"],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: SingleChildScrollView(
                      child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: Text(
                            "Import Recipe",
                            style: TextStyle(
                                fontSize: 28.h, color: Colors.black),
                          )),
                      Container(
                          height: 66.25.h,
                          margin:
                              EdgeInsets.symmetric(horizontal: 5, vertical: 20),
                          child: TextField(
                              controller: _controller,
                              maxLines: 1,
                              style: TextStyle(
                                  height: 1.0,
                                  fontSize: 21.2.h,
                                  color: Colors.black),
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                  suffixIcon: IconButton(
                                    onPressed: _controller.clear,
                                    icon: Icon(Icons.clear,size:21.2.h ,),
                                  ),
                                  fillColor: Colors.white,
                                  filled: true,
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                  contentPadding: EdgeInsets.fromLTRB(
                                      12, 21.2.h, 12, 21.2.h),
                                  hintText: "Url",
                                  label: Text(
                                    "Website url",
                                  ),
                                  labelStyle: TextStyle(
                                      fontSize: 23.85.h, color: Colors.black),
                                  hintStyle: TextStyle(
                                      fontSize: 19.875.h, color: Colors.grey[400]),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black)),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black))))),
                      Container(
                        child: Text(
                          "-- Rules --",
                          style: TextStyle(fontSize: 21.2.h),
                        ),
                      ),
                      Container(
                          height: 238.5.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Color.alphaBlend(color_palette["background_color"], color_palette["white"]),
                          ),
                          child: Column(children: [
                            Expanded(
                                child: SingleChildScrollView(
                                    child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: fairPracticeRules
                                  .map((e) => Container(
                                        padding:
                                            EdgeInsets.fromLTRB(10, 5, 5, 0),
                                        child: Text(
                                          e,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontSize: 22.h,
                                              color: Colors.greenAccent),
                                        ),
                                      ))
                                  .toList(),
                            ))),
                            Container(

                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                      onTap: () async {
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        width:  344.5.h /2,
                                        padding: EdgeInsets.symmetric(vertical: 9),

                                        alignment: AlignmentDirectional.center,
                                        child: Text("Cancel",style: TextStyle(color: Colors.white,fontSize: 24.h),),
                                      )),
                                  GestureDetector(
                                      onTap: () async {
                                        if (_controller.value.text.length > 0) {
                                          String inputUrl =
                                              _controller.value.text;
                                          Map<String, dynamic> urlData =
                                              await RecipeScraper.scrapeUrl(
                                                  inputUrl);
                                          Navigator.pop(context, urlData);
                                        }
                                      },
                                      child: Container(
                                        width:  344.5.h /2,
                                        padding: EdgeInsets.symmetric(vertical: 9),

                                        alignment: AlignmentDirectional.center,
                                        child: Text("Search",style: TextStyle(color: Colors.white,fontSize: 24.h),),
                                      )),


                                ],
                              ),
                            )
                          ])),
                    ],
                  )),
                ))));
  }
}
