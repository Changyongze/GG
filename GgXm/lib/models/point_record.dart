class PointRecord {
  final String id;
  final int points;
  final String type; // earn(获得) / spend(消费)
  final String source; // ad(广告) / exchange(兑换)
  final String description;
  final DateTime createdAt;
  final Map<String, dynamic>? details;

  PointRecord({
    required this.id,
    required this.points,
    required this.type,
    required this.source,
    required this.description,
    required this.createdAt,
    this.details,
  });

  factory PointRecord.fromJson(Map<String, dynamic> json) {
    return PointRecord(
      id: json['id'],
      points: json['points'],
      type: json['type'],
      source: json['source'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      details: json['details'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'points': points,
      'type': type,
      'source': source,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'details': details,
    };
  }
} 