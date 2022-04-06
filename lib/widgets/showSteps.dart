import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mybmr/constants/messages/en_messages.dart';

import 'package:mybmr/models/RecipeStep.dart';
import 'package:mybmr/services/hero_dialog_route.dart';
import 'package:mybmr/views/creationMenus/popups/stepPopup.dart';


class ShowSteps extends StatefulWidget {
  /*
  * ShowSteps class takes all recipe steps and create a vertical ordered list of steps
  * */
  @required final Function(RecipeStep) onRemove;
  @required final List<RecipeStep> steps;
  @required final Color indexColor;
  @required final Function(String step, int prevIdx, int currIdx) onUpdate;

  const ShowSteps({Key key, this.onRemove, this.steps, this.indexColor, this.onUpdate}) : super(key: key);
  @override
  _ShowStepsState createState() => _ShowStepsState();
}

class _ShowStepsState extends State<ShowSteps> {



  @override
  Widget build(BuildContext context) {

    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: widget.steps.asMap().map((int index,RecipeStep step) => MapEntry(
              index,
              Dismissible(
                  key: UniqueKey(),
                  confirmDismiss: (DismissDirection direction) async {
                    if (direction == DismissDirection.endToStart) {
                      return await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                                title:  Text(en_messages["delete_confirmation"],maxLines: 1,),
                                content:  Text(
                                   en_messages["step_remove_question"],maxLines: 3,),
                                actions: <Widget>[
                                  ElevatedButton(
                                      onPressed: () {
                                        widget.onRemove(step);

                                        Navigator.of(context).pop(true);
                                      },
                                      child:  Text(en_messages["delete"],maxLines: 1,)),
                                  ElevatedButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child:  Text(en_messages["cancel"],maxLines: 1,),
                                  ),
                                ]);
                          });
                    }
                    return null;
                  },
                  child: GestureDetector(
                      onTap: () async {
                        Map<String, dynamic> out =
                            await Navigator.of(context)
                            .push(HeroDialogRoute(builder: (context) {
                          return StepPopup(
                            step:step.string,
                            stepIndex: step.stepNum + 1 ,
                            stepRange: widget.steps.length,
                          );
                        }));
                        if (out != null) {
                          String stepStr = out["step"];
                          if (stepStr.length > 0) {
                            int stepNum = out["stepNum"];
                            if (stepStr.length > 0) {

                              widget.onUpdate(stepStr,step.stepNum,stepNum - 1);
                            }

                          }
                        }
                      },
                      child:Container(
                    padding: EdgeInsets.only(left: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,

                      children: [
                        Stack(
                          alignment: AlignmentDirectional.center,
                          children: [
                            SvgPicture.asset(
                              "assets/images/step.svg",
                              height: 36,
                              color: widget.indexColor,
                            ),
                            AutoSizeText(
                                (index + 1).toString(),
                              maxLines: 1,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 10),
                        ),
                        Flexible(child:
                        Text(
                          step.string,
                          style: TextStyle(fontSize: 20, color: Colors.white),
                          softWrap: true,
                        ),)
                      ],
                    ),
                  )))
          )
         
        ).values.toList(),
      ),
    );
  }
}
