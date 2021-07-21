import 'package:anonymous_chat/constants/constants.dart';
import 'package:anonymous_chat/models/chat_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Message extends StatelessWidget {
  Message({Key? key, required this.document}) : super(key: key);

  final DocumentSnapshot? document;

  final double _maxWidth = 280.0;
  final String id = User.uid;

  bool _checkIsSender() {
    return document?.get('idFrom') == id ? true : false;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.3 * kDefaultPadding),
      child: Row(
        mainAxisAlignment:
            _checkIsSender() ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: _maxWidth),
            padding: EdgeInsets.symmetric(
              horizontal: 0.75 * kDefaultPadding,
              vertical: 0.5 * kDefaultPadding,
            ),
            decoration: BoxDecoration(
                color: _checkIsSender()
                    ? kPrimaryColor.withOpacity(0.2)
                    : kTertiaryColor,
                borderRadius: BorderRadius.circular(20)),
            child: Text(
              document?.get('text'),
              style: TextStyle(
                fontSize: 13.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
