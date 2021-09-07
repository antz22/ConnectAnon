import 'dart:io';

import 'package:connect_anon/constants/constants.dart';
import 'package:connect_anon/models/profile.dart';
import 'package:connect_anon/screens/landing_page/landing_page.dart';
import 'package:connect_anon/screens/volunteer/change_volunteer_status/change_volunteer_status.dart';
import 'package:connect_anon/screens/profile/components/bold_text.dart';
import 'package:connect_anon/screens/report/report_screen.dart';
import 'package:connect_anon/services/authentication.dart';
import 'package:connect_anon/services/firestore_services.dart';
import 'package:connect_anon/services/user_provider.dart';
import 'package:connect_anon/widgets/custom_avatar.dart';
import 'package:connect_anon/widgets/custom_popup_dialog.dart';
import 'package:connect_anon/widgets/custom_snackbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'components/sub_text.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    Key? key,
    required this.isMe,
    required this.id,
    this.groupChatId = '',
    this.isReviewing = false,
  }) : super(key: key);

  final bool isMe;
  final String id;
  final String groupChatId;
  final bool isReviewing;

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? role = '';
  String? currentUserId = '';

  Future<Profile> _retrieveProfile() async {
    Profile profile =
        await context.read<FirestoreServices>().getProfile(widget.id);
    role = context.read<UserProvider>().role;
    currentUserId = context.read<UserProvider>().id;
    return profile;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _retrieveProfile(),
        builder: (BuildContext context, AsyncSnapshot<Profile> snapshot) {
          if (snapshot.hasData) {
            var profile = snapshot.data!;
            bool hasReport = profile.reports != 0 ? true : false;
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
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
                                    const SizedBox(width: kDefaultPadding),
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
                                  photoUrl: profile.photoUrl, size: 80.0),
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
                    profile.alias,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22.0,
                    ),
                  ),
                  Text(
                    profile.school,
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: 0.05 * MediaQuery.of(context).size.height),
                  BoldText(text: profile.role),
                  SubText(text: 'role'),
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
                            BoldText(text: profile.peerChats.toString()),
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
                                        text: profile.reports.toString(),
                                        color: Colors.red,
                                      ),
                                      SubText(text: '  Reports '),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                      Container(
                        width: 85.0,
                        margin: EdgeInsets.only(
                            left: hasReport ? 0 : 1.3 * kDefaultPadding),
                        child: Column(
                          children: [
                            BoldText(text: profile.chatRooms.toString()),
                            SubText(text: 'Chat Rooms'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  widget.isMe
                      ? role == 'Chat Buddy'
                          ? _buildChangeStatusButton(
                              context, profile.isAccepting!)
                          : const SizedBox.shrink()
                      : widget.isReviewing
                          ? Container(
                              margin: const EdgeInsets.only(
                                  top: 2 * kDefaultPadding),
                              child: _buildReferralButton(context),
                            )
                          : Column(
                              children: [
                                SizedBox(
                                    height: 0.07 *
                                        MediaQuery.of(context).size.height),
                                ElevatedButton(
                                  onPressed: () async {
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
                                          builder: (context) =>
                                              CustomPopupDialog
                                                  .buildMaterialPopupDialog(
                                                      context,
                                                      params,
                                                      title,
                                                      content,
                                                      purpose));
                                    } else {
                                      showCupertinoDialog(
                                          context: context,
                                          builder: (context) =>
                                              CustomPopupDialog
                                                  .buildCupertinoPopupDialog(
                                                      context,
                                                      params,
                                                      title,
                                                      content,
                                                      purpose));
                                    }
                                  },
                                  child: Text('Archive'),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextButton(
                                      onPressed: () async {
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
                                    const SizedBox(width: kDefaultPadding),
                                    TextButton(
                                      onPressed: () async {
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
                                              builder: (context) =>
                                                  CustomPopupDialog
                                                      .buildMaterialPopupDialog(
                                                          context,
                                                          params,
                                                          title,
                                                          content,
                                                          purpose));
                                        } else {
                                          showCupertinoDialog(
                                              context: context,
                                              builder: (context) =>
                                                  CustomPopupDialog
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
                                role == 'Chat Buddy'
                                    ? _buildReferralButton(context)
                                    : profile.isBanned
                                        ? Container(
                                            margin: EdgeInsets.only(
                                                top: kDefaultPadding),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.info),
                                                const SizedBox(
                                                    width:
                                                        0.5 * kDefaultPadding),
                                                Text(
                                                    'NOTE: This user has been temporarily banned'),
                                              ],
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                              ],
                            ),
                  widget.isMe
                      ? Container(
                          margin: const EdgeInsets.only(top: kDefaultPadding),
                          child: TextButton(
                            onPressed: () async {
                              Map<String, dynamic> params = {};
                              String title = 'Sign Out';
                              String content =
                                  'Are you sure you want to sign out?';
                              String purpose = 'Sign Out';

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
                            child: Text(
                              'Sign Out',
                              style: TextStyle(color: kPrimaryColor),
                            ),
                          ),
                        )
                      : SizedBox.shrink(),
                ],
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Container _buildChangeStatusButton(BuildContext context, bool isAccepting) {
    return Container(
      margin: const EdgeInsets.only(top: 2 * kDefaultPadding),
      child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChangeVolunteerStatus(
                    volunteerId: widget.id, isAccepting: isAccepting),
              ),
            );
          },
          child: Text('Change request status')),
    );
  }

  ElevatedButton _buildReferralButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        var response =
            await context.read<FirestoreServices>().referNewVolunteer(
                  widget.id,
                  currentUserId ?? '',
                );
        if (response != 'Success') {
          CustomSnackbar.buildWarningMessage(context, 'Error', response);
        }
      },
      child: Text('(Chat Buddy) Refer to other volunteer'),
    );
  }
}
