import 'package:connect_anon/constants/constants.dart';
import 'package:connect_anon/screens/home/home_page.dart';
import 'package:connect_anon/services/api_services.dart';
import 'package:connect_anon/widgets/custom_avatar.dart';
import 'package:connect_anon/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class ChatRoomInfoScreen extends StatefulWidget {
  const ChatRoomInfoScreen({
    Key? key,
    required this.roomId,
    required this.roomName,
    required this.description,
    required this.members,
    required this.memberNames,
    required this.memberPhotoUrls,
    required this.currentUserId,
  }) : super(key: key);

  final String roomId;
  final String roomName;
  final String description;
  final List<dynamic> members;
  final List<dynamic> memberNames;
  final List<dynamic> memberPhotoUrls;
  final String currentUserId;

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
            Text(' ${widget.roomName}'),
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
              widget.description,
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
              itemCount: widget.memberNames.length,
              itemBuilder: (BuildContext context, int index) {
                return Row(
                  children: [
                    CustomAvatar(
                      photoUrl: widget.memberPhotoUrls[index],
                      size: 15.0,
                    ),
                    SizedBox(width: 0.7 * kDefaultPadding),
                    Text(
                      widget.memberNames[index],
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
    if (widget.members.contains(widget.currentUserId)) {
      return ElevatedButton(
        onPressed: () async {
          await context
              .read<APIServices>()
              .leaveChatRoom(widget.currentUserId, widget.roomId);

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
              .read<APIServices>()
              .joinChatRoom(widget.currentUserId, widget.roomId);

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
