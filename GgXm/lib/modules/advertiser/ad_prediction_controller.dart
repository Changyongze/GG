import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/ad.dart';
import '../../api/ad_api.dart';

class AdPredictionController extends GetxController {
  final AdApi _adApi = Get.find<AdApi>();
  
  late Ad ad;
  final isLoading = false.obs;
  final predictionResult = <String, dynamic>{}.obs;
  
  late TextEditingController budgetController;
  late TextEditingController durationController;
  
  final selectedAudiences = <String>{}.obs;
  final selectedPlacements = <String>{}.obs;

  final audienceOptions = [
    '18-24岁',
    '25-34岁',
    '35-44岁',
    '男性',
    '女性',
    '学生',
    '上班族',
    '自由职业',
    '高消费',
    '中等消费',
  ];

  final placementOptions = [
    '首页推荐',
    '搜索结果',
    '视频流',
    '信息流',
    '开屏广告',
    '插屏广告',
  ];

  @override
  void onInit() {
    super.onInit();
    ad = Get.arguments as Ad;
    budgetController = TextEditingController(text: ad.budget?.toString() ?? '');
    durationController = TextEditingController(text: '7');
    
    // 初始化已有的目标受众和投放位置
    if (ad.targetAudience != null) {
      selectedAudiences.addAll(ad.targetAudience!);
    }
    if (ad.placement != null) {
      selectedPlacements.addAll(ad.placement!);
    }
  }

  @override
  void onClose() {
    budgetController.dispose();
    durationController.dispose();
    super.onClose();
  }

  void toggleAudience(String audience) {
    if (selectedAudiences.contains(audience)) {
      selectedAudiences.remove(audience);
    } else {
      selectedAudiences.add(audience);
    }
  }

  void togglePlacement(String placement) {
    if (selectedPlacements.contains(placement)) {
      selectedPlacements.remove(placement);
    } else {
      selectedPlacements.add(placement);
    }
  }

  Future<void> predict() async {
    if (budgetController.text.isEmpty) {
      Get.snackbar('提示', '请输入预算金额');
      return;
    }
    if (durationController.text.isEmpty) {
      Get.snackbar('提示', '请输入投放天数');
      return;
    }
    if (selectedAudiences.isEmpty) {
      Get.snackbar('提示', '请选择目标受众');
      return;
    }
    if (selectedPlacements.isEmpty) {
      Get.snackbar('提示', '请选择投放位置');
      return;
    }

    isLoading.value = true;
    try {
      final result = await _adApi.predictAdPerformance(
        ad.id,
        {
          'budget': double.parse(budgetController.text),
          'duration': int.parse(durationController.text),
          'target_audience': selectedAudiences.toList(),
          'placement': selectedPlacements.toList(),
        },
      );
      predictionResult.value = result;

      // 获取投放建议
      final suggestions = await _adApi.getPlacementSuggestions(
        ad.id,
        {
          'budget': double.parse(budgetController.text),
          'target_audience': selectedAudiences.toList(),
          'prediction_result': result,
        },
      );

      // 显示建议对话框
      Get.dialog(
        AlertDialog(
          title: const Text('投放建议'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...suggestions.map((suggestion) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline, size: 16.r, color: Colors.orange),
                    SizedBox(width: 8.w),
                    Expanded(child: Text(suggestion)),
                  ],
                ),
              )),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('知道了'),
            ),
          ],
        ),
      );
    } catch (e) {
      Get.snackbar('错误', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // 获取历史效果数据
  Future<Map<String, dynamic>> getHistoricalPerformance() async {
    try {
      return await _adApi.getAdHistoricalPerformance(ad.id);
    } catch (e) {
      print('获取历史数据失败: $e');
      return {};
    }
  }

  // 获取同类广告效果数据
  Future<Map<String, dynamic>> getSimilarAdsPerformance() async {
    try {
      return await _adApi.getSimilarAdsPerformance(
        ad.id,
        {
          'category': ad.category,
          'target_audience': selectedAudiences.toList(),
          'placement': selectedPlacements.toList(),
        },
      );
    } catch (e) {
      print('获取同类广告数据失败: $e');
      return {};
    }
  }
} 