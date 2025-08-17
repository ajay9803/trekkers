import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_user.dart';
import '../models/chat_message.dart';

class ChatApis {
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// Get the current user ID dynamically
  static String get currentUserId => auth.currentUser!.uid;

  /// Generate a unique conversation ID for two users
  static String getConversationId(String otherUserId) =>
      currentUserId.hashCode <= otherUserId.hashCode
          ? '${currentUserId}_$otherUserId'
          : '${otherUserId}_$currentUserId';

  /// Send a text message
  static Future<void> sendMessage(ChatUser chatUser, String msg) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final message = ChatMessage(
      fromId: currentUserId,
      toId: chatUser.userId,
      message: msg,
      type: ChatMessageType.text,
      sent: time,
      read: '',
      replyText: '',
    );

    final ref = firestore
        .collection('chats/${getConversationId(chatUser.userId)}/messages');

    await ref.doc(time).set(message.toJson());
  }

  /// Stream all messages in a conversation
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser chatUser) {
    return firestore
        .collection('chats/${getConversationId(chatUser.userId)}/messages')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  /// Stream last message in a conversation
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser chatUser) {
    return firestore
        .collection('chats/${getConversationId(chatUser.userId)}/messages')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }
}
