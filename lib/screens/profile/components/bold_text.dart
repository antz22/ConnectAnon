import 'package:flutter/material.dart';

class BoldText extends StatelessWidget {
  const BoldText({Key? key, required this.text, this.color = Colors.black})
      : super(key: key);

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 20.0,
        color: color,
      ),
    );
  }
}
