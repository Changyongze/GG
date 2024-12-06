enum CouponType {
  discount,    // 折扣券
  cash,        // 现金券
  exchange,    // 兑换券
  gift,        // 礼品券
}

enum CouponStatus {
  available,   // 可兑换
  exchanged,   // 已兑换
  used,        // 已使用
  expired,     // 已过期
}

class Coupon {
  final String id;
  final String name;
  final String description;
  final CouponType type;
  final int points;      // 所需积分
  final double value;    // 优惠券面值
  final String? code;    // 兑换码
  final DateTime startDate;
  final DateTime endDate;
  final int stock;       // 剩余库存
  final int limit;       // 每人限兑数量
  final String? useGuide;// 使用说明
  final List<String> tags;
  final CouponStatus status;

  Coupon({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.points,
    required this.value,
    this.code,
    required this.startDate,
    required this.endDate,
    required this.stock,
    required this.limit,
    this.useGuide,
    required this.tags,
    required this.status,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: CouponType.values.byName(json['type']),
      points: json['points'],
      value: json['value'].toDouble(),
      code: json['code'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      stock: json['stock'],
      limit: json['limit'],
      useGuide: json['use_guide'],
      tags: List<String>.from(json['tags']),
      status: CouponStatus.values.byName(json['status']),
    );
  }

  bool get isAvailable => status == CouponStatus.available && stock > 0;
  bool get isExpired => DateTime.now().isAfter(endDate);
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
} 