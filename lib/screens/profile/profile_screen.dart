import 'package:anonymous_chat/constants/constants.dart';
import 'package:anonymous_chat/screens/profile/components/bold_text.dart';
import 'package:anonymous_chat/screens/set_profile_pic/set_profile_pic.dart';
import 'package:anonymous_chat/services/api_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'components/sub_text.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key, required this.isMe, required this.id})
      : super(key: key);

  final bool isMe;
  final String id;

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<Map<String, dynamic>> _retrieveUserData() async {
    Map<String, dynamic> userData =
        await context.read<APIServices>().getUserData(widget.id);
    return userData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _retrieveUserData(),
        builder: (BuildContext context,
            AsyncSnapshot<Map<String, dynamic>> snapshot) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    children: [
                      Container(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).padding.top),
                        decoration: BoxDecoration(
                          color: kPrimaryColor,
                        ),
                        height: 0.28 * MediaQuery.of(context).size.height,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                SizedBox(width: kDefaultPadding),
                                IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: Icon(Icons.arrow_back,
                                      color: Colors.white),
                                ),
                                SizedBox(
                                    width: 0.29 *
                                            MediaQuery.of(context).size.width -
                                        kDefaultPadding),
                                Text(
                                  'Profile',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    fontSize: 22.0,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(height: 4 * kDefaultPadding),
                    ],
                  ),
                  Positioned(
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 11.0,
                                color: Colors.black.withOpacity(0.25),
                                spreadRadius: -2.0,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            backgroundImage:
                                NetworkImage('${snapshot.data?['photoUrl']}'),
                            radius: 80.0,
                          ),
                        ),
                        Positioned(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SetProfilePic(),
                                ),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.all(2.5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                color: kPrimaryColor,
                              ),
                              child: Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 30.0,
                              ),
                            ),
                          ),
                          bottom: 5.0,
                          right: 5.0,
                        ),
                      ],
                    ),
                    bottom: 0.9 * kDefaultPadding,
                  ),
                ],
              ),
              Text(
                snapshot.data?['alias'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22.0,
                ),
              ),
              Text(
                snapshot.data?['school'],
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: 0.05 * MediaQuery.of(context).size.height),
              BoldText(text: snapshot.data?['status']),
              SubText(text: 'status'),
              SizedBox(height: 0.05 * MediaQuery.of(context).size.height),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      BoldText(text: snapshot.data!['peerChats'].toString()),
                      SubText(text: 'Peer chats'),
                    ],
                  ),
                  SizedBox(width: 2 * kDefaultPadding),
                  Column(
                    children: [
                      BoldText(text: snapshot.data!['chatRooms'].toString()),
                      SubText(text: 'Chat Rooms'),
                    ],
                  ),
                  SizedBox(width: 2.09 * kDefaultPadding),
                  Column(
                    children: [
                      BoldText(text: snapshot.data!['reports'].toString()),
                      SubText(text: '  Reports '),
                    ],
                  ),
                ],
              ),
              widget.isMe
                  ? SizedBox.shrink()
                  : Column(
                      children: [
                        SizedBox(
                            height: 0.05 * MediaQuery.of(context).size.height),
                        ElevatedButton(
                            onPressed: () {}, child: Text('Archive')),
                        SizedBox(
                            height: 0.02 * MediaQuery.of(context).size.height),
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            child: Text(
                              'Report',
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
            ],
          );
        },
      ),
    );
  }
}
