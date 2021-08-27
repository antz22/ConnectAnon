import 'package:connect_anon/constants/constants.dart';
import 'package:connect_anon/services/api_services.dart';
import 'package:connect_anon/widgets/chat_rooms_header.dart';
import 'package:connect_anon/widgets/custom_snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class JoinChatRoomScreen extends StatefulWidget {
  const JoinChatRoomScreen({Key? key, required this.currentUserId})
      : super(key: key);

  final String currentUserId;

  @override
  _JoinChatRoomScreenState createState() => _JoinChatRoomScreenState();
}

class _JoinChatRoomScreenState extends State<JoinChatRoomScreen> {
  // Future<List<String>> _retrieveChatRooms() async {
  //   List<String> rooms = await context.read<APIServices>().retrieveChatRooms();
  //   return rooms;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ChatRoomsHeader(title: 'Join Chat Room'),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 1.3 * kDefaultPadding),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('ChatRooms')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  // List docs = snapshot.data!.docs.map((DocumentSnapshot doc) {
                  //   return doc.data();
                  // }).toList();
                  var docs = snapshot.data!.docs;
                  if (docs.length == 0) {
                    return Container(
                      margin: EdgeInsets.only(top: kDefaultPadding),
                      child: Text(
                        'No current chat rooms.',
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
                      itemBuilder: (BuildContext context, int index) {
                        Map<String, dynamic> chatRoom =
                            docs[index].data() as Map<String, dynamic>;
                        String chatRoomId = docs[index].id;
                        if (chatRoom['members']
                            .contains(widget.currentUserId)) {
                          return Container(
                              child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '# ' + chatRoom['name'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0,
                                ),
                              ),
                              Text(
                                '(already joined)',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey.shade500,
                                  fontSize: 17.0,
                                ),
                              ),
                            ],
                          ));
                        } else {
                          return GestureDetector(
                            onTap: () async {
                              String response = await context
                                  .read<APIServices>()
                                  .joinChatRoom(
                                      widget.currentUserId, chatRoomId);
                              if (response == 'Success') {
                                Navigator.pop(context);
                              } else {
                                CustomSnackbar.buildWarningMessage(
                                    context, 'Error', response);
                              }
                            },
                            child: Container(
                              margin:
                                  EdgeInsets.only(top: 0.5 * kDefaultPadding),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '# ' + chatRoom['name'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20.0,
                                    ),
                                  ),
                                  SizedBox(width: kDefaultPadding),
                                  Flexible(
                                    child: Container(
                                      child: Text(
                                        chatRoom['description'],
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          color: Colors.grey.shade500,
                                          fontSize: 17.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      },
                      separatorBuilder: (context, index) {
                        return Column(children: [
                          SizedBox(height: 0.8 * kDefaultPadding),
                          Divider(),
                          SizedBox(height: 0.8 * kDefaultPadding),
                        ]);
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
          ),
        ],
      ),
    );
  }
}
