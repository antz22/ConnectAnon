import 'package:connect_anon/constants/constants.dart';
import 'package:connect_anon/screens/sign_in/components/google_sign_in_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'components/page_header.dart';
import 'components/text_blob.dart';

class GettingStartedPage extends StatelessWidget {
  const GettingStartedPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(2 * kDefaultPadding),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(text: 'Getting Started'),
              const SizedBox(height: kDefaultPadding),
              SvgPicture.asset(
                'assets/svgs/getting_started.svg',
                height: MediaQuery.of(context).size.height * 0.3,
              ),
              const SizedBox(height: kDefaultPadding),
              TextBlob(
                text:
                    'To get started, we need to make sure you are a student of Montgomery. Just sign in with your school email.',
              ),
              const SizedBox(height: kDefaultPadding),
              GoogleSignInButton(action: 'Update user'),
              TextBlob(
                text:
                    'Don\'t worry about your anonymity. This is purely for security pruposes, and your email and identity will be kept completely, 100% hidden from other users.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
