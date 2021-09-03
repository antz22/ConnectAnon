import 'package:connect_anon/constants/constants.dart';
import 'package:connect_anon/screens/chat/rooms/components/chat_room_input_field.dart';
import 'package:connect_anon/screens/chat/rooms/components/chat_room_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect_anon/screens/chat_room_info/chat_room_info_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChatRoomScreen extends StatefulWidget {
  ChatRoomScreen({
    Key? key,
    required this.chatRoomId,
    required this.currentUserId,
    required this.roomName,
    required this.alias,
    required this.photoUrl,
    required this.members,
    required this.memberNames,
    required this.memberPhotoUrls,
    required this.description,
  }) : super(key: key);

  final String chatRoomId;
  final String currentUserId;
  final String roomName;
  final String alias;
  final String photoUrl;
  final List<dynamic> members;
  final List<dynamic> memberNames;
  final List<dynamic> memberPhotoUrls;
  final String description;

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
            // CircleAvatar(
            //   backgroundImage: AssetImage('assets/images/profile3.jpg'),
            //   radius: 17.0,
            // ),
            SvgPicture.asset(
              'assets/svgs/hashtag.svg',
              height: 17.0,
            ),
            SizedBox(width: 0.75 * kDefaultPadding),
            Text(
              widget.roomName,
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
                    roomId: widget.chatRoomId,
                    roomName: widget.roomName,
                    members: widget.members,
                    memberNames: widget.memberNames,
                    memberPhotoUrls: widget.memberPhotoUrls,
                    description: widget.description,
                    currentUserId: widget.currentUserId,
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
                child: widget.chatRoomId.isNotEmpty
                    ? StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('ChatRoomMessages')
                            .doc(widget.chatRoomId.trim())
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
                              listMessage.addAll(snapshot.data!.docs);
                              return ListView.builder(
                                padding: EdgeInsets.only(bottom: 5.0),
                                reverse: true,
                                itemCount: snapshot.data?.docs.length,
                                itemBuilder: (context, index) {
                                  bool displayPhoto = false;
                                  bool displayName = false;
                                  // order is reversed
                                  // displayPhoto
                                  if (index != 0) {
                                    if (snapshot.data?.docs[index - 1]
                                            ['idFrom'] !=
                                        snapshot.data?.docs[index]['idFrom']) {
                                      displayPhoto = true;
                                    }
                                  } else {
                                    if (snapshot.data?.docs[index]['idFrom'] !=
                                        widget.currentUserId) {
                                      displayPhoto = true;
                                    }
                                  }
                                  // displayName
                                  if (index != snapshot.data!.docs.length - 1) {
                                    if (snapshot.data?.docs[index + 1]
                                            ['idFrom'] !=
                                        snapshot.data?.docs[index]['idFrom']) {
                                      displayName = true;
                                    }
                                  } else {
                                    if (snapshot.data?.docs[index]['idFrom'] !=
                                        widget.currentUserId) {
                                      displayName = true;
                                    }
                                  }
                                  return Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: kDefaultPadding),
                                    child: ChatRoomMessage(
                                      userId: widget.currentUserId,
                                      document: snapshot.data?.docs[index],
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
                chatRoomId: widget.chatRoomId,
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
