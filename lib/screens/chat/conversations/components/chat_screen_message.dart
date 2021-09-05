import 'package:connect_anon/constants/constants.dart';
import 'package:connect_anon/models/message.dart';
import 'package:connect_anon/widgets/custom_avatar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatScreenMessage extends StatefulWidget {
  const ChatScreenMessage({
    Key? key,
    required this.userId,
    required this.message,
    required this.photoUrl,
    required this.displayPhoto,
  }) : super(key: key);

  final String userId;
  final Message message;
  final String photoUrl;
  final bool displayPhoto;

  @override
  _ChatScreenMessageState createState() => _ChatScreenMessageState();
}

class _ChatScreenMessageState extends State<ChatScreenMessage>
    with TickerProviderStateMixin {
  double _height = 0.0;

  final double _maxWidth = 280.0;

  bool isSender = false;
  bool _pressed = false;

  Future<bool> _checkIsSender() async {
    isSender = widget.message.idFrom == widget.userId ? true : false;
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
      future: _checkIsSender(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 0.3 * kDefaultPadding),
          child: Row(
            mainAxisAlignment:
                isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              isSender
                  ? const SizedBox.shrink()
                  : widget.displayPhoto
                      ? Column(
                          children: [
                            Container(
                              margin: EdgeInsets.only(
                                right: 0.5 * kDefaultPadding,
                              ),
                              child: CustomAvatar(
                                photoUrl: widget.photoUrl,
                                size: 13.0,
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              curve: Curves.fastOutSlowIn,
                              height: _height,
                              child: SizedBox(),
                            ),
                          ],
                        )
                      : const SizedBox(width: 26.0 + 0.5 * kDefaultPadding),
              Column(
                crossAxisAlignment: isSender
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_pressed == true) {
                          _pressed = false;
                          _height = 0.0;
                        } else {
                          _pressed = true;
                          _height = 20.0;
                        }
                      });
                    },
                    child: Container(
                      constraints: BoxConstraints(maxWidth: _maxWidth),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 0.75 * kDefaultPadding,
                        vertical: 0.5 * kDefaultPadding,
                      ),
                      decoration: BoxDecoration(
                          color: isSender
                              ? kPrimaryColor.withOpacity(0.2)
                              : kTertiaryColor,
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        widget.message.content,
                        style: TextStyle(
                          fontSize: 14.5,
                        ),
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.fastOutSlowIn,
                    height: _height,
                    child: _buildMessageTime(),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageTime() {
    return Container(
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
    );
  }
}
