import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mybmr/constants/Themes.dart';
import 'package:mybmr/services/custom_rect_twenn.dart';
import 'package:mybmr/widgets/unitOfMeasurementsPicker.dart';
import 'package:mybmr/constants/Constants.dart';

class NutritionPopup extends StatefulWidget {
  @required
  final String fieldName;
  @required
  final double val;
  @required
  final String uom;
  @required
  final bool acceptsOtherMeasurement;
  @required
  final bool supportsRDI;
  @required
  final List<bool> validDataTypes;
  const NutritionPopup({
    Key key,
    this.fieldName,
    this.acceptsOtherMeasurement = true,
    this.val = 0.0,
    this.uom,
    this.validDataTypes,
    this.supportsRDI = false,
  }) : super(key: key);
  @override
  _NutritionPopupState createState() => _NutritionPopupState();
}

class _NutritionPopupState extends State<NutritionPopup> {
  bool _isNew = true;
  static const String _NutritionPopup = "NUTRITION_POPUP";
  String _uom;
  TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: Size(2400, 1080),
      minTextAdapt: true,
    );
    if (_isNew) {
      _controller.text = widget.val.toString();
      _isNew = false;
    }
    return Center(
        child: Hero(
      tag: _NutritionPopup,
      createRectTween: (begin, end) {
        return CustomRectTween(begin: begin, end: end);
      },
      child: Container(
          margin:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Material(
              elevation: 3,
              color: color_palette["white"],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Container(
                  width: 344.5.h,
                  padding: EdgeInsets.only(top: 18.h, bottom: 5),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "  Nutrition  ",
                          style: TextStyle(
                              fontSize: 31.8.h,

                              color: Colors.grey[500]),
                        ),
                        Container(
                            width: 318.h,
                            padding: EdgeInsets.symmetric(vertical: 10),

                            child: SingleChildScrollView(
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                  TextField(
                                    controller: _controller,
                                    style: TextStyle(fontSize: 18.h),
                                    decoration: InputDecoration(
                                        labelText: widget.fieldName),
                                    keyboardType: TextInputType.number,
                                  ),
                                  widget.acceptsOtherMeasurement == true
                                      ? MeasurementPicker(
                                          selectedMeasurement: widget.uom,
                                          radioVal: getNutritionOptionFromName(
                                              widget.uom),
                                          dataTypes: widget.validDataTypes,
                                          supportsRDI: widget.supportsRDI,
                                          onChanged: (String val) {
                                            _uom = val;
                                          },
                                        )
                                      : Container(),
                                  Container(
                                    height: 39.75.h,
                                    margin: EdgeInsets.only(top: 10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        GestureDetector(
                                            onTap: () {
                                              Navigator.pop(context);
                                            },
                                            child: Container(
                                              alignment:
                                              AlignmentDirectional.center,
                                              width: 318.h / 2,
                                              child: Text(
                                                "Cancel",
                                                style:
                                                TextStyle(fontSize: 20.h),
                                              ),
                                            )),
                                        GestureDetector(
                                            onTap: () {
                                              String fieldVal =
                                                  _controller.value.text;
                                              fieldVal = fieldVal.replaceAll(
                                                  new RegExp(r"\s+"), "");
                                              double val = double.tryParse(
                                                  fieldVal.replaceAll(',', ''));
                                              if (val != null)
                                                Navigator.pop(context, {
                                                  "value": val,
                                                  "uom": _uom
                                                });
                                            },
                                            child: Container(
                                              width: 318.h / 2,
                                              alignment:
                                                  AlignmentDirectional.center,
                                              child: Text(
                                                "Ok",
                                                style:
                                                    TextStyle(fontSize: 20.h),
                                              ),
                                            )),

                                      ],
                                    ),
                                  )
                                ]))),

                      ])))),
    ));
  }
}
