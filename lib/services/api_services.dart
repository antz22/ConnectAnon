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

  Future<String> createGroup(
      String currentUserId, List chattedWith, List blocked) async {
    var users = await FirebaseFirestore.instance.collection('Users');
    List<String> userIds = new List.from([]);
    var status;
    await users
        .where('status', isEqualTo: 'Peer')
        .get()
        .then((QuerySnapshot snapshot) async {
      snapshot.docs.forEach((DocumentSnapshot doc) {
        String id = doc.id;
        if (id != currentUserId) {
          if (!chattedWith.contains(id)) {
            if (!blocked.contains(id)) {
              userIds.add(id);
            }
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

        String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

        groups.add({
          'members': [currentUserId, randomId],
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

  Future<String> grantPeerRequest(String volunteerId, String requestId,
      String peerId, bool availableUsers) async {
    var status;

    var groups = await FirebaseFirestore.instance.collection('Groups');

    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

    groups.add({
      'members': [peerId, volunteerId],
      'lastMessage': 'New Conversation - Hi!',
      'lastTimestamp': timestamp,
      'lastUpdatedBy': volunteerId,
      'createdAt': timestamp,
      'createdBy': peerId,
      'type': 'Peer-Volunteer',
    }).then((doc) async {
      String groupId = doc.id;

      if (availableUsers) {
        FirebaseFirestore.instance.collection('Users').doc(peerId).update({
          'groups': FieldValue.arrayUnion([groupId]),
          // renew the volunteers if they've already talked to all of them
          // FIX THISSSSSSS
          'specialChattedWith': FieldValue.arrayUnion([volunteerId]),
          'lastConnected': timestamp,
        });
        FirebaseFirestore.instance.collection('Users').doc(volunteerId).update({
          'groups': FieldValue.arrayUnion([groupId]),
          'specialChattedWith': FieldValue.arrayUnion([peerId]),
          'lastConnected': timestamp,
        });
      } else {
        FirebaseFirestore.instance.collection('Users').doc(peerId).update({
          'groups': FieldValue.arrayUnion([groupId]),
          // renew the volunteers if they've already talked to all of them
          // FIX THISSSSSSS
          'specialChattedWith': [volunteerId],
          'lastConnected': timestamp,
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
      print(err.runtimeType);
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

  Future<String> requestVolunteer(
      String currentUserId, List volunteersChattedWith, List blocked) async {
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
    if (lastRequestedAt != '') {
      DateTime lastReportedTimeAt =
          DateTime.fromMillisecondsSinceEpoch(int.parse(lastRequestedAt));
      DateTime currentDateTime = DateTime.now();
      var difference =
          currentDateTime.difference(lastReportedTimeAt).inMilliseconds;
      // it's been over an 1 hour
      if (difference > 3600000 || totalRequests % 3 != 0) {
        var status;
        await users
            .where('status', isEqualTo: 'Chat Buddy')
            .get()
            .then((QuerySnapshot snapshot) async {
          snapshot.docs.forEach((DocumentSnapshot doc) {
            allIds.add(doc.id);
            String id = doc.id;
            if (id != currentUserId) {
              if (!volunteersChattedWith.contains(id)) {
                if (!blocked.contains(id)) {
                  userIds.add(id);
                }
              }
            }
          });

          // if (userIds.isEmpty) {
          // status = 'No more available users';
          Random rng = new Random();
          int randomNum = rng.nextInt(allIds.length);
          String randomId = allIds[randomNum];
          print('random id: ' + randomId);

          var requests =
              await FirebaseFirestore.instance.collection('Requests');

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
            });
            status = 'Success';
            return 'Success';
          }).catchError((err) {
            print('Error processing request: $err');
            print(err.runtimeType);
            status = err;
            return err;
          });
          status = 'Success';
          // } else {
          // }
        }).catchError((err) {
          print('Error processing request: $err');
          status = err;
          return err;
        });
        return status;
      } else {
        return 'Volunteer Request cool down (1 hour)';
      }
    } else {
      var status;
      await users
          .where('status', isEqualTo: 'Chat Buddy')
          .get()
          .then((QuerySnapshot snapshot) async {
        snapshot.docs.forEach((DocumentSnapshot doc) {
          allIds.add(doc.id);
          String id = doc.id;
          if (id != currentUserId) {
            if (!volunteersChattedWith.contains(id)) {
              if (!blocked.contains(id)) {
                userIds.add(id);
              }
            }
          }
        });

        // if (userIds.isEmpty) {
        // status = 'No more available users';
        Random rng = new Random();
        int randomNum = rng.nextInt(allIds.length);
        String randomId = allIds[randomNum];
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
          });
          status = 'Success';
          return 'Success';
        }).catchError((err) {
          print('Error processing request: $err');
          print(err.runtimeType);
          status = err;
          return err;
        });
        status = 'Success';
        // } else {
        // }
      }).catchError((err) {
        print('Error processing request: $err');
        status = err;
        return err;
      });
      return status;
    }
  }

  Future<String> referNewVolunteer(String peerId) async {
    // EDIT THISSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS
    var users = await FirebaseFirestore.instance.collection('Users');
    List<String> userIds = new List.from([]);
    List<String> allIds = new List.from([]);
    var userDocument = await FirebaseFirestore.instance
        .collection('Users')
        .doc(peerId.trim())
        .get();
    Map<String, dynamic>? userData = userDocument.data();
    List<dynamic> volunteersChattedWith = userData?['specialChattedWith'];
    List<dynamic> blocked = userData?['blocked'];
    var status;
    await users
        .where('status', isEqualTo: 'Chat Buddy')
        .get()
        .then((QuerySnapshot snapshot) async {
      snapshot.docs.forEach((DocumentSnapshot doc) {
        allIds.add(doc.id);
        String id = doc.id;
        if (id != peerId) {
          if (!volunteersChattedWith.contains(id)) {
            if (!blocked.contains(id)) {
              userIds.add(id);
            }
          }
        }
      });

      if (userIds.isEmpty) {
        // status = 'No more available users';
        // Probably have to do something different here

        // Random rng = new Random();
        // int randomNum = rng.nextInt(allIds.length);
        // String randomId = allIds[randomNum];
        // print('random id: ' + randomId);

        // var groups = await FirebaseFirestore.instance.collection('Groups');

        // String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

        // groups.add({
        //   'members': [peerId, randomId],
        //   'lastMessage': 'New Conversation - Say Hi!',
        //   'lastTimestamp': timestamp,
        //   'lastUpdatedBy': peerId,
        //   'createdAt': timestamp,
        //   'createdBy': peerId,
        //   'type': 'Peer-Volunteer',
        // }).then((doc) {
        //   String groupId = doc.id;

        //   FirebaseFirestore.instance.collection('Users').doc(peerId).update({
        //     'groups': FieldValue.arrayUnion([groupId]),
        //     // renew the volunteers if they've already talked to all of them
        //     'specialChattedWith': [randomId],
        //   });

        //   FirebaseFirestore.instance.collection('Users').doc(randomId).update({
        //     'groups': FieldValue.arrayUnion([groupId]),
        //     'specialChattedWith': FieldValue.arrayUnion([peerId]),
        //   });

        //   status = 'Success';
        //   return 'Success';
        // }).catchError((err) {
        //   print('Error creating group: $err');
        //   print(err.runtimeType);
        //   status = err;
        //   return err;
        // });
        status = 'Error';
      } else {
        Random rng = new Random();
        int randomNum = rng.nextInt(userIds.length);
        String randomId = userIds[randomNum];
        print('random id: ' + randomId);

        var groups = await FirebaseFirestore.instance.collection('Groups');

        String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

        groups.add({
          'members': [peerId, randomId],
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
            'specialChattedWith': FieldValue.arrayUnion([randomId]),
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
      }
    }).catchError((err) {
      print('Error creating group: $err');
      status = err;
      return err;
    });
    return status;
  }

  Future<Map<String, String>> getConversationData(groupChatId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String currentUserId = prefs.getString('id')!;
    String peerId;
    String peerName;
    String peerPhotoUrl;

    var document = await FirebaseFirestore.instance
        .collection('Groups')
        .doc(groupChatId)
        .get();
    Map<String, dynamic>? groupData = document.data();

    var memberIDs = groupData?['members'];
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
    String? currentUserPhotoUrl = await prefs.getString('alias');

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
    var chatRooms = await FirebaseFirestore.instance.collection('ChatRooms');
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

  Future<Map<String, dynamic>> getChatRoomData(chatRoomId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String currentUserId = prefs.getString('id')!;

    var document = await FirebaseFirestore.instance
        .collection('ChatRooms')
        .doc(chatRoomId)
        .get();
    Map<String, dynamic>? data = document.data();

    String roomName = data?['name'];
    String description = data?['description'];
    List<dynamic> members = data?['members'];
    List<dynamic> memberNames = data?['memberNames'];
    List<dynamic> memberPhotoUrls = data?['memberPhotoUrls'];

    return {
      'roomName': roomName,
      'currentUserId': currentUserId,
      'description': description,
      'members': members,
      'memberNames': memberNames,
      'memberPhotoUrls': memberPhotoUrls,
    };
  }

  Future<String> reportUser(currentUserId, peerId, topic, description) async {
    // add checking to see last report of user, if they can still report

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
      // it's been over an 1 hour
      if (difference > 3600000) {
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

        await FirebaseFirestore.instance
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
      } else {
        return 'Error';
      }
      // user hasn't reported anyone before
    } else {
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
      await FirebaseFirestore.instance
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
      FirebaseFirestore.instance.collection('Messages').doc(groupId).delete();
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
      FirebaseFirestore.instance.collection('Messages').doc(groupId).delete();
    } catch (e) {
      print(e);
      return e.toString();
    }

    return 'Success';
  }

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

// var users = await FirebaseFirestore.instance.collection('Users').get();
// var blah = users.docs.map((doc) => doc.data()).toList();
// print(blah);

