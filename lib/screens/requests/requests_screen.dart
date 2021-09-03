import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect_anon/constants/constants.dart';
import 'package:connect_anon/screens/home/home_page.dart';
import 'package:connect_anon/services/api_services.dart';
import 'package:connect_anon/widgets/custom_avatar.dart';
import 'package:connect_anon/widgets/info_header.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({
    Key? key,
    required this.currentUserId,
    required this.photoUrl,
  }) : super(key: key);

  final String currentUserId;
  final String? photoUrl;

  @override
  _RequestsScreenState createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  int _limit = 10;

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
                title: 'Requests',
                photoUrl: widget.photoUrl!,
                id: widget.currentUserId),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Requests')
                .where('volunteer', isEqualTo: widget.currentUserId)
                .orderBy('timestamp', descending: true)
                .limit(_limit)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var docs = snapshot.data!.docs;
                if (docs.length == 0) {
                  return Container(
                    margin: EdgeInsets.only(top: kDefaultPadding),
                    child:
                        Text('You don\'t have any requests at the moment :)'),
                  );
                } else {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      String requestId = docs[index].id;
                      String peerId = docs[index]['peer'];
                      String volunteerId = docs[index]['volunteer'];
                      String peerName = docs[index]['peerName'];
                      String timestamp = docs[index]['timestamp'];
                      String peerPhotoUrl = docs[index]['peerPhotoUrl'];
                      bool availableUsers = docs[index]['availableUsers'];
                      return Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 0.9 * kDefaultPadding,
                            vertical: 0.4 * kDefaultPadding),
                        child: Row(
                          children: [
                            CustomAvatar(photoUrl: peerPhotoUrl, size: 20.0),
                            SizedBox(width: 0.9 * kDefaultPadding),
                            Expanded(
                              child: Container(
                                height: 53.0,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      peerName,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      _buildTimeAgo(timestamp),
                                      style: TextStyle(
                                        color: Color(0xFF535353),
                                        fontSize: 15.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 0.9 * kDefaultPadding),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () async {
                                    String response = await context
                                        .read<APIServices>()
                                        .declineRequest(requestId);
                                  },
                                  child: Container(
                                    height: 40.0,
                                    width: 40.0,
                                    child: Center(
                                      child: Icon(Icons.cancel_outlined,
                                          color: Colors.white, size: 30.0),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 0.8 * kDefaultPadding),
                            Container(
                              decoration: BoxDecoration(
                                color: kPrimaryColor,
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () async {
                                    String response = await context
                                        .read<APIServices>()
                                        .grantPeerRequest(volunteerId,
                                            requestId, peerId, availableUsers);
                                    if (response == 'Success') {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => HomePage(
                                              message: 'Request accepted.',
                                              messageStatus: 'Success'),
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                    height: 40.0,
                                    width: 40.0,
                                    child: Center(
                                      child: Icon(Icons.check,
                                          color: Colors.white, size: 30.0),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
        ],
      ),
    );
  }

  String _buildTimeAgo(String timestamp) {
    DateTime lastDateTime =
        DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp));
    DateTime currentDateTime = DateTime.now();
    var difference = currentDateTime.difference(lastDateTime).inMilliseconds;
    final timeAgo = DateTime.now().subtract(Duration(milliseconds: difference));
    return timeago.format(timeAgo);
  }
}
