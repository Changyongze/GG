class ReportTemplate {
  final String id;
  final String name;
  final String description;
  final List<String> metrics;
  final Map<String, dynamic> layout;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReportTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.metrics,
    required this.layout,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReportTemplate.fromJson(Map<String, dynamic> json) {
    return ReportTemplate(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      metrics: List<String>.from(json['metrics']),
      layout: json['layout'],
      isDefault: json['is_default'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'metrics': metrics,
      'layout': layout,
      'is_default': isDefault,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
} 