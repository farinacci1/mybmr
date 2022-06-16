import 'package:flutter/material.dart';

class BottomMenu extends StatefulWidget {
  final List<Widget> children;
  final double height;
  final Duration duration;
  final Color backgroundColor;
  final bool isHidden;
  final VoidCallback onClose;
  final Radius top;
  final EdgeInsets padding;
  const BottomMenu({
    Key key,
    this.children,
    this.height = 200,
    this.duration = const Duration(milliseconds: 300),
    this.backgroundColor = Colors.white,
    this.isHidden = true,
    this.onClose,
    this.top = const Radius.circular(50),
    this.padding = const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
  }) : super(key: key);
  @override
  _BottomMenuState createState() => _BottomMenuState();
}

class _BottomMenuState extends State<BottomMenu> {
  @override
  Widget build(BuildContext context) {
    return Container(

      child: Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: [
          if (!widget.isHidden)
            GestureDetector(
                onTap: () {
                  if (widget.onClose != null) widget.onClose();
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: Colors.transparent,
                )),
          AnimatedContainer(
            duration: widget.duration,
            width: MediaQuery.of(context).size.width,
            height: widget.isHidden ? 0 : widget.height,
            padding: widget.padding,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 2,
                  spreadRadius: 2

                ),
              ],
              color: widget.backgroundColor,
              borderRadius: BorderRadius.vertical(top: widget.top),

            ),
            child: NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (overscroll) {
                  overscroll.disallowIndicator();
                  return;
                },
                child: CustomScrollView(slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,

                      mainAxisSize: MainAxisSize.max,
                      children: widget.children,
                    ),
                  )
                ])),
          )
        ],
      ),
    );
  }
}
