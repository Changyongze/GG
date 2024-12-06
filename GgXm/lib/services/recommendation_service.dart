import 'package:get/get.dart';
import '../models/ad.dart';
import '../models/user.dart';
import '../api/ad_api.dart';
import '../api/user_api.dart';

class RecommendationService extends GetxService {
  final AdApi _adApi = Get.find<AdApi>();
  final UserApi _userApi = Get.find<UserApi>();

  // 基于用户画像和行为的广告推荐
  Future<List<Ad>> getPersonalizedAds({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      // 获取用户画像
      final userProfile = await _userApi.getUserProfile();
      
      // 构建推荐参数
      final params = {
        'page': page,
        'page_size': pageSize,
        'age': userProfile.age,
        'gender': userProfile.gender,
        'interests': userProfile.interests,
        'location': userProfile.location,
        'behavior_tags': await _getBehaviorTags(),
      };

      // 获取推荐广告
      final ads = await _adApi.getRecommendedAds(
        params: params,
      );

      // 应用排序规则
      return _rankAds(ads);
    } catch (e) {
      print('广告推荐失败: $e');
      // 返回默认推荐
      return _adApi.getRecommendedAds(
        page: page,
        pageSize: pageSize,
      );
    }
  }

  // 获取用户行为标签
  Future<List<String>> _getBehaviorTags() async {
    try {
      // 获取用户近期行为数据
      final behaviors = await _userApi.getUserBehaviors(
        days: 30, // 最近30天
      );

      // 提取行为特征
      final tags = <String>{};
      for (final behavior in behaviors) {
        // 观看行为
        if (behavior.type == 'watch') {
          tags.add('watch_${behavior.adCategory}');
          if (behavior.watchDuration > 30) {
            tags.add('interested_${behavior.adCategory}');
          }
        }
        
        // 互动行为
        if (behavior.type == 'interaction') {
          tags.add('interact_${behavior.adCategory}');
          if (behavior.action == 'like') {
            tags.add('like_${behavior.adCategory}');
          }
        }
        
        // 转化行为
        if (behavior.type == 'conversion') {
          tags.add('convert_${behavior.adCategory}');
        }
      }

      return tags.toList();
    } catch (e) {
      print('获取行为标签失败: $e');
      return [];
    }
  }

  // 广告排序
  List<Ad> _rankAds(List<Ad> ads) {
    // 计算广告权重
    final weights = <String, double>{};
    for (final ad in ads) {
      weights[ad.id] = _calculateAdWeight(ad);
    }

    // 根据权重排序
    ads.sort((a, b) => weights[b.id]!.compareTo(weights[a.id]!));
    return ads;
  }

  // 计算单个广告权重
  double _calculateAdWeight(Ad ad) {
    double weight = 1.0;

    // CTR权重
    weight *= (ad.views > 0 ? ad.likes / ad.views : 0) * 100;

    // 互动率权重
    final interactionRate = (ad.likes + ad.comments + ad.shares) / ad.views;
    weight *= (1 + interactionRate);

    // 时效性权重
    final days = DateTime.now().difference(ad.createdAt).inDays;
    weight *= (1 - days / 30).clamp(0.1, 1.0);

    return weight;
  }
} 