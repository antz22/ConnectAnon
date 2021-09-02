import 'package:connect_anon/constants/constants.dart';
import 'package:connect_anon/screens/chat_room_info/chat_room_info_screen.dart';
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
                      itemBuilder: (BuildContext context, int index) {
                        Map<String, dynamic> chatRoom =
                            docs[index].data() as Map<String, dynamic>;
                        String chatRoomId = docs[index].id;
                        // if (!chatRoom['members']
                        //     .contains(widget.currentUserId)) {
                        return Container(
                          margin: EdgeInsets.only(top: 0.5 * kDefaultPadding),
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
                                // Flexible(
                                //   child: Container(
                                //     child: Text(
                                //       chatRoom['description'],
                                //       overflow: TextOverflow.ellipsis,
                                //       style: TextStyle(
                                //         fontWeight: FontWeight.w400,
                                //         color: Colors.grey.shade500,
                                //         fontSize: 17.0,
                                //       ),
                                //     ),
                                //   ),
                                // ),
                              ),
                            ],
                          ),
                        );
                        // return Container(
                        //     child: Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     Text(
                        //       '# ' + chatRoom['name'],
                        //       style: TextStyle(
                        //         fontWeight: FontWeight.bold,
                        //         fontSize: 20.0,
                        //       ),
                        //     ),
                        //     IconButton(
                        //       onPressed: () {
                        //         Navigator.push(
                        //           context,
                        //           MaterialPageRoute(
                        //             builder: (context) => ChatRoomInfoScreen(
                        //               roomId: chatRoomId,
                        //               roomName: chatRoom['name'],
                        //               description: chatRoom['description'],
                        //               members: chatRoom['members'],
                        //               memberNames: chatRoom['memberNames'],
                        //               memberPhotoUrls:
                        //                   chatRoom['memberPhotoUrls'],
                        //               currentUserId: widget.currentUserId,
                        //             ),
                        //           ),
                        //         );
                        //       },
                        //       icon: Icon(Icons.arrow_forward),
                        //     )
                        //     //   ,
                        //     //   overflow: TextOverflow.ellipsis,
                        //     //   style: TextStyle(
                        //     //     fontWeight: FontWeight.w400,
                        //     //     color: Colors.grey.shade500,
                        //     //     fontSize: 17.0,
                        //     //   ),
                        //     // ),
                        //   ],
                        // ));
                        // } else {
                        //   return SizedBox.shrink();
                        // }
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
