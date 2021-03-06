import 'package:connect_anon/screens/home/home_page.dart';
import 'package:connect_anon/screens/landing_page/landing_page.dart';
import 'package:connect_anon/services/authentication.dart';
import 'package:connect_anon/services/firestore_services.dart';
import 'package:connect_anon/services/user_provider.dart';
import 'package:connect_anon/widgets/custom_snackbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomPopupDialog {
  static Widget buildMaterialPopupDialog(
      BuildContext context,
      Map<String, dynamic> params,
      String title,
      String content,
      String purpose) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            switch (purpose) {
              case 'Update User Info':
                String controllerText = params['controllerText'];
                String photoUrl = params['photoUrl'];
                String school = params['school'];
                var user = params['user'];
                var response = await context
                    .read<AuthenticationService>()
                    .updateUserInfo(controllerText, user, photoUrl, school);
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await Provider.of<UserProvider>(context, listen: false)
                    .initUser(prefs);
                if (response == 'Success') {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => HomePage(
                          message: 'Account Creation successful.',
                          messageStatus: 'Success'),
                    ),
                  );
                } else if (response == 'Your email domain is not verified') {
                  CustomSnackbar.buildWarningMessage(
                      context, 'Error', 'Your email domain is not verified.');
                } else {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) {
                        return HomePage(message: response);
                      },
                    ),
                  );
                }
                break;
              case 'Archive Conversation':
                String currentUserId = params['currentUserId'];
                String peerId = params['peerId'];
                String groupChatId = params['groupChatId'];
                String response = await context
                    .read<FirestoreServices>()
                    .archiveConversation(currentUserId, peerId, groupChatId);
                if (response == 'Success') {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => HomePage(
                          message: 'Conversation archived.',
                          messageStatus: 'Success'),
                    ),
                  );
                } else {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) {
                        return HomePage(message: response);
                      },
                    ),
                  );
                }
                break;
              case 'Block User':
                String currentUserId = params['currentUserId'];
                String peerId = params['peerId'];
                String groupChatId = params['groupChatId'];
                String response = await context
                    .read<FirestoreServices>()
                    .blockUser(currentUserId, peerId, groupChatId);
                if (response == 'Success') {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => HomePage(
                        message: 'User blocked.',
                        messageStatus: 'Success',
                      ),
                    ),
                  );
                } else {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) {
                        return HomePage(message: response);
                      },
                    ),
                  );
                }
                break;
              // case 'Request Volunteer':
              //   String currentUserId = params['currentUserId'];
              //   String response = await context
              //       .read<FirestoreServices>()
              //       .requestVolunteer(currentUserId);
              //   if (response == 'Success') {
              //     Navigator.of(context).pushReplacement(
              //       MaterialPageRoute(
              //         builder: (context) => HomePage(
              //           message: 'A volunteer has been requested.',
              //           messageStatus: 'Success',
              //         ),
              //       ),
              //     );
              //   } else {
              //     Navigator.of(context).pushReplacement(
              //       MaterialPageRoute(
              //         builder: (context) {
              //           return HomePage(message: response);
              //         },
              //       ),
              //     );
              //   }
              //   break;
              case 'Create Group':
                String currentUserId = params['currentUserId'];
                String response = await context
                    .read<FirestoreServices>()
                    .requestPeer(currentUserId);
                if (response == 'Success') {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => HomePage(
                        message:
                            'New conversation with anonymous peer requested',
                        messageStatus: 'Success',
                      ),
                    ),
                  );
                } else {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) {
                        return HomePage(message: response);
                      },
                    ),
                  );
                }
                break;
              case 'Sign Out':
                await context
                    .read<AuthenticationService>()
                    .signOut(context: context);

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LandingPage(),
                  ),
                );
                break;
            }
          },
          child: Text('Confirm'),
        ),
      ],
    );
  }

  static Widget buildCupertinoPopupDialog(
      BuildContext context,
      Map<String, dynamic> params,
      String title,
      String content,
      String purpose) {
    return CupertinoAlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            switch (purpose) {
              case 'Update User Info':
                String controllerText = params['controllerText'];
                String photoUrl = params['photoUrl'];
                String school = params['school'];
                var user = params['user'];
                var response = await context
                    .read<AuthenticationService>()
                    .updateUserInfo(controllerText, user, photoUrl, school);
                if (response == 'Success') {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => HomePage(
                        message: 'Account Creation successful.',
                        messageStatus: 'Success',
                      ),
                    ),
                  );
                } else if (response == 'Your email domain is not verified') {
                  CustomSnackbar.buildWarningMessage(
                      context, 'Error', 'Your email domain is not verified.');
                } else {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) {
                        return HomePage(message: response);
                      },
                    ),
                  );
                }
                break;
              case 'Archive Conversation':
                String currentUserId = params['currentUserId'];
                String peerId = params['peerId'];
                String groupChatId = params['groupChatId'];
                String response = await context
                    .read<FirestoreServices>()
                    .archiveConversation(currentUserId, peerId, groupChatId);
                if (response == 'Success') {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => HomePage(
                        message: 'Conversation archived.',
                        messageStatus: 'Success',
                      ),
                    ),
                  );
                } else {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) {
                        return HomePage(message: response);
                      },
                    ),
                  );
                }
                break;
              case 'Block User':
                String currentUserId = params['currentUserId'];
                String peerId = params['peerId'];
                String groupChatId = params['groupChatId'];
                String response = await context
                    .read<FirestoreServices>()
                    .blockUser(currentUserId, peerId, groupChatId);
                if (response == 'Success') {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => HomePage(
                        message: 'User blocked.',
                        messageStatus: 'Success',
                      ),
                    ),
                  );
                } else {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) {
                        return HomePage(message: response);
                      },
                    ),
                  );
                }
                break;
              // case 'Request Volunteer':
              //   String currentUserId = params['currentUserId'];
              //   String response = await context
              //       .read<FirestoreServices>()
              //       .requestVolunteer(currentUserId);
              //   if (response == 'Success') {
              //     Navigator.of(context).pushReplacement(
              //       MaterialPageRoute(
              //         builder: (context) => HomePage(
              //           message: 'A volunteer has been requested.',
              //           messageStatus: 'Success',
              //         ),
              //       ),
              //     );
              //   } else {
              //     Navigator.of(context).pushReplacement(
              //       MaterialPageRoute(
              //         builder: (context) {
              //           return HomePage(message: response);
              //         },
              //       ),
              //     );
              //   }
              //   break;
              case 'Create Group':
                String currentUserId = params['currentUserId'];
                String response = await context
                    .read<FirestoreServices>()
                    .requestPeer(currentUserId);
                if (response == 'Success') {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => HomePage(
                        message:
                            'New conversation with anonymous peer requested',
                        messageStatus: 'Success',
                      ),
                    ),
                  );
                } else {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) {
                        return HomePage(message: response);
                      },
                    ),
                  );
                }
                break;
              case 'Sign Out':
                await context
                    .read<AuthenticationService>()
                    .signOut(context: context);

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LandingPage(),
                  ),
                );
                break;
            }
          },
          child: Text('Confirm'),
        ),
      ],
    );
  }
}
