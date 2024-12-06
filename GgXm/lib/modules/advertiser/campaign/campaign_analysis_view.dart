import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'campaign_analysis_controller.dart';

class CampaignAnalysisView extends GetView<CampaignAnalysisController> {
  const CampaignAnalysisView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('广告效果分析'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final analysis = controller.analysis.value!;
        return ListView(
          padding: EdgeInsets.all(16.r),
          children: [
            _buildPerformanceCard(analysis),
            SizedBox(height: 16.h),
            _buildAudienceAnalysis(analysis),
            SizedBox(height: 16.h),
            _buildTimingAnalysis(analysis),
            SizedBox(height: 16.h),
            _buildRegionAnalysis(analysis),
            SizedBox(height: 16.h),
            _buildSuggestions(analysis),
          ],
        );
      }),
    );
  }

  Widget _buildPerformanceCard(CampaignAnalysis analysis) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '效果指标',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPerformanceItem(
                  label: '展示成本',
                  value: '¥${analysis.performance['cpm']?.toStringAsFixed(2)}',
                  trend: analysis.performance['cpm_trend'],
                ),
                _buildPerformanceItem(
                  label: '点击成本',
                  value: '¥${analysis.performance['cpc']?.toStringAsFixed(2)}',
                  trend: analysis.performance['cpc_trend'],
                ),
                _buildPerformanceItem(
                  label: '转化成本',
                  value: '¥${analysis.performance['cpa']?.toStringAsFixed(2)}',
                  trend: analysis.performance['cpa_trend'],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceItem({
    required String label,
    required String value,
    required double trend,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey,
          ),
        ),
        SizedBox(height: 4.h),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              trend > 0 ? Icons.arrow_upward : Icons.arrow_downward,
              size: 12.r,
              color: trend > 0 ? Colors.red : Colors.green,
            ),
            Text(
              '${trend.abs().toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 12.sp,
                color: trend > 0 ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAudienceAnalysis(CampaignAnalysis analysis) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '受众分析',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            AspectRatio(
              aspectRatio: 1.5,
              child: PieChart(
                PieChartData(
                  sections: _getAudienceSections(analysis.audience),
                  centerSpaceRadius: 40.r,
                  sectionsSpace: 2,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Wrap(
              spacing: 16.w,
              runSpacing: 8.h,
              children: _buildAudienceLegends(analysis.audience),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _getAudienceSections(Map<String, dynamic> audience) {
    final List<Color> colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
    ];

    return audience.entries.map((entry) {
      final index = audience.keys.toList().indexOf(entry.key);
      return PieChartSectionData(
        value: entry.value['percentage'].toDouble(),
        title: '${entry.value['percentage']}%',
        radius: 100.r,
        titleStyle: TextStyle(
          fontSize: 12.sp,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        color: colors[index % colors.length],
      );
    }).toList();
  }

  List<Widget> _buildAudienceLegends(Map<String, dynamic> audience) {
    final List<Color> colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
    ];

    return audience.entries.map((entry) {
      final index = audience.keys.toList().indexOf(entry.key);
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12.r,
            height: 12.r,
            decoration: BoxDecoration(
              color: colors[index % colors.length],
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            entry.value['label'],
            style: TextStyle(fontSize: 12.sp),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildTimingAnalysis(CampaignAnalysis analysis) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '时段分析',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            AspectRatio(
              aspectRatio: 1.7,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}时',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.grey[600],
                            ),
                          );
                        },
                        reservedSize: 22,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.grey[600],
                            ),
                          );
                        },
                        reservedSize: 28,
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: _getTimeBarGroups(analysis.timing),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _getTimeBarGroups(Map<String, dynamic> timing) {
    return timing.entries.map((entry) {
      return BarChartGroupData(
        x: int.parse(entry.key),
        barRods: [
          BarChartRodData(
            toY: entry.value['percentage'].toDouble(),
            color: Colors.blue,
            width: 16.w,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildRegionAnalysis(CampaignAnalysis analysis) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '地域分析',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            _buildRegionList(analysis.region),
          ],
        ),
      ),
    );
  }

  Widget _buildRegionList(Map<String, dynamic> region) {
    final sortedRegions = region.entries.toList()
      ..sort((a, b) => (b.value['percentage'] as num)
          .compareTo(a.value['percentage'] as num));

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedRegions.length,
      separatorBuilder: (context, index) => Divider(height: 24.h),
      itemBuilder: (context, index) {
        final entry = sortedRegions[index];
        return Row(
          children: [
            SizedBox(
              width: 80.w,
              child: Text(
                entry.value['label'],
                style: TextStyle(fontSize: 14.sp),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  Container(
                    height: 16.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: entry.value['percentage'] / 100,
                    child: Container(
                      height: 16.h,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            SizedBox(
              width: 48.w,
              child: Text(
                '${entry.value['percentage']}%',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSuggestions(CampaignAnalysis analysis) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, size: 20.r, color: Colors.orange),
                SizedBox(width: 8.w),
                Text(
                  '优化建议',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: analysis.suggestions.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 20.r,
                        height: 20.r,
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          analysis.suggestions[index],
                          style: TextStyle(
                            fontSize: 14.sp,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
} 