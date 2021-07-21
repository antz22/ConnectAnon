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
