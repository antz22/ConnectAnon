import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoom {
  final String id;
  final String name;
  final String description;
  final String lastMessage;
  final String lastTimestamp;
  final List<dynamic> members;
  final List<dynamic> memberNames;
  final List<dynamic> memberPhotoUrls;

  ChatRoom({
    required this.id,
    required this.name,
    required this.description,
    required this.lastMessage,
    required this.lastTimestamp,
    required this.members,
    required this.memberNames,
    required this.memberPhotoUrls,
  });

  factory ChatRoom.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    String id = doc.id;
    return ChatRoom(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      lastMessage: data['lastMessage'] ?? '',
      lastTimestamp: data['lastTimestamp'] ?? '',
      members: data['members'] ?? [],
      memberNames: data['memberNames'] ?? [],
      memberPhotoUrls: data['memberPhotoUrls'] ?? [],
    );
  }
}
