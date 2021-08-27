import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class APIServices {
  Future<Map<String, dynamic>> getUserData(userId) async {
    var userDocument = await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId.trim())
        .get();
    Map<String, dynamic> userData = userDocument.data()!;
    String alias = userData['alias'];
    String status = userData['status'];
    String school = userData['school'];
    String photoUrl = userData['photoUrl'];
    int peerChats = userData['chattedWith'].length;
    int chatRooms = userData['chatRooms'].length;
    int reports = userData['reports'];
    return {
      'alias': alias,
      'status': status,
      'school': school,
      'photoUrl': photoUrl,
      'peerChats': peerChats,
      'chatRooms': chatRooms,
      'reports': reports,
    };
  }

  Future<String> createGroup(String currentUserId, List chattedWith) async {
    var users = await FirebaseFirestore.instance.collection('Users');
    List<String> userIds = new List.from([]);
    var status;
    await users.get().then((QuerySnapshot snapshot) async {
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

      if (userIds.isEmpty) {
        status = 'No more available users';
      } else {
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
          print(err.runtimeType);
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

    return status;
  }

  Future<String> createSpecialGroup(
      String currentUserId, List volunteersChattedWith) async {
    var users = await FirebaseFirestore.instance.collection('Users');
    List<String> userIds = new List.from([]);
    List<String> allIds = new List.from([]);
    var status;
    await users
        .where('status', isEqualTo: 'Chat Buddy')
        .get()
        .then((QuerySnapshot snapshot) async {
      snapshot.docs.forEach((DocumentSnapshot doc) {
        allIds.add(doc.id);
        String id = doc.id;
        bool valid = true;
        if (id != currentUserId) {
          volunteersChattedWith.forEach((chattedWithId) {
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

      if (userIds.isEmpty) {
        // status = 'No more available users';
        Random rng = new Random();
        int randomNum = rng.nextInt(allIds.length);
        String randomId = allIds[randomNum];
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
            // renew the volunteers if they've already talked to all of them
            'specialChattedWith': [randomId],
          });

          FirebaseFirestore.instance.collection('Users').doc(randomId).update({
            'groups': FieldValue.arrayUnion([groupId]),
            'specialChattedWith': FieldValue.arrayUnion([currentUserId]),
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
      } else {
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
            'chattedWith': FieldValue.arrayUnion([currentUserId]),
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
      }
    }).catchError((err) {
      print('Error creating group: $err');
      status = err;
      return err;
    });
    return status;
  }

  Future<Map<String, String>> getPeerData(groupChatId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String currentUserId = prefs.getString('id')!;
    String peerId;
    String peerName;
    String peerPhotoUrl;

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
    peerPhotoUrl = userData['photoUrl'];

    return {
      'peerId': peerId,
      'peerName': peerName,
      'currentUserId': currentUserId,
      'peerPhotoUrl': peerPhotoUrl,
    };
  }

  Future<List<String>> retrieveChatRooms() async {
    var collection = await FirebaseFirestore.instance.collection('ChatRooms');
    List<String> chatRooms = new List.from([]);
    collection.get().then((QuerySnapshot snapshot) {
      snapshot.docs.forEach((DocumentSnapshot doc) {
        chatRooms.add(doc['name']);
      });
    });
    return chatRooms;
  }

  Future<String> joinChatRoom(currentUserId, chatRoomId) async {
    FirebaseFirestore.instance.collection('Users').doc(currentUserId).update({
      'chatRooms': FieldValue.arrayUnion([chatRoomId]),
    });

    FirebaseFirestore.instance.collection('ChatRooms').doc(chatRoomId).update({
      'members': FieldValue.arrayUnion([currentUserId]),
    });

    return 'Success';
  }

  Future<String> createChatRoom(currentUserId, name, description) async {
    var chatRooms = await FirebaseFirestore.instance.collection('ChatRooms');
    var status;

    chatRooms.add({
      'members': [currentUserId],
      'name': name,
      'description': description,
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

  Future<Map<String, String>> getChatRoomData(chatRoomId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String currentUserId = prefs.getString('id')!;
    String roomName;

    var document = await FirebaseFirestore.instance
        .collection('ChatRooms')
        .doc(chatRoomId)
        .get();
    Map<String, dynamic>? data = document.data();

    roomName = data?['name'];

    return {
      'roomName': roomName,
      'currentUserId': currentUserId,
    };
  }

  Future<String> reportUser(currentUserId, peerId) async {
    FirebaseFirestore.instance.collection('Users').doc(peerId).update({
      'reports': FieldValue.increment(1),
    });

    // FirebaseFirestore.instance.collection('Users').doc(currentUserId).update({
    //   'lastReported': Now,
    // });

    // FirebaseFirestore.instance.collection('Users').doc(peerId).update({
    //   'lastBeenReported': Now,
    // });

    return 'Success';
  }

  Future<String> archiveConversation(currentUserId, peerId, groupId) async {
    try {
      FirebaseFirestore.instance.collection('Users').doc(peerId).update({
        'groups': FieldValue.arrayRemove([groupId]),
      });

      FirebaseFirestore.instance.collection('Users').doc(currentUserId).update({
        'groups': FieldValue.arrayRemove([groupId]),
      });

      FirebaseFirestore.instance.collection('Groups').doc(groupId).delete();
    } catch (e) {
      print(e);
      return e.toString();
    }

    return 'Success';

    //   groups.add({
    //     'members': [currentUserId, randomId]
    //   }).then((doc) {
    //     String groupId = doc.id;

    //     FirebaseFirestore.instance.collection('Users').doc(currentUserId).update({
    //       'groups': FieldValue.arrayUnion([groupId]),
    //       'chattedWith': FieldValue.arrayUnion([randomId]),
    //     });

    //     FirebaseFirestore.instance.collection('Users').doc(randomId).update({
    //       'groups': FieldValue.arrayUnion([groupId]),
    //       'chattedWith': FieldValue.arrayUnion([currentUserId]),
    //     });

    //     status = 'Success';
    //     return 'Success';
    //   }).catchError((err) {
    //     print('Error creating group: $err');
    //     print(err.runtimeType);
    //     status = err;
    //     return err;
    //   });
    //   status = 'Success';
    // }
    return 'Success';
  }
}

// var users = await FirebaseFirestore.instance.collection('Users').get();
// var blah = users.docs.map((doc) => doc.data()).toList();
// print(blah);
