import 'package:connect_anon/constants/constants.dart';
import 'package:connect_anon/models/chat_room.dart';
import 'package:connect_anon/models/chat_room_message.dart';
import 'package:connect_anon/screens/chat/rooms/components/chat_room_input_field.dart';
import 'package:connect_anon/screens/chat/rooms/components/room_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect_anon/screens/chat_room_info/chat_room_info_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChatRoomScreen extends StatefulWidget {
  ChatRoomScreen({
    Key? key,
    required this.currentUserId,
    required this.alias,
    required this.photoUrl,
    required this.chatRoom,
  }) : super(key: key);

  final String currentUserId;
  final ChatRoom chatRoom;
  final String alias;
  final String photoUrl;

  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final List<QueryDocumentSnapshot> listMessage = new List.from([]);

  final int _limitIncrement = 20;
  int _limit = 20;

  final ScrollController _scrollController = ScrollController();

  _scrollListener() {
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
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 3,
        title: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back),
              color: kPrimaryColor,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            SizedBox(width: 0.75 * kDefaultPadding),
            SvgPicture.asset(
              'assets/svgs/hashtag.svg',
              height: 17.0,
            ),
            SizedBox(width: 0.75 * kDefaultPadding),
            Text(
              widget.chatRoom.name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18.0,
                color: Colors.black,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info, color: kPrimaryColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatRoomInfoScreen(
                    currentUserId: widget.currentUserId,
                    chatRoom: widget.chatRoom,
                  ),
                ),
              );
            },
          ),
          SizedBox(width: 0.9 * kDefaultPadding),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          child: Column(
            children: [
              Expanded(
                child: widget.chatRoom.id.isNotEmpty
                    ? StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('ChatRoomMessages')
                            .doc(widget.chatRoom.id.trim())
                            .collection('messages')
                            .orderBy('timestamp', descending: true)
                            .limit(_limit)
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data!.docs.isEmpty) {
                              return Center(
                                child: Text(
                                  'New Chat Room: Say hello to everyone!',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            } else {
                              List<ChatRoomMessage> messages = snapshot
                                  .data!.docs
                                  .map((doc) =>
                                      ChatRoomMessage.fromFirestore(doc))
                                  .toList();

                              return ListView.builder(
                                padding:
                                    EdgeInsets.only(top: 15.0, bottom: 5.0),
                                controller: _scrollController,
                                reverse: true,
                                itemCount: messages.length,
                                itemBuilder: (context, index) {
                                  bool displayPhoto = false;
                                  bool displayName = false;
                                  // order is reversed
                                  // displayPhoto
                                  if (index != 0) {
                                    if (messages[index - 1].idFrom !=
                                        messages[index].idFrom) {
                                      displayPhoto = true;
                                    }
                                  } else {
                                    if (messages[index].idFrom !=
                                        widget.currentUserId) {
                                      displayPhoto = true;
                                    }
                                  }
                                  // displayName
                                  if (index != messages.length - 1) {
                                    if (messages[index + 1].idFrom !=
                                        messages[index].idFrom) {
                                      displayName = true;
                                    }
                                  } else {
                                    if (messages[index].idFrom !=
                                        widget.currentUserId) {
                                      displayName = true;
                                    }
                                  }
                                  return Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: kDefaultPadding),
                                    child: ChatRoomScreenMessage(
                                      userId: widget.currentUserId,
                                      message: messages[index],
                                      displayPhoto: displayPhoto,
                                      displayName: displayName,
                                    ),
                                  );
                                },
                              );
                            }
                          } else {
                            return Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    kPrimaryColor),
                              ),
                            );
                          }
                        },
                      )
                    : Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(kPrimaryColor),
                        ),
                      ),
              ),
              ChatRoomInputField(
                chatRoomId: widget.chatRoom.id,
                alias: widget.alias,
                photoUrl: widget.photoUrl,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
