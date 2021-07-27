import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class APIServices {
  Future<String> createGroup(currentUserId, chattedWith) async {
    var users = await FirebaseFirestore.instance.collection('Users');
    List<String> userIds = new List.from([]);
    users.get().then((QuerySnapshot snapshot) async {
      snapshot.docs.forEach((DocumentSnapshot doc) {
        String id = doc.id;
        bool valid = true;
        if (id != currentUserId) {
          chattedWith.forEach((chattedWithId) {
            if (chattedWithId == id) {
              valid = false;
            }
            print(chattedWithId);
          });
          if (valid) {
            userIds.add(id);
          }
        }
      });

      Random rng = new Random();
      int randomNum = rng.nextInt(userIds.length);
      String randomId = userIds[randomNum];
      print('random id: ' + randomId);

      var groups = await FirebaseFirestore.instance.collection('Groups');

      groups.add({
        'members': [currentUserId, randomId]
      }).then((doc) {
        String groupId = doc.id;

        FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUserId)
            .update({
          'groups': FieldValue.arrayUnion([groupId]),
          'chattedWith': FieldValue.arrayUnion([randomId]),
        });

        FirebaseFirestore.instance.collection('Users').doc(randomId).update({
          'groups': FieldValue.arrayUnion([groupId]),
          'chattedWith': FieldValue.arrayUnion([randomId]),
        });

        return 'Success';
      }).catchError((err) {
        print('Error creating group: $err');
        return err;
      });
    });
    return 'Error creating group';
  }

  Future<Map<String, String>> getPeerData(groupChatId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String currentUserId = prefs.getString('id')!;
    String peerId;
    String peerName;

    var document = await FirebaseFirestore.instance
        .collection('Groups')
        .doc(groupChatId)
        .get();
    Map<String, dynamic>? data = document.data();

    var memberIDs = data?['members'];
    if (memberIDs[0] == currentUserId) {
      peerId = memberIDs[1];
    } else {
      peerId = memberIDs[0];
    }

    var userDocument = await FirebaseFirestore.instance
        .collection('Users')
        .doc(peerId.trim())
        .get();
    Map<String, dynamic>? userData = userDocument.data();
    peerName = userData!['alias'];

    return {
      'peerId': peerId,
      'peerName': peerName,
      'currentUserId': currentUserId,
    };
  }
}

// var users = await FirebaseFirestore.instance.collection('Users').get();
// var blah = users.docs.map((doc) => doc.data()).toList();
// print(blah);
