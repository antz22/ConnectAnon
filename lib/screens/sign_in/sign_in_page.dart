import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'components/google_sign_in_button.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height / 14,
            ),
            decoration: BoxDecoration(),
            child: SvgPicture.asset('assets/svgs/landing_page.svg'),
          ),
          Text(
            'Connect to Peers Anonymously',
            style: TextStyle(
              fontSize: 23.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20.0),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 35.0),
            child: Text(
              'Talk with random classmates to make new friends and have spicy conversations',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 16.0,
                height: 1.8,
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height / 8),
          GoogleSignInButton(action: 'Sign in'),
        ],
      ),
    );
  }
}
