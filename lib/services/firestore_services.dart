import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect_anon/models/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

// All services for both peers and volunteers
class FirestoreServices {
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

    if (peerData['reports'] + 1 % 3 == 0 && peerData['banned'] == false) {
      FirebaseFirestore.instance.collection('Users').doc(peerId).update({
        'isBanned': true,
        'bannedSince': timestamp,
        'reports': FieldValue.increment(1),
      });
    } else {
      FirebaseFirestore.instance.collection('Users').doc(peerId).update({
        'reports': FieldValue.increment(1),
      });
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
      FirebaseFirestore.instance.collection('Users').doc(peerId).update({
        'groups': FieldValue.arrayRemove([groupId]),
      });

      FirebaseFirestore.instance.collection('Users').doc(currentUserId).update({
        'groups': FieldValue.arrayRemove([groupId]),
      });

      FirebaseFirestore.instance.collection('Groups').doc(groupId).delete();
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
      FirebaseFirestore.instance.collection('Users').doc(peerId).update({
        'groups': FieldValue.arrayRemove([groupId]),
        'chattedWith': FieldValue.arrayRemove([currentUserId]),
      });

      FirebaseFirestore.instance.collection('Users').doc(currentUserId).update({
        'groups': FieldValue.arrayRemove([groupId]),
        'chattedWith': FieldValue.arrayRemove([peerId]),
      });

      FirebaseFirestore.instance.collection('Groups').doc(groupId).delete();
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

    FirebaseFirestore.instance.collection('Users').doc(currentUserId).update({
      'chatRooms': FieldValue.arrayRemove([chatRoomId]),
    });

    FirebaseFirestore.instance.collection('ChatRooms').doc(chatRoomId).update({
      'members': FieldValue.arrayRemove([currentUserId]),
      'memberNames': FieldValue.arrayRemove([currentUserName]),
      'memberPhotoUrls': FieldValue.arrayRemove([currentUserPhotoUrl]),
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
    var status;
    await users
        .where('status', isEqualTo: 'Peer')
        .get()
        .then((QuerySnapshot snapshot) async {
      snapshot.docs.forEach((DocumentSnapshot doc) {
        String id = doc.id;
        if (id != currentUserId &&
            !chattedWith.contains(id) &&
            !blocked.contains(id)) {
          userIds.add(id);
        }
      });

      Random rng = new Random();
      int randomNum;
      String randomId;
      bool keepHistory = false;

      if (userIds.isEmpty) {
        // refresh history and stuff
        randomNum = rng.nextInt(allIds.length);
        randomId = allIds[randomNum];
        keepHistory = false;
      } else {
        randomNum = rng.nextInt(userIds.length);
        randomId = userIds[randomNum];
        keepHistory = true;
      }
      print('random id: ' + randomId);

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
          'lastConnected': DateTime.now().millisecondsSinceEpoch.toString(),
        });

        FirebaseFirestore.instance.collection('Users').doc(randomId).update({
          'groups': FieldValue.arrayUnion([groupId]),
          'chattedWith': FieldValue.arrayUnion([currentUserId]),
          'lastConnected': DateTime.now().millisecondsSinceEpoch.toString(),
        });

        status = 'Success';
        return 'Success';
      }).catchError((err) {
        print('Error creating group: $err');
        status = err;
        return err;
      });
      status = 'Success';
    }).catchError((err) {
      print('Error creating group: $err');
      status = err;
      return err;
    });

    return status;
  }

  Future<String> requestVolunteer(String currentUserId) async {
    var users = await FirebaseFirestore.instance.collection('Users');
    List<String> userIds = new List.from([]);
    List<String> allIds = new List.from([]);
    var userDocument = await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUserId.trim())
        .get();
    Map<String, dynamic>? userData = userDocument.data();
    String lastRequestedAt = userData?['lastRequestedAt'];
    int totalRequests = userData?['totalRequests'];
    List<dynamic> volunteersChattedWith = userData?['specialChattedWith'];
    List<dynamic> blocked = userData?['blocked'];
    List<dynamic> requestedIds = userData?['requestedIds'];
    var status;
    if (lastRequestedAt != '') {
      DateTime lastReportedTimeAt =
          DateTime.fromMillisecondsSinceEpoch(int.parse(lastRequestedAt));
      DateTime currentDateTime = DateTime.now();
      var difference =
          currentDateTime.difference(lastReportedTimeAt).inMilliseconds;
      // it's been less than an 1 hour, has reported % 3 times
      // if (difference <= 3600000 || totalRequests % 3 == 0) {
      if (difference <= 3600000 && totalRequests % 3 == 0) {
        return 'Volunteer Request cool down (1 hour)';
      }
    }
    await users
        .where('status', isEqualTo: 'Chat Buddy')
        .get()
        .then((QuerySnapshot snapshot) async {
      snapshot.docs.forEach((DocumentSnapshot doc) {
        allIds.add(doc.id);
        String id = doc.id;
        if (id != currentUserId &&
            !volunteersChattedWith.contains(id) &&
            !blocked.contains(id) &&
            !requestedIds.contains(id)) {
          userIds.add(id);
        }
      });

      if (userIds.isEmpty) {
        status = 'No more available users';
      } else {
        Random rng = new Random();
        int randomNum = rng.nextInt(userIds.length);
        String randomId = userIds[randomNum];
        print('random id: ' + randomId);

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
          'availableUsers': userIds.isEmpty,
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
          status = err;
          return err;
        });
        status = 'Success';
      }
    }).catchError((err) {
      print('Error processing request: $err');
      status = err;
      return err;
    });
    return status;
  }

  // ************ VOLUNTEER SERVICES ***************** //

  Future<String> changeRequestStatus(
      String volunteerId, String status, bool isAccepting) async {
    if ((status == 'Not Accepting' && isAccepting == true) ||
        (status == 'Accepting' && isAccepting == false)) {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(volunteerId.trim())
          .update({
        'isAccepting': !isAccepting,
      });
      return 'Success';
    } else {
      return 'Same status';
    }
  }

  Future<String> referNewVolunteer(String peerId, String volunteerId) async {
    var users = await FirebaseFirestore.instance.collection('Users');
    List<String> userIds = new List.from([]);
    List<String> allIds = new List.from([]);
    List<String> acceptingIds = new List.from([]);
    var userDocument = await FirebaseFirestore.instance
        .collection('Users')
        .doc(peerId.trim())
        .get();
    Map<String, dynamic>? userData = userDocument.data();
    List<dynamic> blocked = userData?['blocked'];
    String peerName = userData?['alias'];
    String peerPhotoUrl = userData?['photoUrl'];

    var status;
    await users
        .where('status', isEqualTo: 'Chat Buddy')
        .get()
        .then((QuerySnapshot snapshot) async {
      snapshot.docs.forEach((DocumentSnapshot doc) {
        String id = doc.id;
        allIds.add(id);
        bool isAccepting = doc.get('isAccepting');
        if (isAccepting) {
          acceptingIds.add(id);
        }
        // won't be considering volunteers chatted with
        if (id != volunteerId &&
            !blocked.contains(id) &&
            doc.get('isAccepting') == true) {
          userIds.add(id);
        }
      });

      Random rng = new Random();
      String randomId;
      int randomNum;
      bool keepHistory;

      if (userIds.isEmpty) {
        // will disregard history
        if (acceptingIds.isEmpty) {
          randomNum = rng.nextInt(allIds.length);
          randomId = allIds[randomNum];
          keepHistory = false;
        } else {
          randomNum = rng.nextInt(acceptingIds.length);
          randomId = acceptingIds[randomNum];
          keepHistory = false;
        }
      } else {
        randomNum = rng.nextInt(userIds.length);
        randomId = userIds[randomNum];
        keepHistory = true;
      }
      print('random id: ' + randomId);

      var groups = await FirebaseFirestore.instance.collection('Groups');

      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

      var randomUserDocument = await FirebaseFirestore.instance
          .collection('Users')
          .doc(randomId.trim())
          .get();
      Map<String, dynamic>? randomUserData = randomUserDocument.data();
      String randomName = randomUserData!['alias'];
      String randomPhotoUrl = randomUserData['photoUrl'];

      groups.add({
        'members': [peerId, randomId],
        'memberNames': [peerName, randomName],
        'memberPhotoUrls': [peerPhotoUrl, randomPhotoUrl],
        'lastMessage': 'New Conversation - Say Hi!',
        'lastTimestamp': timestamp,
        'lastUpdatedBy': peerId,
        'createdAt': timestamp,
        'createdBy': peerId,
        'type': 'Peer-Volunteer',
      }).then((doc) {
        String groupId = doc.id;

        FirebaseFirestore.instance.collection('Users').doc(peerId).update({
          'groups': FieldValue.arrayUnion([groupId]),
          // refresh history if nobody left
          'specialChattedWith':
              keepHistory ? FieldValue.arrayUnion([randomId]) : [randomId],
          'lastConnected': timestamp,
        });

        FirebaseFirestore.instance.collection('Users').doc(randomId).update({
          'groups': FieldValue.arrayUnion([groupId]),
          'specialChattedWith': FieldValue.arrayUnion([peerId]),
          'lastConnected': timestamp,
        });

        status = 'Success';
        return 'Success';
      }).catchError((err) {
        print('Error creating group: $err');
        print(err.runtimeType);
        status = err;
        return err;
      });
      status = 'Success';
    }).catchError((err) {
      print('Error creating group: $err');
      status = err;
      return err;
    });
    return status;
  }

  Future<String> grantPeerRequest(String volunteerId, String requestId,
      String peerId, bool availableUsers) async {
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
      'members': [peerId, volunteerId],
      'memberNames': [peerName, alias],
      'memberPhotoUrls': [peerPhotoUrl, photoUrl],
      'lastMessage': 'New Conversation - Hi!',
      'lastTimestamp': timestamp,
      'lastUpdatedBy': volunteerId,
      'createdAt': timestamp,
      'createdBy': peerId,
      'type': 'Peer-Volunteer',
    }).then((doc) async {
      String groupId = doc.id;

      if (availableUsers) {
        // keep history if still users they havent talked to
        FirebaseFirestore.instance.collection('Users').doc(peerId).update({
          'groups': FieldValue.arrayUnion([groupId]),
          'specialChattedWith': FieldValue.arrayUnion([volunteerId]),
          'lastConnected': timestamp,
          'requestedIds': FieldValue.arrayRemove([volunteerId]),
        });
        FirebaseFirestore.instance.collection('Users').doc(volunteerId).update({
          'groups': FieldValue.arrayUnion([groupId]),
          'specialChattedWith': FieldValue.arrayUnion([peerId]),
          'lastConnected': timestamp,
        });
      } else {
        FirebaseFirestore.instance.collection('Users').doc(peerId).update({
          'groups': FieldValue.arrayUnion([groupId]),
          'specialChattedWith': [volunteerId],
          'lastConnected': timestamp,
          'requestedIds': FieldValue.arrayRemove([volunteerId]),
        });
        FirebaseFirestore.instance.collection('Users').doc(volunteerId).update({
          'groups': FieldValue.arrayUnion([groupId]),
          // doesn't really matter for the volunteer
          // 'specialChattedWith': FieldValue.arrayUnion([peerId]),
          'lastConnected': timestamp,
        });
      }

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
    status = 'Success';

    return status;
  }

  Future<String> declineRequest(String requestId) async {
    await FirebaseFirestore.instance
        .collection('Requests')
        .doc(requestId)
        .delete();
    return 'Success';
  }

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