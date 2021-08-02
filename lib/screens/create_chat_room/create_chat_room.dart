import 'package:anonymous_chat/services/api_services.dart';
import 'package:anonymous_chat/widgets/custom_snackbar.dart';
import 'package:anonymous_chat/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Create new chat room'),
            CustomTextField(
              hintText: 'Chat Room Name',
              controller: roomNameController,
            ),
            ElevatedButton(
              onPressed: () async {
                String response = await context
                    .read<APIServices>()
                    .createChatRoom(
                        widget.currentUserId, roomNameController.text);
                if (response != 'Success') {
                  CustomSnackbar.buildWarningMessage(
                      context, 'Error', response);
                } else {
                  Navigator.pop(context);
                }
              },
              child: Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}
