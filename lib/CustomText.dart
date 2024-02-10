import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  CustomText(this.text, {this.style, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle defaultStyle = GoogleFonts.mPlus1();

    TextStyle effectiveStyle = defaultStyle.merge(style);

    return Text(
      text,
      style: effectiveStyle,
    );
  }
}