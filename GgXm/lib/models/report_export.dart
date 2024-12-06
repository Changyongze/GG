class ReportExport {
  final String id;
  final String name;
  final String status; // pending/processing/completed/failed
  final String? downloadUrl;
  final String format; // pdf/excel
  final Map<String, dynamic> params;
  final DateTime createdAt;
  final DateTime? completedAt;

  ReportExport({
    required this.id,
    required this.name,
    required this.status,
    this.downloadUrl,
    required this.format,
    required this.params,
    required this.createdAt,
    this.completedAt,
  });

  factory ReportExport.fromJson(Map<String, dynamic> json) {
    return ReportExport(
      id: json['id'],
      name: json['name'],
      status: json['status'],
      downloadUrl: json['download_url'],
      format: json['format'],
      params: json['params'],
      createdAt: DateTime.parse(json['created_at']),
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'download_url': downloadUrl,
      'format': format,
      'params': params,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
  bool get isProcessing => status == 'processing' || status == 'pending';
} 