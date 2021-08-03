import 'package:anonymous_chat/constants/constants.dart';
import 'package:anonymous_chat/screens/home/home_page.dart';
import 'package:anonymous_chat/services/authentication.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UpdateUserInfoPage extends StatefulWidget {
  const UpdateUserInfoPage({Key? key, required this.user}) : super(key: key);

  final User user;

  @override
  _UpdateUserInfoPageState createState() => _UpdateUserInfoPageState();
}

class _UpdateUserInfoPageState extends State<UpdateUserInfoPage> {
  final TextEditingController aliasController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complete Account Setup'),
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(kDefaultPadding),
              child: TextField(
                controller: aliasController,
                decoration: InputDecoration(
                  hintText: 'Alias',
                ),
              ),
            ),
            SizedBox(height: kDefaultPadding),
            ElevatedButton(
              onPressed: () async {
                await context
                    .read<AuthenticationService>()
                    .updateUserInfo(aliasController.text, widget.user);
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => HomePage(),
                  ),
                );
              },
              child: Text('Update user info'),
            )
          ],
        ),
      ),
    );
  }
}
