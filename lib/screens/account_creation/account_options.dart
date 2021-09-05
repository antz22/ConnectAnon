import 'package:connect_anon/constants/constants.dart';
import 'package:flutter/material.dart';

import 'components/page_header.dart';
import 'components/text_blob.dart';

class AccountOptionsPage extends StatelessWidget {
  const AccountOptionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(2 * kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              text: 'Would you like to finish setting up your account?',
            ),
            const SizedBox(height: 2 * kDefaultPadding),
            Text(
              'Create an Account',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 21.0,
              ),
            ),
            const SizedBox(height: kDefaultPadding),
            TextBlob(
              text:
                  'Finish setting up your account with an alias so you can access past conversations and participate in and create chat rooms.',
            ),
            Spacer(),
            Text(
              'Continue without an Account',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 21.0,
              ),
            ),
            const SizedBox(height: kDefaultPadding),
            TextBlob(
              text:
                  'Create a conversation to chat with anyone from your school and view chat rooms without registering. Your conversations will disappear and you won\'t be able to text in chat rooms.',
            ),
          ],
        ),
      ),
    );
  }
}
