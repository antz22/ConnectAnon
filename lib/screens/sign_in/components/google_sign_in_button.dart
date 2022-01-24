import 'package:connect_anon/constants/constants.dart';
import 'package:connect_anon/screens/account_creation/update_user_info.dart';
import 'package:connect_anon/screens/home/home_page.dart';
import 'package:connect_anon/services/authentication.dart';
import 'package:connect_anon/services/user_provider.dart';
import 'package:connect_anon/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class GoogleSignInButton extends StatefulWidget {
  const GoogleSignInButton({required this.action});

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

                if (user != null) {
                  setState(() {
                    _isSigningIn = false;
                  });
                  if (widget.action == 'Sign in') {
                    print('alias: ${context.read<UserProvider>().alias}');
                    print('isBanned: ${context.read<UserProvider>().isBanned}');
                    print('id: ${context.read<UserProvider>().id}');
                    print('photoUrl: ${context.read<UserProvider>().photoUrl}');
                    if (context.read<UserProvider>().alias != null) {
                      // User has logged in and has an account
                      bool? isBanned = context.read<UserProvider>().isBanned;
                      if (!isBanned!) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => HomePage(),
                          ),
                        );
                      } else {
                        CustomSnackbar.buildWarningMessage(context, 'Error',
                            'You have been temporarily banned.');
                      }
                    } else {
                      // User has logged in but doesn't have an account
                      print('No account');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UpdateUserInfoPage(user: user),
                        ),
                      );
                    }
                  } else if (widget.action == 'Update user') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdateUserInfoPage(user: user),
                      ),
                    );
                  }
                } else {
                  CustomSnackbar.buildWarningMessage(context, 'Error',
                      'Error signing into Google Account. Please try again.');
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
