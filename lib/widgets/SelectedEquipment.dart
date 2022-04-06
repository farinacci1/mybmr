import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:mybmr/notifiers/EquipmentNotifier.dart';
import 'package:mybmr/constants/Constants.dart';
import 'package:mybmr/constants/messages/en_messages.dart';
import 'package:mybmr/models/Equipment.dart';
import 'package:provider/provider.dart';


class SelectedEquipment extends StatefulWidget {
  /*
  * selectedEquipment is a vertical list that contains that shows all equipment selected for use in recipe
  * and possess the ability to remove them from the list
  *  used by class recipebuilder
  * */

  const SelectedEquipment({Key key}) : super(key: key);
  @override
  _SelectedEquipmentState createState() => _SelectedEquipmentState();
}

class _SelectedEquipmentState extends State<SelectedEquipment> {


  List<Widget> drawEquipment({List<Equipment> equipment,}) {
    List<Widget> out = [];
    for (Equipment equip in equipment) {

      Widget child = Dismissible(
          key: UniqueKey(),
          confirmDismiss: (DismissDirection direction) async {
            if (direction == DismissDirection.endToStart) {
              return await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                        title:  Text(en_messages["delete_confirmation"],maxLines: 1,),
                        content:  Text(
                            en_messages["remove_equipment_question"],maxLines: 3,),
                        actions: <Widget>[
                          ElevatedButton(
                              onPressed: () {
                                 Provider.of<EquipmentNotifier>(context,listen: false).removeEquipmentFromRecipe(equip);
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
          child: Container(
            padding: EdgeInsets.only(left: 8,bottom:10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100.0),
                      border: Border.all(color: Colors.blueGrey,),
                      image: DecorationImage(
                          image: NetworkImage(
                            equip.equipmentImageFromDb,
                          ),
                          fit: BoxFit.fill)
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 10),
                ),
                Expanded(child:AutoSizeText(
                  toTitleCase(equip.name),
                  maxLines: 1,
                  style: TextStyle(fontSize: 20, color: Colors.white),

                  overflow: TextOverflow.ellipsis,

                )),

              ],
            ),
          ));

      out.add(child);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    EquipmentNotifier equipmentNotifier = Provider.of<EquipmentNotifier>(context,listen: true);
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: drawEquipment(equipment: equipmentNotifier.equipmentList_inUse),
      ),
    );
  }
}
