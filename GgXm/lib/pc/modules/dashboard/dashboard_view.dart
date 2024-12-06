import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dashboard_controller.dart';
import 'widgets/overview_card.dart';
import 'widgets/trend_chart.dart';
import 'widgets/activity_list.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 数据概览卡片
              Row(
                children: [
                  Expanded(
                    child: OverviewCard(
                      title: '今日广告展示',
                      value: controller.todayImpressions.value.toString(),
                      trend: controller.impressionsTrend.value,
                      icon: Icons.visibility,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: OverviewCard(
                      title: '今日点击量',
                      value: controller.todayClicks.value.toString(),
                      trend: controller.clicksTrend.value,
                      icon: Icons.touch_app,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: OverviewCard(
                      title: '今日收入',
                      value: '¥${controller.todayRevenue.value}',
                      trend: controller.revenueTrend.value,
                      icon: Icons.attach_money,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: OverviewCard(
                      title: '活跃用户',
                      value: controller.activeUsers.value.toString(),
                      trend: controller.usersTrend.value,
                      icon: Icons.people,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 趋势图表
              Container(
                height: 400,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          '数据趋势',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        DropdownButton<String>(
                          value: controller.selectedMetric.value,
                          items: const [
                            DropdownMenuItem(value: 'impressions', child: Text('展示量')),
                            DropdownMenuItem(value: 'clicks', child: Text('点击量')),
                            DropdownMenuItem(value: 'revenue', child: Text('收入')),
                            DropdownMenuItem(value: 'users', child: Text('用户数')),
                          ],
                          onChanged: controller.changeMetric,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: TrendChart(
                        data: controller.chartData,
                        labels: controller.timeLabels,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 最近活动列表
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '最近活动',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ActivityList(
                      activities: controller.recentActivities,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
} 