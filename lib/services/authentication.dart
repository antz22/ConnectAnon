import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth;

  AuthenticationService(this._firebaseAuth);

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<User?> signInWithGoogle({required BuildContext context}) async {
    User? user;

    final GoogleSignIn _googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleSignInAccount =
        await _googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      try {
        final UserCredential userCredential =
            await _firebaseAuth.signInWithCredential(credential);

        user = userCredential.user;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          ScaffoldMessenger.of(context).showSnackBar(
            AuthenticationService.customSnackBar(
              content: 'The account already exists with a different credential',
            ),
          );
        } else if (e.code == 'invalid-credential') {
          ScaffoldMessenger.of(context).showSnackBar(
            AuthenticationService.customSnackBar(
              content: 'Error occurred while accessing credentials. Try again.',
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          AuthenticationService.customSnackBar(
            content: 'Error occurred using Google Sign In. Try again.',
          ),
        );
      }

      return user;
    }
  }

  // Future<String> signIn({String email, String password}) async {
  //   try {
  //     await _firebaseAuth.signInWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );
  //     return "Signed in";
  //   } on FirebaseAuthException catch (e) {
  //     return e.message;
  //   }
  // }

  // Future<String> signUp({String email, String password}) async {
  //   try {
  //     await _firebaseAuth.createUserWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );
  //     return "Signed up";
  //   } on FirebaseAuthException catch (e) {
  //     return e.message;
  //   }
  // }

  Future<String> signOut({required BuildContext context}) async {
    final GoogleSignIn _googleSignIn = GoogleSignIn();
    try {
      await _googleSignIn.signOut();
      return "Signed out";
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        AuthenticationService.customSnackBar(
          content: 'Error signing out. Try again.',
        ),
      );
      await _firebaseAuth.signOut();
      return "Error signing out";
    }
  }

  static SnackBar customSnackBar({required String content}) {
    return SnackBar(
      backgroundColor: Colors.black,
      content: Text(
        content,
        style: TextStyle(color: Colors.redAccent, letterSpacing: 0.5),
      ),
    );
  }
}
