import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mybmr/constants/messages/en_messages.dart';
import 'package:mybmr/services/custom_rect_twenn.dart';
import 'package:mybmr/services/toast.dart';
import 'package:mybmr/widgets/CustomDropdown.dart';

class StepPopup extends StatefulWidget {
  /*
  * stepPopup is the widget that popups in center of UI and is used for creating recipe steps
  *
  * */
  final String step;
  final int stepIndex;
  final int stepRange;

  const StepPopup({
    Key key,
    this.step = "",
    this.stepIndex = -1,
    this.stepRange = 1,
  }) : super(key: key);
  @override
  _StepPopupState createState() => _StepPopupState();
}

class _StepPopupState extends State<StepPopup> {
  static const String _StepPopup = "STEP_POPUP";
  TextEditingController _controller = TextEditingController();

  int stepNum;
  List<int> numbers = [];
  @override void dispose() {
    if(_controller!=null)_controller.dispose();
    super.dispose();
  }
  @override
  void initState() {
    numbers = List<int>.generate(widget.stepRange, (int index) => index + 1);
    print(numbers.toString());
    if (widget.stepIndex != -1)
      stepNum = widget.stepIndex;
    else
      stepNum = widget.stepRange;
    print(stepNum.toString());
    if (widget.step != null) _controller.text = widget.step;
    super.initState();
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
            tag: _StepPopup,
            createRectTween: (begin, end) {
              return CustomRectTween(begin: begin, end: end);
            },
            child: Container(
                margin: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Material(
                  elevation: 3,
                  color: Colors.grey[200],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Container(
                      width: 331.25.h,
                      margin: EdgeInsets.all(18),
                      child: SingleChildScrollView(
                          child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Add A Step",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 31.8.h),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 5),
                            child: TextField(
                                controller: _controller,
                                style: TextStyle(fontSize: 20.h),
                                maxLines: 5,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.done,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(512),
                                ],
                                maxLength: 512,
                                decoration: new InputDecoration(
                                    enabledBorder: const OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.grey, width: 0.0),
                                ))),
                          ),
                          Container(
                            margin: EdgeInsets.only(bottom: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Step Number ",style: TextStyle(fontSize: 16.h),),
                                Container(
                                    width: 66.25.h,
                                    margin: EdgeInsets.only(left: 15),
                                    child: CustomDropdownButton(
                                      style: TextStyle(fontSize: 21.h,color: Colors.black),
                                      iconSize: 31.8.h,
                                      value: stepNum,
                                      items: numbers
                                          .map((int index) =>
                                              DropdownMenuItem<int>(
                                                child: Text(index.toString()),
                                                value: index,
                                              ))
                                          .toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          stepNum = value;
                                        });
                                      },
                                    ))
                              ],
                            ),
                          ),
                          Container(

                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                    child: Container(
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.pop(context, {"step": ""});
                                          },
                                          child: Container(
                                            height: 53.h,
                                            alignment: AlignmentDirectional.center,
                                            child: Text("Cancel",style: TextStyle(fontSize: 26.5.h)),
                                          ),
                                        ))),
                                Expanded(
                                    child: Container(
                                        child: GestureDetector(
                                  onTap: () {
                                    String step = _controller.value.text;
                                    step = step.trim();
                                    step = step.replaceAll(RegExp('\\s+'), " ");

                                    if (step.length > 0) {
                                      Navigator.pop(context,
                                          {"step": step, "stepNum": stepNum});
                                    } else {
                                      CustomToast(en_messages[
                                          "step_missing_instruction"]);
                                    }
                                  },
                                  child: Container(
                                    height: 53.h,
                                    alignment: AlignmentDirectional.center,
                                    child: Text("Confirm",style: TextStyle(fontSize: 26.5.h),),
                                  ),
                                ))),

                              ],
                            ),
                          )
                        ],
                      ))),
                ))));
  }
}
