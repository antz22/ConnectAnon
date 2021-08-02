import 'package:anonymous_chat/constants/constants.dart';
import 'package:anonymous_chat/models/chat_message.dart';
import 'package:anonymous_chat/screens/chat/rooms/components/chat_room_input_field.dart';
import 'package:anonymous_chat/screens/chat/rooms/components/chat_room_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatRoomScreen extends StatefulWidget {
  ChatRoomScreen({
    Key? key,
    required this.chatRoomId,
    required this.currentUserId,
    required this.roomName,
  }) : super(key: key);

  final String chatRoomId;
  final String currentUserId;
  final String roomName;

  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState(
        chatRoomId: chatRoomId,
        currentUserId: currentUserId,
        roomName: roomName,
      );
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final String chatRoomId;
  final String currentUserId;
  final String roomName;

  _ChatRoomScreenState({
    required this.chatRoomId,
    required this.currentUserId,
    required this.roomName,
  });

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
            CircleAvatar(
              backgroundImage: AssetImage('assets/images/profile3.jpg'),
              radius: 17.0,
            ),
            SizedBox(width: 0.75 * kDefaultPadding),
            Text(
              roomName,
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
            onPressed: () {},
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
                child: chatRoomId.isNotEmpty
                    ? StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('ChatRoomMessages')
                            .doc(chatRoomId.trim())
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
                                itemBuilder: (context, index) => Padding(
                                  // if this element is the first text
                                  padding: index == demoChatMessages.length - 1
                                      ? EdgeInsets.only(
                                          top: 0.3 * kDefaultPadding,
                                          left: kDefaultPadding,
                                          right: kDefaultPadding)
                                      : EdgeInsets.symmetric(
                                          horizontal: kDefaultPadding),
                                  child: ChatRoomMessage(
                                      userId: currentUserId,
                                      document: snapshot.data?.docs[index]),
                                ),
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
              ChatRoomInputField(chatRoomId: chatRoomId),
            ],
          ),
        ),
      ),
    );
  }
}
