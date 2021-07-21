import 'package:anonymous_chat/constants/constants.dart';
import 'package:anonymous_chat/models/chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConversationPreview extends StatelessWidget {
  ConversationPreview({Key? key, required this.groupChatId}) : super(key: key);

  final String groupChatId;

  String currentUserId = '';
  String peerId = '';
  String peerName = '';

  Future<void> getMemberIDs(id) async {
    var document =
        await FirebaseFirestore.instance.collection('Groups').doc(id).get();
    Map<String, dynamic>? data = document.data();
    var memberIDs = data?['members'];
  }

  @override
  Widget build(BuildContext context) {
    currentUserId = context.watch<User>().uid;
    if (groupChatId != null) {
      getMemberIDs(groupChatId);
      Chat chat = Chat.fromDocument(doc);
      if (chat.id == currentUserId) {
        return SizedBox.shrink();
      } else {
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
                    'Funny Fox',
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
      }
    } else {
      return SizedBox.shrink();
    }
  }
}
