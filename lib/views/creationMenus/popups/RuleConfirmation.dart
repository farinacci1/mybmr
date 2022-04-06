import 'package:flutter/material.dart';
import 'package:mybmr/services/custom_rect_twenn.dart';

class RuleConfirmationPopup extends StatefulWidget {
  @override
  _RuleConfirmationPopupState createState() => _RuleConfirmationPopupState();
}

class _RuleConfirmationPopupState extends State<RuleConfirmationPopup> {
  static const String _RULEPOPUP = "RULES_POPUP";
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Hero(
            tag: _RULEPOPUP,
            createRectTween: (begin, end) {
              return CustomRectTween(begin: begin, end: end);
            },
            child: Container(
              width: 260,
              child: Material(
                elevation: 3,
                color: Colors.grey[200],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                          "By tapping the 'Acknowledged' button you confirm that you have read the following rules and that the content you are submitting abides by the conditions set forth."),
                      Text("Rules"),
                      Container(
                          margin:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          padding: EdgeInsets.all(5),
                          width: 240,
                          height: 120,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.black, width: 2),
                              borderRadius: BorderRadius.circular(8)),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                    "▸ You confirm that this submission does not contain any personally identifiable information."),
                                Container(
                                  height: 3,
                                ),
                                Text(
                                    "▸ You confirm that this submission does not contain any content deemed Not Safe For Work."),
                                Container(
                                  height: 3,
                                ),
                                Text(
                                    "▸ You confirm that this submission does in no way incite violence, or hold the intent of offending others."),
                                Container(
                                  height: 3,
                                ),
                                Text(
                                    "▸ You confirm that for this submission images provided are relevant to the rest of the content in the submission."),
                                Container(
                                  height: 3,
                                ),
                                Text(
                                    "▸ You acknowledge that once created this submission cannot be modified, as it will be submitted to the cloud and will no longer be deemed your possession."),
                                Container(
                                  height: 3,
                                ),
                                Text(
                                    "▸ You acknowledge that failure to follow the rules of this app, may result in suspension of future submissions from the offending device."),
                              ],
                            ),
                          )),
                      Container(
                        margin:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: ElevatedButton(
                          onPressed: (){
                            Navigator.pop(context,{"confirmed": true});
                          },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.black
                            ),
                          child: Text("Acknowledged")
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )));
  }
}
