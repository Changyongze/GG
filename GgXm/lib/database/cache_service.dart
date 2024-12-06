import 'package:get/get.dart';
import 'package:shared_preferences.dart';
import 'dart:convert';
import '../models/ad.dart';
import '../models/user.dart';

class CacheService extends GetxService {
  static const String KEY_USER = 'cached_user';
  static const String KEY_ADS = 'cached_ads';
  static const String KEY_LAST_SYNC = 'last_sync_time';
  
  late SharedPreferences _prefs;
  
  Future<CacheService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // 用户数据缓存
  Future<void> cacheUser(User user) async {
    await _prefs.setString(KEY_USER, jsonEncode(user.toMap()));
  }

  User? getCachedUser() {
    final userStr = _prefs.getString(KEY_USER);
    if (userStr == null) return null;
    
    final userMap = jsonDecode(userStr);
    return User(
      id: userMap['id'],
      phone: userMap['phone'],
      nickname: userMap['nickname'],
      avatar: userMap['avatar'],
      gender: userMap['gender'],
      age: userMap['age'],
      region: userMap['region'],
      interests: userMap['interests'] != null 
        ? List<String>.from(userMap['interests'])
        : null,
      createdAt: DateTime.parse(userMap['created_at']),
      lastLoginAt: userMap['last_login_at'] != null
        ? DateTime.parse(userMap['last_login_at'])
        : null,
    );
  }

  // 广告列表缓存
  Future<void> cacheAds(List<Ad> ads) async {
    final adsJson = ads.map((ad) => ad.toJson()).toList();
    await _prefs.setString(KEY_ADS, jsonEncode(adsJson));
    await _prefs.setString(KEY_LAST_SYNC, DateTime.now().toIso8601String());
  }

  List<Ad>? getCachedAds() {
    final adsStr = _prefs.getString(KEY_ADS);
    if (adsStr == null) return null;
    
    final adsList = jsonDecode(adsStr) as List;
    return adsList.map((json) => Ad.fromJson(json)).toList();
  }

  DateTime? getLastSyncTime() {
    final timeStr = _prefs.getString(KEY_LAST_SYNC);
    if (timeStr == null) return null;
    return DateTime.parse(timeStr);
  }

  // 清除缓存
  Future<void> clearCache() async {
    await _prefs.clear();
  }

  // 检查缓存是否过期
  bool isCacheExpired() {
    final lastSync = getLastSyncTime();
    if (lastSync == null) return true;
    
    final now = DateTime.now();
    final difference = now.difference(lastSync);
    return difference.inHours >= 24; // 24小时过期
  }
} 