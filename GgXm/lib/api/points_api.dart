import 'package:get/get.dart';
import '../models/coupon.dart';
import '../models/point_record.dart';
import '../models/user_coupon.dart';
import '../models/points_record.dart';
import '../models/coupon_usage.dart';
import '../models/coupon_stats.dart';
import '../services/http_service.dart';
import '../utils/constants.dart';

class PointsApi {
  final HttpService _httpService = Get.find<HttpService>();

  Future<List<Coupon>> getCoupons() async {
    final response = await _httpService.get<List<dynamic>>(
      ApiConstants.coupons,
    );
    
    return response.map((json) => Coupon.fromJson(json)).toList();
  }

  Future<void> exchangeCoupon(String couponId) async {
    await _httpService.post(
      '${ApiConstants.coupons}/$couponId/exchange',
    );
  }

  Future<Map<String, dynamic>> getUserPoints() async {
    final response = await _httpService.get<Map<String, dynamic>>(
      ApiConstants.userPoints,
    );
    
    return response;
  }

  Future<List<PointRecord>> getPointRecords({
    String? type,
    String? source,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _httpService.get<List<dynamic>>(
      ApiConstants.pointRecords,
      queryParameters: {
        if (type != null) 'type': type,
        if (source != null) 'source': source,
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
        'page': page,
        'page_size': pageSize,
      },
    );
    
    return response.map((json) => PointRecord.fromJson(json)).toList();
  }

  Future<List<UserCoupon>> getUserCoupons() async {
    final response = await _httpService.get<List<dynamic>>(
      ApiConstants.userCoupons,
    );
    
    return response.map((json) => UserCoupon.fromJson(json)).toList();
  }

  // 获取积分余额
  Future<int> getBalance() async {
    final response = await _httpService.get<Map<String, dynamic>>(
      ApiConstants.pointsBalance,
    );
    return response['balance'] as int;
  }

  // 获取积分记录
  Future<List<PointsRecord>> getRecords({
    int page = 1,
    int pageSize = 20,
    PointsType? type,
  }) async {
    final response = await _httpService.get<List<dynamic>>(
      ApiConstants.pointsRecords,
      queryParameters: {
        'page': page,
        'page_size': pageSize,
        if (type != null) 'type': type.name,
      },
    );
    return response.map((json) => PointsRecord.fromJson(json)).toList();
  }

  // 获取每日积分上限
  Future<Map<String, int>> getDailyLimits() async {
    final response = await _httpService.get<Map<String, dynamic>>(
      ApiConstants.pointsLimits,
    );
    return {
      'watch': response['watch_limit'] as int,
      'interaction': response['interaction_limit'] as int,
    };
  }

  // 获取日已获积分
  Future<Map<String, int>> getTodayPoints() async {
    final response = await _httpService.get<Map<String, dynamic>>(
      ApiConstants.pointsToday,
    );
    return {
      'watch': response['watch_points'] as int,
      'interaction': response['interaction_points'] as int,
    };
  }

  // 观看广告获取积分
  Future<PointsRecord> earnWatchPoints(String adId) async {
    final response = await _httpService.post<Map<String, dynamic>>(
      '${ApiConstants.pointsEarn}/watch',
      data: {'ad_id': adId},
    );
    return PointsRecord.fromJson(response);
  }

  // 互动获取积分
  Future<PointsRecord> earnInteractionPoints(String adId, PointsType type) async {
    final response = await _httpService.post<Map<String, dynamic>>(
      '${ApiConstants.pointsEarn}/interaction',
      data: {
        'ad_id': adId,
        'type': type.name,
      },
    );
    return PointsRecord.fromJson(response);
  }

  // 获取优惠券使用记录
  Future<List<CouponUsage>> getCouponUsages(String couponId) async {
    final response = await _httpService.get<List<dynamic>>(
      '${ApiConstants.userCoupons}/$couponId/usages',
    );
    return response.map((json) => CouponUsage.fromJson(json)).toList();
  }

  // 获即将过期的优惠券
  Future<List<UserCoupon>> getExpiringCoupons() async {
    final response = await _httpService.get<List<dynamic>>(
      ApiConstants.userCoupons,
      queryParameters: {
        'expiring': true,
        'days': 7, // 7天内过期
      },
    );
    return response.map((json) => UserCoupon.fromJson(json)).toList();
  }

  // 获取优惠券统计数据
  Future<CouponStats> getCouponStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final response = await _httpService.get<Map<String, dynamic>>(
      ApiConstants.couponStats,
      queryParameters: {
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
      },
    );
    return CouponStats.fromJson(response);
  }

  // 归档过期优惠券
  Future<void> archiveExpiredCoupons() async {
    await _httpService.post(
      ApiConstants.archiveCoupons,
    );
  }

  // 获取优惠券归档记录
  Future<List<UserCoupon>> getArchivedCoupons({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _httpService.get<List<dynamic>>(
      ApiConstants.archivedCoupons,
      queryParameters: {
        'page': page,
        'page_size': pageSize,
      },
    );
    return response.map((json) => UserCoupon.fromJson(json)).toList();
  }

  // 导出优惠券统计数据
  Future<String> exportCouponStats({
    DateTime? startDate,
    DateTime? endDate,
    String format = 'excel', // excel/csv/pdf
  }) async {
    final response = await _httpService.get<Map<String, dynamic>>(
      ApiConstants.exportCouponStats,
      queryParameters: {
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
        'format': format,
      },
    );
    return response['download_url'] as String;
  }

  // 获取优惠券使用时段分布
  Future<Map<String, int>> getCouponUsageTimeDistribution() async {
    final response = await _httpService.get<Map<String, dynamic>>(
      ApiConstants.couponUsageTime,
    );
    return Map<String, int>.from(response);
  }

  // 获取优惠券用户画像
  Future<Map<String, dynamic>> getCouponUserProfile() async {
    final response = await _httpService.get<Map<String, dynamic>>(
      ApiConstants.couponUserProfile,
    );
    return response;
  }

  // 获取对比数据
  Future<Map<String, CouponStats>> getComparisonStats({
    required DateTime startDate1,
    required DateTime endDate1,
    required DateTime startDate2,
    required DateTime endDate2,
  }) async {
    final response = await _httpService.get<Map<String, dynamic>>(
      ApiConstants.couponComparison,
      queryParameters: {
        'start_date1': startDate1.toIso8601String(),
        'end_date1': endDate1.toIso8601String(),
        'start_date2': startDate2.toIso8601String(),
        'end_date2': endDate2.toIso8601String(),
      },
    );
    
    return {
      'period1': CouponStats.fromJson(response['period1']),
      'period2': CouponStats.fromJson(response['period2']),
    };
  }

  // 导出对比数据
  Future<String> exportComparisonStats({
    required DateTime startDate1,
    required DateTime endDate1,
    required DateTime startDate2,
    required DateTime endDate2,
    String format = 'excel', // excel/csv/pdf
  }) async {
    final response = await _httpService.get<Map<String, dynamic>>(
      ApiConstants.exportComparison,
      queryParameters: {
        'start_date1': startDate1.toIso8601String(),
        'end_date1': endDate1.toIso8601String(),
        'start_date2': startDate2.toIso8601String(),
        'end_date2': endDate2.toIso8601String(),
        'format': format,
      },
    );
    return response['download_url'] as String;
  }

  // 获取用户画像对比
  Future<Map<String, dynamic>> getUserProfileComparison({
    required DateTime startDate1,
    required DateTime endDate1,
    required DateTime startDate2,
    required DateTime endDate2,
  }) async {
    final response = await _httpService.get<Map<String, dynamic>>(
      ApiConstants.userProfileComparison,
      queryParameters: {
        'start_date1': startDate1.toIso8601String(),
        'end_date1': endDate1.toIso8601String(),
        'start_date2': startDate2.toIso8601String(),
        'end_date2': endDate2.toIso8601String(),
      },
    );
    return response;
  }
} 