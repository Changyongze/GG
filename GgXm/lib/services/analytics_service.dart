import 'package:get/get.dart';
import '../models/activity.dart';

class AnalyticsService extends GetxService {
  // 获取今日统计数据
  Future<DailyStats> getTodayStats() async {
    // TODO: 实现真实的API调用
    await Future.delayed(const Duration(seconds: 1));
    return DailyStats(
      impressions: 1234,
      clicks: 567,
      revenue: 890.12,
      activeUsers: 345,
    );
  }

  // 获取趋势数据
  Future<Trends> getTrends() async {
    // TODO: 实现真实的API调用
    await Future.delayed(const Duration(seconds: 1));
    return Trends(
      impressions: 12.3,
      clicks: 8.9,
      revenue: 15.6,
      users: -3.2,
    );
  }

  // 获取图表数据
  Future<ChartData> getChartData({
    required String metric,
    required int days,
  }) async {
    // TODO: 实现真实的API调用
    await Future.delayed(const Duration(seconds: 1));
    return ChartData(
      values: List.generate(7, (i) => (i * 100 + Random().nextInt(50)).toDouble()),
      labels: List.generate(7, (i) => '${DateTime.now().subtract(Duration(days: 6 - i)).day}日'),
    );
  }

  // 获取最近活动
  Future<List<Activity>> getRecentActivities() async {
    // TODO: 实现真实的API调用
    await Future.delayed(const Duration(seconds: 1));
    return [
      Activity(
        id: '1',
        type: 'ad_view',
        title: '广告观看',
        description: '用户观看了广告"夏季大促销"',
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      Activity(
        id: '2',
        type: 'coupon_exchange',
        title: '优惠券兑换',
        description: '用户兑换了"满100减20"优惠券',
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      // ... 更多活动数据
    ];
  }
}

class DailyStats {
  final int impressions;
  final int clicks;
  final double revenue;
  final int activeUsers;

  DailyStats({
    required this.impressions,
    required this.clicks,
    required this.revenue,
    required this.activeUsers,
  });
}

class Trends {
  final double impressions;
  final double clicks;
  final double revenue;
  final double users;

  Trends({
    required this.impressions,
    required this.clicks,
    required this.revenue,
    required this.users,
  });
}

class ChartData {
  final List<double> values;
  final List<String> labels;

  ChartData({
    required this.values,
    required this.labels,
  });
} 