import 'package:cloud_firestore/cloud_firestore.dart';

class Request {
  final String id;
  final String peerId;
  final String peerName;
  final String peerPhotoUrl;
  final String requestedPeerId;
  final String timestamp;

  const Request({
    required this.id,
    required this.peerId,
    required this.peerName,
    required this.peerPhotoUrl,
    required this.requestedPeerId,
    required this.timestamp,
  });

  factory Request.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Request(
      id: doc.id,
      peerId: data['peer'] ?? '',
      peerName: data['peerName'] ?? '',
      peerPhotoUrl: data['peerPhotoUrl'] ?? '',
      requestedPeerId: data['requestedPeer'] ?? '',
      timestamp: data['timestamp'] ?? '',
    );
  }
}
