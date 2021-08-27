import 'dart:io';

import 'package:connect_anon/constants/constants.dart';
import 'package:connect_anon/screens/profile/components/bold_text.dart';
import 'package:connect_anon/screens/set_profile_pic/set_profile_pic.dart';
import 'package:connect_anon/services/api_services.dart';
import 'package:connect_anon/widgets/custom_avatar.dart';
import 'package:connect_anon/widgets/custom_popup_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'components/sub_text.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen(
      {Key? key, required this.isMe, required this.id, this.groupChatId = ''})
      : super(key: key);

  final bool isMe;
  final String id;
  final String groupChatId;

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
          if (snapshot.hasData) {
            var userData = snapshot.data!;
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
                                              MediaQuery.of(context)
                                                  .size
                                                  .width -
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
                            child: CustomAvatar(
                                photoUrl: userData['photoUrl'], size: 80.0),
                          ),
                          // Positioned(
                          //   child: GestureDetector(
                          //     onTap: () {
                          //       Navigator.push(
                          //         context,
                          //         MaterialPageRoute(
                          //           builder: (context) => SetProfilePic(),
                          //         ),
                          //       );
                          //     },
                          //     child: Container(
                          //       padding: EdgeInsets.all(2.5),
                          //       decoration: BoxDecoration(
                          //         borderRadius: BorderRadius.circular(5.0),
                          //         color: kPrimaryColor,
                          //       ),
                          //       child: Icon(
                          //         Icons.edit,
                          //         color: Colors.white,
                          //         size: 30.0,
                          //       ),
                          //     ),
                          //   ),
                          //   bottom: 5.0,
                          //   right: 5.0,
                          // ),
                        ],
                      ),
                      bottom: 0.9 * kDefaultPadding,
                    ),
                  ],
                ),
                Text(
                  userData['alias'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22.0,
                  ),
                ),
                Text(
                  userData['school'],
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: 0.05 * MediaQuery.of(context).size.height),
                BoldText(text: userData['status']),
                SubText(text: 'status'),
                SizedBox(height: 0.05 * MediaQuery.of(context).size.height),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        BoldText(text: userData['peerChats'].toString()),
                        SubText(text: 'Peer chats'),
                      ],
                    ),
                    SizedBox(width: 2 * kDefaultPadding),
                    Column(
                      children: [
                        BoldText(text: userData['chatRooms'].toString()),
                        SubText(text: 'Chat Rooms'),
                      ],
                    ),
                    snapshot.data!['reports'] != 0
                        ? Column(
                            children: [
                              SizedBox(width: 2.09 * kDefaultPadding),
                              Column(
                                children: [
                                  BoldText(
                                    text: userData['reports'].toString(),
                                    color: Colors.red,
                                  ),
                                  SubText(text: '  Reports '),
                                ],
                              ),
                            ],
                          )
                        : SizedBox.shrink(),
                  ],
                ),
                widget.isMe
                    ? SizedBox.shrink()
                    : Column(
                        children: [
                          SizedBox(
                              height:
                                  0.07 * MediaQuery.of(context).size.height),
                          ElevatedButton(
                              onPressed: () async {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                String? currentUserId = prefs.getString('id');
                                Map<String, dynamic> params = {
                                  'currentUserId': currentUserId,
                                  'peerId': widget.id,
                                  'groupChatId': widget.groupChatId,
                                };
                                String title = 'Archive';
                                String content =
                                    'Are you sure you want to archive this conversation? You won\'t be able to chat with this user again.';
                                String purpose = 'Archive Conversation';

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
                              child: Text('Archive')),
                          TextButton(
                            onPressed: () async {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              String? currentUserId = prefs.getString('id');

                              await context
                                  .read<APIServices>()
                                  .reportUser(currentUserId, widget.id);
                            },
                            child: Text(
                              'Report',
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      )
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
