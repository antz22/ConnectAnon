import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String idFrom;
  final String idTo;
  final String timestamp;
  final String content;

  const Message({
    required this.idFrom,
    required this.idTo,
    required this.timestamp,
    required this.content,
  });

  factory Message.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Message(
      idFrom: data['idFrom'] ?? '',
      idTo: data['idTo'] ?? '',
      timestamp: data['timestamp'] ?? '',
      content: data['content'] ?? '',
    );
  }
}
