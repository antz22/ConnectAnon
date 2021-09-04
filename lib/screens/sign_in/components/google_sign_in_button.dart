import 'package:connect_anon/constants/constants.dart';
import 'package:connect_anon/screens/account_creation/update_user_info.dart';
import 'package:connect_anon/screens/home/home_page.dart';
import 'package:connect_anon/services/authentication.dart';
import 'package:connect_anon/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class GoogleSignInButton extends StatefulWidget {
  GoogleSignInButton({required this.action});

  final String action;

  @override
  _GoogleSignInButtonState createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  bool _isSigningIn = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: _isSigningIn
          ? CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
            )
          : OutlinedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.white),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
              ),
              onPressed: () async {
                setState(() {
                  _isSigningIn = true;
                });

                User? user = await context
                    .read<AuthenticationService>()
                    .signInWithGoogle(
                      context: context,
                    );

                bool? isBanned = context.read<UserProvider>().isBanned;
                if (!isBanned!) {
                  setState(() {
                    _isSigningIn = false;
                  });

                  if (user != null) {
                    if (widget.action == 'Sign in') {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => HomePage(),
                        ),
                      );
                    } else if (widget.action == 'Update user') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UpdateUserInfoPage(user: user),
                        ),
                      );
                    }
                  }
                }
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SvgPicture.asset(
                      "assets/svgs/google.svg",
                      height: 27.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        'Sign in with Google',
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
