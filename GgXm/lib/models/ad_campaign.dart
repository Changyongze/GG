enum CampaignStatus {
  draft,
  pending,
  active,
  paused,
  completed,
  rejected
}

class AdCampaign {
  final String id;
  final String title;
  final String description;
  final String videoUrl;
  final String category;
  final Map<String, dynamic> targetAudience;
  final double budget;
  final double costPerView;
  final CampaignStatus status;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  AdCampaign({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.category,
    required this.targetAudience,
    required this.budget,
    required this.costPerView,
    required this.status,
    required this.startDate,
    this.endDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdCampaign.fromJson(Map<String, dynamic> json) {
    return AdCampaign(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      videoUrl: json['video_url'],
      category: json['category'],
      targetAudience: json['target_audience'],
      budget: json['budget'].toDouble(),
      costPerView: json['cost_per_view'].toDouble(),
      status: CampaignStatus.values.byName(json['status']),
      startDate: DateTime.parse(json['start_date']),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
} 