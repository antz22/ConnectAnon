import 'package:flutter/material.dart';

const kPrimaryColor = Color(0xFF4158D0);
const kSecondaryColor = Color(0xFFC850C0);
const kTertiaryColor = Color(0xFFF4F4F4);

const kDefaultPadding = 20.0;

kGradient1() {
  return LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [Color(0xFF9C63E4), Color(0xFF2B9DCE)],
  );
}

kGradient2() {
  return LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [Color(0xFF6DB0FF), Color(0xFFBE50C8)],
  );
}

Map<int, Color> colors = {
  50: Color.fromRGBO(147, 205, 72, .1),
  100: Color.fromRGBO(147, 205, 72, .2),
  200: Color.fromRGBO(147, 205, 72, .3),
  300: Color.fromRGBO(147, 205, 72, .4),
  400: Color.fromRGBO(147, 205, 72, .5),
  500: Color.fromRGBO(147, 205, 72, .6),
  600: Color.fromRGBO(147, 205, 72, .7),
  700: Color.fromRGBO(147, 205, 72, .8),
  800: Color.fromRGBO(147, 205, 72, .9),
  900: Color.fromRGBO(147, 205, 72, 1),
};

MaterialColor customSwatch = new MaterialColor(0xFF4158D0, colors);
