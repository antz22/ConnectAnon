import 'package:anonymous_chat/services/api_services.dart';
import 'package:anonymous_chat/widgets/custom_snackbar.dart';
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
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder<QuerySnapshot>(
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
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      Map<String, dynamic> chatRoom =
                          docs[index].data() as Map<String, dynamic>;
                      String chatRoomId = docs[index].id;
                      if (chatRoom['members'].contains(widget.currentUserId)) {
                        return Container(
                          child: Center(
                            child: Text(chatRoom['name'] + ' (already joined)'),
                          ),
                        );
                      } else {
                        return GestureDetector(
                          onTap: () async {
                            String response = await context
                                .read<APIServices>()
                                .joinChatRoom(widget.currentUserId, chatRoomId);
                            if (response == 'Success') {
                              Navigator.pop(context);
                            } else {
                              CustomSnackbar.buildWarningMessage(
                                  context, 'Error', response);
                            }
                          },
                          child: Container(
                            child: Center(
                              child: Text(chatRoom['name']),
                            ),
                          ),
                        );
                      }
                    },
                  );
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
