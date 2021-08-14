import 'package:anonymous_chat/constants/constants.dart';
import 'package:anonymous_chat/screens/chat/groups/chat_screen.dart';
import 'package:anonymous_chat/screens/conversations/components/conversation_preview.dart';
import 'package:anonymous_chat/screens/set_profile_pic/set_profile_pic.dart';
import 'package:anonymous_chat/services/api_services.dart';
import 'package:anonymous_chat/services/authentication.dart';
import 'package:anonymous_chat/widgets/custom_snackbar.dart';
import 'package:anonymous_chat/widgets/info_header.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class ConversationsScreen extends StatefulWidget {
  ConversationsScreen({Key? key, required this.currentUserId})
      : super(key: key);

  final String currentUserId;

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

  Future<Map<String, String>> _retrievePeerData(group) async {
    Map<String, String> peerData =
        await context.read<APIServices>().getPeerData(group);
    return peerData;
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
                        future: _retrievePeerData(groups[index]),
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
                  ElevatedButton(
                    onPressed: () async {
                      dynamic response = await context
                          .read<APIServices>()
                          .createGroup(currentUserId, chattedWith);
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
                  ),
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
