import 'package:anonymous_chat/constants/constants.dart';
import 'package:anonymous_chat/models/chat.dart';
import 'package:anonymous_chat/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConversationPreview extends StatelessWidget {
  ConversationPreview({
    Key? key,
    required this.groupChatId,
    required this.currentUserId,
    required this.peerId,
    required this.peerName,
  }) : super(key: key);

  final String groupChatId;
  final String currentUserId;
  final String peerId;
  final String peerName;

  @override
  Widget build(BuildContext context) {
    if (groupChatId != null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: AssetImage('assets/images/profile2.jpg'),
            radius: 28.0,
          ),
          SizedBox(width: 0.9 * kDefaultPadding),
          Container(
            height: 53.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  peerName,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'That sounds awesome!',
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
            '3m ago',
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
