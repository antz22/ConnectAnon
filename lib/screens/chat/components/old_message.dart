import 'package:anonymous_chat/constants/constants.dart';
import 'package:anonymous_chat/models/chat_message.dart';
import 'package:flutter/material.dart';

class Message extends StatelessWidget {
  const Message({Key? key, required this.message}) : super(key: key);

  final ChatMessage message;

  // lil sketchy here
  static GlobalKey _globalKey = GlobalKey();
  final double _maxWidth = 280.0;

  double _getHeight() {
    final RenderBox textMessage =
        _globalKey.currentContext?.findRenderObject() as RenderBox;
    final height = textMessage.size.height;
    return height;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 0.3 * kDefaultPadding),
      child: Row(
        mainAxisAlignment:
            message.isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            key: _globalKey,
            constraints: BoxConstraints(maxWidth: _maxWidth),
            padding: EdgeInsets.symmetric(
              horizontal: 0.75 * kDefaultPadding,
              vertical: 0.5 * kDefaultPadding,
            ),
            decoration: BoxDecoration(
              color: message.isSender
                  ? kPrimaryColor.withOpacity(0.2)
                  : kTertiaryColor,
              borderRadius: _getHeight() == _maxWidth
                  ? BorderRadius.circular(15)
                  : BorderRadius.circular(35),
            ),
            child: Text(
              message.text,
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
