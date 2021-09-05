import 'package:cloud_firestore/cloud_firestore.dart';

class Request {
  final String id;
  final String peer;
  final String peerName;
  final String peerPhotoUrl;
  final String volunteerId;
  final String timestamp;
  final bool keepHistory;
  final bool addHistory;

  const Request({
    required this.id,
    required this.peer,
    required this.peerName,
    required this.peerPhotoUrl,
    required this.volunteerId,
    required this.timestamp,
    required this.keepHistory,
    required this.addHistory,
  });

  factory Request.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Request(
      id: doc.id,
      peer: data['peer'] ?? '',
      peerName: data['peerName'] ?? '',
      peerPhotoUrl: data['peerPhotoUrl'] ?? '',
      volunteerId: data['volunteerId'] ?? '',
      timestamp: data['timestamp'] ?? '',
      keepHistory: data['keepHistory'] ?? false,
      addHistory: data['addHistory'] ?? false,
    );
  }
}
