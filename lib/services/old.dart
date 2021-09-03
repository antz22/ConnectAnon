// Future<String> createSpecialGroup(
//     String currentUserId, List volunteersChattedWith, List blocked) async {
//   var users = await FirebaseFirestore.instance.collection('Users');
//   List<String> userIds = new List.from([]);
//   List<String> allIds = new List.from([]);
//   var status;
//   await users
//       .where('status', isEqualTo: 'Chat Buddy')
//       .get()
//       .then((QuerySnapshot snapshot) async {
//     snapshot.docs.forEach((DocumentSnapshot doc) {
//       allIds.add(doc.id);
//       String id = doc.id;
//       if (id != currentUserId) {
//         if (!volunteersChattedWith.contains(id)) {
//           if (!blocked.contains(id)) {
//             userIds.add(id);
//           }
//         }
//       }
//     });

//     if (userIds.isEmpty) {
//       // status = 'No more available users';
//       Random rng = new Random();
//       int randomNum = rng.nextInt(allIds.length);
//       String randomId = allIds[randomNum];
//       print('random id: ' + randomId);

//       var groups = await FirebaseFirestore.instance.collection('Groups');

//       String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

//       groups.add({
//         'members': [currentUserId, randomId],
//         'lastMessage': 'New Conversation - Say Hi!',
//         'lastTimestamp': timestamp,
//         'lastUpdatedBy': currentUserId,
//         'createdAt': timestamp,
//         'createdBy': currentUserId,
//         'type': 'Peer-Volunteer',
//       }).then((doc) {
//         String groupId = doc.id;

//         FirebaseFirestore.instance
//             .collection('Users')
//             .doc(currentUserId)
//             .update({
//           'groups': FieldValue.arrayUnion([groupId]),
//           // renew the volunteers if they've already talked to all of them
//           'specialChattedWith': [randomId],
//         });

//         FirebaseFirestore.instance.collection('Users').doc(randomId).update({
//           'groups': FieldValue.arrayUnion([groupId]),
//           'specialChattedWith': FieldValue.arrayUnion([currentUserId]),
//         });

//         status = 'Success';
//         return 'Success';
//       }).catchError((err) {
//         print('Error creating group: $err');
//         print(err.runtimeType);
//         status = err;
//         return err;
//       });
//       status = 'Success';
//     } else {
//       Random rng = new Random();
//       int randomNum = rng.nextInt(userIds.length);
//       String randomId = userIds[randomNum];
//       print('random id: ' + randomId);

//       var groups = await FirebaseFirestore.instance.collection('Groups');

//       String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

//       groups.add({
//         'members': [currentUserId, randomId],
//         'lastMessage': 'New Conversation - Say Hi!',
//         'lastTimestamp': timestamp,
//         'lastUpdatedBy': currentUserId,
//         'createdAt': timestamp,
//         'createdBy': currentUserId,
//         'type': 'Peer-Volunteer',
//       }).then((doc) {
//         String groupId = doc.id;

//         FirebaseFirestore.instance
//             .collection('Users')
//             .doc(currentUserId)
//             .update({
//           'groups': FieldValue.arrayUnion([groupId]),
//           'chattedWith': FieldValue.arrayUnion([randomId]),
//         });

//         FirebaseFirestore.instance.collection('Users').doc(randomId).update({
//           'groups': FieldValue.arrayUnion([groupId]),
//           'chattedWith': FieldValue.arrayUnion([currentUserId]),
//         });

//         status = 'Success';
//         return 'Success';
//       }).catchError((err) {
//         print('Error creating group: $err');
//         print(err.runtimeType);
//         status = err;
//         return err;
//       });
//       status = 'Success';
//     }
//   }).catchError((err) {
//     print('Error creating group: $err');
//     status = err;
//     return err;
//   });
//   return status;
// }
