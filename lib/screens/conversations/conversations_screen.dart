import 'dart:io';

import 'package:connect_anon/constants/constants.dart';
import 'package:connect_anon/screens/chat/groups/chat_screen.dart';
import 'package:connect_anon/screens/conversations/components/conversation_preview.dart';
import 'package:connect_anon/services/api_services.dart';
import 'package:connect_anon/widgets/custom_popup_dialog.dart';
import 'package:connect_anon/widgets/custom_snackbar.dart';
import 'package:connect_anon/widgets/info_header.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConversationsScreen extends StatefulWidget {
  ConversationsScreen({
    Key? key,
    required this.currentUserId,
    required this.status,
    required this.photoUrl,
  }) : super(key: key);

  final String currentUserId;
  final String? status;
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
          margin: EdgeInsets.only(
            left: 0.9 * kDefaultPadding,
            right: 0.9 * kDefaultPadding,
            top: 0.7 * kDefaultPadding,
            bottom: 0.7 * kDefaultPadding,
          ),
          child: InfoHeader(
              title: 'Messages',
              photoUrl: widget.photoUrl ?? '',
              id: currentUserId),
        ),
        Container(
          child: Column(
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Groups')
                    .where('members', arrayContains: currentUserId)
                    .orderBy('lastTimestamp', descending: true)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    var groups = snapshot.data!.docs;

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: groups.length,
                      itemBuilder: (BuildContext context, int index) {
                        Map<String, dynamic> group =
                            groups[index].data() as Map<String, dynamic>;
                        String groupChatId = groups[index].id;
                        String lastMessage = group['lastMessage'];
                        String lastTimestamp = group['lastTimestamp'];
                        int peerIndex;
                        if (group['members'][0] == currentUserId) {
                          peerIndex = 1;
                        } else {
                          peerIndex = 0;
                        }
                        String peerId = group['members'][peerIndex];
                        String peerName = group['memberNames'][peerIndex];
                        String peerPhotoUrl =
                            group['memberPhotoUrls'][peerIndex];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  groupChatId: groupChatId,
                                  currentUserId: currentUserId,
                                  peerId: peerId,
                                  peerName: peerName,
                                  peerPhotoUrl: peerPhotoUrl,
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
                            child: ConversationPreview(
                              groupChatId: groupChatId,
                              currentUserId: currentUserId,
                              peerId: peerId,
                              peerName: peerName,
                              peerPhotoUrl: peerPhotoUrl,
                              lastMessage: lastMessage,
                              lastTimestamp: lastTimestamp,
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
              widget.status != 'Chat Buddy'
                  ? ElevatedButton(
                      onPressed: () async {
                        var response = await context
                            .read<APIServices>()
                            .createGroup(currentUserId);
                        if (response != 'Success') {
                          CustomSnackbar.buildWarningMessage(
                              context, 'Error', response);
                        }
                      },
                      child: Text('Connect to anonymous peer'),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(kPrimaryColor),
                      ),
                    )
                  : SizedBox.shrink(),
              widget.status != 'Chat Buddy'
                  ? ElevatedButton(
                      onPressed: () async {
                        Map<String, dynamic> params = {
                          'currentUserId': currentUserId
                        };
                        String title = 'Confirm';
                        String content =
                            'You can only request 3 volunteers per hour. Continue?';
                        String purpose = 'Request Volunteer';

                        if (Platform.isAndroid) {
                          showDialog(
                              context: context,
                              builder: (context) =>
                                  CustomPopupDialog.buildMaterialPopupDialog(
                                      context,
                                      params,
                                      title,
                                      content,
                                      purpose));
                        } else {
                          showCupertinoDialog(
                              context: context,
                              builder: (context) =>
                                  CustomPopupDialog.buildCupertinoPopupDialog(
                                      context,
                                      params,
                                      title,
                                      content,
                                      purpose));
                        }
                      },
                      child: Text('Connect to chat buddy'),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(kPrimaryColor),
                      ),
                    )
                  : SizedBox.shrink(),
            ],
          ),
        ),
      ],
    ));
  }
}
