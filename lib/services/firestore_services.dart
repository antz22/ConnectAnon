import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect_anon/models/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

// All services for both peers and volunteers
class FirestoreServices {
  Future<List<String>> getSchools() async {
    var firebaseSchools =
        await FirebaseFirestore.instance.collection('Schools').get();
    List<String> schools = firebaseSchools.docs
        .map((school) => school.data()['name'] as String)
        .toList();
    return schools;
  }

  Future<Profile> getProfile(userId) async {
    var userDocument = await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId.trim())
        .get();
    Profile profile = Profile.fromFirestore(userDocument);
    return profile;
  }

  Future<String> reportUser(currentUserId, peerId, topic, description) async {
    // might have to only do this after manual review

    var userDocument = await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUserId.trim())
        .get();
    Map<String, dynamic> userData = userDocument.data()!;
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    String lastReportedAt = userData['lastReportedAt'];
    if (lastReportedAt != '') {
      DateTime lastReportedTimeAt =
          DateTime.fromMillisecondsSinceEpoch(int.parse(lastReportedAt));
      DateTime currentDateTime = DateTime.now();
      var difference =
          currentDateTime.difference(lastReportedTimeAt).inMilliseconds;
      // it's been less than an 1 hour
      if (difference <= 3600000) {
        return 'Error';
      }
    }
    // user hasn't reported anyone before
    var peerDocument = await FirebaseFirestore.instance
        .collection('Users')
        .doc(peerId.trim())
        .get();
    Map<String, dynamic> peerData = peerDocument.data()!;

    // add 1 to reports - you are about to report them the third time
    if ((peerData['reports'] + 1) % 3 == 0 && peerData['isBanned'] == false) {
      FirebaseFirestore.instance.collection('Users').doc(peerId).update({
        'isBanned': true,
        'bannedSince': timestamp,
        'reports': FieldValue.increment(1),
      });
      print('ahhh');
    } else {
      FirebaseFirestore.instance.collection('Users').doc(peerId).update({
        'reports': FieldValue.increment(1),
      });
      print('ahhh2');
      print(peerData);
      print(peerData['reports']);
      print(peerData['isBanned']);
    }

    FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUserId.trim())
        .update({
      'lastReportedAt': timestamp,
    });

    var reports = await FirebaseFirestore.instance.collection('Reports');

    await reports.add({
      'reportedBy': currentUserId,
      'reportedOn': peerId,
      'timestamp': timestamp,
      'reviewed': false,
      'topic': topic,
      'description': description,
    }).catchError((error) => error);

    return 'Success';
  }

  Future<String> blockUser(currentUserId, peerId, groupId) async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUserId)
        .update({
      'blocked': FieldValue.arrayUnion([peerId]),
    });

    try {
      FirebaseFirestore.instance.collection('Groups').doc(groupId).delete();

      FirebaseFirestore.instance.collection('Users').doc(peerId).update({
        'groups': FieldValue.arrayRemove([groupId]),
      });

      FirebaseFirestore.instance.collection('Users').doc(currentUserId).update({
        'groups': FieldValue.arrayRemove([groupId]),
      });
      // this won't work...
      // FirebaseFirestore.instance.collection('Messages').doc(groupId).delete();
    } catch (e) {
      print(e);
      return e.toString();
    }

    return 'Success';
  }

  Future<String> archiveConversation(currentUserId, peerId, groupId) async {
    try {
      FirebaseFirestore.instance.collection('Groups').doc(groupId).delete();

      FirebaseFirestore.instance.collection('Users').doc(peerId).update({
        'groups': FieldValue.arrayRemove([groupId]),
        'chattedWith': FieldValue.arrayRemove([currentUserId]),
      });

      FirebaseFirestore.instance.collection('Users').doc(currentUserId).update({
        'groups': FieldValue.arrayRemove([groupId]),
        'chattedWith': FieldValue.arrayRemove([peerId]),
      });

      // this won't work...
      // FirebaseFirestore.instance.collection('Messages').doc(groupId).delete();
    } catch (e) {
      print(e);
      return e.toString();
    }

    return 'Success';
  }

  Future<String> joinChatRoom(currentUserId, chatRoomId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? currentUserName = await prefs.getString('alias');
    String? currentUserPhotoUrl = await prefs.getString('photoUrl');

    FirebaseFirestore.instance.collection('Users').doc(currentUserId).update({
      'chatRooms': FieldValue.arrayUnion([chatRoomId]),
    });

    FirebaseFirestore.instance.collection('ChatRooms').doc(chatRoomId).update({
      'members': FieldValue.arrayUnion([currentUserId]),
      'memberNames': FieldValue.arrayUnion([currentUserName]),
      'memberPhotoUrls': FieldValue.arrayUnion([currentUserPhotoUrl]),
    });

    return 'Success';
  }

  Future<String> leaveChatRoom(currentUserId, chatRoomId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? currentUserName = await prefs.getString('alias');
    String? currentUserPhotoUrl = await prefs.getString('photoUrl');

    await FirebaseFirestore.instance
        .collection('ChatRooms')
        .doc(chatRoomId)
        .update({
      'members': FieldValue.arrayRemove([currentUserId]),
      'memberNames': FieldValue.arrayRemove([currentUserName]),
      'memberPhotoUrls': FieldValue.arrayRemove([currentUserPhotoUrl]),
    });

    FirebaseFirestore.instance.collection('Users').doc(currentUserId).update({
      'chatRooms': FieldValue.arrayRemove([chatRoomId]),
    });

    return 'Success';
  }

  Future<String> createChatRoom(currentUserId, name, description) async {
    var chatRooms =
        await FirebaseFirestore.instance.collection('ChatRoomRequests');
    var status = '';
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? currentUserName = await prefs.getString('alias');
    String? currentUserPhotoUrl = await prefs.getString('photoUrl');

    await chatRooms.add({
      'members': [currentUserId],
      'memberNames': [currentUserName],
      'memberPhotoUrls': [currentUserPhotoUrl],
      'name': name,
      'description': description,
      'lastMessage': 'New Discussion - Say Hi!',
      'lastTimestamp': timestamp,
      'lastUpdatedById': currentUserId,
      'lastUpdatedByName': currentUserName,
      'createdAt': timestamp,
      'createdBy': currentUserId,
    }).then((doc) {
      String roomId = doc.id;

      FirebaseFirestore.instance.collection('Users').doc(currentUserId).update({
        'chatRooms': FieldValue.arrayUnion([roomId]),
      });

      status = 'Success';
    }).catchError((err) {
      print('Error creating group: $err');
      status = err;
    });
    return status;
  }

  // ************ PEER SERVICES ***************** //
  Future<String> createGroup(String currentUserId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? alias = await prefs.getString('alias');
    String? photoUrl = await prefs.getString('photoUrl');
    var users = await FirebaseFirestore.instance.collection('Users');
    List<String> userIds = new List.from([]);
    List<String> allIds = new List.from([]);
    var userDocument = await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUserId.trim())
        .get();
    Map<String, dynamic>? userData = userDocument.data();
    List<dynamic> chattedWith = userData?['chattedWith'];
    List<dynamic> blocked = userData?['blocked'];
    String lastPeerConnectedAt = userData?['lastPeerConnectedAt'];
    String school = userData?['school'];
    int peerConnects = userData?['peerConnects'];
    bool keepHistory = false;
    var status;
    if (lastPeerConnectedAt != '') {
      DateTime lastPeerConnectedTimeAt =
          DateTime.fromMillisecondsSinceEpoch(int.parse(lastPeerConnectedAt));
      DateTime currentDateTime = DateTime.now();
      var difference =
          currentDateTime.difference(lastPeerConnectedTimeAt).inMilliseconds;
      // it's been less than an 1 hour, has reported % 3 times
      // if (difference <= 3600000 || totalRequests % 3 == 0) {
      if (difference <= 3600000 && peerConnects % 1 != 0) {
        return 'Peer Connect cool down (1 hour)';
      }
    }
    await users
        .where('role', isEqualTo: 'Peer')
        .get()
        .then((QuerySnapshot snapshot) async {
      snapshot.docs.forEach((DocumentSnapshot<dynamic> doc) {
        String id = doc.id;
        Map<String, dynamic>? data = doc.data();
        String otherSchool = data?['name'];

        allIds.add(id);
        if (id != currentUserId &&
            !chattedWith.contains(id) &&
            !blocked.contains(id) &&
            school == otherSchool) {
          userIds.add(id);
        }
      });

      Random rng = new Random();
      int randomNum;
      String randomId;

      if (userIds.isEmpty) {
        // don't really want to be doing this i think - if it grows large enough
        // refresh history and stuff
        // randomNum = rng.nextInt(allIds.length);
        // randomId = allIds[randomNum];
        // keepHistory = false;
        status = 'No more users left';
      } else {
        randomNum = rng.nextInt(userIds.length);
        randomId = userIds[randomNum];
        keepHistory = true;

        var randomUserDocument = await FirebaseFirestore.instance
            .collection('Users')
            .doc(randomId.trim())
            .get();
        Map<String, dynamic>? randomUserData = randomUserDocument.data();
        String randomName = randomUserData!['alias'];
        String randomPhotoUrl = randomUserData['photoUrl'];

        var groups = await FirebaseFirestore.instance.collection('Groups');

        String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

        groups.add({
          'members': [currentUserId, randomId],
          'memberNames': [alias, randomName],
          'memberPhotoUrls': [photoUrl, randomPhotoUrl],
          'lastMessage': 'New Conversation - Say Hi!',
          'lastTimestamp': timestamp,
          'lastUpdatedBy': currentUserId,
          'createdAt': timestamp,
          'createdBy': currentUserId,
          'type': 'Peer-Peer',
        }).then((doc) {
          String groupId = doc.id;

          FirebaseFirestore.instance
              .collection('Users')
              .doc(currentUserId)
              .update({
            'groups': FieldValue.arrayUnion([groupId]),
            'chattedWith':
                keepHistory ? FieldValue.arrayUnion([randomId]) : [randomId],
            'lastPeerConnectedAt':
                DateTime.now().millisecondsSinceEpoch.toString(),
            'peerConnects': FieldValue.increment(1),
          });

          FirebaseFirestore.instance.collection('Users').doc(randomId).update({
            'groups': FieldValue.arrayUnion([groupId]),
            'chattedWith': FieldValue.arrayUnion([currentUserId]),
            'lastPeerConnectedAt':
                DateTime.now().millisecondsSinceEpoch.toString(),
          });

          status = 'Success';
          return 'Success';
        }).catchError((err) {
          print('Error creating group: $err');
          status = err;
          return err;
        });
        status = 'Success';
      }
    }).catchError((err) {
      print('Error creating group: $err');
      status = err;
      return err;
    });

    if (status == 'Success' && keepHistory) {
      return 'Success';
    } else if (status == 'Success' && !keepHistory) {
      // maybe make this instead just throw an error and not make the conversation - users should archive convos anyway.
      return 'Clearing peer conversation history - no more new users left! You might get a duplicate conversation.';
    } else {
      return status;
    }
  }

  // ************ VOLUNTEER SERVICES ***************** //

  // ************ CHAT SERVICES ********************** //

  Future<String> sendPeerMessage(
      String content, String? idFrom, String? idTo, String groupChatId) async {
    try {
      var messagesReference = FirebaseFirestore.instance
          .collection('Messages')
          .doc(groupChatId.trim())
          .collection('messages');

      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

      messagesReference.add({
        'idFrom': idFrom,
        'idTo': idTo,
        'timestamp': timestamp,
        'content': content,
      });

      var groupReference = FirebaseFirestore.instance
          .collection('Groups')
          .doc(groupChatId.trim());

      groupReference.update({
        'lastMessage': content,
        'lastTimestamp': timestamp,
        'lastUpdatedById': idFrom,
      });
    } catch (e) {
      print(e);
      return e.toString();
    }
    return 'Success';
  }

  Future<String> sendChatRoomMessage(String content, String? idFrom,
      String? nameFrom, String? photoUrlFrom, String chatRoomId) async {
    try {
      var messagesReference = FirebaseFirestore.instance
          .collection('ChatRoomMessages')
          .doc(chatRoomId.trim())
          .collection('messages');

      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

      messagesReference.add({
        'idFrom': idFrom,
        'nameFrom': nameFrom,
        'timestamp': timestamp,
        'content': content,
        'photoUrlFrom': photoUrlFrom,
      });

      var chatRoomReference = FirebaseFirestore.instance
          .collection('ChatRooms')
          .doc(chatRoomId.trim());

      chatRoomReference.update({
        'lastMessage': content,
        'lastTimestamp': timestamp,
        'lastUpdatedById': idFrom,
        'lastUpdatedByName': nameFrom,
      });
    } catch (e) {
      print(e);
      return e.toString();
    }
    return 'Success';
  }
}
