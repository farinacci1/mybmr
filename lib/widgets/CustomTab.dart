import 'package:flutter/cupertino.dart';

class CustomTab extends StatefulWidget {
  @required final Function(int) onChangeIdx;
  @required final int defaultIdx;
  @required final List<Widget> tabs;
  @required final Widget child;
  const CustomTab({Key key, this.onChangeIdx, this.defaultIdx, this.tabs, this.child})
      : super(key: key);
  @override
  _CustomTabState createState() => _CustomTabState();
}

class _CustomTabState extends State<CustomTab> {
  int idx;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(

        children: [


         widget.child

        ],
      ),
    );
  }
}
