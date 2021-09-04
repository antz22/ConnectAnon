import 'package:cloud_firestore/cloud_firestore.dart';

class ChatServices {
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
