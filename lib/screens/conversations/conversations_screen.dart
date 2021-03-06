import 'dart:io';

import 'package:connect_anon/constants/constants.dart';
import 'package:connect_anon/models/conversation.dart';
import 'package:connect_anon/screens/chat/conversations/chat_screen.dart';
import 'package:connect_anon/screens/conversations/components/conversation_preview.dart';
import 'package:connect_anon/widgets/custom_popup_dialog.dart';
import 'package:connect_anon/widgets/info_header.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({
    Key? key,
    required this.currentUserId,
    required this.role,
    required this.photoUrl,
  }) : super(key: key);

  final String currentUserId;
  final String? role;
  final String? photoUrl;

  @override
  _ConversationsScreenState createState() =>
      _ConversationsScreenState(currentUserId: currentUserId);
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  _ConversationsScreenState({required this.currentUserId});

  final String currentUserId;

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
              title: 'Messages',
              photoUrl: widget.photoUrl ?? '',
              id: currentUserId,
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
                          .collection('Groups')
                          .where('members', arrayContains: currentUserId)
                          .orderBy('lastTimestamp', descending: true)
                          .limit(_limit)
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasData) {
                          List<Conversation> conversations = snapshot.data!.docs
                              .map((doc) => Conversation.fromFirestore(doc))
                              .toList();

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: conversations.length,
                            itemBuilder: (BuildContext context, int index) {
                              Conversation conversation = conversations[index];
                              int peerIndex;
                              if (conversation.members[0] == currentUserId) {
                                peerIndex = 1;
                              } else {
                                peerIndex = 0;
                              }
                              String peerId = conversation.members[peerIndex];
                              String peerName =
                                  conversation.memberNames[peerIndex];
                              String peerPhotoUrl =
                                  conversation.memberPhotoUrls[peerIndex];
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatScreen(
                                        groupChatId: conversation.id,
                                        currentUserId: currentUserId,
                                        peerId: peerId,
                                        peerName: peerName,
                                        peerPhotoUrl: peerPhotoUrl,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 0.4 * kDefaultPadding,
                                    horizontal: 0.9 * kDefaultPadding,
                                  ),
                                  child: ConversationPreview(
                                    groupChatId: conversation.id,
                                    currentUserId: currentUserId,
                                    peerId: peerId,
                                    peerName: peerName,
                                    peerPhotoUrl: peerPhotoUrl,
                                    lastMessage: conversation.lastMessage,
                                    lastTimestamp: conversation.lastTimestamp,
                                  ),
                                ),
                              );
                            },
                          );
                        } else {
                          return Center(child: CircularProgressIndicator());
                        }
                      },
                    ),
                    const SizedBox(height: kDefaultPadding),
                    widget.role != 'Chat Buddy'
                        ? ElevatedButton(
                            onPressed: () async {
                              Map<String, dynamic> params = {
                                'currentUserId': currentUserId
                              };
                              String title = 'Confirm';
                              String content =
                                  'You can only connect with 2 new peers per hour, so use this wisely! Continue?';
                              String purpose = 'Create Group';

                              if (Platform.isAndroid) {
                                showDialog(
                                    context: context,
                                    builder: (context) => CustomPopupDialog
                                        .buildMaterialPopupDialog(context,
                                            params, title, content, purpose));
                              } else {
                                showCupertinoDialog(
                                    context: context,
                                    builder: (context) => CustomPopupDialog
                                        .buildCupertinoPopupDialog(context,
                                            params, title, content, purpose));
                              }
                            },
                            child: Text('Connect to anonymous peer'),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  kPrimaryColor),
                            ),
                          )
                        : const SizedBox.shrink(),
                    // widget.role != 'Chat Buddy'
                    //     ? ElevatedButton(
                    //         onPressed: () async {
                    //           Map<String, dynamic> params = {
                    //             'currentUserId': currentUserId
                    //           };
                    //           String title = 'Confirm';
                    //           String content =
                    //               'You can only request 3 volunteers per hour. Continue?';
                    //           String purpose = 'Request Volunteer';

                    //           if (Platform.isAndroid) {
                    //             showDialog(
                    //                 context: context,
                    //                 builder: (context) => CustomPopupDialog
                    //                     .buildMaterialPopupDialog(context,
                    //                         params, title, content, purpose));
                    //           } else {
                    //             showCupertinoDialog(
                    //                 context: context,
                    //                 builder: (context) => CustomPopupDialog
                    //                     .buildCupertinoPopupDialog(context,
                    //                         params, title, content, purpose));
                    //           }
                    //         },
                    //         child: Text('Connect to chat buddy'),
                    //         style: ButtonStyle(
                    //           backgroundColor: MaterialStateProperty.all<Color>(
                    //               kPrimaryColor),
                    //         ),
                    //       )
                    //     : const SizedBox.shrink(),
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
