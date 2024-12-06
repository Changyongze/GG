class UserCoupon {
  final String id;
  final String couponId;
  final String userId;
  final String name;
  final String description;
  final CouponType type;
  final double value;
  final String? code;
  final DateTime startDate;
  final DateTime endDate;
  final String? useGuide;
  final bool isUsed;
  final DateTime? usedAt;
  final DateTime createdAt;

  UserCoupon({
    required this.id,
    required this.couponId,
    required this.userId,
    required this.name,
    required this.description,
    required this.type,
    required this.value,
    this.code,
    required this.startDate,
    required this.endDate,
    this.useGuide,
    required this.isUsed,
    this.usedAt,
    required this.createdAt,
  });

  factory UserCoupon.fromJson(Map<String, dynamic> json) {
    return UserCoupon(
      id: json['id'],
      couponId: json['coupon_id'],
      userId: json['user_id'],
      name: json['name'],
      description: json['description'],
      type: CouponType.values.byName(json['type']),
      value: json['value'].toDouble(),
      code: json['code'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      useGuide: json['use_guide'],
      isUsed: json['is_used'],
      usedAt: json['used_at'] != null ? DateTime.parse(json['used_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  bool get isExpired => DateTime.now().isAfter(endDate);
  bool get isAvailable => !isUsed && !isExpired;
  String get valueText {
    switch (type) {
      case CouponType.discount:
        return '${value.toStringAsFixed(1)}折';
      case CouponType.cash:
        return '¥${value.toStringAsFixed(2)}';
      default:
        return value.toString();
    }
  }

  String get statusText {
    if (isUsed) return '已使用';
    if (isExpired) return '已过期';
    return '未使用';
  }
} 