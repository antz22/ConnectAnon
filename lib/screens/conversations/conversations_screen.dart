import 'package:connect_anon/constants/constants.dart';
import 'package:connect_anon/screens/chat/groups/chat_screen.dart';
import 'package:connect_anon/screens/conversations/components/conversation_preview.dart';
import 'package:connect_anon/services/api_services.dart';
import 'package:connect_anon/widgets/custom_snackbar.dart';
import 'package:connect_anon/widgets/info_header.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConversationsScreen extends StatefulWidget {
  ConversationsScreen({
    Key? key,
    required this.currentUserId,
    required this.status,
  }) : super(key: key);

  final String currentUserId;
  final String? status;

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

  Future<Map<String, String>> _retrieveConversationData(group) async {
    Map<String, String> conversationData =
        await context.read<APIServices>().getConversationData(group);
    return conversationData;
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUserId)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasData) {
            Map<String, dynamic> data =
                snapshot.data!.data() as Map<String, dynamic>;
            List groups = data['groups'];
            List chattedWith = data['chattedWith'];
            List specialChattedWith = data['specialChattedWith'];
            List blocked = data['blocked'];
            String photoUrl = data['photoUrl'];
            return Column(children: [
              Container(
                margin: EdgeInsets.only(
                  left: 0.9 * kDefaultPadding,
                  right: 0.9 * kDefaultPadding,
                  top: 0.7 * kDefaultPadding,
                  bottom: 0.7 * kDefaultPadding,
                ),
                child: InfoHeader(
                    title: 'Messages', photoUrl: photoUrl, id: currentUserId),
              ),
              Container(
                  child: Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: groups.length,
                    itemBuilder: (BuildContext context, int index) {
                      return FutureBuilder(
                        future: _retrieveConversationData(groups[index]),
                        builder: (BuildContext context,
                            AsyncSnapshot<Map<String, String>> snapshot) {
                          if (snapshot.hasData) {
                            String groupChatId = groups[index];
                            String currentUserId =
                                snapshot.data!['currentUserId']!;
                            String peerId = snapshot.data!['peerId']!;
                            String peerName = snapshot.data!['peerName']!;
                            String peerPhotoUrl =
                                snapshot.data!['peerPhotoUrl']!;
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
                                ),
                              ),
                            );
                          } else {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        },
                      );
                    },
                  ),
                  widget.status != 'Chat Buddy'
                      ? ElevatedButton(
                          onPressed: () async {
                            var response = await context
                                .read<APIServices>()
                                .createGroup(
                                    currentUserId, chattedWith, blocked);
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
                            var response = await context
                                .read<APIServices>()
                                .requestVolunteer(
                                    currentUserId, specialChattedWith, blocked);
                            if (response != 'Success') {
                              CustomSnackbar.buildWarningMessage(
                                  context, 'Error', response);
                            } else {
                              CustomSnackbar.buildInfoMessage(context,
                                  'Success', 'A volunteer has been requested');
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
              )),
            ]);
          } else {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
              ),
            );
          }
        },
      ),
    );
  }
}
