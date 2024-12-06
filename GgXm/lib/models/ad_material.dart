class AdMaterial {
  final String id;
  final String campaignId;
  final String title;
  final String description;
  final String type; // video/image
  final String url;
  final String? coverUrl;
  final Map<String, dynamic>? metadata; // 视频时长、分辨率等
  final DateTime createdAt;
  final DateTime updatedAt;

  AdMaterial({
    required this.id,
    required this.campaignId,
    required this.title,
    required this.description,
    required this.type,
    required this.url,
    this.coverUrl,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdMaterial.fromJson(Map<String, dynamic> json) {
    return AdMaterial(
      id: json['id'],
      campaignId: json['campaign_id'],
      title: json['title'],
      description: json['description'],
      type: json['type'],
      url: json['url'],
      coverUrl: json['cover_url'],
      metadata: json['metadata'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'campaign_id': campaignId,
      'title': title,
      'description': description,
      'type': type,
      'url': url,
      'cover_url': coverUrl,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
} 