import 'package:connect_anon/constants/constants.dart';
import 'package:connect_anon/models/message.dart';
import 'package:connect_anon/screens/chat/conversations/components/chat_input_field.dart';
import 'package:connect_anon/screens/chat/conversations/components/chat_message.dart';
import 'package:connect_anon/screens/profile/profile_screen.dart';
import 'package:connect_anon/widgets/custom_avatar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen({
    Key? key,
    required this.groupChatId,
    required this.currentUserId,
    required this.peerId,
    required this.peerName,
    required this.peerPhotoUrl,
  }) : super(key: key);

  final String groupChatId;
  final String currentUserId;
  final String peerId;
  final String peerName;
  final String peerPhotoUrl;

  @override
  _ChatScreenState createState() => _ChatScreenState(
        groupChatId: groupChatId,
        currentUserId: currentUserId,
        peerId: peerId,
        peerName: peerName,
        peerPhotoUrl: peerPhotoUrl,
      );
}

class _ChatScreenState extends State<ChatScreen> {
  final String groupChatId;
  final String currentUserId;
  final String peerId;
  final String peerName;
  final String peerPhotoUrl;

  _ChatScreenState({
    required this.groupChatId,
    required this.currentUserId,
    required this.peerId,
    required this.peerName,
    required this.peerPhotoUrl,
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
            CustomAvatar(photoUrl: peerPhotoUrl, size: 17.0),
            SizedBox(width: 0.75 * kDefaultPadding),
            Text(
              peerName,
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
                  builder: (context) => ProfileScreen(
                      isMe: false, id: peerId, groupChatId: groupChatId),
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
                child: groupChatId.isNotEmpty
                    ? StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('Messages')
                            .doc(groupChatId.trim())
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
                                  'New Conversation: Say hello to $peerName!',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.5,
                                  ),
                                ),
                              );
                            } else {
                              List<Message> messages = snapshot.data!.docs
                                  .map((doc) => Message.fromFirestore(doc))
                                  .toList();

                              return ListView.builder(
                                padding:
                                    EdgeInsets.only(top: 15.0, bottom: 5.0),
                                reverse: true,
                                controller: _scrollController,
                                itemCount: snapshot.data?.docs.length,
                                itemBuilder: (context, index) {
                                  bool displayPhoto = false;
                                  // order is reversed
                                  if (index != 0) {
                                    if (messages[index - 1].idFrom != peerId) {
                                      displayPhoto = true;
                                    }
                                  } else {
                                    if (messages[index].idFrom == peerId) {
                                      displayPhoto = true;
                                    }
                                  }
                                  return Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: kDefaultPadding),
                                    child: ChatScreenMessage(
                                      userId: currentUserId,
                                      message: messages[index],
                                      photoUrl: peerPhotoUrl,
                                      displayPhoto: displayPhoto,
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
              ChatInputField(groupChatId: groupChatId, peerId: peerId),
            ],
          ),
        ),
      ),
    );
  }
}
