import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mybmr/notifiers/EquipmentNotifier.dart';
import 'package:mybmr/constants/messages/en_messages.dart';
import 'package:mybmr/services/custom_rect_twenn.dart';
import 'package:mybmr/services/hero_dialog_route.dart';
import 'package:mybmr/services/toast.dart';
import 'package:mybmr/models/Equipment.dart';
import 'package:mybmr/views/creationMenus/popups/RuleConfirmation.dart';

import 'package:provider/provider.dart';

import '../../../constants/Themes.dart';

class EquipmentPopup extends StatefulWidget {
  final Equipment equipment;
  final bool inShopping;
  const EquipmentPopup({
    Key key,
    this.equipment, this.inShopping =false,
  }) : super(key: key);
  @override
  _EquipmentPopupState createState() => _EquipmentPopupState();
}

class _EquipmentPopupState extends State<EquipmentPopup> {
  static const String _EquipmentPopup = "EQUIPMENT_POPUP";
  final ImagePicker _picker = ImagePicker();
  bool isNew = true;
  TextEditingController _controller;
  File imageFile;
  String equipmentImageFromDb;

  @override void dispose() {
    _controller.dispose();

    super.dispose();
  }


  Future<void> createEquipment(String name) async {
      Equipment equip;
      if(imageFile == null){
        CustomToast(en_messages["equipment_missing_image"]);
      }else{

        Map<String, dynamic> out =
        await Navigator.of(context)
            .push(HeroDialogRoute(builder: (context) {
          return RuleConfirmationPopup();
        }));
        if(out !=null && out["confirmed"] == true){
          equip = Equipment(name: name,image: imageFile);
          Provider.of<EquipmentNotifier>(context, listen: false).createEquipment(equip,isForRecipe: !widget.inShopping);
          Navigator.pop(context,{"create": true});
        }
      }



  }



  @override
  void initState() {
    _controller = TextEditingController();
    if (widget.equipment != null) {
      _controller.text = widget.equipment.name;
      if (widget.equipment.image != null) imageFile = widget.equipment.image;
      if (widget.equipment.equipmentImageFromDb != null && widget.equipment.equipmentImageFromDb.length > 0) equipmentImageFromDb = widget.equipment.equipmentImageFromDb;
    }
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
      tag: _EquipmentPopup,
      createRectTween: (begin, end) {
        return CustomRectTween(begin: begin, end: end);
      },
          child: Container(
              width: 344.5.h,
          margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Material(
              elevation: 3,
              color:color_palette["white"],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),

                  child: Container(
                    padding: EdgeInsets.fromLTRB(15,35,15,5),
                      child:Stack(
                      clipBehavior: Clip.none,
                      alignment: AlignmentDirectional.topCenter,
                      children: [
                        Container(
                            width: 291.5.h,
                            padding: EdgeInsets.symmetric(vertical: 25),
                            decoration: BoxDecoration(
                                border: Border(
                              top: BorderSide(color: color_palette["background_color"]),
                            )),
                            child:SingleChildScrollView(child:  Column(
                              mainAxisSize: MainAxisSize.min,
                                children: [
                              TextField(
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(18),
                                ],
                                enabled: widget.equipment == null,
                                controller: _controller,
                                style: TextStyle(),
                                decoration: InputDecoration(

                                    labelText: "Equipment Name"),
                              ),
                              Padding(padding: EdgeInsets.only(top: 10)),
                              GestureDetector(
                                onTap: () async {
                                  if( widget.equipment == null){
                                    print("Request for image");
                                    XFile pickedFile = await _picker.pickImage(
                                        source: ImageSource.gallery,
                                        maxHeight: 1024,
                                        maxWidth: 1024);
                                    if (pickedFile != null) {
                                      imageFile = File(pickedFile.path);
                                      setState(() {});
                                    }
                                  }

                                },
                                child: Container(
                                  margin: EdgeInsets.only(top: 20),
                                  height: 132.5.h,
                                  width: double.infinity,
                                  color: color_palette["overlay"],
                                  child: imageFile != null
                                      ? Image.file(
                                    imageFile,
                                    fit: BoxFit.cover,
                                  ): equipmentImageFromDb != null ? 
                                      Image.network(equipmentImageFromDb,
                                        fit: BoxFit.cover,)
                                      :Column(
                                    mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                              Icon(
                                                Icons.add_a_photo,
                                                size: 47.7.h,
                                                color: color_palette["white"],
                                              ),
                                              Container(
                                                height: 2.65.h,
                                              ),
                                              Text(
                                                "Add a photo",
                                                style: TextStyle(
                                                    color: color_palette["white"],
                                                    fontSize: 21.2.h),
                                              )
                                            ])


                                ),
                              ),
                              Padding(padding: EdgeInsets.only(top: 10)),
                              Container(
                                height: 30,
                                margin: EdgeInsets.only(top: 10),
                                child: widget.equipment == null ? Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        String name = _controller.value.text;
                                        name = name.trim();
                                        if (name.length == 0) {
                                          CustomToast(en_messages["equipment_missing_title"]);
                                        } else {
                                          createEquipment(name);
                                        }
                                      },
                                      child: Text("Ok"),
                                      style: ElevatedButton.styleFrom(
                                          primary: Colors.black),
                                    ),
                                    Container(
                                      width: 8,
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context,{"create":false});
                                      },
                                      child: Text("Cancel"),
                                      style: ElevatedButton.styleFrom(
                                          primary: Colors.black),
                                    )
                                  ],
                                )
                                : Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {

                                        if(!widget.inShopping){
                                          Provider.of<EquipmentNotifier>(context,listen: false).addEquipmentToRecipe(widget.equipment);
                                          Provider.of<EquipmentNotifier>(context,listen: false).optionSelected = true;
                                          Navigator.pop(context, {"use": true});
                                        }else{
                                          Navigator.pop(context, {"use": true, "equipment" :widget.equipment});
                                        }

                                      },
                                      child: Text("Use"),
                                      style: ElevatedButton.styleFrom(
                                          primary: Colors.black),
                                    )
                                  ],
                                ),
                              )
                            ]))),
                        Positioned(
                            top: -27,
                            child: Text(
                              widget.equipment == null ? "  Equipment\n Maker  " : "  Equipment\n Selector  ",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                height: 1.1,
                                backgroundColor: color_palette["white"],
                                color: color_palette["overlay"],
                              ),
                            ))
                      ])))),
    ));
  }
}

extension TimeOfDayExtension on TimeOfDay {
  int compareTo(TimeOfDay other) {
    if (this.hour < other.hour) return -1;
    if (this.hour > other.hour) return 1;
    if (this.minute < other.minute) return -1;
    if (this.minute > other.minute) return 1;
    return 0;
  }

  TimeOfDay convertString(String timeString) {
    return TimeOfDay(
        hour: int.parse(timeString.split(":")[0]),
        minute: int.parse(timeString.split(":")[1].split(" ")[0]));
  }
}
