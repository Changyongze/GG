import 'package:get/get.dart';
import '../../models/ad_analytics.dart';
import '../../api/ad_api.dart';
import 'package:fl_chart/fl_chart.dart';

class AdAnalyticsController extends GetxController {
  final AdApi _adApi = Get.find<AdApi>();
  final isLoading = false.obs;
  final analytics = Rx<AdAnalytics>(AdAnalytics.empty());
  final selectedMetric = '展示量'.obs;
  final dateRange = Rx<DateTimeRange?>(null);

  // 图表数据
  final chartData = <FlSpot>[].obs;
  final timeLabels = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadAnalytics();
  }

  Future<void> loadAnalytics() async {
    isLoading.value = true;
    try {
      final data = await _adApi.getAdAnalytics(
        startDate: dateRange.value?.start,
        endDate: dateRange.value?.end,
      );
      analytics.value = data;
      _updateChartData();
    } catch (e) {
      Get.snackbar('错误', '加载数据失败');
    } finally {
      isLoading.value = false;
    }
  }

  void changeMetric(String? metric) {
    if (metric != null) {
      selectedMetric.value = metric;
      _updateChartData();
    }
  }

  void _updateChartData() {
    final data = analytics.value;
    chartData.clear();
    timeLabels.clear();

    switch (selectedMetric.value) {
      case '展示量':
        for (var i = 0; i < data.impressionHistory.length; i++) {
          chartData.add(FlSpot(i.toDouble(), data.impressionHistory[i].toDouble()));
          timeLabels.add(data.timeLabels[i]);
        }
        break;
      case '点击量':
        for (var i = 0; i < data.clickHistory.length; i++) {
          chartData.add(FlSpot(i.toDouble(), data.clickHistory[i].toDouble()));
          timeLabels.add(data.timeLabels[i]);
        }
        break;
      // ... 其他指标
    }
  }

  LineChartData getChartData() {
    return LineChartData(
      // ... 图表配置
    );
  }

  Future<void> exportReport() async {
    try {
      final path = await _adApi.exportAnalyticsReport(
        analytics.value,
        dateRange: dateRange.value,
      );
      Get.snackbar('成功', '报告已导出至: $path');
    } catch (e) {
      Get.snackbar('错误', '导出报告失败');
    }
  }
}