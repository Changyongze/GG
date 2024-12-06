class AdPrediction {
  final int impressions;
  final int clicks;
  final double ctr;
  final int conversions;
  final double cvr;
  final double roi;
  final Map<String, double> audienceDistribution;
  final Map<String, double> regionDistribution;
  final Map<String, double> timeDistribution;
  final List<String> suggestions;

  AdPrediction({
    required this.impressions,
    required this.clicks,
    required this.ctr,
    required this.conversions,
    required this.cvr,
    required this.roi,
    required this.audienceDistribution,
    required this.regionDistribution,
    required this.timeDistribution,
    required this.suggestions,
  });

  factory AdPrediction.fromJson(Map<String, dynamic> json) {
    return AdPrediction(
      impressions: json['impressions'],
      clicks: json['clicks'],
      ctr: json['ctr'].toDouble(),
      conversions: json['conversions'],
      cvr: json['cvr'].toDouble(),
      roi: json['roi'].toDouble(),
      audienceDistribution: Map<String, double>.from(json['audience_distribution']),
      regionDistribution: Map<String, double>.from(json['region_distribution']),
      timeDistribution: Map<String, double>.from(json['time_distribution']),
      suggestions: List<String>.from(json['suggestions']),
    );
  }
} 