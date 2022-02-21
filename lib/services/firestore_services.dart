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
      'lastActiveAt': timestamp,
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
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUserId)
        .update({
      'blocked': FieldValue.arrayUnion([peerId]),
      'lastActiveAt': timestamp,
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
        'lastActiveAt': DateTime.now().millisecondsSinceEpoch.toString(),
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
      'lastActiveAt': DateTime.now().millisecondsSinceEpoch.toString(),
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
      'lastActiveAt': DateTime.now().millisecondsSinceEpoch.toString(),
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
      // String roomId = doc.id;

      // FirebaseFirestore.instance.collection('Users').doc(currentUserId).update({
      //   'chatRooms': FieldValue.arrayUnion([roomId]),
      // });

      status = 'Success';
    }).catchError((err) {
      print('Error creating group: $err');
      status = err;
    });
    return status;
  }

  // ************ PEER SERVICES ***************** //

  // ==WORK IN PROGRESS==

  Future<String> requestPeer(String currentUserId) async {
    // initialize lists for user IDs to select from to request a chat iwth
    List<String> userIds = new List.from([]);
    List<String> allIds = new List.from([]);
    // obtain current user info
    var users = await FirebaseFirestore.instance.collection('Users');
    var userDocument = await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUserId.trim())
        .get();
    Map<String, dynamic>? userData = userDocument.data();
    List<dynamic> chattedWith = userData?['chattedWith'];
    List<dynamic> blocked = userData?['blocked'];
    String lastRequestedAt = userData?['lastRequestedAt'];
    int totalRequests = userData?['totalRequests'];
    String school = userData?['school'];
    List<dynamic> requestedIds = userData?['requestedIds'];
    var status;
    if (lastRequestedAt != '') {
      DateTime lastReportedTimeAt =
          DateTime.fromMillisecondsSinceEpoch(int.parse(lastRequestedAt));
      DateTime currentDateTime = DateTime.now();
      var difference =
          currentDateTime.difference(lastReportedTimeAt).inMilliseconds;
      // it's been less than an 1 hour, has requested % 3 times
      // if (difference <= 3600000 || totalRequests % 3 == 0) {
      if (difference <= 3600000 && totalRequests % 3 == 0) {
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
        String otherSchool = data?['school'];
        String lastLoggedInAt = data?['lastActiveAt'];
        bool otherIsBanned = data?['isBanned'];
        String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        int timeDiff = int.parse(timestamp) - int.parse(lastLoggedInAt);

        if (id != currentUserId &&
            !chattedWith.contains(id) &&
            !blocked.contains(id) &&
            !requestedIds.contains(id) &&
            school == otherSchool &&
            timeDiff <= 7200000 &&
            otherIsBanned == false) {
          userIds.add(id);
        } else if (id != currentUserId &&
            !chattedWith.contains(id) &&
            !blocked.contains(id) &&
            !requestedIds.contains(id) &&
            school == otherSchool &&
            otherIsBanned == false) {
          allIds.add(id);
        }
      });

      Random rng = new Random();
      int randomNum;
      String randomId;

      if (userIds.isEmpty && allIds.isEmpty) {
        status = 'No more users left';
      } else {
        // if there are active users, choose them
        // if there are no active users available, choose inactive users
        randomNum = userIds.isEmpty
            ? rng.nextInt(allIds.length)
            : rng.nextInt(userIds.length);
        randomId = userIds.isEmpty ? allIds[randomNum] : userIds[randomNum];

        var requests = await FirebaseFirestore.instance.collection('Requests');

        String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? photoUrl = await prefs.getString('photoUrl');
        String? currentUserName = await prefs.getString('alias');

        requests.add({
          'peer': currentUserId,
          'peerPhotoUrl': photoUrl,
          'volunteer': randomId,
          'peerName': currentUserName,
          'timestamp': timestamp,
        }).then((doc) async {
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(currentUserId)
              .update({
            'lastRequestedAt': timestamp,
            'totalRequests': FieldValue.increment(1),
            'requestedIds': FieldValue.arrayUnion([randomId]),
          });
          status = 'Success';
          return 'Success';
        }).catchError((err) {
          print('Error processing request: $err');
          status = err.toString();
          return err.toString();
        });
        status = 'Success';
      }
    }).catchError((err) {
      print('Error processing request: $err');
      status = err.toString();
      return err;
    });

    if (status == 'Success') {
      return 'Success';
    } else {
      return status;
    }
  }

  Future<String> grantPeerRequest(
      String userId, String requestId, String peerId) async {
    var status;

    var peerUserDocument = await FirebaseFirestore.instance
        .collection('Users')
        .doc(peerId.trim())
        .get();
    Map<String, dynamic>? peerUserData = peerUserDocument.data();
    String peerName = peerUserData!['alias'];
    String peerPhotoUrl = peerUserData['photoUrl'];

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? alias = await prefs.getString('alias');
    String? photoUrl = await prefs.getString('photoUrl');

    var groups = await FirebaseFirestore.instance.collection('Groups');

    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

    groups.add({
      'members': [peerId, userId],
      'memberNames': [peerName, alias],
      'memberPhotoUrls': [peerPhotoUrl, photoUrl],
      'lastMessage': 'New Conversation - Hi!',
      'lastTimestamp': timestamp,
      'lastUpdatedBy': userId,
      'createdAt': timestamp,
      'createdBy': peerId,
      'type': 'Peer-Peer',
    }).then((doc) async {
      String groupId = doc.id;

      FirebaseFirestore.instance.collection('Users').doc(peerId).update({
        'groups': FieldValue.arrayUnion([groupId]),
        'requestedIds': FieldValue.arrayRemove([userId]),
        'chattedWith': FieldValue.arrayUnion([userId]),
        'lastPeerConnectedAt': timestamp,
      });
      FirebaseFirestore.instance.collection('Users').doc(userId).update({
        'groups': FieldValue.arrayUnion([groupId]),
        'chattedWith': FieldValue.arrayUnion([userId]),
        'lastPeerConnectedAt': timestamp,
        'peerConnects': FieldValue.increment(1),
        'lastActiveAt': timestamp,
      });

      await FirebaseFirestore.instance
          .collection('Requests')
          .doc(requestId)
          .delete();

      status = 'Success';
      return 'Success';
    }).catchError((err) {
      print('Error creating group: $err');
      status = err;
      return err;
    });

    return status;
  }

  Future<String> declineRequest(String requestId) async {
    await FirebaseFirestore.instance
        .collection('Requests')
        .doc(requestId)
        .delete();
    return 'Success';
  }

  // =====================

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
    // bool keepHistory = false;
    var status;
    if (lastPeerConnectedAt != '') {
      DateTime lastPeerConnectedTimeAt =
          DateTime.fromMillisecondsSinceEpoch(int.parse(lastPeerConnectedAt));
      DateTime currentDateTime = DateTime.now();
      var difference =
          currentDateTime.difference(lastPeerConnectedTimeAt).inMilliseconds;
      // it's been less than an 1 hour, has reported % 3 times
      // if (difference <= 3600000 || totalRequests % 3 == 0) {
      if (difference <= 3600000 && peerConnects % 3 == 0) {
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
        String otherSchool = data?['school'];
        String lastLoggedInAt = data?['lastActiveAt'];
        bool otherIsBanned = data?['isBanned'];
        String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        int timeDiff = int.parse(timestamp) - int.parse(lastLoggedInAt);

        if (id != currentUserId &&
            !chattedWith.contains(id) &&
            !blocked.contains(id) &&
            school == otherSchool &&
            timeDiff <= 7200000 &&
            otherIsBanned == false) {
          userIds.add(id);
        } else if (id != currentUserId &&
            !chattedWith.contains(id) &&
            !blocked.contains(id) &&
            school == otherSchool &&
            otherIsBanned == false) {
          allIds.add(id);
        }
      });

      Random rng = new Random();
      int randomNum;
      String randomId;

      if (userIds.isEmpty && allIds.isEmpty) {
        status = 'No more users left';
      } else {
        // if there are active users, choose them
        // if there are no active users available, choose inactive users
        randomNum = userIds.isEmpty
            ? rng.nextInt(allIds.length)
            : rng.nextInt(userIds.length);
        randomId = userIds.isEmpty ? allIds[randomNum] : userIds[randomNum];

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
            'chattedWith': FieldValue.arrayUnion([randomId]),
            'lastPeerConnectedAt': timestamp,
            'peerConnects': FieldValue.increment(1),
            'lastActiveAt': timestamp,
          });

          FirebaseFirestore.instance.collection('Users').doc(randomId).update({
            'groups': FieldValue.arrayUnion([groupId]),
            'chattedWith': FieldValue.arrayUnion([currentUserId]),
            'lastPeerConnectedAt': timestamp,
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

    if (status == 'Success') {
      return 'Success';
      // } else if (status == 'Success' && !keepHistory) {
      //   // maybe make this instead just throw an error and not make the conversation - users should archive convos anyway.
      //   return 'Clearing peer conversation history - no more new users left! You might get a duplicate conversation.';
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

      FirebaseFirestore.instance.collection('Users').doc(idFrom).update({
        'lastActiveAt': DateTime.now().millisecondsSinceEpoch.toString(),
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
