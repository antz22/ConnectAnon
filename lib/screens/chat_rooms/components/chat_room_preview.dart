import 'package:connect_anon/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ChatRoomPreview extends StatelessWidget {
  ChatRoomPreview({
    Key? key,
    required this.chatRoomId,
    required this.currentUserId,
    required this.roomName,
  }) : super(key: key);

  final String? chatRoomId;
  final String currentUserId;
  final String roomName;

  @override
  Widget build(BuildContext context) {
    if (chatRoomId != null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CircleAvatar(
          //   backgroundImage: AssetImage('assets/images/profile2.jpg'),
          //   radius: 28.0,
          // ),
          SvgPicture.asset('assets/svgs/chat_room_selected.svg', height: 46.0),
          SizedBox(width: 0.9 * kDefaultPadding),
          Container(
            height: 53.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$roomName',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'New Message',
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
            'minutes ago',
            style: TextStyle(
              fontSize: 15.0,
              color: Color(0xFF959595),
            ),
          ),
        ],
      );
    } else {
      return SizedBox.shrink();
    }
  }
}
