import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/chat_message.dart';

class GroupChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;

  const GroupChatPage(
      {super.key, required this.groupId, required this.groupName});

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get currentUserId => _auth.currentUser!.uid;

  void sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final message = ChatMessage(
      fromId: currentUserId,
      toId: '',
      message: text,
      type: ChatMessageType.text,
      sent: time,
      read: '',
      replyText: '',
    );

    await _firestore
        .collection('groupchats')
        .doc(widget.groupId)
        .collection('messages')
        .doc(time)
        .set(message.toJson());

    _controller.clear();
  }

  Future<Map<String, dynamic>> _getUserData(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return doc.data()!;
    }
    return {'username': 'Unknown', 'profileImageUrl': ''};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.groupName)),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _firestore
                  .collection('groupchats')
                  .doc(widget.groupId)
                  .collection('messages')
                  .orderBy('sent', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final data = messages[index].data();
                    final isMe = data['fromId'] == currentUserId;

                    return FutureBuilder<Map<String, dynamic>>(
                      future: _getUserData(data['fromId']),
                      builder: (context, userSnapshot) {
                        final username =
                            userSnapshot.data?['username'] ?? 'Unknown';
                        final profileImageUrl =
                            userSnapshot.data?['profileImageUrl'] ?? '';

                        final messageWidget = Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(username,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isMe ? Colors.blue : Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                data['message'] ?? '',
                                style: TextStyle(
                                    color: isMe ? Colors.white : Colors.black),
                              ),
                            ),
                          ],
                        );

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          child: Row(
                            mainAxisAlignment: isMe
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            children: [
                              if (!isMe)
                                CircleAvatar(
                                  backgroundImage: profileImageUrl.isNotEmpty
                                      ? NetworkImage(profileImageUrl)
                                      : null,
                                  child: profileImageUrl.isEmpty
                                      ? const Icon(Icons.person)
                                      : null,
                                ),
                              const SizedBox(width: 8),
                              Flexible(child: messageWidget),
                              if (isMe) const SizedBox(width: 8),
                              if (isMe)
                                CircleAvatar(
                                  backgroundImage: profileImageUrl.isNotEmpty
                                      ? NetworkImage(profileImageUrl)
                                      : null,
                                  child: profileImageUrl.isEmpty
                                      ? const Icon(Icons.person)
                                      : null,
                                ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
