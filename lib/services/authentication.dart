import 'package:connect_anon/widgets/custom_snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

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

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('id', user!.uid);

        var userDocument = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid.trim())
            .get();

        if (userDocument.exists) {
          Map<String, dynamic> userData = userDocument.data()!;
          String alias = userData['alias'];
          String photoUrl = userData['photoUrl'];
          bool isBanned = userData['isBanned'];
          String bannedSince = userData['bannedSince'];
          String status = userData['status'];
          if (isBanned) {
            DateTime lastDateTime =
                DateTime.fromMillisecondsSinceEpoch(int.parse(bannedSince));
            DateTime currentDateTime = DateTime.now();
            var difference =
                currentDateTime.difference(lastDateTime).inMilliseconds;
            // it's been less than 3 days
            if (difference <= 259200000) {
              CustomSnackbar.buildWarningMessage(context, 'Warning',
                  'Unfortunately, you have been temporarily banned (3 days) due to reports filed against you.');
              await prefs.setBool('isBanned', true);
            } else {
              // relieve them from the ban if it's been over 3 days
              FirebaseFirestore.instance
                  .collection('Users')
                  .doc(user.uid.trim())
                  .update({
                'isBanned': false,
              });

              await prefs.setBool('isBanned', false);
              await prefs.setString('alias', alias);
              await prefs.setString('photoUrl', photoUrl);
              await prefs.setString('status', status);
            }
          } else {
            await prefs.setString('alias', alias);
            await prefs.setString('photoUrl', photoUrl);
            await prefs.setString('status', status);
          }
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   AuthenticationService.customSnackBar(
          //     content: 'The account already exists with a different credential',
          //   ),
          // );
          CustomSnackbar.buildWarningMessage(context, 'Error',
              'The account already exists with a different credential');
          print(e);
        } else if (e.code == 'invalid-credential') {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   AuthenticationService.customSnackBar(
          //     content: 'Error occurred while accessing credentials. Try again.',
          //   ),
          // );
          CustomSnackbar.buildWarningMessage(context, 'Error',
              'Error occurred while accessing credentials. Try again.');
          print(e);
        }
      } catch (e) {
        CustomSnackbar.buildWarningMessage(context, 'Error',
            'Error occurred using Google Sign In. Try again.');
        print(e);
      }
      return user;
    }
  }

  Future<String> updateUserInfo(
      String alias, User? user, String photoUrl) async {
    if (user != null) {
      var document = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get();
      Map<String, dynamic>? userData = document.data();
      if (userData == null) {
        // Update data to server if new user
        FirebaseFirestore.instance.collection('Users').doc(user.uid).set({
          'uid': user.uid,
          'displayName': user.displayName,
          'alias': alias,
          'photoUrl': photoUrl,
          'groups': [],
          'chattedWith': [],
          'specialChattedWith': [],
          'blocked': [],
          'chatRooms': [],
          'school': 'MHS',
          'status': 'Peer',
          'reports': 0,
          'lastReportedAt': '',
          'bannedSince': '',
          'isBanned': false,
        });
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('alias', alias);
        await prefs.setString('photoUrl', photoUrl);
        await prefs.setString('status', 'Peer');
        return 'Success';
      } else {
        return 'You already have an account, signing in now';
      }
    }
    return 'Error';
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
