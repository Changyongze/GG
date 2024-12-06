class Activity {
  final String id;
  final String type; // ad_view/ad_click/coupon_exchange
  final String title;
  final String description;
  final DateTime createdAt;
  final Map<String, dynamic>? data;

  Activity({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.createdAt,
    this.data,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'],
      type: json['type'],
      title: json['title'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      data: json['data'],
    );
  }
} 