// 用户表
class User {
  final String id;
  final String phone;
  final String? nickname;
  final String? avatar;
  final String? gender;
  final int? age;
  final String? region;
  final List<String>? interests;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  User({
    required this.id,
    required this.phone,
    this.nickname,
    this.avatar,
    this.gender,
    this.age,
    this.region,
    this.interests,
    required this.createdAt,
    this.lastLoginAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'phone': phone,
      'nickname': nickname,
      'avatar': avatar,
      'gender': gender,
      'age': age,
      'region': region,
      'interests': interests,
      'created_at': createdAt.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
    };
  }
}

// 广告表
class Advertisement {
  final String id;
  final String advertiserId;
  final String title;
  final String description;
  final String videoUrl;
  final String coverUrl;
  final String category;
  final List<String> tags;
  final double budget;
  final List<String> targetAudience;
  final List<String> placement;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final DateTime createdAt;

  Advertisement({
    required this.id,
    required this.advertiserId,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.coverUrl,
    required this.category,
    required this.tags,
    required this.budget,
    required this.targetAudience,
    required this.placement,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'advertiser_id': advertiserId,
      'title': title,
      'description': description,
      'video_url': videoUrl,
      'cover_url': coverUrl,
      'category': category,
      'tags': tags,
      'budget': budget,
      'target_audience': targetAudience,
      'placement': placement,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

// 广告数据表
class AdStats {
  final String id;
  final String adId;
  final int impressions;
  final int clicks;
  final int likes;
  final int comments;
  final int shares;
  final Map<String, int> regionDistribution;
  final Map<String, int> ageDistribution;
  final Map<String, int> genderDistribution;
  final Map<String, int> timeDistribution;
  final DateTime date;

  AdStats({
    required this.id,
    required this.adId,
    required this.impressions,
    required this.clicks,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.regionDistribution,
    required this.ageDistribution,
    required this.genderDistribution,
    required this.timeDistribution,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ad_id': adId,
      'impressions': impressions,
      'clicks': clicks,
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'region_distribution': regionDistribution,
      'age_distribution': ageDistribution,
      'gender_distribution': genderDistribution,
      'time_distribution': timeDistribution,
      'date': date.toIso8601String(),
    };
  }
}

// 用户行为表
class UserBehavior {
  final String id;
  final String userId;
  final String adId;
  final String type;
  final Map<String, dynamic> data;
  final DateTime createdAt;

  UserBehavior({
    required this.id,
    required this.userId,
    required this.adId,
    required this.type,
    required this.data,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'ad_id': adId,
      'type': type,
      'data': data,
      'created_at': createdAt.toIso8601String(),
    };
  }
} 