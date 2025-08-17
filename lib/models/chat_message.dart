enum ChatMessageType { text }

class ChatMessage {
  final String fromId;
  final String toId;
  final String message;
  final ChatMessageType type;
  final String sent;
  final String read;
  final String replyText;

  ChatMessage({
    required this.fromId,
    required this.toId,
    required this.message,
    required this.type,
    required this.sent,
    this.read = '',
    this.replyText = '',
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      fromId: map['fromId'] ?? '',
      toId: map['toId'] ?? '',
      message: map['message'] ?? '',
      type: ChatMessageType.values.firstWhere(
          (e) => e.toString() == 'ChatMessageType.${map['type'] ?? 'text'}',
          orElse: () => ChatMessageType.text),
      sent: map['sent'] ?? '',
      read: map['read'] ?? '',
      replyText: map['replyText'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fromId': fromId,
      'toId': toId,
      'message': message,
      'type': type.toString().split('.').last,
      'sent': sent,
      'read': read,
      'replyText': replyText,
    };
  }
}
