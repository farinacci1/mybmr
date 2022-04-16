import 'package:flutter/material.dart';

class RecipeChoice extends StatefulWidget {
  final List<Widget> children;
  final double height;
  final Duration duration;
  final Color backgroundColor;
  final bool isHidden;
  final VoidCallback onClose;
  const RecipeChoice({
    Key key,
    this.children,
    this.height = 200,
    this.duration = const Duration(milliseconds: 300),
    this.backgroundColor = Colors.white,
    this.isHidden = true,
    this.onClose,
  }) : super(key: key);
  @override
  _RecipeChoiceState createState() => _RecipeChoiceState();
}

class _RecipeChoiceState extends State<RecipeChoice> {
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
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(50)),

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
