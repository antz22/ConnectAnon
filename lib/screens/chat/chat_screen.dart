import 'package:anonymous_chat/constants/constants.dart';
import 'package:anonymous_chat/models/chat_message.dart';
import 'package:anonymous_chat/screens/chat/components/chat_input_field.dart';
import 'package:anonymous_chat/screens/chat/components/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen({Key? key, required this.groupChatId}) : super(key: key);

  final String groupChatId;

  @override
  _ChatScreenState createState() => _ChatScreenState(groupChatId: groupChatId);
}

class _ChatScreenState extends State<ChatScreen> {
  final String groupChatId;

  _ChatScreenState({required this.groupChatId});

  final List<QueryDocumentSnapshot> listMessage = new List.from([]);

  final String peerId = '';
  // final String groupChatId = '';
  String id = '';

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

  readLocal() async {
    String id = context.watch<User>().uid;
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    readLocal();
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
              'Mystic Tiger',
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
                child: true
                    ? StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('Messages')
                            .doc(groupChatId)
                            .collection('messages')
                            .orderBy('timestamp', descending: true)
                            .limit(_limit)
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasData) {
                            listMessage.addAll(snapshot.data!.docs);
                            return ListView.builder(
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
                                child: Message(
                                    document: snapshot.data?.docs[index]),
                              ),
                            );
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
              ChatInputField(),
            ],
          ),
        ),
      ),
    );
  }
}
