import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect_anon/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:timeago/timeago.dart' as timeago;

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
      return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('ChatRooms')
            .doc(chatRoomId?.trim())
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasData) {
            Map<String, dynamic> data =
                snapshot.data!.data() as Map<String, dynamic>;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset('assets/svgs/chat_room.svg',
                    height: 46.0, color: kPrimaryColor),
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
                        data['lastMessage'],
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
                  _buildLastTimestamp(data['lastTimestamp']),
                  style: TextStyle(
                    fontSize: 15.0,
                    color: Color(0xFF959595),
                  ),
                ),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      );
    } else {
      return SizedBox.shrink();
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
