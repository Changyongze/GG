import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'ad_analytics_controller.dart';

class AdAnalyticsView extends GetView<AdAnalyticsController> {
  const AdAnalyticsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('广告分析'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () => _showDateRangePicker(context),
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: controller.exportReport,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return SingleChildScrollView(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOverview(),
              SizedBox(height: 24.h),
              _buildPerformanceChart(),
              SizedBox(height: 24.h),
              _buildAudienceAnalysis(),
              SizedBox(height: 24.h),
              _buildRegionDistribution(),
              SizedBox(height: 24.h),
              _buildEngagementMetrics(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildOverview() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '总览',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    '展示次数',
                    controller.analytics.value.impressions.toString(),
                    Icons.visibility,
                    Colors.blue,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildMetricCard(
                    '点击次数',
                    controller.analytics.value.clicks.toString(),
                    Icons.touch_app,
                    Colors.green,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildMetricCard(
                    '转化率',
                    '${(controller.analytics.value.conversionRate * 100).toStringAsFixed(2)}%',
                    Icons.trending_up,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24.r),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceChart() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '效果趋势',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                DropdownButton<String>(
                  value: controller.selectedMetric.value,
                  items: [
                    '展示量',
                    '点击量',
                    '转化率',
                    '花费',
                  ].map((metric) {
                    return DropdownMenuItem(
                      value: metric,
                      child: Text(metric),
                    );
                  }).toList(),
                  onChanged: controller.changeMetric,
                ),
              ],
            ),
            SizedBox(height: 16.h),
            AspectRatio(
              aspectRatio: 1.5,
              child: LineChart(controller.getChartData()),
            ),
          ],
        ),
      ),
    );
  }

  // ... 继续实现其他部分
} 