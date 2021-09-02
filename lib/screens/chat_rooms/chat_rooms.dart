import 'package:connect_anon/constants/constants.dart';
import 'package:connect_anon/screens/chat/rooms/chat_room_screen.dart';
import 'package:connect_anon/screens/create_chat_room/create_chat_room.dart';
import 'package:connect_anon/screens/join_chat_room/join_chat_room.dart';
import 'package:connect_anon/services/api_services.dart';
import 'package:connect_anon/widgets/info_header.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'components/chat_room_preview.dart';

class ChatRoomsScreen extends StatefulWidget {
  ChatRoomsScreen({Key? key, required this.currentUserId}) : super(key: key);

  final String currentUserId;

  @override
  _ChatRoomsScreenState createState() =>
      _ChatRoomsScreenState(currentUserId: currentUserId);
}

class _ChatRoomsScreenState extends State<ChatRoomsScreen> {
  _ChatRoomsScreenState({required this.currentUserId});

  final String currentUserId;

  int _limit = 10;
  int _limitIncrement = 10;
  bool _isLoading = false;

  final ScrollController _scrollController = ScrollController();

  scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  Future<Map<String, dynamic>> _retrieveChatRoomData(group) async {
    Map<String, dynamic> chatRoomData =
        await context.read<APIServices>().getChatRoomData(group);
    return chatRoomData;
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUserId)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasData) {
            Map<String, dynamic> data =
                snapshot.data!.data() as Map<String, dynamic>;
            List chatRooms = data['chatRooms'];
            String photoUrl = data['photoUrl'];
            String alias = data['alias'];
            return Column(
              children: [
                Container(
                  margin: EdgeInsets.only(
                    left: 0.9 * kDefaultPadding,
                    right: 0.9 * kDefaultPadding,
                    top: 0.7 * kDefaultPadding,
                    bottom: 0.7 * kDefaultPadding,
                  ),
                  child: InfoHeader(
                      title: 'Chat Rooms',
                      photoUrl: photoUrl,
                      id: currentUserId),
                ),
                Container(
                  child: Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: chatRooms.length,
                        itemBuilder: (BuildContext context, int index) {
                          // should probably make this a streambuilder
                          return FutureBuilder(
                            future: _retrieveChatRoomData(chatRooms[index]),
                            builder: (BuildContext context,
                                AsyncSnapshot<Map<String, dynamic>> snapshot) {
                              if (snapshot.hasData) {
                                String chatRoomId = chatRooms[index];
                                String currentUserId =
                                    snapshot.data!['currentUserId']!;
                                String roomName = snapshot.data!['roomName']!;
                                String description =
                                    snapshot.data!['description']!;
                                List<dynamic> members =
                                    snapshot.data!['members']!;
                                List<dynamic> memberNames =
                                    snapshot.data!['memberNames']!;
                                List<dynamic> memberPhotoUrls =
                                    snapshot.data!['memberPhotoUrls'];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatRoomScreen(
                                          chatRoomId: chatRoomId,
                                          currentUserId: currentUserId,
                                          roomName: roomName,
                                          alias: alias,
                                          photoUrl: photoUrl,
                                          members: members,
                                          memberNames: memberNames,
                                          memberPhotoUrls: memberPhotoUrls,
                                          description: description,
                                        ),
                                      ),
                                    );
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                    margin: EdgeInsets.only(
                                      bottom: 0.8 * kDefaultPadding,
                                      left: 0.9 * kDefaultPadding,
                                      right: 0.9 * kDefaultPadding,
                                    ),
                                    child: ChatRoomPreview(
                                      chatRoomId: chatRoomId,
                                      currentUserId: currentUserId,
                                      roomName: roomName,
                                    ),
                                  ),
                                );
                              } else {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                            },
                          );
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => JoinChatRoomScreen(
                                    currentUserId: currentUserId,
                                  ),
                                ),
                              );
                            },
                            child: Text('Join chat room'),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  kPrimaryColor),
                            ),
                          ),
                          SizedBox(width: kDefaultPadding),
                          ElevatedButton(
                            onPressed: () async {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CreateChatRoomScreen(
                                    currentUserId: currentUserId,
                                  ),
                                ),
                              );
                            },
                            child: Text('Create chat room'),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  kPrimaryColor),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
              ),
            );
          }
        },
      ),
    );
  }
}
