class CampaignStats {
  final String campaignId;
  final Map<String, dynamic> overview; // 总览数据
  final List<Map<String, dynamic>> dailyStats; // 每日数据
  final Map<String, dynamic> audience; // 受众分析
  final Map<String, dynamic> regions; // 地域分析
  final Map<String, dynamic> schedule; // 时段分析
  final DateTime startDate;
  final DateTime endDate;

  CampaignStats({
    required this.campaignId,
    required this.overview,
    required this.dailyStats,
    required this.audience,
    required this.regions,
    required this.schedule,
    required this.startDate,
    required this.endDate,
  });

  factory CampaignStats.fromJson(Map<String, dynamic> json) {
    return CampaignStats(
      campaignId: json['campaign_id'],
      overview: json['overview'],
      dailyStats: List<Map<String, dynamic>>.from(json['daily_stats']),
      audience: json['audience'],
      regions: json['regions'],
      schedule: json['schedule'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'campaign_id': campaignId,
      'overview': overview,
      'daily_stats': dailyStats,
      'audience': audience,
      'regions': regions,
      'schedule': schedule,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
    };
  }
} 