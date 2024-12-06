import 'package:get/get.dart';
import '../models/user_behavior.dart';
import '../api/user_api.dart';
import '../utils/constants.dart';

class BehaviorTrackingService extends GetxService {
  final UserApi _userApi = Get.find<UserApi>();
  
  // 跟踪广告观看行为
  Future<void> trackWatchBehavior({
    required String adId,
    required String adCategory,
    required int duration,
    required double watchProgress,
    required bool isComplete,
  }) async {
    try {
      final behavior = UserBehavior(
        type: 'watch',
        adId: adId,
        adCategory: adCategory,
        timestamp: DateTime.now(),
        data: {
          'duration': duration,
          'progress': watchProgress,
          'complete': isComplete,
        },
      );
      
      await _userApi.recordBehavior(behavior);
    } catch (e) {
      print('记录观看行为失败: $e');
    }
  }

  // 跟踪互动行为
  Future<void> trackInteractionBehavior({
    required String adId,
    required String adCategory,
    required String action, // like/comment/share
    Map<String, dynamic>? extraData,
  }) async {
    try {
      final behavior = UserBehavior(
        type: 'interaction',
        adId: adId,
        adCategory: adCategory,
        timestamp: DateTime.now(),
        action: action,
        data: extraData,
      );
      
      await _userApi.recordBehavior(behavior);
    } catch (e) {
      print('记录互动行为失败: $e');
    }
  }

  // 跟踪转化行为
  Future<void> trackConversionBehavior({
    required String adId,
    required String adCategory,
    required String conversionType,
    required double value,
    Map<String, dynamic>? extraData,
  }) async {
    try {
      final behavior = UserBehavior(
        type: 'conversion',
        adId: adId,
        adCategory: adCategory,
        timestamp: DateTime.now(),
        action: conversionType,
        data: {
          'value': value,
          ...?extraData,
        },
      );
      
      await _userApi.recordBehavior(behavior);
    } catch (e) {
      print('记录转化行为失败: $e');
    }
  }

  // 跟踪搜索行为
  Future<void> trackSearchBehavior({
    required String keyword,
    required String category,
    required int resultCount,
    List<String>? clickedAds,
  }) async {
    try {
      final behavior = UserBehavior(
        type: 'search',
        timestamp: DateTime.now(),
        data: {
          'keyword': keyword,
          'category': category,
          'result_count': resultCount,
          'clicked_ads': clickedAds,
        },
      );
      
      await _userApi.recordBehavior(behavior);
    } catch (e) {
      print('记录搜索行为失败: $e');
    }
  }

  // 跟踪页面浏览行为
  Future<void> trackPageViewBehavior({
    required String page,
    required String category,
    required Duration duration,
    Map<String, dynamic>? extraData,
  }) async {
    try {
      final behavior = UserBehavior(
        type: 'page_view',
        timestamp: DateTime.now(),
        data: {
          'page': page,
          'category': category,
          'duration': duration.inSeconds,
          ...?extraData,
        },
      );
      
      await _userApi.recordBehavior(behavior);
    } catch (e) {
      print('记录页面浏览失败: $e');
    }
  }
} 