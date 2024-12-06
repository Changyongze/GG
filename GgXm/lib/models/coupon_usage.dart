class CouponUsage {
  final String id;
  final String couponId;
  final String userId;
  final String orderId;
  final String orderNo;
  final double orderAmount;
  final double discountAmount;
  final DateTime usedAt;
  final String? remark;

  CouponUsage({
    required this.id,
    required this.couponId,
    required this.userId,
    required this.orderId,
    required this.orderNo,
    required this.orderAmount,
    required this.discountAmount,
    required this.usedAt,
    this.remark,
  });

  factory CouponUsage.fromJson(Map<String, dynamic> json) {
    return CouponUsage(
      id: json['id'],
      couponId: json['coupon_id'],
      userId: json['user_id'],
      orderId: json['order_id'],
      orderNo: json['order_no'],
      orderAmount: json['order_amount'].toDouble(),
      discountAmount: json['discount_amount'].toDouble(),
      usedAt: DateTime.parse(json['used_at']),
      remark: json['remark'],
    );
  }
} 