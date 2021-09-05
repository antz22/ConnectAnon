import 'package:connect_anon/constants/constants.dart';
import 'package:connect_anon/models/chat_room.dart';
import 'package:connect_anon/screens/chat/rooms/chat_room_screen.dart';
import 'package:connect_anon/screens/request_chat_room/request_chat_room.dart';
import 'package:connect_anon/screens/join_chat_room/join_chat_room.dart';
import 'package:connect_anon/widgets/info_header.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'components/chat_room_preview.dart';

class ChatRoomsScreen extends StatefulWidget {
  const ChatRoomsScreen({
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

  _scrollListener() {
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
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    super.dispose();
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
                          List<ChatRoom> chatRooms = snapshot.data!.docs
                              .map((doc) => ChatRoom.fromFirestore(doc))
                              .toList();

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: chatRooms.length,
                            itemBuilder: (BuildContext context, int index) {
                              ChatRoom chatRoom = chatRooms[index];
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatRoomScreen(
                                          currentUserId: widget.currentUserId,
                                          alias: widget.alias,
                                          photoUrl: widget.photoUrl,
                                          chatRoom: chatRoom,
                                        ),
                                      ));
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 0.4 * kDefaultPadding,
                                    horizontal: 0.9 * kDefaultPadding,
                                  ),
                                  child: ChatRoomPreview(
                                    currentUserId: widget.currentUserId,
                                    chatRoom: chatRoom,
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
                    const SizedBox(height: kDefaultPadding),
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
                        const SizedBox(width: kDefaultPadding),
                        ElevatedButton(
                          onPressed: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RequestChatRoomScreen(
                                  currentUserId: widget.currentUserId,
                                ),
                              ),
                            );
                          },
                          child: Text('Request chat room'),
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(kPrimaryColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: kDefaultPadding),
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
