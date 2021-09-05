import 'package:connect_anon/constants/constants.dart';
import 'package:connect_anon/models/chat_room_message.dart';
import 'package:connect_anon/widgets/custom_avatar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatRoomScreenMessage extends StatefulWidget {
  ChatRoomScreenMessage({
    Key? key,
    required this.userId,
    required this.message,
    required this.displayPhoto,
    required this.displayName,
  }) : super(key: key);

  final String userId;
  final ChatRoomMessage message;
  final bool displayPhoto;
  final bool displayName;

  @override
  _ChatRoomScreenMessageState createState() => _ChatRoomScreenMessageState();
}

class _ChatRoomScreenMessageState extends State<ChatRoomScreenMessage> {
  final double _maxWidth = 280.0;

  bool isSender = false;
  bool _pressed = false;
  String senderName = '';
  String photoUrlFrom = '';

  Future<bool> _checkSender() async {
    isSender = widget.message.idFrom == widget.userId ? true : false;
    senderName = widget.message.nameFrom;
    photoUrlFrom = widget.message.photoUrlFrom;
    return isSender;
  }

  String _getMessageTime() {
    var date = DateTime.fromMicrosecondsSinceEpoch(
        int.parse(widget.message.timestamp) * 1000);
    var format = new DateFormat('h:mm a');
    String time = format.format(date);
    return time;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _checkSender(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        return Padding(
          padding: EdgeInsets.only(bottom: 0.3 * kDefaultPadding),
          child: Column(
            crossAxisAlignment:
                isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              _buildMessage(isSender),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessage(bool isSender) {
    if (isSender) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
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
                  color: kPrimaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20)),
              child: Text(
                widget.message.content,
                style: TextStyle(
                  fontSize: 14.5,
                ),
              ),
            ),
          ),
          _pressed ? _buildMessageTime() : SizedBox.shrink(),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          widget.displayPhoto
              ? CustomAvatar(
                  photoUrl: photoUrlFrom,
                  size: 14.0,
                )
              : SizedBox(width: 28.0),
          SizedBox(width: 0.5 * kDefaultPadding),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.displayName
                  ? Container(
                      margin: EdgeInsets.only(bottom: 5.0, left: 10.0),
                      child: Text(
                        widget.message.nameFrom,
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    )
                  : SizedBox.shrink(),
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
                      color: kTertiaryColor,
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    widget.message.content,
                    style: TextStyle(
                      fontSize: 14.5,
                    ),
                  ),
                ),
              ),
              _pressed ? _buildMessageTime() : SizedBox.shrink(),
            ],
          ),
        ],
      );
    }
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
