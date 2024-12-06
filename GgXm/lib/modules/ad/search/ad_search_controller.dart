import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/ad.dart';
import '../../../api/ad_api.dart';
import '../../../services/behavior_tracking_service.dart';

class AdSearchController extends GetxController {
  final AdApi _adApi = Get.find<AdApi>();
  final BehaviorTrackingService _behaviorTracking = Get.find<BehaviorTrackingService>();
  
  final searchResults = <Ad>[].obs;
  final isLoading = false.obs;
  final selectedCategory = '全部'.obs;
  late TextEditingController searchController;

  final categories = [
    '全部', '美食', '旅游', '电影', '音乐', '运动',
    '游戏', '购物', '摄影', '阅读', '科技', '时尚',
  ];

  @override
  void onInit() {
    super.onInit();
    searchController = TextEditingController();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> search(String keyword) async {
    if (keyword.trim().isEmpty) return;
    
    isLoading.value = true;
    try {
      final results = await _adApi.searchAds(
        keyword: keyword,
        category: selectedCategory.value == '��部' ? null : selectedCategory.value,
      );
      searchResults.value = results;

      // 记录搜索行为
      await _behaviorTracking.trackSearchBehavior(
        keyword: keyword,
        category: selectedCategory.value,
        resultCount: results.length,
      );
    } catch (e) {
      Get.snackbar('错误', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
    if (searchController.text.isNotEmpty) {
      search(searchController.text);
    }
  }

  void viewAdDetail(Ad ad) {
    // 记录点击行为
    _behaviorTracking.trackSearchBehavior(
      keyword: searchController.text,
      category: selectedCategory.value,
      resultCount: searchResults.length,
      clickedAds: [ad.id],
    );

    Get.toNamed(
      Routes.AD_DETAIL,
      arguments: ad,
    );
  }
} 