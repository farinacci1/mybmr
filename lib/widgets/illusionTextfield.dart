import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class IllusionTextField extends StatelessWidget {
  /*
  * Illusion text field mimics the look of  a text field, but has no concept of a focusnode and instead registers ontap events
  * and process them according to conditions set by onTap callback
  * */
  final Color backgroundColor;
  final String hiddenText;
  final Color hiddenTextColor;
  final double height;
  final double width;
  final Function onTap;
  const IllusionTextField(
      {Key key,
      this.backgroundColor,
      this.hiddenText = "<Select Ingredients>",
      this.hiddenTextColor = Colors.white54,
      this.height = 42,
      this.width = 300,
      this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          if (this.onTap != null) this.onTap();
        },
        child: Container(
          height: this.height,
          margin: EdgeInsets.symmetric(vertical: 10),
          width: this.width,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(this.height /2),
                  right:Radius.circular(4)),
              border: Border.all(
                color: Colors.white,
              )),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.fromLTRB(8, 2, 2, 5),
                  alignment: AlignmentDirectional.centerStart,

                  decoration:BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(this.height /2),
                  ),
                  ),
                  child: AutoSizeText(
                    hiddenText,
                    maxLines: 1,
                    style: TextStyle(color: hiddenTextColor, fontSize: 0.375 * this.height),
                  ),
                ),
              ),
              Container(
                  width: this.height,
                  height: this.height,
                  color: Colors.white54,
                  child: Icon(
                    Icons.arrow_drop_down_rounded,
                    color: Colors.white,
                    size: 24,
                  ))
            ],
          ),
        ));
  }
}
