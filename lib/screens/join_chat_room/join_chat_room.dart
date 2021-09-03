import 'package:connect_anon/constants/constants.dart';
import 'package:connect_anon/screens/chat_room_info/chat_room_info_screen.dart';
import 'package:connect_anon/widgets/chat_rooms_header.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class JoinChatRoomScreen extends StatefulWidget {
  const JoinChatRoomScreen({Key? key, required this.currentUserId})
      : super(key: key);

  final String currentUserId;

  @override
  _JoinChatRoomScreenState createState() => _JoinChatRoomScreenState();
}

class _JoinChatRoomScreenState extends State<JoinChatRoomScreen> {
  int _limit = 10;
  int _limitIncrement = 10;

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

  @override
  void initState() {
    _scrollController.addListener(scrollListener);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            ChatRoomsHeader(title: 'Join Chat Room'),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('ChatRooms')
                  .limit(_limit)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  var docs = snapshot.data!.docs;
                  if (docs.length == 0) {
                    return Container(
                      margin: EdgeInsets.only(
                        top: kDefaultPadding,
                        left: 1.3 * kDefaultPadding,
                        right: 1.3 * kDefaultPadding,
                      ),
                      child: Text(
                        'No more chat rooms.',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  } else {
                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: docs.length,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        Map<String, dynamic> chatRoom =
                            docs[index].data() as Map<String, dynamic>;
                        String chatRoomId = docs[index].id;
                        return Container(
                          margin: EdgeInsets.only(
                            top: 0.5 * kDefaultPadding,
                            left: 1.3 * kDefaultPadding,
                            right: 1.3 * kDefaultPadding,
                            bottom: index == docs.length - 1
                                ? 1.3 * kDefaultPadding
                                : 0.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '# ' + chatRoom['name'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                ),
                              ),
                              SizedBox(width: kDefaultPadding),
                              IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatRoomInfoScreen(
                                        roomId: chatRoomId,
                                        roomName: chatRoom['name'],
                                        description: chatRoom['description'],
                                        members: chatRoom['members'],
                                        memberNames: chatRoom['memberNames'],
                                        memberPhotoUrls:
                                            chatRoom['memberPhotoUrls'],
                                        currentUserId: widget.currentUserId,
                                      ),
                                    ),
                                  );
                                },
                                icon: Icon(Icons.arrow_forward),
                              ),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return Column(
                          children: [
                            SizedBox(height: 0.3 * kDefaultPadding),
                            Divider(),
                            SizedBox(height: 0.3 * kDefaultPadding),
                          ],
                        );
                      },
                    );
                  }
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
