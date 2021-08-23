import 'package:connect_anon/constants/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Message extends StatefulWidget {
  Message({Key? key, required this.userId, required this.document})
      : super(key: key);

  final String userId;
  final DocumentSnapshot? document;

  @override
  _MessageState createState() => _MessageState();
}

class _MessageState extends State<Message> {
  final double _maxWidth = 280.0;

  bool isSender = false;
  bool _pressed = false;

  Future<bool> _checkIsSender() async {
    isSender = widget.document?.get('idFrom') == widget.userId ? true : false;
    return widget.document?.get('idFrom') == widget.userId ? true : false;
  }

  String _getMessageTime() {
    var date = DateTime.fromMicrosecondsSinceEpoch(
        int.parse(widget.document!['timestamp']) * 1000);
    var format = new DateFormat('h:mm a');
    String time = format.format(date);
    return time;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _checkIsSender(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        return Padding(
          padding: EdgeInsets.only(bottom: 0.3 * kDefaultPadding),
          child: Column(
            crossAxisAlignment:
                isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (_pressed == true) {
                      _pressed = false;
                    } else {
                      _pressed = true;
                    }
                  });
                },
                child: Container(
                  constraints: BoxConstraints(maxWidth: _maxWidth),
                  padding: EdgeInsets.symmetric(
                    horizontal: 0.75 * kDefaultPadding,
                    vertical: 0.5 * kDefaultPadding,
                  ),
                  decoration: BoxDecoration(
                      color: isSender
                          ? kPrimaryColor.withOpacity(0.2)
                          : kTertiaryColor,
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    widget.document?['content'],
                    style: TextStyle(
                      fontSize: 14.5,
                    ),
                  ),
                ),
              ),
              _pressed ? _buildMessageTime() : SizedBox.shrink(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageTime() {
    return Column(
      crossAxisAlignment:
          isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          margin: isSender
              ? EdgeInsets.only(right: 5.0, top: 5.0)
              : EdgeInsets.only(left: 5.0, top: 5.0),
          child: Text(
            _getMessageTime(),
            style: TextStyle(
              fontSize: 13.0,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }
}
