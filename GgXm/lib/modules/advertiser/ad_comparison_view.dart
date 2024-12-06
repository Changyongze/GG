import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/ad.dart';
import '../../models/ad_stats.dart';
import 'ad_comparison_controller.dart';

class AdComparisonView extends GetView<AdComparisonController> {
  const AdComparisonView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('数据对比分析'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: controller.selectAdsForComparison,
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
            children: [
              _buildAdSelector(),
              if (controller.selectedAds.isNotEmpty) ...[
                SizedBox(height: 24.h),
                _buildMetricsComparison(),
                SizedBox(height: 24.h),
                _buildTrendComparison(),
                SizedBox(height: 24.h),
                _buildAudienceComparison(),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildAdSelector() {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: controller.selectedAds.map((ad) {
        return Chip(
          label: Text(ad.title),
          onDeleted: () => controller.removeAd(ad),
          deleteIcon: const Icon(Icons.close, size: 18),
        );
      }).toList(),
    );
  }

  Widget _buildMetricsComparison() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '核心指标对比',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            AspectRatio(
              aspectRatio: 1.5,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: controller.maxMetricValue,
                  barGroups: _buildBarGroups(),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 10.sp,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final metrics = ['展示', '点击', '互动', '转化'];
                          return Text(
                            metrics[value.toInt()],
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 10.sp,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    final metrics = ['impressions', 'clicks', 'interactions', 'conversions'];
    final colors = [Colors.blue, Colors.red, Colors.green, Colors.purple];

    return List.generate(metrics.length, (index) {
      return BarChartGroupData(
        x: index,
        barRods: controller.selectedAds.asMap().entries.map((entry) {
          final adIndex = entry.key;
          final ad = entry.value;
          final stats = controller.statsMap[ad.id]!;
          
          double value;
          switch (metrics[index]) {
            case 'impressions':
              value = stats.impressions.toDouble();
              break;
            case 'clicks':
              value = stats.clicks.toDouble();
              break;
            case 'interactions':
              value = (stats.likes + stats.comments + stats.shares).toDouble();
              break;
            case 'conversions':
              value = (stats.clicks * stats.cvr).toDouble();
              break;
            default:
              value = 0;
          }

          return BarChartRodData(
            toY: value,
            color: colors[adIndex % colors.length],
            width: 12.w,
          );
        }).toList(),
      );
    });
  }

  Widget _buildTrendComparison() {
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
                  '趋势对比',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                DropdownButton<String>(
                  value: controller.selectedMetric.value,
                  items: ['展示', '点击', '互动', '转化'].map((metric) {
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
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 10.sp,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= controller.dates.length) {
                            return const SizedBox();
                          }
                          return Text(
                            controller.dates[value.toInt()],
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 10.sp,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: _buildLineBarsData(),
                  minY: 0,
                  maxY: controller.maxTrendValue * 1.2,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Wrap(
              spacing: 16.w,
              runSpacing: 8.h,
              children: _buildTrendLegends(),
            ),
          ],
        ),
      ),
    );
  }

  List<LineChartBarData> _buildLineBarsData() {
    final colors = [Colors.blue, Colors.red, Colors.green, Colors.purple];
    
    return controller.selectedAds.asMap().entries.map((entry) {
      final index = entry.key;
      final ad = entry.value;
      final stats = controller.statsMap[ad.id]!;
      
      List<double> data;
      switch (controller.selectedMetric.value) {
        case '展示':
          data = stats.impressionTrend.map((e) => e.toDouble()).toList();
          break;
        case '点击':
          data = stats.clickTrend.map((e) => e.toDouble()).toList();
          break;
        case '互动':
          // 假设有互动趋势数据
          data = List.generate(stats.dates.length, (i) => 0);
          break;
        case '转化':
          // 假设有转化趋势数据
          data = List.generate(stats.dates.length, (i) => 0);
          break;
        default:
          data = [];
      }

      return LineChartBarData(
        spots: data.asMap().entries.map((e) {
          return FlSpot(e.key.toDouble(), e.value);
        }).toList(),
        isCurved: true,
        color: colors[index % colors.length],
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          color: colors[index % colors.length].withOpacity(0.1),
        ),
      );
    }).toList();
  }

  List<Widget> _buildTrendLegends() {
    final colors = [Colors.blue, Colors.red, Colors.green, Colors.purple];
    
    return controller.selectedAds.asMap().entries.map((entry) {
      final index = entry.key;
      final ad = entry.value;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12.w,
            height: 2.h,
            color: colors[index % colors.length],
          ),
          SizedBox(width: 4.w),
          Text(
            ad.title,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildAudienceComparison() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '受众分析对比',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            _buildDistributionComparison(
              '年龄分布',
              (stats) => stats.ageDistribution,
              Colors.orange,
            ),
            SizedBox(height: 24.h),
            _buildDistributionComparison(
              '性别分布',
              (stats) => stats.genderDistribution,
              Colors.blue,
            ),
            SizedBox(height: 24.h),
            _buildDistributionComparison(
              '兴趣分布',
              (stats) => stats.interestDistribution,
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistributionComparison(
    String title,
    Map<String, double> Function(AdStats) getData,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 12.h),
        ...controller.getAllDistributionKeys(getData).map((key) {
          return Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 80.w,
                    child: Text(
                      key,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: controller.selectedAds.map((ad) {
                        final stats = controller.statsMap[ad.id]!;
                        final value = getData(stats)[key] ?? 0.0;
                        return Expanded(
                          child: Container(
                            height: 16.h,
                            margin: EdgeInsets.symmetric(horizontal: 2.w),
                            decoration: BoxDecoration(
                              color: color.withOpacity(value),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
            ],
          );
        }),
      ],
    );
  }
} 