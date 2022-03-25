import 'package:connect_anon/constants/constants.dart';
import 'package:connect_anon/screens/account_creation/components/email_sign_in_button.dart';
import 'package:connect_anon/screens/sign_in/components/google_sign_in_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GettingStartedPage extends StatelessWidget {
  const GettingStartedPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(2 * kDefaultPadding),
        child: SingleChildScrollView(
          // bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/svgs/getting_started.svg',
                height: MediaQuery.of(context).size.height * 0.35,
              ),
              const SizedBox(height: kDefaultPadding),
              Container(
                margin: EdgeInsets.all(10.0),
                child: Text(
                  'Getting Started',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 28.0),
                ),
              ),
              const SizedBox(height: 0.5 * kDefaultPadding),
              Container(
                margin: EdgeInsets.all(10.0),
                child: Text(
                  // 'To get started, we need to make sure you are a student. Sign into Google with your school email below, or create a new account with your school email.',
                  'To get started, we need to make sure you are a student. Sign into Google with your school email below.',
                  style: TextStyle(fontSize: 17.0),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: kDefaultPadding),
              GoogleSignInButton(action: 'Update user'),
              // EmailSignInButton(action: 'Sign in'),
            ],
          ),
        ),
      ),
    );
  }
}
