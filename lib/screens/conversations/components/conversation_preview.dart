import 'package:connect_anon/constants/constants.dart';
import 'package:connect_anon/widgets/custom_avatar.dart';
import 'package:flutter/material.dart';

class ConversationPreview extends StatelessWidget {
  ConversationPreview({
    Key? key,
    required this.groupChatId,
    required this.currentUserId,
    required this.peerId,
    required this.peerName,
    required this.peerPhotoUrl,
  }) : super(key: key);

  final String? groupChatId;
  final String currentUserId;
  final String peerId;
  final String peerName;
  final String peerPhotoUrl;

  @override
  Widget build(BuildContext context) {
    if (groupChatId != null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomAvatar(photoUrl: peerPhotoUrl, size: 28.0),
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
