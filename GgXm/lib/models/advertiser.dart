class Advertiser {
  final String id;
  final String name;
  final String type; // personal/enterprise
  final String contactPhone;
  final String? licenseNo; // 营业执照号
  final String? idCard;   // 身份证号
  final String status;    // pending/approved/rejected
  final DateTime createdAt;
  final String? avatar;
  final String? description;
  final double balance;    // 账户余额
  final Map<String, dynamic>? settings; // 投放设置

  Advertiser({
    required this.id,
    required this.name,
    required this.type,
    required this.contactPhone,
    this.licenseNo,
    this.idCard,
    required this.status,
    required this.createdAt,
    this.avatar,
    this.description,
    required this.balance,
    this.settings,
  });

  factory Advertiser.fromJson(Map<String, dynamic> json) {
    return Advertiser(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      contactPhone: json['contact_phone'],
      licenseNo: json['license_no'],
      idCard: json['id_card'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      avatar: json['avatar'],
      description: json['description'],
      balance: json['balance']?.toDouble() ?? 0.0,
      settings: json['settings'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'contact_phone': contactPhone,
      'license_no': licenseNo,
      'id_card': idCard,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'avatar': avatar,
      'description': description,
      'balance': balance,
      'settings': settings,
    };
  }
} 