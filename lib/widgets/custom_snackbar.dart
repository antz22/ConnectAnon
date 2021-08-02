import 'package:anonymous_chat/constants/constants.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

class CustomSnackbar {
  static Widget buildInfoMessage(
      BuildContext context, String title, String message) {
    return Flushbar(
      title: title,
      messageText: Text(message, style: TextStyle(color: Colors.white)),
      duration: Duration(seconds: 2),
      icon: Icon(Icons.info, color: Colors.white),
      backgroundColor: kPrimaryColor,
      titleColor: Colors.white,
    )..show(context);
  }

  static Widget buildWarningMessage(
      BuildContext context, String title, String message) {
    return Flushbar(
      title: title,
      message: message,
      duration: Duration(seconds: 4),
      icon: Icon(Icons.info, color: Colors.red),
    )..show(context);
  }
}
