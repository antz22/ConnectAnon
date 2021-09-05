import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomMessage {
  final String idFrom;
  final String idTo;
  final String nameFrom;
  final String photoUrlFrom;
  final String timestamp;
  final String content;

  const ChatRoomMessage({
    required this.idFrom,
    required this.idTo,
    required this.nameFrom,
    required this.photoUrlFrom,
    required this.timestamp,
    required this.content,
  });

  factory ChatRoomMessage.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ChatRoomMessage(
      idFrom: data['idFrom'] ?? '',
      idTo: data['idTo'] ?? '',
      nameFrom: data['nameFrom'] ?? '',
      photoUrlFrom: data['photoUrlFrom'] ?? '',
      timestamp: data['timestamp'] ?? '',
      content: data['content'] ?? '',
    );
  }
}
