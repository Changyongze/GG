enum AdType {
  video,    // 视频广告
  image,    // 图片广告
  html5,    // H5广告
}

class Ad {
  final String id;
  final String title;
  final String description;
  final String advertiserName;
  final String videoUrl;
  final String coverUrl;
  final String category;
  final List<String> tags;
  final AdType type;
  final int points;      // 观看可获得积分
  final int views;       // 观看次数
  final int likes;       // 点赞数
  final int comments;    // 评论数
  final int shares;      // 分享数
  final bool isLiked;    // 当前用户是否点赞
  final DateTime createdAt;
  final Map<String, dynamic>? extra; // 额外参数

  Ad({
    required this.id,
    required this.title,
    required this.description,
    required this.advertiserName,
    required this.videoUrl,
    required this.coverUrl,
    required this.category,
    required this.tags,
    required this.type,
    required this.points,
    required this.views,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.isLiked,
    required this.createdAt,
    this.extra,
  });

  factory Ad.fromJson(Map<String, dynamic> json) {
    return Ad(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      advertiserName: json['advertiser_name'],
      videoUrl: json['video_url'],
      coverUrl: json['cover_url'],
      category: json['category'],
      tags: List<String>.from(json['tags']),
      type: AdType.values.byName(json['type']),
      points: json['points'],
      views: json['views'],
      likes: json['likes'],
      comments: json['comments'],
      shares: json['shares'],
      isLiked: json['is_liked'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      extra: json['extra'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'advertiser_name': advertiserName,
      'video_url': videoUrl,
      'cover_url': coverUrl,
      'category': category,
      'tags': tags,
      'type': type.name,
      'points': points,
      'views': views,
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'is_liked': isLiked,
      'created_at': createdAt.toIso8601String(),
      'extra': extra,
    };
  }
} 