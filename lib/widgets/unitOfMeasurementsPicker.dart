import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mybmr/constants/Constants.dart';
import 'package:mybmr/constants/messages/en_messages.dart';

import 'CustomDropdown.dart';

class MeasurementPicker extends StatefulWidget {
  /*
  * Measurement picker is a tool that enables user to set  weight, volume, or energy values by unit of measurement
  *
  * */
  @required
  final String radioVal;
  @required
  final String selectedMeasurement;
  @required
  final ValueSetter<String> onChanged;
  @required
  final bool supportsRDI;
  @required
  final List<bool> dataTypes;
  const MeasurementPicker({
    Key key,
    this.radioVal = "Weight",
    this.supportsRDI = false,
    this.selectedMeasurement,
    this.onChanged,
    this.dataTypes,
  }) : super(key: key);
  @override
  _MeasurementPickerState createState() => _MeasurementPickerState();
}

class _MeasurementPickerState extends State<MeasurementPicker> {
  bool _isNew = true;
  String _selectedMeasurement;
  String _radioVal;

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
    if (_isNew) {
      _radioVal = widget.radioVal;
      switch (_radioVal) {
        case "Weight":
          _selectedMeasurement = widget.selectedMeasurement;
          widget.onChanged(_selectedMeasurement);
          break;
        case "Volume":
          _selectedMeasurement = widget.selectedMeasurement;
          widget.onChanged(_selectedMeasurement);
          break;
        case "Energy":
          _selectedMeasurement = widget.selectedMeasurement;
          widget.onChanged(_selectedMeasurement);
          break;
      }
      _isNew = false;
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            margin: EdgeInsets.only(top: 5),
            alignment: AlignmentDirectional.topStart,
            child: AutoSizeText(
              "Units of Measurement",
              maxLines: 1,
              style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14.h),
            )),
        Container(
            height: 53.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                widget.dataTypes[0] == true
                    ? Container(
                        margin: EdgeInsets.only(right: 5),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Radio<String>(
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity:
                                    VisualDensity(horizontal: -4, vertical: 0),
                                value: "Volume",
                                groupValue: _radioVal,
                                activeColor: Colors.red,
                                onChanged: (String val) {
                                  setState(() {
                                    _radioVal = "Volume";
                                    _selectedMeasurement =
                                        volumeMeasurements[5];
                                    widget.onChanged(_selectedMeasurement);
                                  });
                                }),
                            AutoSizeText(en_messages["volume_label"],maxLines: 1,style: TextStyle(fontSize: 14.h),),
                          ],
                        ),
                      )
                    : Container(),
                widget.dataTypes[1] == true
                    ? Container(
                        margin: EdgeInsets.only(right: 5),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Radio<String>(
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity:
                                    VisualDensity(horizontal: -4, vertical: 0),
                                value: "Weight",
                                groupValue: _radioVal,
                                activeColor: Colors.red,
                                onChanged: (String val) {
                                  setState(() {
                                    _radioVal = "Weight";
                                    _selectedMeasurement =
                                        weightMeasurements[2];
                                    widget.onChanged(_selectedMeasurement);
                                  });
                                }),
                            AutoSizeText(en_messages["weight_label"],maxLines: 1,style: TextStyle(fontSize: 14.h),),
                          ],
                        ),
                      )
                    : Container(),
                widget.dataTypes[2] == true
                    ? Container(
                        margin: EdgeInsets.only(right: 5),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Radio<String>(
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity:
                                    VisualDensity(horizontal: -4, vertical: 0),
                                value: "Energy",
                                groupValue: _radioVal,
                                activeColor: Colors.red,
                                onChanged: (String val) {
                                  setState(() {
                                    _radioVal = "Energy";
                                    _selectedMeasurement =
                                        energyMeasurements[0];
                                    widget.onChanged(_selectedMeasurement);
                                  });
                                }),
                            AutoSizeText(en_messages["energy_label"],maxLines: 1,style: TextStyle(fontSize: 14.h),),
                          ],
                        ),
                      )
                    : Container(),
              ],
            )),
        (_radioVal == "Volume")
            ? CustomDropdownButton(
                value: _selectedMeasurement,
                items: volumeMeasurements.map((String val) {
                  return DropdownMenuItem<String>(child: AutoSizeText(val,maxLines: 1,style: TextStyle(fontSize: 16.h),), value: val);
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMeasurement = value;
                    widget.onChanged(_selectedMeasurement);
                  });
                },
              )
            : (_radioVal == "Weight")
                ? CustomDropdownButton(
                    value: _selectedMeasurement,
                    items: weightMeasurements.sublist(0,widget.supportsRDI ? weightMeasurements.length  :weightMeasurements.length - 1).map((String val) {
                      return DropdownMenuItem<String>(
                          child: AutoSizeText(val,maxLines: 1,style: TextStyle(fontSize: 16.h),), value: val);
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedMeasurement = value;
                        widget.onChanged(_selectedMeasurement);
                      });
                    },
                  )
                : CustomDropdownButton(
                    value: _selectedMeasurement,
                    items: energyMeasurements.map((String val) {
                      return DropdownMenuItem<String>(
                          child: AutoSizeText(val,maxLines: 1,style: TextStyle(fontSize: 16.h),), value: val);
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedMeasurement = value;
                        widget.onChanged(_selectedMeasurement);
                      });
                    },
                  )
      ],
    );
  }
}
