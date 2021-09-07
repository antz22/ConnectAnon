import 'package:cloud_firestore/cloud_firestore.dart';

class Profile {
  final String alias;
  final String role;
  final String school;
  final String photoUrl;
  final int peerChats;
  final int chatRooms;
  final int reports;
  final bool isBanned;
  final bool? isAccepting;

  const Profile({
    required this.alias,
    required this.role,
    required this.school,
    required this.photoUrl,
    required this.peerChats,
    required this.chatRooms,
    required this.reports,
    required this.isBanned,
    this.isAccepting,
  });

  factory Profile.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Profile(
      alias: data['alias'] ?? '',
      role: data['role'] ?? '',
      school: data['school'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      peerChats: data['chattedWith'].length,
      chatRooms: data['chatRooms'].length,
      reports: data['reports'] ?? 0,
      isBanned: data['isBanned'] ?? false,
      // only check if role of user is chat buddy
      isAccepting: data['role'] == 'Chat Buddy' ? data['isAccepting'] : null,
    );
  }
}
