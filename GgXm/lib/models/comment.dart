class Comment {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String content;
  final int likes;
  final bool isLiked;
  final DateTime createdAt;
  final List<Comment> replies;

  Comment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.content,
    required this.likes,
    required this.isLiked,
    required this.createdAt,
    this.replies = const [],
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      userId: json['user_id'],
      userName: json['user_name'],
      userAvatar: json['user_avatar'],
      content: json['content'],
      likes: json['likes'],
      isLiked: json['is_liked'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      replies: (json['replies'] as List?)
          ?.map((e) => Comment.fromJson(e))
          .toList() ?? [],
    );
  }
} 