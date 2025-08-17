class ChatUser {
  final String userId;
  final String username;
  final String profileImageUrl;

  ChatUser({
    required this.userId,
    required this.username,
    this.profileImageUrl = '',
  });

  factory ChatUser.fromMap(Map<String, dynamic> map, String id) {
    return ChatUser(
      userId: id,
      username: map['username'] ?? 'Unknown',
      profileImageUrl: map['profileImageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'profileImageUrl': profileImageUrl,
    };
  }
}
