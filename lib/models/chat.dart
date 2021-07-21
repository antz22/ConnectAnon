import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final String id;
  final String photoUrl;
  final String alias;

  Chat({required this.id, required this.photoUrl, required this.alias});

  factory Chat.fromDocument(DocumentSnapshot doc) {
    String alias = '';
    String photoUrl = '';
    try {
      alias = doc.get('alias');
    } catch (e) {}
    try {
      photoUrl = doc.get('photoUrl');
    } catch (e) {}
    return Chat(
      id: doc.id,
      photoUrl: photoUrl,
      alias: alias,
    );
  }
}
