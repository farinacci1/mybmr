import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mybmr/services/custom_rect_twenn.dart';
import 'package:mybmr/services/toast.dart';

class QuantitySetterPopup extends StatefulWidget {
  final double value;

  final String itemName;
  QuantitySetterPopup({this.value = 0.0, this.itemName = "item"});
  @override
  _QuantitySetterPopup createState() => _QuantitySetterPopup();
}

class _QuantitySetterPopup extends State<QuantitySetterPopup> {
  String _TAG = "QUANTITY_SETTER_POPUP";
  TextEditingController _controller = new TextEditingController();
  @override void initState() {
    _controller.text =widget.value.toString();
    super.initState();
  }
  @override void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Hero(
            tag: _TAG,
            createRectTween: (begin, end) {
              return CustomRectTween(begin: begin, end: end);
            },
            child: Container(
                height: 150,
                child: Material(
                    elevation: 3,
                    color: Colors.grey[200],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    child: Container(
                      width: 200,
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(widget.itemName,style: TextStyle(decoration: TextDecoration.underline),),
                          TextField(
                            controller: _controller,
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(7)
                            ],
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: "Amount",

                            ),
                          ),
                          ElevatedButton(
                              onPressed: () {
                                String numText = _controller.value.text.trim();
                                try{
                                  double out = double.parse(numText);
                                  Navigator.pop(context,{"amount": out});
                                }catch(_){
                                  CustomToast("Value is not a valid number");
                                }

                              }, child: Text("Update"))
                        ],
                      ),
                    )))));
  }
}
