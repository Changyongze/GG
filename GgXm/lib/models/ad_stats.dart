class AdStats {
  final int impressions;
  final int clicks;
  final int likes;
  final int comments;
  final int shares;
  final double impressionIncrease;
  final double clickIncrease;
  final double likeIncrease;
  final double commentIncrease;
  final double shareIncrease;
  final List<int> impressionTrend;
  final List<int> clickTrend;
  final List<String> dates;
  final Map<String, double> ageDistribution;
  final Map<String, double> genderDistribution;
  final Map<String, double> interestDistribution;
  final Map<String, double> provinceDistribution;
  final Map<String, double> cityDistribution;

  AdStats({
    required this.impressions,
    required this.clicks,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.impressionIncrease,
    required this.clickIncrease,
    required this.likeIncrease,
    required this.commentIncrease,
    required this.shareIncrease,
    required this.impressionTrend,
    required this.clickTrend,
    required this.dates,
    required this.ageDistribution,
    required this.genderDistribution,
    required this.interestDistribution,
    required this.provinceDistribution,
    required this.cityDistribution,
  });

  factory AdStats.fromJson(Map<String, dynamic> json) {
    return AdStats(
      impressions: json['impressions'],
      clicks: json['clicks'],
      likes: json['likes'],
      comments: json['comments'],
      shares: json['shares'],
      impressionIncrease: json['impression_increase'].toDouble(),
      clickIncrease: json['click_increase'].toDouble(),
      likeIncrease: json['like_increase'].toDouble(),
      commentIncrease: json['comment_increase'].toDouble(),
      shareIncrease: json['share_increase'].toDouble(),
      impressionTrend: List<int>.from(json['impression_trend']),
      clickTrend: List<int>.from(json['click_trend']),
      dates: List<String>.from(json['dates']),
      ageDistribution: Map<String, double>.from(json['age_distribution']),
      genderDistribution: Map<String, double>.from(json['gender_distribution']),
      interestDistribution: Map<String, double>.from(json['interest_distribution']),
      provinceDistribution: Map<String, double>.from(json['province_distribution']),
      cityDistribution: Map<String, double>.from(json['city_distribution']),
    );
  }

  double get ctr => clicks / impressions;
  double get cvr => likes / clicks;
  double get maxValue => [
    ...impressionTrend,
    ...clickTrend,
  ].reduce((a, b) => a > b ? a : b).toDouble();
} 