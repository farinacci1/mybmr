import 'package:flutter/material.dart';

Map<String, dynamic> color_palette = {
  "background_color": Color(0xFF121212),
  "text_color_alt": Color(0xFFe48400),
  "text_color_dark": Color(0xFF430051),
  "white": Color(0XFFF5F5F5),
  "overlay": Color(0xBB444444),
  "tone": Color(0x22555555),
  "neutral": Colors.greenAccent,
  "offWhite": Colors.white70,
  "error_color": Colors.redAccent,
  "semi_transparent": Color(0x33000000),
  "alternative": Color(0xFF353935),
  "gradient": LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [Color(0xFF434343), Color(0xFFe48400), Color(0xFFe48400)],
  ),
  "gradient_inverse": LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topRight,
    colors: [Color(0xFF434343), Color(0xFFe48400), Color(0xFFe48400)],
  )
};
