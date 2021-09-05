import 'package:connect_anon/constants/constants.dart';
import 'package:connect_anon/models/chat_room.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatRoomPreview extends StatelessWidget {
  const ChatRoomPreview({
    Key? key,
    required this.currentUserId,
    required this.chatRoom,
  }) : super(key: key);

  final String currentUserId;
  final ChatRoom chatRoom;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset('assets/svgs/chat_room.svg',
            height: 46.0, color: kPrimaryColor),
        const SizedBox(width: 0.9 * kDefaultPadding),
        Container(
          height: 53.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                chatRoom.name,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                chatRoom.lastMessage,
                style: TextStyle(
                  color: Color(0xFF535353),
                  fontSize: 15.0,
                ),
              ),
            ],
          ),
        ),
        Spacer(),
        Text(
          _buildLastTimestamp(chatRoom.lastTimestamp),
          style: TextStyle(
            fontSize: 15.0,
            color: Color(0xFF959595),
          ),
        ),
      ],
    );
  }

  String _buildLastTimestamp(String lastTimestamp) {
    DateTime lastDateTime =
        DateTime.fromMillisecondsSinceEpoch(int.parse(lastTimestamp));
    DateTime currentDateTime = DateTime.now();
    var difference = currentDateTime.difference(lastDateTime).inMilliseconds;
    final timeAgo = DateTime.now().subtract(Duration(milliseconds: difference));
    return timeago.format(timeAgo, locale: 'en_short');
  }
}
