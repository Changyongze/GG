import 'package:get/get.dart';
import '../../services/analytics_service.dart';
import '../../models/activity.dart';

class DashboardController extends GetxController {
  final AnalyticsService _analyticsService = Get.find<AnalyticsService>();
  
  // 加载状态
  final isLoading = false.obs;
  
  // 今日数据
  final todayImpressions = 0.obs;
  final todayClicks = 0.obs;
  final todayRevenue = 0.0.obs;
  final activeUsers = 0.obs;
  
  // 趋势数据
  final impressionsTrend = 0.0.obs;
  final clicksTrend = 0.0.obs;
  final revenueTrend = 0.0.obs;
  final usersTrend = 0.0.obs;
  
  // 图表数据
  final selectedMetric = 'impressions'.obs;
  final chartData = <double>[].obs;
  final timeLabels = <String>[].obs;
  
  // 活动列表
  final recentActivities = <Activity>[].obs;
  
  // 定时刷新
  Timer? _refreshTimer;

  @override
  void onInit() {
    super.onInit();
    loadData();
    _startAutoRefresh();
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    super.onClose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => loadData(),
    );
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      // 加载今日数据
      final todayStats = await _analyticsService.getTodayStats();
      todayImpressions.value = todayStats.impressions;
      todayClicks.value = todayStats.clicks;
      todayRevenue.value = todayStats.revenue;
      activeUsers.value = todayStats.activeUsers;
      
      // 加载趋势数据
      final trends = await _analyticsService.getTrends();
      impressionsTrend.value = trends.impressions;
      clicksTrend.value = trends.clicks;
      revenueTrend.value = trends.revenue;
      usersTrend.value = trends.users;
      
      // 加载图表数据
      await loadChartData();
      
      // 加载活动列表
      final activities = await _analyticsService.getRecentActivities();
      recentActivities.value = activities;
      
    } catch (e) {
      Get.snackbar('错误', '加载数据失败');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadChartData() async {
    try {
      final data = await _analyticsService.getChartData(
        metric: selectedMetric.value,
        days: 7,
      );
      
      chartData.value = data.values;
      timeLabels.value = data.labels;
      
    } catch (e) {
      print('加载图表数据失败: $e');
    }
  }

  void changeMetric(String? metric) {
    if (metric != null && metric != selectedMetric.value) {
      selectedMetric.value = metric;
      loadChartData();
    }
  }
} 