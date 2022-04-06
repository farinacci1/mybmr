import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mybmr/models/Task.dart';
import 'package:mybmr/notifiers/UserListNotifier.dart';
import 'package:mybmr/views/creationMenus/popups/TaskPopup.dart';
import 'package:mybmr/widgets/HeaderBar.dart';
import 'package:provider/provider.dart';

import '../../../constants/Themes.dart';
import '../../../services/hero_dialog_route.dart';
import '../../../services/toast.dart';

class TaskBuilder extends StatefulWidget {
  final UserTask task;
  const TaskBuilder({Key key, this.task}) : super(key: key);
  @override
  _TaskBuilderState createState() => _TaskBuilderState();
}

class _TaskBuilderState extends State<TaskBuilder> {
  TextEditingController _titleController = TextEditingController();
  List<String> _taskList = [];
  List<bool> _isAccomplished = [];
  @override
  void initState() {
    if (widget.task != null) {
      _titleController.text = widget.task.title;
      _taskList = List.from(widget.task.subtasks);
      _isAccomplished = List.from(widget.task.hasCompleted);
    }

    super.initState();
  }

  void saveTask(String title) {
    UserTask task = UserTask(
        title: title, subtasks: _taskList, hasCompleted: _isAccomplished);
    if (widget.task != null) {
      task.id = widget.task.id;
      Provider.of<UserListNotifier>(context, listen: false).updateTask(task);
    } else {
      Provider.of<UserListNotifier>(context, listen: false).createTask(task);
    }
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
      body: Container(
          decoration: BoxDecoration(gradient: color_palette["gradient"]),
          child: NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (overscroll) {
                overscroll.disallowIndicator();
                return;
              },
              child: CustomScrollView(slivers: [
                SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      children: [
                        HeaderBar(
                          popWidget: Icon(
                            Icons.arrow_back,
                            color: color_palette["white"],
                            size: 31.8.h,
                          ),
                          onPopCallback: () {},
                          title: _titleController.text.length > 0
                              ? _titleController.value.text
                              : "Task Builder",
                          submitColor: color_palette["text_color_dark"],
                          submitWidget: Text(
                            "Save",
                            textScaleFactor: 1.0,
                            style: TextStyle(color: color_palette["white"], fontSize: 20.h),
                          ),
                          submitCallback: () {
                            String title = _titleController.value.text.trim();
                            if (title.length == 0) {
                              CustomToast("A title is required");
                            } else if (_taskList.length == 0) {
                              CustomToast("Task requires sub task");
                            } else {
                              saveTask(title);
                              Navigator.pop(context);
                            }
                          },
                        ),
                        Container(
                            width: MediaQuery.of(context).size.width - 30,
                            margin: EdgeInsets.fromLTRB(15, 10, 15, 0),
                            child: Text(
                              "Title",
                              textAlign: TextAlign.left,
                              textScaleFactor: 1.0,
                              style: TextStyle(
                                  color: color_palette["white"],
                                  fontSize: 23.5.h,
                                  fontWeight: FontWeight.bold),
                            )),
                        Container(
                            margin: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                            child: TextField(
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(50),
                                ],
                                style: TextStyle(
                                    color: color_palette["white"], fontSize: 30.h,height:1.5),

                                onChanged: (str) {
                                  setState(() {});
                                },
                                controller: _titleController,
                                decoration:InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(vertical: 30.h/2,horizontal: 15.h),
                                    isDense: true,
                                    filled: true,
                                    hintText: "Add A Title...",
                                    hintStyle: TextStyle(
                                      color: color_palette["white"],
                                    ),
                                    fillColor: Colors.black54,
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: color_palette["white"])),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: color_palette["white"]))),
                            )
                        ),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 15),
                            child: Column(
                              children: [
                                Container(
                                    alignment: AlignmentDirectional.centerStart,
                                    child: Text(
                                      "Subtasks",
                                      textScaleFactor: 1.0,
                                      style: TextStyle(
                                          color: color_palette["white"],
                                          fontSize: 23.5.h,
                                          fontWeight: FontWeight.bold),
                                    )),
                                SingleChildScrollView(
                                  child: Column(
                                    children: _taskList.length > 0
                                        ? List.generate(_isAccomplished.length,
                                            (int idx) {
                                            return Dismissible(
                                                key: UniqueKey(),
                                                confirmDismiss:
                                                    (DismissDirection
                                                        direction) async {
                                                  if (direction ==
                                                      DismissDirection
                                                          .endToStart) {
                                                    setState(() {
                                                      _taskList.removeAt(idx);
                                                      _isAccomplished
                                                          .removeAt(idx);
                                                    });

                                                    return true;
                                                  }
                                                  return false;
                                                },
                                                child: Container(
                                                    child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Transform.scale(
                                                        scale: 1.5,
                                                        child: Checkbox(
                                                          value:
                                                              _isAccomplished[
                                                                  idx],
                                                          checkColor: color_palette[
                                                              "text_color_dark"],
                                                          activeColor:
                                                              color_palette[
                                                                  "white"],
                                                          shape: CircleBorder(),
                                                          onChanged:
                                                              (newValue) {
                                                            setState(() {
                                                              _isAccomplished[
                                                                      idx] =
                                                                  newValue;
                                                            });
                                                          },
                                                        )),
                                                    AnimatedContainer(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width -
                                                            80,
                                                        duration: Duration(
                                                            milliseconds: 800),
                                                        child: Text(
                                                          _taskList[idx],
                                                          textAlign:
                                                              TextAlign.justify,
                                                          maxLines: null,
                                                          style: TextStyle(
                                                              color: !_isAccomplished[
                                                                      idx]
                                                                  ? Colors.white
                                                                  : color_palette[
                                                                      "overlay"],
                                                              fontSize: 31.8.h),
                                                        )),
                                                  ],
                                                )));
                                          }
                                            // some widgets here
                                            ).toList()
                                        : [],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 30),
                          child: Column(
                            children: [
                              Container(
                                  width: 132.5.h,
                                  height: 132.5.h,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      Map<String, dynamic> out =
                                          await Navigator.of(context).push(
                                              HeroDialogRoute(
                                                  builder: (context) {
                                        return TaskPopup();
                                      }));
                                      if (out != null &&
                                          out.containsKey("value")) {
                                        _taskList.add(out["value"]);
                                        _isAccomplished.add(false);
                                        setState(() {});
                                      }
                                    },
                                    child: Icon(FontAwesomeIcons.plus),
                                    style: ElevatedButton.styleFrom(
                                        shape: CircleBorder(),
                                        shadowColor: color_palette["white"],
                                        elevation: 8,
                                        primary:
                                            color_palette["text_color_dark"]),
                                  )),
                            ],
                          ),
                        )
                      ],
                    ))
              ]))),
    );
  }
}
