class CouponStats {
  final int totalCount;
  final int usedCount;
  final int expiredCount;
  final double totalValue;
  final double usedValue;
  final double expiredValue;
  final Map<String, int> typeDistribution;
  final Map<String, double> monthlyUsage;
  final List<CouponUsageStats> topUsedCoupons;
  final int impressions;
  final double ctr;
  final double cvr;
  final Map<String, double> regionDistribution;

  CouponStats({
    required this.totalCount,
    required this.usedCount,
    required this.expiredCount,
    required this.totalValue,
    required this.usedValue,
    required this.expiredValue,
    required this.typeDistribution,
    required this.monthlyUsage,
    required this.topUsedCoupons,
    required this.impressions,
    required this.ctr,
    required this.cvr,
    required this.regionDistribution,
  });

  factory CouponStats.fromJson(Map<String, dynamic> json) {
    return CouponStats(
      totalCount: json['total_count'],
      usedCount: json['used_count'],
      expiredCount: json['expired_count'],
      totalValue: json['total_value'].toDouble(),
      usedValue: json['used_value'].toDouble(),
      expiredValue: json['expired_value'].toDouble(),
      typeDistribution: Map<String, int>.from(json['type_distribution']),
      monthlyUsage: Map<String, double>.from(json['monthly_usage']),
      topUsedCoupons: (json['top_used_coupons'] as List)
          .map((e) => CouponUsageStats.fromJson(e))
          .toList(),
      impressions: json['impressions'],
      ctr: json['ctr'].toDouble(),
      cvr: json['cvr'].toDouble(),
      regionDistribution: Map<String, double>.from(json['region_distribution']),
    );
  }

  double get useRate => usedCount / totalCount;
  double get expireRate => expiredCount / totalCount;
  double get valueUseRate => usedValue / totalValue;
}

class CouponUsageStats {
  final String couponId;
  final String name;
  final CouponType type;
  final int usedCount;
  final double totalValue;
  final double avgOrderAmount;

  CouponUsageStats({
    required this.couponId,
    required this.name,
    required this.type,
    required this.usedCount,
    required this.totalValue,
    required this.avgOrderAmount,
  });

  factory CouponUsageStats.fromJson(Map<String, dynamic> json) {
    return CouponUsageStats(
      couponId: json['coupon_id'],
      name: json['name'],
      type: CouponType.values.byName(json['type']),
      usedCount: json['used_count'],
      totalValue: json['total_value'].toDouble(),
      avgOrderAmount: json['avg_order_amount'].toDouble(),
    );
  }
} 