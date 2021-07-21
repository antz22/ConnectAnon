import 'package:anonymous_chat/constants/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ChatInputField extends StatefulWidget {
  ChatInputField({Key? key}) : super(key: key);

  @override
  _ChatInputFieldState createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final TextEditingController _textEditingController = TextEditingController();

  void onSendMessage(String content) {
    if (content.trim() != '') {
      _textEditingController.clear();

      var documentReference = FirebaseFirestore.instance
          .collection('Messages')
          .doc(groupChatId)
          .collection('messages')
          .doc(DateTime.now().millisecondsSinceEpoch.toString());

      FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(
          documentReference,
          {
            'idFrom': id,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content,
          }
        )
      }) 

      setState(() {
        _isEmpty = true;
      });
    }
  }

  bool _isEmpty = true;

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
                  onSubmitted: (value) {
                    onSendMessage(_textEditingController.text);
                  },
                ),
              ),
            ),
            SizedBox(width: kDefaultPadding),
            GestureDetector(
              onTap: () {
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
