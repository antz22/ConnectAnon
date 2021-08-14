import 'package:flutter/material.dart';

class SubText extends StatelessWidget {
  const SubText({Key? key, required this.text}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15.0,
          color: Colors.grey.shade500,
        ),
      ),
    );
  }
}
