import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ChoiceButton extends StatelessWidget {
  final List<Color> colors;
  final IconData faIcon;
  final double size;
  final Color primary;
  final EdgeInsets margin;
  final Function onTap;
  ChoiceButton({
    @required this.colors,
    @required this.faIcon,
    this.onTap,
    this.size = 80.0,
    this.primary = Colors.white,
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
        onTap: () {
          if (this.onTap != null) this.onTap();
        },
        child: Container(
            width: this.size,
            height: this.size,
            alignment: AlignmentDirectional.center,
            margin: this.margin,
            child: FaIcon(
              faIcon,
              color: primary,
              size: 26,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(size / 2),
              boxShadow: [
                BoxShadow(
                    color: Colors.white, offset: Offset(0, 4), blurRadius: 5.0)
              ],
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0.0, 1.0],
                  colors: this.colors),
            )));
  }
}
