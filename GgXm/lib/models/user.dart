class User {
  final String id;
  final String phone;
  final String? nickname;
  final String? avatar;
  final int points;
  final String? gender;
  final int? age;
  final String? region;
  final List<String>? interests;

  User({
    required this.id,
    required this.phone,
    this.nickname,
    this.avatar,
    this.points = 0,
    this.gender,
    this.age,
    this.region,
    this.interests,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      phone: json['phone'],
      nickname: json['nickname'],
      avatar: json['avatar'],
      points: json['points'] ?? 0,
      gender: json['gender'],
      age: json['age'],
      region: json['region'],
      interests: json['interests'] != null 
        ? List<String>.from(json['interests'])
        : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'nickname': nickname,
      'avatar': avatar,
      'points': points,
      'gender': gender,
      'age': age,
      'region': region,
      'interests': interests,
    };
  }
} 