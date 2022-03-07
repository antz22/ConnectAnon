import 'package:connect_anon/services/user_provider.dart';
import 'package:connect_anon/widgets/custom_snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
          String role = userData['role'];
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
                'lastActiveAt':
                    DateTime.now().millisecondsSinceEpoch.toString(),
              });

              await prefs.setBool('isBanned', false);
              await prefs.setString('alias', alias);
              await prefs.setString('photoUrl', photoUrl);
              await prefs.setString('role', role);
              await Provider.of<UserProvider>(context, listen: false)
                  .initUser(prefs);
            }
          } else {
            // if userdoc exists and is not banned
            await prefs.setBool('isBanned', false);
            await prefs.setString('alias', alias);
            await prefs.setString('photoUrl', photoUrl);
            await prefs.setString('role', role);
            FirebaseFirestore.instance
                .collection('Users')
                .doc(user.uid.trim())
                .update({
              'lastActiveAt': DateTime.now().millisecondsSinceEpoch.toString(),
            });
            await Provider.of<UserProvider>(context, listen: false)
                .initUser(prefs);
          }
        } else {
          // if userdoc doesn't exist
          await prefs.setBool('isBanned', false);
          await Provider.of<UserProvider>(context, listen: false)
              .initUser(prefs);
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          CustomSnackbar.buildWarningMessage(context, 'Error',
              'The account already exists with a different credential');
          print(e);
        } else if (e.code == 'invalid-credential') {
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
      String alias, User? user, String photoUrl, String school) async {
    if (user != null) {
      var document = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get();
      Map<String, dynamic>? userData = document.data();
      if (userData == null) {
        // Update data to server if new user
        String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        try {
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(user.uid)
              .set({
            'uid': user.uid,
            'displayName': user.displayName,
            'alias': alias,
            'photoUrl': photoUrl,
            'groups': [],
            'chattedWith': [],
            'specialChattedWith': [],
            'blocked': [],
            'chatRooms': [],
            'school': school,
            // peer: role, 'Chat Buddy'
            'role': 'Peer',
            'reports': 0,
            'lastReportedAt': '',
            'lastRequestedAt': '',
            'lastPeerConnectedAt': '',
            'lastActiveAt': timestamp,
            'requestedIds': [],
            'totalRequests': 0,
            'peerConnects': 0,
            'bannedSince': '',
            'isBanned': false,
            // (peer only) isAccepting: (bool)
          });
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('alias', alias);
          await prefs.setString('photoUrl', photoUrl);
          await prefs.setString('role', 'Peer');
          await prefs.setBool('isBanned', false);
          return 'Success';
        } catch (e) {
          print(e.toString());
          return 'Your email domain is not verified';
        }
      } else {
        return 'You already have an account, signing in now';
      }
    }
    return 'Error';
  }

  Future<String> signOut({required BuildContext context}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isBanned');
    await prefs.remove('role');
    await prefs.remove('alias');
    await prefs.remove('photoUrl');
    await prefs.remove('id');
    final GoogleSignIn _googleSignIn = GoogleSignIn();
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
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
