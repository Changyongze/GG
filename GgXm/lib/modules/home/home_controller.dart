import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/ad.dart';
import '../../api/ad_api.dart';
import '../../api/points_api.dart';

class HomeController extends GetxController {
  final AdApi _adApi = Get.find<AdApi>();
  final PointsApi _pointsApi = Get.find<PointsApi>();
  
  final ads = <Ad>[].obs;
  final currentIndex = 0.obs;
  final showPointsReward = false.obs;
  final isLoading = false.obs;
  
  late PageController pageController;
  Timer? _rewardTimer;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
    loadAds();
  }

  @override
  void onClose() {
    pageController.dispose();
    _rewardTimer?.cancel();
    super.onClose();
  }

  Future<void> loadAds() async {
    if (isLoading.value) return;
    
    isLoading.value = true;
    try {
      final newAds = await _adApi.getRecommendedAds();
      ads.addAll(newAds);
    } catch (e) {
      Get.snackbar('错误', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void onPageChanged(int index) {
    currentIndex.value = index;
    
    // 加载更多广告
    if (index >= ads.length - 3) {
      loadAds();
    }

    // 开始计时观看时长
    _rewardTimer?.cancel();
    _rewardTimer = Timer(const Duration(seconds: 5), () {
      _earnPoints(ads[index]);
    });
  }

  Future<void> _earnPoints(Ad ad) async {
    try {
      await _pointsApi.earnWatchPoints(ad.id);
      showPointsReward.value = true;
      Future.delayed(const Duration(seconds: 2), () {
        showPointsReward.value = false;
      });
    } catch (e) {
      print('获取积分失败: $e');
    }
  }

  Future<void> likeAd(Ad ad) async {
    try {
      if (ad.isLiked) {
        await _adApi.unlikeAd(ad.id);
      } else {
        await _adApi.likeAd(ad.id);
        await _pointsApi.earnInteractionPoints(ad.id, PointsType.like);
      }
      // 刷新广告数据
      final index = ads.indexWhere((a) => a.id == ad.id);
      if (index != -1) {
        final updatedAd = await _adApi.getAdDetail(ad.id);
        ads[index] = updatedAd;
      }
    } catch (e) {
      Get.snackbar('错误', e.toString());
    }
  }

  void showComments(Ad ad) {
    Get.toNamed(
      Routes.AD_COMMENTS,
      arguments: ad,
    );
  }

  Future<void> shareAd(Ad ad) async {
    try {
      final result = await Share.share(
        '${ad.title}\n${ad.description}\n点击观看: https://example.com/ad/${ad.id}',
      );
      if (result.status == ShareResultStatus.success) {
        await _pointsApi.earnInteractionPoints(ad.id, PointsType.share);
      }
    } catch (e) {
      Get.snackbar('错误', '分享失败');
    }
  }
} 