import 'package:connect_anon/constants/constants.dart';
import 'package:connect_anon/models/chat_room.dart';
import 'package:connect_anon/screens/home/home_page.dart';
import 'package:connect_anon/services/firestore_services.dart';
import 'package:connect_anon/widgets/custom_avatar.dart';
import 'package:connect_anon/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class ChatRoomInfoScreen extends StatefulWidget {
  const ChatRoomInfoScreen({
    Key? key,
    required this.currentUserId,
    required this.chatRoom,
  }) : super(key: key);

  final String currentUserId;
  final ChatRoom chatRoom;

  @override
  _ChatRoomInfoScreenState createState() => _ChatRoomInfoScreenState();
}

class _ChatRoomInfoScreenState extends State<ChatRoomInfoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SvgPicture.asset(
              'assets/svgs/hashtag.svg',
              height: 17.0,
              color: Colors.white,
            ),
            SizedBox(width: 0.3 * kDefaultPadding),
            Text(' ${widget.chatRoom.name}'),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(kDefaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.chatRoom.description,
              style: TextStyle(
                fontSize: 17.0,
              ),
            ),
            SizedBox(height: 3 * kDefaultPadding),
            Text(
              'Members',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: kDefaultPadding),
            ListView.separated(
              shrinkWrap: true,
              itemCount: widget.chatRoom.memberNames.length,
              itemBuilder: (BuildContext context, int index) {
                return Row(
                  children: [
                    CustomAvatar(
                      photoUrl: widget.chatRoom.memberPhotoUrls[index],
                      size: 15.0,
                    ),
                    SizedBox(width: 0.7 * kDefaultPadding),
                    Text(
                      widget.chatRoom.memberNames[index],
                      style: TextStyle(
                        fontSize: 17.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                );
              },
              separatorBuilder: (context, index) {
                return Column(
                  children: [
                    SizedBox(height: kDefaultPadding),
                  ],
                );
              },
            ),
            SizedBox(height: 3 * kDefaultPadding),
            _buildActionButton(context),
          ],
        ),
      ),
    );
  }

  ElevatedButton _buildActionButton(BuildContext context) {
    if (widget.chatRoom.members.contains(widget.currentUserId)) {
      return ElevatedButton(
        onPressed: () async {
          await context
              .read<FirestoreServices>()
              .leaveChatRoom(widget.currentUserId, widget.chatRoom.id);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(
                message: 'Successfully left Chat Room',
                messageStatus: 'Success',
              ),
            ),
          );
        },
        child: Text(
          'Leave',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      );
    } else {
      return ElevatedButton(
        onPressed: () async {
          String response = await context
              .read<FirestoreServices>()
              .joinChatRoom(widget.currentUserId, widget.chatRoom.id);

          if (response == 'Success') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(
                  message: 'Successfully joined Chat Room',
                  messageStatus: 'Success',
                ),
              ),
            );
          } else {
            CustomSnackbar.buildWarningMessage(
                context, 'Error', 'Could not join Chat Room.');
          }
        },
        child: Text(
          'Join',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      );
    }
  }
}
