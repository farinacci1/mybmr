import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mybmr/services/toast.dart';

import '../../../constants/Themes.dart';

class TaskPopup extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();
  final String TaskPopupTag = "TASK_POPUP";

  @override
  Widget build(BuildContext context) {
    return Hero(
        tag: TaskPopupTag,
        child: Center(
          child: Container(
            constraints: BoxConstraints(
                maxWidth: min(MediaQuery.of(context).size.width - 80, 600)),
            decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20)),
            child: Material(
              color: color_palette["white"],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Subtask Title", style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20,
                      color: color_palette["text_color_alt"]
                  ),),
                      TextField(
                        controller: _controller,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 24),
                      ),
                      Container(
                        alignment: AlignmentDirectional.center,
                        margin: EdgeInsets.only(top: 8),
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            String content = _controller.value.text.trim();
                            if(content.length > 0)
                              Navigator.pop(context,{"value":content});
                            else
                              CustomToast("Subtask cannot be empty");
                          },
                          child: Container(

                              height: 50,
                              width: double.infinity,
                              alignment: AlignmentDirectional.center,


                              child: Text(
                                "Add",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20,
                                color: color_palette["text_color_alt"]
                                ),
                              )),
                        ),
                      )
                    ],
                  ),
                )),
          ),
        ));
  }
}
