class CampaignAnalysis {
  final String campaignId;
  final Map<String, dynamic> performance; // 效果指标
  final Map<String, dynamic> audience; // 受众分析
  final Map<String, dynamic> timing; // 时段分析
  final Map<String, dynamic> region; // 地域分析
  final List<String> suggestions; // 优化建议
  final DateTime analyzedAt;

  CampaignAnalysis({
    required this.campaignId,
    required this.performance,
    required this.audience,
    required this.timing,
    required this.region,
    required this.suggestions,
    required this.analyzedAt,
  });

  factory CampaignAnalysis.fromJson(Map<String, dynamic> json) {
    return CampaignAnalysis(
      campaignId: json['campaign_id'],
      performance: json['performance'],
      audience: json['audience'],
      timing: json['timing'],
      region: json['region'],
      suggestions: List<String>.from(json['suggestions']),
      analyzedAt: DateTime.parse(json['analyzed_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'campaign_id': campaignId,
      'performance': performance,
      'audience': audience,
      'timing': timing,
      'region': region,
      'suggestions': suggestions,
      'analyzed_at': analyzedAt.toIso8601String(),
    };
  }
} 