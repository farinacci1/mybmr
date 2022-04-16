import 'package:flutter/material.dart';

class ActionDialogue {
  final VoidCallback approveAction;
  final VoidCallback declineAction;
  @required
  final String title;
  @required
  final String message;
  @required
  final String approveLabel;
  @required
  final String declineLabel;
  @required
  final BuildContext ctx;
  const ActionDialogue(
      {Key key,
      this.approveAction,
      this.declineAction,
      this.title = "Delete Confirmation",
      this.message,
      this.approveLabel = "Delete",
      this.declineLabel = "Cancel",
      this.ctx});
  Future<bool> build(BuildContext ctx) async {
    return await showDialog(
        context: ctx,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text(title, maxLines: 1),
              content: Text(message, maxLines: 3),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    if (declineAction != null) declineAction();
                    Navigator.of(context).pop(false);
                  },
                  child: Text(declineLabel),
                ),
                ElevatedButton(
                    onPressed: () {
                      if (approveAction != null) approveAction();
                      Navigator.of(context).pop(true);
                    },
                    child: Text(approveLabel)),

              ]);
        });
  }
}
