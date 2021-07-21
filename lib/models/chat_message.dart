enum MessageStatus { not_sent, not_viewed, viewed }

class ChatMessage {
  final String text;
  final MessageStatus messageStatus;
  final bool isSender;

  ChatMessage({
    this.text = '',
    required this.messageStatus,
    required this.isSender,
  });
}

List demoChatMessages = [
  ChatMessage(
    text: 'So you don\'t like apples?',
    messageStatus: MessageStatus.viewed,
    isSender: false,
  ),
  ChatMessage(
    text: 'nah not really. too sweet',
    messageStatus: MessageStatus.viewed,
    isSender: true,
  ),
  ChatMessage(
    text: 'do you have a favorite fruit? i am kinda weird ngl',
    messageStatus: MessageStatus.viewed,
    isSender: true,
  ),
  ChatMessage(
    text: 'i like bananas a lot, especially when they\'re frozen',
    messageStatus: MessageStatus.viewed,
    isSender: false,
  ),
  ChatMessage(
    text: 'lets talk about something spicy. do you have a crush?',
    messageStatus: MessageStatus.viewed,
    isSender: false,
  ),
  ChatMessage(
    text: 'lollll i knew it was gonna go here',
    messageStatus: MessageStatus.viewed,
    isSender: true,
  ),
  ChatMessage(
    text: 'Crazy thing is i actually don\'t',
    messageStatus: MessageStatus.viewed,
    isSender: true,
  ),
  ChatMessage(
    text: 'What??? actually?',
    messageStatus: MessageStatus.viewed,
    isSender: false,
  ),
  ChatMessage(
    text: 'What??? actually?',
    messageStatus: MessageStatus.viewed,
    isSender: true,
  ),
  ChatMessage(
    text: 'What??? actually?',
    messageStatus: MessageStatus.viewed,
    isSender: true,
  ),
  ChatMessage(
    text: 'What??? actually?',
    messageStatus: MessageStatus.viewed,
    isSender: false,
  ),
];
