class AdSuggestion {
  final double recommendedBudget;
  final double estimatedRoi;
  final List<String> budgetTips;
  final List<String> recommendedAudiences;
  final List<String> audienceTips;
  final List<PlacementSuggestion> recommendedPlacements;
  final String bestTimeRange;
  final int recommendedDuration;
  final List<String> timingTips;
  final List<String> optimizationTips;

  AdSuggestion({
    required this.recommendedBudget,
    required this.estimatedRoi,
    required this.budgetTips,
    required this.recommendedAudiences,
    required this.audienceTips,
    required this.recommendedPlacements,
    required this.bestTimeRange,
    required this.recommendedDuration,
    required this.timingTips,
    required this.optimizationTips,
  });

  factory AdSuggestion.fromJson(Map<String, dynamic> json) {
    return AdSuggestion(
      recommendedBudget: json['recommended_budget'].toDouble(),
      estimatedRoi: json['estimated_roi'].toDouble(),
      budgetTips: List<String>.from(json['budget_tips']),
      recommendedAudiences: List<String>.from(json['recommended_audiences']),
      audienceTips: List<String>.from(json['audience_tips']),
      recommendedPlacements: (json['recommended_placements'] as List)
          .map((e) => PlacementSuggestion.fromJson(e))
          .toList(),
      bestTimeRange: json['best_time_range'],
      recommendedDuration: json['recommended_duration'],
      timingTips: List<String>.from(json['timing_tips']),
      optimizationTips: List<String>.from(json['optimization_tips']),
    );
  }
}

class PlacementSuggestion {
  final String name;
  final String reason;
  final double score;

  PlacementSuggestion({
    required this.name,
    required this.reason,
    required this.score,
  });

  factory PlacementSuggestion.fromJson(Map<String, dynamic> json) {
    return PlacementSuggestion(
      name: json['name'],
      reason: json['reason'],
      score: json['score'].toDouble(),
    );
  }
} 