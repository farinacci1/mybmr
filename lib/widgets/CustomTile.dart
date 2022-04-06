import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';

class CustomTile extends StatelessWidget{
  final double height;
  final double width;
  final Color color;
  final Widget trailing;
  final AutoSizeText title;
  final Widget subtitle;
  final Widget preceding;
  final BorderRadius radius;

  const CustomTile({Key key, this.height, this.width, this.color, this.trailing, this.title, this.subtitle, this.preceding, this.radius}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Container(
      height: height,
      width:width,
      alignment: AlignmentDirectional.center,
      margin: EdgeInsets.fromLTRB(10, 8, 10, 0),
      decoration: BoxDecoration(
          color:color,
          borderRadius: radius),
      child: Row(
        children: [
          Container(
              margin: EdgeInsets.only(left: 15),

              child: preceding),
          Expanded(
            child: Container(
                margin: EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    title,
                    subtitle
                  ],
                )),
          ),
          Container(
            margin: EdgeInsets.only(right: 15),
            child: Container(
              height: double.infinity,
              child: trailing
            ),
          ),
        ],
      ),
    );
  }

}