import 'package:get/get.dart';
import '../../models/ad.dart';
import '../../models/ad_stats.dart';
import '../../api/ad_api.dart';

class AdComparisonController extends GetxController {
  final AdApi _adApi = Get.find<AdApi>();
  
  final selectedAds = <Ad>[].obs;
  final statsMap = <String, AdStats>{}.obs;
  final isLoading = false.obs;
  final selectedMetric = '展示'.obs;
  final selectedRegionType = '省份'.obs;

  final isPredicting = false.obs;
  final predictionResults = <String, Map<String, dynamic>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    final initialAd = Get.arguments as Ad?;
    if (initialAd != null) {
      selectedAds.add(initialAd);
      loadStats();
    }
  }

  void changeMetric(String? metric) {
    if (metric != null) {
      selectedMetric.value = metric;
    }
  }

  List<String> get dates {
    if (statsMap.isEmpty) return [];
    return statsMap.values.first.dates;
  }

  double get maxTrendValue {
    if (statsMap.isEmpty) return 100;
    
    double maxValue = 0;
    for (final stats in statsMap.values) {
      List<int> data;
      switch (selectedMetric.value) {
        case '展示':
          data = stats.impressionTrend;
          break;
        case '点击':
          data = stats.clickTrend;
          break;
        case '互动':
          data = List.generate(stats.dates.length, (i) => 0); // 假设数据
          break;
        case '转化':
          data = List.generate(stats.dates.length, (i) => 0); // 假设数据
          break;
        default:
          data = [];
      }
      final localMax = data.isEmpty ? 0 : data.reduce((a, b) => a > b ? a : b);
      if (localMax > maxValue) maxValue = localMax.toDouble();
    }
    return maxValue;
  }

  Set<String> getAllDistributionKeys(Map<String, double> Function(AdStats) getData) {
    final allKeys = <String>{};
    for (final stats in statsMap.values) {
      allKeys.addAll(getData(stats).keys);
    }
    return allKeys;
  }

  Future<void> selectAdsForComparison() async {
    final selected = await Get.toNamed(
      Routes.AD_SELECTOR,
      arguments: selectedAds.map((ad) => ad.id).toList(),
    );

    if (selected != null && selected is List<Ad>) {
      selectedAds.value = selected;
      loadStats();
    }
  }

  void removeAd(Ad ad) {
    selectedAds.remove(ad);
    statsMap.remove(ad.id);
  }

  Future<void> loadStats() async {
    if (selectedAds.isEmpty) return;
    
    isLoading.value = true;
    try {
      for (final ad in selectedAds) {
        if (!statsMap.containsKey(ad.id)) {
          final stats = await _adApi.getAdStats(ad.id);
          statsMap[ad.id] = stats;
        }
      }
    } catch (e) {
      Get.snackbar('错误', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  double get maxMetricValue {
    if (statsMap.isEmpty) return 100;
    
    return statsMap.values.map((stats) => [
      stats.impressions.toDouble(),
      stats.clicks.toDouble(),
      (stats.likes + stats.comments + stats.shares).toDouble(),
      (stats.clicks * stats.cvr).toDouble(),
    ].reduce((a, b) => a > b ? a : b)).reduce((a, b) => a > b ? a : b) * 1.2;
  }

  Future<void> predictAdPerformance(Ad ad) async {
    isPredicting.value = true;
    try {
      final result = await _adApi.predictAdPerformance(
        ad.id,
        {
          'budget': ad.budget,
          'target_audience': ad.targetAudience,
          'placement': ad.placement,
          'duration': ad.duration,
        },
      );
      predictionResults[ad.id] = result;
    } catch (e) {
      Get.snackbar('错误', '预测失败: ${e.toString()}');
    } finally {
      isPredicting.value = false;
    }
  }

  Future<List<String>> getPlacementSuggestions(Ad ad) async {
    try {
      final suggestions = await _adApi.getPlacementSuggestions(
        ad.id,
        {
          'budget': ad.budget,
          'target_audience': ad.targetAudience,
          'historical_performance': statsMap[ad.id],
        },
      );
      return suggestions;
    } catch (e) {
      Get.snackbar('错误', '获取建议失败: ${e.toString()}');
      return [];
    }
  }

  Future<void> exportComparisonReport() async {
    try {
      final url = await _adApi.exportComparisonReport(
        selectedAds.map((ad) => ad.id).toList(),
        {
          'metrics': [
            'impressions',
            'clicks',
            'interactions',
            'conversions',
          ],
          'date_range': {
            'start': dates.first,
            'end': dates.last,
          },
          'include_predictions': true,
        },
      );

      await Get.find<DownloadService>().downloadFile(
        url,
        'ad_comparison_report.xlsx',
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

  Future<Map<String, List<String>>> getOptimizationSuggestions() async {
    try {
      final suggestions = await _adApi.getOptimizationSuggestions(
        selectedAds.map((ad) => ad.id).toList(),
      );
      return suggestions;
    } catch (e) {
      Get.snackbar('错误', '获取优化建议失败: ${e.toString()}');
      return {};
    }
  }
} 