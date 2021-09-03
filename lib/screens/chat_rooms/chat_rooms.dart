import 'package:connect_anon/constants/constants.dart';
import 'package:connect_anon/screens/chat/rooms/chat_room_screen.dart';
import 'package:connect_anon/screens/create_chat_room/create_chat_room.dart';
import 'package:connect_anon/screens/join_chat_room/join_chat_room.dart';
import 'package:connect_anon/widgets/info_header.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'components/chat_room_preview.dart';

class ChatRoomsScreen extends StatefulWidget {
  ChatRoomsScreen({
    Key? key,
    required this.currentUserId,
    required this.photoUrl,
    required this.alias,
  }) : super(key: key);

  final String currentUserId;
  final String photoUrl;
  final String alias;

  @override
  _ChatRoomsScreenState createState() => _ChatRoomsScreenState();
}

class _ChatRoomsScreenState extends State<ChatRoomsScreen> {
  int _limit = 10;
  int _limitIncrement = 10;
  bool atTop = true;

  final ScrollController _scrollController = ScrollController();

  scrollListener() {
    if (_scrollController.position.pixels == 0) {
      setState(() {
        atTop = true;
      });
    } else {
      setState(() {
        atTop = false;
      });
    }
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  @override
  void initState() {
    _scrollController.addListener(scrollListener);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            child: InfoHeader(
              title: 'Chat Rooms',
              photoUrl: widget.photoUrl,
              id: widget.currentUserId,
              atTop: atTop,
            ),
          ),
          Expanded(
            child: Container(
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('ChatRooms')
                          .where('members', arrayContains: widget.currentUserId)
                          .orderBy('lastTimestamp', descending: true)
                          .limit(_limit)
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasData) {
                          var chatRooms = snapshot.data!.docs;

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: chatRooms.length,
                            itemBuilder: (BuildContext context, int index) {
                              String chatRoomId = chatRooms[index].id;
                              Map<String, dynamic> chatRoom = chatRooms[index]
                                  .data() as Map<String, dynamic>;
                              String roomName = chatRoom['name'];
                              String description = chatRoom['description'];
                              String lastMessage = chatRoom['lastMessage'];
                              String lastTimestamp = chatRoom['lastTimestamp'];
                              List<dynamic> members = chatRoom['members'];
                              List<dynamic> memberNames =
                                  chatRoom['memberNames'];
                              List<dynamic> memberPhotoUrls =
                                  chatRoom['memberPhotoUrls'];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatRoomScreen(
                                        chatRoomId: chatRoomId,
                                        currentUserId: widget.currentUserId,
                                        roomName: roomName,
                                        alias: widget.alias,
                                        photoUrl: widget.photoUrl,
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
                                    currentUserId: widget.currentUserId,
                                    roomName: roomName,
                                    lastMessage: lastMessage,
                                    lastTimestamp: lastTimestamp,
                                  ),
                                ),
                              );
                            },
                          );
                        } else {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
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
                                  currentUserId: widget.currentUserId,
                                ),
                              ),
                            );
                          },
                          child: Text('Join chat room'),
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(kPrimaryColor),
                          ),
                        ),
                        SizedBox(width: kDefaultPadding),
                        ElevatedButton(
                          onPressed: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CreateChatRoomScreen(
                                  currentUserId: widget.currentUserId,
                                ),
                              ),
                            );
                          },
                          child: Text('Create chat room'),
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(kPrimaryColor),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: kDefaultPadding),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
