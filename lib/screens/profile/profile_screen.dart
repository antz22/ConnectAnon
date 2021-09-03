import 'dart:io';

import 'package:connect_anon/constants/constants.dart';
import 'package:connect_anon/screens/profile/components/bold_text.dart';
import 'package:connect_anon/screens/report/report_screen.dart';
import 'package:connect_anon/services/api_services.dart';
import 'package:connect_anon/widgets/custom_avatar.dart';
import 'package:connect_anon/widgets/custom_popup_dialog.dart';
import 'package:connect_anon/widgets/custom_snackbar.dart';
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
  String? status = '';

  Future<Map<String, dynamic>> _retrieveUserData() async {
    Map<String, dynamic> userData =
        await context.read<APIServices>().getUserData(widget.id);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    status = await prefs.getString('status');
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
            bool hasReport = snapshot.data!['reports'] != 0 ? true : false;
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
                  mainAxisAlignment: hasReport
                      ? MainAxisAlignment.spaceEvenly
                      : MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 85.0,
                      margin: EdgeInsets.only(
                          right: hasReport ? 0 : 1.3 * kDefaultPadding),
                      child: Column(
                        children: [
                          BoldText(text: userData['peerChats'].toString()),
                          SubText(text: 'Peer chats'),
                        ],
                      ),
                    ),
                    hasReport
                        ? Container(
                            width: 85.0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
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
                            ),
                          )
                        : SizedBox.shrink(),
                    Container(
                      width: 85.0,
                      margin: EdgeInsets.only(
                          left: hasReport ? 0 : 1.3 * kDefaultPadding),
                      child: Column(
                        children: [
                          BoldText(text: userData['chatRooms'].toString()),
                          SubText(text: 'Chat Rooms'),
                        ],
                      ),
                    ),
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
                                  'Are you sure you want to archive this conversation? You won\'t be able to access your conversation anymore.';
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
                            child: Text('Archive'),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: () async {
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  String? currentUserId = prefs.getString('id');

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ReportScreen(
                                          currentUserId: currentUserId,
                                          peerId: widget.id),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Report',
                                  style: TextStyle(
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                              SizedBox(width: kDefaultPadding),
                              TextButton(
                                onPressed: () async {
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  String? currentUserId = prefs.getString('id');
                                  Map<String, dynamic> params = {
                                    'currentUserId': currentUserId,
                                    'peerId': widget.id,
                                    'groupChatId': widget.groupChatId,
                                  };
                                  String title = 'Block';
                                  String content =
                                      'Are you sure you want to block this user? You won\'t be able to chat with this user again.';
                                  String purpose = 'Block User';

                                  if (Platform.isAndroid) {
                                    showDialog(
                                        context: context,
                                        builder: (context) => CustomPopupDialog
                                            .buildMaterialPopupDialog(
                                                context,
                                                params,
                                                title,
                                                content,
                                                purpose));
                                  } else {
                                    showCupertinoDialog(
                                        context: context,
                                        builder: (context) => CustomPopupDialog
                                            .buildCupertinoPopupDialog(
                                                context,
                                                params,
                                                title,
                                                content,
                                                purpose));
                                  }
                                },
                                child: Text(
                                  'Block',
                                  style: TextStyle(
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          status == 'Chat Buddy'
                              ? ElevatedButton(
                                  onPressed: () async {
                                    var response = await context
                                        .read<APIServices>()
                                        .referNewVolunteer(
                                          widget.id,
                                        );
                                    if (response != 'Success') {
                                      CustomSnackbar.buildWarningMessage(
                                          context, 'Error', response);
                                    }
                                  },
                                  child: Text(
                                      '(Chat Buddy) Refer to other volunteer'),
                                )
                              : userData['isBanned']
                                  ? Container(
                                      margin:
                                          EdgeInsets.only(top: kDefaultPadding),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.info),
                                          SizedBox(
                                              width: 0.5 * kDefaultPadding),
                                          Text(
                                              'NOTE: This user has been temporarily banned'),
                                        ],
                                      ),
                                    )
                                  : SizedBox.shrink(),
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
