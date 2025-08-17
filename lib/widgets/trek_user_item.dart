import 'package:flutter/material.dart';
import 'package:trekkers/models/chat_user.dart';
import 'package:trekkers/screens/chat_screen.dart';

class TrekUserTile extends StatelessWidget {
  final String userId;
  final String username;
  final String email;
  final String profileImageUrl;
  final bool isCurrentUser;
  final VoidCallback? onChatPressed;

  const TrekUserTile({
    super.key,
    required this.userId,
    required this.username,
    required this.email,
    required this.profileImageUrl,
    required this.isCurrentUser,
    this.onChatPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: profileImageUrl.isNotEmpty
            ? NetworkImage(profileImageUrl)
            : null,
        child: profileImageUrl.isEmpty ? const Icon(Icons.person) : null,
      ),
      title: Text(username),
      subtitle: Text(email),
      trailing: !isCurrentUser
          ? IconButton(
              icon: const Icon(Icons.chat),
              onPressed: () {
                // Construct a ChatUser and navigate
                final chatUser = ChatUser(
                  userId: userId,
                  username: username,
                  profileImageUrl: profileImageUrl,
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatPage(userData: chatUser),
                  ),
                );
              },
            )
          : null,
    );
  }
}
