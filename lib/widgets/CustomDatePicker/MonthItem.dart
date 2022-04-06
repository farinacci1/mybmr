
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

/// Creates a Widget to represent the months.
class MonthItem extends StatelessWidget {
  final String name;
  final Function onTap;
  final bool isSelected;
  final Color color;
  final double height;
  MonthItem({
    @required this.name,
    @required this.onTap,
    this.isSelected = false,
    this.color,
    this.height = 70.0
  });

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: this.onTap as void Function(),
      child: AutoSizeText(
        this.name.toUpperCase(),
        maxLines: 1,
        style: TextStyle(
          fontSize: 0.2 * this.height,
          color: color ?? Colors.black87,
          fontWeight: this.isSelected ? FontWeight.bold : FontWeight.w300,
        ),
      ),
    );
  }
}

