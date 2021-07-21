import 'package:anonymous_chat/models/chat.dart';
import 'package:anonymous_chat/screens/home/home_page.dart';
import 'package:anonymous_chat/services/authentication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class GoogleSignInButton extends StatefulWidget {
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
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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

                // User? user = await AuthenticationService(FirebaseAuth.instance)
                //     .signInWithGoogle(
                //   context: context,
                // );

                if (user != null) {
                  // Has the user already signed up before?
                  final QuerySnapshot result = await FirebaseFirestore.instance
                      .collection('Users')
                      .where('id', isEqualTo: user.uid)
                      .get();
                  final List<DocumentSnapshot> documents = result.docs;
                  if (documents.length == 0) {
                    // Update data to server if new user
                    FirebaseFirestore.instance
                        .collection('Users')
                        .doc(user.uid)
                        .set({
                      'uid': user.uid,
                      'displayName': user.displayName,
                      'alias': 'hi',
                      'photoUrl': user.photoURL,
                      'chattingWith': null,
                    });
                    // update provider / state management!
                  } else {
                    DocumentSnapshot documentSnapshot = documents[0];
                    Chat chat = Chat.fromDocument(documentSnapshot);

                    // write data to local with state management
                  }
                }

                setState(() {
                  _isSigningIn = false;
                });

                if (user != null) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => HomePage(),
                    ),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Image(
                    //   image: AssetImage("assets/google_logo.png"),
                    //   height: 35.0,
                    // ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        'Sign in with Google',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
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
