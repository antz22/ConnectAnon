import 'package:flutter/material.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 24.0,
      ),
    );
  }
}
