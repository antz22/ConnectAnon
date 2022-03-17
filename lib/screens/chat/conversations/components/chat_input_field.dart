import 'package:connect_anon/constants/constants.dart';
import 'package:connect_anon/services/firestore_services.dart';
import 'package:connect_anon/services/user_provider.dart';
import 'package:connect_anon/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class ChatInputField extends StatefulWidget {
  const ChatInputField({
    Key? key,
    required this.groupChatId,
    required this.peerId,
  }) : super(key: key);

  final String groupChatId;
  final String peerId;

  @override
  _ChatInputFieldState createState() =>
      _ChatInputFieldState(groupChatId: groupChatId);
}

class _ChatInputFieldState extends State<ChatInputField> {
  final String groupChatId;

  _ChatInputFieldState({required this.groupChatId});

  final TextEditingController _textEditingController = TextEditingController();

  bool _isEmpty = true;

  void onSendMessage(String content) async {
    String? id = context.read<UserProvider>().id;

    if (content.trim() != '') {
      _textEditingController.clear();

      String response = await context
          .read<FirestoreServices>()
          .sendPeerMessage(content, id, widget.peerId, groupChatId);

      if (response == 'Success') {
        setState(() {
          _isEmpty = true;
        });
      } else {
        CustomSnackbar.buildWarningMessage(
            context, 'Error', 'The message failed to send');
      }
    }
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: 0.8 * kDefaultPadding,
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
                margin: const EdgeInsets.symmetric(
                  vertical: 0.5 * kDefaultPadding,
                ),
                padding: const EdgeInsets.symmetric(
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
                      fontSize: 14.0,
                    ),
                    border: InputBorder.none,
                  ),
                  textCapitalization: TextCapitalization.sentences,
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
            Container(
              width: 50.0,
              height: 50.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
              margin: const EdgeInsets.only(right: 0.2 * kDefaultPadding),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    onSendMessage(_textEditingController.text);
                  },
                  customBorder: CircleBorder(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: _isEmpty
                        ? SvgPicture.asset('assets/svgs/send_unvalid.svg')
                        : SvgPicture.asset('assets/svgs/send_valid.svg'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
