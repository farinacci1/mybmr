import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:mybmr/views/creationMenus/builders/TaskBuilder.dart';

import '../constants/Themes.dart';
import '../views/creationMenus/builders/NoteBuilder.dart';
import '../views/creationMenus/builders/shoppingListBuilder.dart';

class CornerActionList extends StatefulWidget {
  final double radius;
  final double cornerOffset;
  final Duration duration;

  const CornerActionList(
      {Key key,
      this.radius = 50.0,
      this.cornerOffset = 5,
      this.duration = const Duration(milliseconds: 800)})
      : super(key: key);

  @override
  _CornerListState createState() => _CornerListState();
}

class _CornerListState extends State<CornerActionList>
    with SingleTickerProviderStateMixin {
  bool isActive = false;
  bool isVisible1 = false;
  bool isVisible2 = false;
  bool isVisible3 = false;

  double getCircleCenterXOffset(
      double radiusParent, double radiusChild, double degrees) {
    double center = radiusParent -radiusChild;
    double radians = degrees * pi / 180;
    double desiredRadius = radiusChild * 3;
    double cX = (desiredRadius * cos(radians)) +center ;
    return cX;

  }
  double getCircleCenterYOffset( double radiusParent, double radiusChild, double degrees){
    double center = radiusParent -radiusChild;
    double radians = degrees * pi / 180;
    double desiredRadius = radiusChild * 3;
    double cY = (desiredRadius * sin(radians)) + center ;
    return cY ;
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      margin: EdgeInsets.all(widget.cornerOffset),
      child: Stack(
        alignment: AlignmentDirectional.bottomEnd,
        children: [
          Stack(
            children: [
              AnimatedPositioned(
                  onEnd: () {
                    if (!isActive) {
                      isVisible1 = false;
                      if (!isVisible1 && !isVisible2 && !isVisible3)
                        setState(() {});
                    }
                  },
                  bottom: (!isActive)
                      ? widget.radius - widget.radius / 2
                      : getCircleCenterYOffset(widget.radius,(widget.radius * 1.25) /2, 90),
                  right: (!isActive)
                      ? widget.radius - widget.radius / 2
                      : getCircleCenterXOffset(widget.radius, (widget.radius * 1.25) /2, 90 ),
                  duration: widget.duration,
                  curve: Curves.fastLinearToSlowEaseIn,
                  child: Visibility(
                      visible: isVisible1,
                      child: GestureDetector(onTap:() async {
                        await Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                              return NoteBuilder();
                            }));

                      },child:Container(
                        width: widget.radius * 1.25,
                        height: widget.radius * 1.25,
                        alignment: AlignmentDirectional.center,
                        child: AutoSizeText.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                  text: "📝\n",
                                  style: TextStyle(
                                      fontSize: widget.radius * 0.4,
                                      color: color_palette["white"])),
                              TextSpan(
                                  text: "Note",
                                  style: TextStyle(
                                      fontSize: widget.radius * 0.3,
                                      color: Colors.black)),
                            ],
                          ),
                          textAlign: TextAlign.center,
                          minFontSize: 6,
                          maxLines: 2,
                        ),
                        decoration: BoxDecoration(
                          color: color_palette["white"],
                          borderRadius:
                          BorderRadius.all(Radius.circular(widget.radius)),
                        ),
                      )))),
              AnimatedPositioned(
                  onEnd: () {
                    if (!isActive) {
                      isVisible2 = false;

                      if (!isVisible1 && !isVisible2 && !isVisible3)
                        setState(() {});
                    }
                  },
                  bottom: (!isActive)
                      ? widget.radius - widget.radius / 2
                      :getCircleCenterYOffset(widget.radius,(widget.radius * 1.25) /2, 45),
                  right: (!isActive)
                      ? widget.radius - widget.radius / 2
                      : getCircleCenterXOffset(widget.radius,(widget.radius * 1.25) /2, 45),
                  duration: widget.duration,
                  curve: Curves.fastLinearToSlowEaseIn,
                  child: Visibility(
                      visible: isVisible2,
                      child: GestureDetector(onTap:() async {
                        await Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                              return TaskBuilder();
                            }));
                      },child:Container(
                        width: widget.radius * 1.25,
                        height: widget.radius * 1.25,
                        alignment: AlignmentDirectional.center,
                        child: AutoSizeText.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                  text: "✓\n",
                                  style: TextStyle(
                                    fontSize: widget.radius * 0.4,
                                  )),
                              TextSpan(
                                  text: "Task",
                                  style: TextStyle(
                                      fontSize: widget.radius * 0.3,
                                      color: Colors.black)),
                            ],
                          ),
                          textAlign: TextAlign.center,
                          minFontSize: 6,
                          maxLines: 2,
                        ),
                        decoration: BoxDecoration(
                          color: color_palette["white"],
                          borderRadius:
                          BorderRadius.all(Radius.circular(widget.radius)),
                        ),
                      )))),
              AnimatedPositioned(
                  onEnd: () {
                    if (!isActive) {
                      isVisible3 = false;
                      if (!isVisible1 && !isVisible2 && !isVisible3)
                        setState(() {});
                    }
                  },
                  bottom: (!isActive)
                      ? widget.radius - widget.radius / 2
                      : getCircleCenterYOffset(widget.radius,(widget.radius * 1.25) /2, 0),
                  right: (!isActive)
                      ? widget.radius - widget.radius / 2
                      : getCircleCenterXOffset(widget.radius,(widget.radius * 1.25) /2, 0),
                  duration: widget.duration,
                  curve: Curves.fastLinearToSlowEaseIn,
                  child: Visibility(
                      visible: isVisible3,
                      child: GestureDetector(
                          onTap: () async {
                            await Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                                  return ShoppingListBuilder();
                                }));
                          },
                          child: Container(
                            width: widget.radius * 1.25,
                            height: widget.radius * 1.25,
                            alignment: AlignmentDirectional.center,
                            child: AutoSizeText.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                      text: "🛒\n",
                                      style: TextStyle(
                                          fontSize: widget.radius * 0.4,
                                          color: color_palette["white"])),
                                  TextSpan(
                                      text: "Shop",
                                      style: TextStyle(
                                          fontSize: widget.radius * 0.3,
                                          color: Colors.black)),
                                ],
                              ),
                              textAlign: TextAlign.center,
                              minFontSize: 6,
                              maxLines: 2,
                            ),
                            decoration: BoxDecoration(
                              color: color_palette["white"],
                              borderRadius:
                              BorderRadius.all(Radius.circular(widget.radius)),
                            ),
                          ))))
            ],
          ),
          Positioned(
              bottom: 0,
              child: GestureDetector(
                  onTap: () {
                    setState(() {
                      isActive = !isActive;
                      isVisible1 = true;
                      isVisible2 = true;
                      isVisible3 = true;
                    });
                  },
                  child: Container(
                    width: widget.radius * 2,
                    height: widget.radius * 2,
                    child: Icon(
                      Icons.add,
                      size: widget.radius * 0.8,
                      color: Colors.orangeAccent,
                    ),
                    decoration: BoxDecoration(
                      color: color_palette["white"],
                      borderRadius:
                          BorderRadius.all(Radius.circular(widget.radius)),
                    ),
                  ))),

        ],
      ),
    );
  }
}
