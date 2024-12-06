class AppNotification {
  final String id;
  final String title;
  final String content;
  final String type; // system / points / ad
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? data;

  AppNotification({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.createdAt,
    required this.isRead,
    this.data,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      type: json['type'],
      createdAt: DateTime.parse(json['created_at']),
      isRead: json['is_read'] ?? false,
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'type': type,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
      'data': data,
    };
  }
} 