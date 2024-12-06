class BillingRecord {
  final String id;
  final String advertiserId;
  final String type; // recharge/consume
  final double amount;
  final String description;
  final Map<String, dynamic>? metadata; // 充值方式、消费详情等
  final DateTime createdAt;

  BillingRecord({
    required this.id,
    required this.advertiserId,
    required this.type,
    required this.amount,
    required this.description,
    this.metadata,
    required this.createdAt,
  });

  factory BillingRecord.fromJson(Map<String, dynamic> json) {
    return BillingRecord(
      id: json['id'],
      advertiserId: json['advertiser_id'],
      type: json['type'],
      amount: json['amount']?.toDouble() ?? 0.0,
      description: json['description'],
      metadata: json['metadata'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'advertiser_id': advertiserId,
      'type': type,
      'amount': amount,
      'description': description,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
    };
  }
} 