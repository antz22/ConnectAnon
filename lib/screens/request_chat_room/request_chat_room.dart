import 'package:connect_anon/constants/constants.dart';
import 'package:connect_anon/screens/home/home_page.dart';
import 'package:connect_anon/services/firestore_services.dart';
import 'package:connect_anon/widgets/chat_rooms_header.dart';
import 'package:connect_anon/widgets/custom_snackbar.dart';
import 'package:connect_anon/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RequestChatRoomScreen extends StatefulWidget {
  const RequestChatRoomScreen({Key? key, required this.currentUserId})
      : super(key: key);

  final String currentUserId;

  @override
  _RequestChatRoomScreenState createState() => _RequestChatRoomScreenState();
}

class _RequestChatRoomScreenState extends State<RequestChatRoomScreen> {
  final roomNameController = TextEditingController();
  final roomDescController = TextEditingController();

  @override
  void dispose() {
    roomNameController.dispose();
    roomDescController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ChatRoomsHeader(title: 'Request Chat Room'),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 1.5 * kDefaultPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 2 * kDefaultPadding),
                  Text(
                    'Feel free to propose ideas for chat rooms that warrant discussion among peers! Requests will be reviewed, and if accepted, will be open to peers to join.',
                    style: TextStyle(
                      fontSize: 15.0,
                    ),
                  ),
                  const SizedBox(height: 1.3 * kDefaultPadding),
                  CustomTextField(
                    hintText: 'Chat Room Name',
                    controller: roomNameController,
                  ),
                  const SizedBox(height: 1.3 * kDefaultPadding),
                  CustomTextField(
                    controller: roomDescController,
                    hintText: 'Brief description of chat room',
                    textarea: true,
                  ),
                  const SizedBox(height: 2 * kDefaultPadding),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Spacer(),
                      ElevatedButton(
                        onPressed: () async {
                          String response = await context
                              .read<FirestoreServices>()
                              .createChatRoom(
                                  widget.currentUserId,
                                  roomNameController.text,
                                  roomDescController.text);
                          if (response != 'Success') {
                            CustomSnackbar.buildWarningMessage(
                                context, 'Error', response);
                          } else {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomePage(
                                  message:
                                      'Your request has been submitted and will be reviewed. Thanks!',
                                  messageStatus: 'Success',
                                ),
                              ),
                            );
                          }
                        },
                        child: Text('Submit'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
