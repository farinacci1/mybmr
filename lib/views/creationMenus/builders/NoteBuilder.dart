import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mybmr/notifiers/UserListNotifier.dart';
import 'package:mybmr/models/UserNote.dart';
import 'package:mybmr/services/toast.dart';
import 'package:provider/provider.dart';

import '../../../constants/Themes.dart';
import '../../../widgets/HeaderBar.dart';

class NoteBuilder extends StatefulWidget {
  final UserNote note;

  const NoteBuilder({Key key, this.note}) : super(key: key);
  @override
  _NoteBuilderState createState() => _NoteBuilderState();
}

class _NoteBuilderState extends State<NoteBuilder> {
  TextEditingController _titleController = new TextEditingController();
  TextEditingController _bodyController = new TextEditingController();

  void createOrUpdateNote(UserNote note) {
    if (widget.note == null)
      Provider.of<UserListNotifier>(context, listen: false).createNote(note);
    else {
      note.noteId = widget.note.noteId;
      Provider.of<UserListNotifier>(context, listen: false).updateNote(note);
    }
    reset();
    Navigator.pop(context);
  }

  @override
  void initState() {
    if (widget.note != null) {
      _titleController.text = widget.note.title;
      _bodyController.text = widget.note.bodyText;
    } else {
      reset();
    }
    super.initState();
  }

  void reset() {
    _titleController.text = "";
    _bodyController.text = "";
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
      height: MediaQuery.of(context).size.height,
      padding: EdgeInsets.only(bottom: 30),
      decoration: BoxDecoration(
        gradient: color_palette["gradient"]
      ),
      child: Column(
        children: [
          HeaderBar(
            popWidget: Icon(
              Icons.arrow_back,
              color: color_palette["white"],
              size: 31.8.h,
            ),
            onPopCallback: () {
              reset();
            },
            title:   _titleController.text.length > 0 ?  _titleController.value.text : "Note Builder",
            submitColor: color_palette["text_color_dark"],
            submitWidget: Text(
              "Save",
              textScaleFactor: 1.0,
              style: TextStyle(color: color_palette["white"], fontSize: 20.h),
            ),
            submitCallback: () {
              String title = _titleController.text.trim();
              String body = _bodyController.text.trim();
              if(title.length == 0 || body.length == 0){
                CustomToast("Fields cannot be empty.");
              }else{
                UserNote userNote = UserNote(title: title ,bodyText: body);
                createOrUpdateNote(userNote);
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
                    fontSize: 23.85.h,
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
                controller: _titleController,
                onChanged: (str){
                  setState(() {});
                },

                decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 30.h/2,horizontal: 15.h),
                    isDense: true,
                    filled: true,
                    fillColor: Colors.black54,
                    hintText: "Add A Title...",
                    hintStyle: TextStyle(
                      color: color_palette["white"],
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),

                        borderSide: BorderSide(
                            color: color_palette["white"])),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),

                        borderSide: BorderSide(
                            color: color_palette["white"]))),
              )),
          Container(
              width: MediaQuery.of(context).size.width - 30,
              margin: EdgeInsets.fromLTRB(15, 0, 15, 10),

              child: Text(
                "Body",
                textScaleFactor: 1.0,
                textAlign: TextAlign.left,

                style: TextStyle(
                    color: color_palette["white"],
                    fontSize: 23.85.h,
                    fontWeight: FontWeight.bold),
              )),
          Expanded(
              child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  child: TextField(
                    controller: _bodyController,
                    style: TextStyle(
                        color: color_palette["white"], fontSize: 30.h,height:1.5),
                    maxLines: null,
                    autofocus: false,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.black54,
                        hintText: "Start typing notes...",
                        hintStyle: TextStyle(
                          color: color_palette["white"],
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: color_palette["white"])),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: color_palette["white"]))),
                  ))),
        ],
      ),
    ));
  }
}
