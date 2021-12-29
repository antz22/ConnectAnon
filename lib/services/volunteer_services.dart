import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VolunteerServices {
  Future<String> requestVolunteer(String currentUserId) async {
    var users = await FirebaseFirestore.instance.collection('Users');
    List<String> userIds = new List.from([]);
    List<String> allIds = new List.from([]);
    List<String> acceptingIds = new List.from([]);
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
      // it's been less than an 1 hour, has requested % 3 times
      // if (difference <= 3600000 || totalRequests % 3 == 0) {
      if (difference <= 3600000 && totalRequests % 3 == 0) {
        return 'Volunteer Request cool down (1 hour)';
      }
    }
    await users
        .where('role', isEqualTo: 'Chat Buddy')
        .get()
        .then((QuerySnapshot snapshot) async {
      snapshot.docs.forEach((DocumentSnapshot doc) {
        allIds.add(doc.id);
        String id = doc.id;
        bool isAccepting = doc.get('isAccepting');
        if (isAccepting) {
          acceptingIds.add(id);
        }
        if (id != currentUserId &&
            !volunteersChattedWith.contains(id) &&
            !blocked.contains(id) &&
            !requestedIds.contains(id) &&
            isAccepting) {
          userIds.add(id);
        }
      });

      Random rng = new Random();
      String randomId;
      int randomNum;
      bool keepHistory;
      bool addHistory;

      if (userIds.isEmpty) {
        // will disregard history
        if (acceptingIds.isEmpty) {
          randomNum = rng.nextInt(allIds.length);
          randomId = allIds[randomNum];
          keepHistory = false;
          addHistory = false;
        } else {
          randomNum = rng.nextInt(acceptingIds.length);
          randomId = acceptingIds[randomNum];
          keepHistory = true;
          addHistory = false;
        }
      } else {
        randomNum = rng.nextInt(userIds.length);
        randomId = userIds[randomNum];
        keepHistory = true;
        addHistory = true;
      }

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
        'keepHistory': keepHistory,
        'addHistory': addHistory,
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
    }).catchError((err) {
      print('Error processing request: $err');
      status = err.toString();
      return err;
    });
    return status;
  }

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
        .where('role', isEqualTo: 'Chat Buddy')
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
        if (id != volunteerId && !blocked.contains(id) && isAccepting) {
          userIds.add(id);
        }
      });

      Random rng = new Random();
      String randomId;
      int randomNum;
      bool keepHistory;
      bool addHistory;

      if (userIds.isEmpty) {
        // will disregard history
        if (acceptingIds.isEmpty) {
          randomNum = rng.nextInt(allIds.length);
          randomId = allIds[randomNum];
          keepHistory = false;
          addHistory = false;
        } else {
          randomNum = rng.nextInt(acceptingIds.length);
          randomId = acceptingIds[randomNum];
          keepHistory = true;
          addHistory = false;
        }
      } else {
        randomNum = rng.nextInt(userIds.length);
        randomId = userIds[randomNum];
        keepHistory = true;
        addHistory = true;
      }

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

        if (addHistory) {
          FirebaseFirestore.instance.collection('Users').doc(peerId).update({
            'groups': FieldValue.arrayUnion([groupId]),
            // refresh history if nobody left
            'specialChattedWith':
                keepHistory ? FieldValue.arrayUnion([randomId]) : [randomId],
            // 'lastConnected': timestamp,
          });
        } else {
          FirebaseFirestore.instance.collection('Users').doc(peerId).update({
            'groups': FieldValue.arrayUnion([groupId]),
            'lastConnected': timestamp,
          });
        }

        FirebaseFirestore.instance.collection('Users').doc(randomId).update({
          'groups': FieldValue.arrayUnion([groupId]),
          'specialChattedWith': FieldValue.arrayUnion([peerId]),
          // 'lastConnected': timestamp,
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
      String peerId, bool keepHistory, bool addHistory) async {
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

      if (addHistory) {
        // keep history if still users they havent talked to
        FirebaseFirestore.instance.collection('Users').doc(peerId).update({
          'groups': FieldValue.arrayUnion([groupId]),
          'specialChattedWith': keepHistory
              ? FieldValue.arrayUnion([volunteerId])
              : [volunteerId],
          // 'lastConnected': timestamp,
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
          // 'lastConnected': timestamp,
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
}
