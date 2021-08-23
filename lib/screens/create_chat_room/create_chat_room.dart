import 'package:connect_anon/constants/constants.dart';
import 'package:connect_anon/services/api_services.dart';
import 'package:connect_anon/widgets/chat_rooms_header.dart';
import 'package:connect_anon/widgets/custom_snackbar.dart';
import 'package:connect_anon/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class CreateChatRoomScreen extends StatefulWidget {
  const CreateChatRoomScreen({Key? key, required this.currentUserId})
      : super(key: key);

  final String currentUserId;

  @override
  _CreateChatRoomScreenState createState() => _CreateChatRoomScreenState();
}

class _CreateChatRoomScreenState extends State<CreateChatRoomScreen> {
  final roomNameController = TextEditingController();
  final roomDescController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ChatRoomsHeader(title: 'New Chat Room'),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 1.5 * kDefaultPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 2 * kDefaultPadding),
                CustomTextField(
                  hintText: 'Chat Room Name',
                  controller: roomNameController,
                ),
                SizedBox(height: 1.3 * kDefaultPadding),
                CustomTextField(
                  controller: roomDescController,
                  hintText: 'Brief description of chat room',
                  textarea: true,
                ),
                SizedBox(height: 2 * kDefaultPadding),
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
                            .read<APIServices>()
                            .createChatRoom(
                                widget.currentUserId,
                                roomNameController.text,
                                roomDescController.text);
                        if (response != 'Success') {
                          CustomSnackbar.buildWarningMessage(
                              context, 'Error', response);
                        } else {
                          Navigator.pop(context);
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
    );
  }
}
