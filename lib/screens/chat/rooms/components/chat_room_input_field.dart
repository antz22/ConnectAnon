import 'package:anonymous_chat/constants/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatRoomInputField extends StatefulWidget {
  ChatRoomInputField({Key? key, required this.chatRoomId}) : super(key: key);

  final String chatRoomId;

  @override
  _ChatRoomInputFieldState createState() =>
      _ChatRoomInputFieldState(chatRoomId: chatRoomId);
}

class _ChatRoomInputFieldState extends State<ChatRoomInputField> {
  final String chatRoomId;

  _ChatRoomInputFieldState({required this.chatRoomId});

  final TextEditingController _textEditingController = TextEditingController();

  bool _isEmpty = true;

  void onSendMessage(String content) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = await prefs.getString('id');
    print(chatRoomId);

    // final user = Provider.of<User?>(context, listen: false);

    if (content.trim() != '') {
      _textEditingController.clear();

      var documentReference = FirebaseFirestore.instance
          .collection('ChatRoomMessages')
          .doc(chatRoomId.trim())
          .collection('messages');

      documentReference.add({
        'idFrom': id,
        // FIX HERE
        'nameFrom': 'hi',
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        'content': content,
      });

      setState(() {
        _isEmpty = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: kDefaultPadding,
        vertical: 0.5 * kDefaultPadding,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 4),
            blurRadius: 32,
            color: Color(0xFF087949).withOpacity(0.08),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 0.8 * kDefaultPadding,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Color(0xFFF7F7F7),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Type here...',
                    hintStyle: TextStyle(
                      color: Color(0xFF9A9A9A),
                      fontSize: 12.0,
                    ),
                    border: InputBorder.none,
                  ),
                  minLines: 1,
                  maxLines: 5,
                  controller: _textEditingController,
                  onChanged: (text) {
                    if (_textEditingController.text.isNotEmpty) {
                      setState(() {
                        _isEmpty = false;
                      });
                    } else {
                      setState(() {
                        _isEmpty = true;
                      });
                    }
                  },
                  onSubmitted: (value) async {
                    onSendMessage(_textEditingController.text);
                  },
                ),
              ),
            ),
            SizedBox(width: kDefaultPadding),
            GestureDetector(
              onTap: () async {
                onSendMessage(_textEditingController.text);
              },
              child: _isEmpty
                  ? SvgPicture.asset(
                      'assets/svgs/send_unvalid.svg',
                      height: 23.0,
                    )
                  : SvgPicture.asset(
                      'assets/svgs/send_valid.svg',
                      height: 23.0,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
