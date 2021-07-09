import 'package:flutter/material.dart';

class TextBlob extends StatelessWidget {
  const TextBlob({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w400,
        height: 1.8,
        fontSize: 17,
      ),
    );
  }
}
