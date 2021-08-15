import 'package:flutter/material.dart';
import 'package:anonymous_chat/constants/constants.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.textarea = false,
  }) : super(key: key);

  final TextEditingController controller;
  final String hintText;
  final bool textarea;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: hintText.contains('Password') ? true : false,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Color(0xFFEEEEEE),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13.0),
          borderSide: BorderSide(width: 0, style: BorderStyle.none),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13.0),
          borderSide: BorderSide(width: 2, color: kPrimaryColor),
        ),
      ),
      keyboardType: textarea ? TextInputType.multiline : TextInputType.text,
      maxLines: textarea ? 10 : 1,
    );
  }
}
