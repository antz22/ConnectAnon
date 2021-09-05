import 'package:connect_anon/constants/constants.dart';
import 'package:connect_anon/widgets/custom_avatar.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class ConversationPreview extends StatelessWidget {
  const ConversationPreview({
    Key? key,
    required this.groupChatId,
    required this.currentUserId,
    required this.peerId,
    required this.peerName,
    required this.peerPhotoUrl,
    required this.lastMessage,
    required this.lastTimestamp,
  }) : super(key: key);

  final String? groupChatId;
  final String currentUserId;
  final String peerId;
  final String peerName;
  final String peerPhotoUrl;
  final String lastMessage;
  final String lastTimestamp;

  @override
  Widget build(BuildContext context) {
    if (groupChatId != null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomAvatar(photoUrl: peerPhotoUrl, size: 28.0),
          const SizedBox(width: 0.9 * kDefaultPadding),
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
                  lastMessage,
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
            _buildLastTimestamp(lastTimestamp),
            style: TextStyle(
              fontSize: 15.0,
              color: Color(0xFF959595),
            ),
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
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
