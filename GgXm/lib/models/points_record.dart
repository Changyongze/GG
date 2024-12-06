enum PointsType {
  watchAd,      // 观看广告
  like,         // 点赞
  comment,      // 评论
  share,        // 分享
  shareBonus,   // 分享观看奖励
  exchange,     // 积分兑换
  system,       // 系统调整
}

class PointsRecord {
  final String id;
  final String userId;
  final int points;
  final PointsType type;
  final String? adId;
  final String? adTitle;
  final String? remark;
  final DateTime createdAt;

  PointsRecord({
    required this.id,
    required this.userId,
    required this.points,
    required this.type,
    this.adId,
    this.adTitle,
    this.remark,
    required this.createdAt,
  });

  factory PointsRecord.fromJson(Map<String, dynamic> json) {
    return PointsRecord(
      id: json['id'],
      userId: json['user_id'],
      points: json['points'],
      type: PointsType.values.byName(json['type']),
      adId: json['ad_id'],
      adTitle: json['ad_title'],
      remark: json['remark'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
} 