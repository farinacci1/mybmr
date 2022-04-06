import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

/// Creates a Widget representing the day.
class DayItem extends StatelessWidget {
  final int dayNumber;
  final String shortName;
  final bool isSelected;
  final Function onTap;
  final Color dayColor;
  final Color activeDayColor;
  final Color activeDayBackgroundColor;
  final bool available;
  final Color dotsColor;
  final Color dayNameColor;
  final double height;
  final double width;
  const DayItem({
    Key key,
    @required this.dayNumber,
    @required this.shortName,
    @required this.onTap,
    this.isSelected = false,
    this.dayColor,
    this.activeDayColor,
    this.activeDayBackgroundColor,
    this.available = true,
    this.dotsColor,
    this.dayNameColor,
    this.height = 70.0,
    this.width = 60.0
  }) : super(key: key);



  _buildDay(BuildContext context) {
    final textStyle = TextStyle(
        color: available
            ? dayColor ?? Theme.of(context).colorScheme.secondary
            : dayColor?.withOpacity(0.5) ??
            Theme.of(context).colorScheme.secondary.withOpacity(0.5),
        fontSize:  this.height * 0.45,
        fontWeight: FontWeight.normal);
    final selectedStyle = TextStyle(
      color: activeDayColor ?? Colors.white,
      fontSize: this.height * 0.45,
      fontWeight: FontWeight.bold,
      height: 0.8,
    );

    return GestureDetector(
      onTap: available ? onTap as void Function() : null,
      child: Container(
        decoration: isSelected
            ? BoxDecoration(
          color:
          activeDayBackgroundColor ?? Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(.172 * this.height),
        )
            : BoxDecoration(color: Colors.transparent),
        height: height,
        width: width,
        child: Column(
          children: <Widget>[
            if (isSelected) ...[
              SizedBox(height: .1 * this.height),
              _buildDots(),
              SizedBox(height: .1714 * this.height),
            ] else
              SizedBox(height: .2 * this.height),
            AutoSizeText(
              dayNumber.toString(),
              maxLines: 1,
              style: isSelected ? selectedStyle : textStyle,
            ),
            if (isSelected)
              AutoSizeText(
                shortName,
                maxLines: 1,
                style: TextStyle(
                  color: dayNameColor ?? activeDayColor ?? Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 0.2 * this.height,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDots() {
    final dot = Container(
      height: .0714 * this.height,
      width:  .0714 * this.height,
      decoration: new BoxDecoration(
        color: this.dotsColor ?? this.activeDayColor ?? Colors.white,
        shape: BoxShape.circle,
      ),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [dot, dot],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildDay(context);
  }
}

