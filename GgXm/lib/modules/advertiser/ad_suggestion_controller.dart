import 'package:get/get.dart';
import '../../models/ad.dart';
import '../../models/ad_suggestion.dart';
import '../../api/ad_api.dart';

class AdSuggestionController extends GetxController {
  final AdApi _adApi = Get.find<AdApi>();
  
  late Ad ad;
  final isLoading = false.obs;
  final suggestions = Rxn<AdSuggestion>();

  @override
  void onInit() {
    super.onInit();
    ad = Get.arguments as Ad;
    loadSuggestions();
  }

  Future<void> loadSuggestions() async {
    isLoading.value = true;
    try {
      // 获取广告历史数据
      final historicalData = await _adApi.getAdHistoricalPerformance(ad.id);
      
      // 获取同类广告数据
      final similarAdsData = await _adApi.getSimilarAdsPerformance(
        ad.id,
        {
          'category': ad.category,
          'target_audience': ad.targetAudience,
          'placement': ad.placement,
        },
      );

      // 获取投放建议
      final suggestion = await _adApi.getAdSuggestions(
        ad.id,
        {
          'historical_data': historicalData,
          'similar_ads_data': similarAdsData,
          'current_budget': ad.budget,
          'current_target_audience': ad.targetAudience,
          'current_placement': ad.placement,
        },
      );

      suggestions.value = suggestion;
    } catch (e) {
      Get.snackbar('错误', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // 导出建议报告
  Future<void> exportSuggestionReport() async {
    try {
      final url = await _adApi.exportAdSuggestionReport(
        ad.id,
        suggestions.value!,
      );

      await Get.find<DownloadService>().downloadFile(
        url,
        'ad_suggestion_report.pdf',
        onProgress: (progress) {
          Get.dialog(
            WillPopScope(
              onWillPop: () async => false,
              child: AlertDialog(
                title: const Text('导出中'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(value: progress),
                    const SizedBox(height: 16),
                    Text('${(progress * 100).toInt()}%'),
                  ],
                ),
              ),
            ),
            barrierDismissible: false,
          );
        },
      );
      Get.back(); // 关闭进度对话框
      Get.snackbar('成功', '报告已导出');
    } catch (e) {
      Get.snackbar('错误', e.toString());
    }
  }

  // 应用建议
  Future<void> applySuggestions() async {
    try {
      await _adApi.updateAdSettings(
        ad.id,
        {
          'budget': suggestions.value!.recommendedBudget,
          'target_audience': suggestions.value!.recommendedAudiences,
          'placement': suggestions.value!.recommendedPlacements
              .map((p) => p.name)
              .toList(),
          'duration': suggestions.value!.recommendedDuration,
        },
      );
      Get.snackbar('成功', '已应用建议设置');
      Get.back(); // 返回上一页
    } catch (e) {
      Get.snackbar('错误', e.toString());
    }
  }
} 