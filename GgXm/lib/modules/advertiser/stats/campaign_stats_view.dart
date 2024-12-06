import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'campaign_stats_controller.dart';
import 'package:fl_chart/fl_chart.dart';

class CampaignStatsView extends GetView<CampaignStatsController> {
  const CampaignStatsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('数据分析'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () => _showExportDialog(context),
          ),
          TextButton(
            onPressed: controller.selectDateRange,
            child: Obx(() {
              final range = controller.selectedDateRange.value;
              if (range == null) return const Text('选择日期');
              return Text(
                '${DateFormat('MM-dd').format(range.start)} - '
                '${DateFormat('MM-dd').format(range.end)}',
                style: const TextStyle(color: Colors.white),
              );
            }),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final stats = controller.stats.value;
        if (stats == null) {
          return const Center(child: Text('暂无数据'));
        }

        return RefreshIndicator(
          onRefresh: controller.refreshStats,
          child: ListView(
            padding: EdgeInsets.all(16.r),
            children: [
              _buildOverview(stats),
              SizedBox(height: 24.h),
              _buildTrendChart(stats),
              SizedBox(height: 24.h),
              _buildAudienceAnalysis(stats),
              SizedBox(height: 24.h),
              _buildRegionAnalysis(stats),
              SizedBox(height: 24.h),
              _buildScheduleAnalysis(stats),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildOverview(CampaignStats stats) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '数据概览',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16.h,
              crossAxisSpacing: 16.w,
              childAspectRatio: 2,
              children: controller.metricOptions.map((option) {
                final value = stats.overview[option['value']] as double;
                final trend = stats.overview['${option['value']}_trend'] as double;
                return _buildMetricCard(
                  label: option['label'] as String,
                  value: controller.formatMetricValue(value, option['value'] as String),
                  trend: trend,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required double trend,
  }) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Icon(
                trend >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                size: 12.r,
                color: trend >= 0 ? Colors.red : Colors.green,
              ),
              SizedBox(width: 4.w),
              Text(
                '${trend.abs().toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: trend >= 0 ? Colors.red : Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendChart(CampaignStats stats) {
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
                  '趋势分析',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                DropdownButton<String>(
                  value: controller.selectedMetric.value,
                  items: controller.metricOptions.map((option) {
                    return DropdownMenuItem(
                      value: option['value'] as String,
                      child: Text(option['label'] as String),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) controller.selectMetric(value);
                  },
                ),
              ],
            ),
            SizedBox(height: 16.h),
            AspectRatio(
              aspectRatio: 1.7,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40.w,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            controller.formatMetricValue(
                              value,
                              controller.selectedMetric.value,
                            ),
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
                        reservedSize: 22.h,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < stats.dailyStats.length) {
                            final date = DateTime.parse(stats.dailyStats[value.toInt()]['date']);
                            return Text(
                              DateFormat('MM-dd').format(date),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 10.sp,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _getSpots(stats),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.1),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: Colors.black87,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final date = DateTime.parse(
                            stats.dailyStats[spot.x.toInt()]['date'],
                          );
                          return LineTooltipItem(
                            '${DateFormat('MM-dd').format(date)}\n'
                            '${controller.formatMetricValue(spot.y, controller.selectedMetric.value)}',
                            TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                            ),
                          );
                        }).toList();
                      },
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

  List<FlSpot> _getSpots(CampaignStats stats) {
    return List.generate(stats.dailyStats.length, (index) {
      final metric = controller.selectedMetric.value;
      final value = stats.dailyStats[index][metric]?.toDouble() ?? 0.0;
      return FlSpot(index.toDouble(), value);
    });
  }

  Widget _buildAudienceAnalysis(CampaignStats stats) {
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
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '性别分布',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8.h),
                      AspectRatio(
                        aspectRatio: 1,
                        child: PieChart(
                          PieChartData(
                            sections: _getGenderSections(stats.audience['gender']),
                            centerSpaceRadius: 40.r,
                            sectionsSpace: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '年龄分布',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8.h),
                      AspectRatio(
                        aspectRatio: 1,
                        child: PieChart(
                          PieChartData(
                            sections: _getAgeSections(stats.audience['age']),
                            centerSpaceRadius: 40.r,
                            sectionsSpace: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            Text(
              '兴趣分布',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8.h),
            _buildInterestChart(stats.audience['interests']),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _getGenderSections(Map<String, dynamic> data) {
    final colors = [Colors.blue, Colors.pink];
    final labels = {'male': '男', 'female': '女'};
    
    return data.entries.map((entry) {
      final index = data.keys.toList().indexOf(entry.key);
      return PieChartSectionData(
        value: entry.value['percentage'].toDouble(),
        title: '${labels[entry.key]}\n${entry.value['percentage']}%',
        radius: 100.r,
        titleStyle: TextStyle(
          fontSize: 12.sp,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        color: colors[index],
      );
    }).toList();
  }

  List<PieChartSectionData> _getAgeSections(Map<String, dynamic> data) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
    ];
    
    return data.entries.map((entry) {
      final index = data.keys.toList().indexOf(entry.key);
      return PieChartSectionData(
        value: entry.value['percentage'].toDouble(),
        title: '${entry.key}\n${entry.value['percentage']}%',
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

  Widget _buildInterestChart(Map<String, dynamic> data) {
    final sortedData = data.entries.toList()
      ..sort((a, b) => (b.value['percentage'] as num)
          .compareTo(a.value['percentage'] as num));

    return Column(
      children: sortedData.map((entry) {
        return Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Row(
            children: [
              SizedBox(
                width: 80.w,
                child: Text(
                  entry.key,
                  style: TextStyle(fontSize: 12.sp),
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
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRegionAnalysis(CampaignStats stats) {
    final sortedRegions = stats.regions.entries.toList()
      ..sort((a, b) => (b.value['percentage'] as num)
          .compareTo(a.value['percentage'] as num));

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
            // TODO: 添加地图热力图
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sortedRegions.length,
              separatorBuilder: (context, index) => Divider(height: 16.h),
              itemBuilder: (context, index) {
                final entry = sortedRegions[index];
                return Row(
                  children: [
                    Container(
                      width: 24.r,
                      height: 24.r,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    SizedBox(
                      width: 80.w,
                      child: Text(
                        entry.key,
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
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleAnalysis(CampaignStats stats) {
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
                  '时段分析',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                DropdownButton<String>(
                  value: controller.selectedMetric.value,
                  items: controller.metricOptions.map((option) {
                    return DropdownMenuItem(
                      value: option['value'] as String,
                      child: Text(option['label'] as String),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) controller.selectMetric(value);
                  },
                ),
              ],
            ),
            SizedBox(height: 16.h),
            AspectRatio(
              aspectRatio: 1.7,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxValue(stats.schedule),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.black87,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final hour = group.x.toInt();
                        final metric = controller.selectedMetric.value;
                        final value = stats.schedule['$hour']?[metric]?.toDouble() ?? 0.0;
                        return BarTooltipItem(
                          '$hour:00\n${controller.formatMetricValue(value, metric)}',
                          TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                          ),
                        );
                      },
                    ),
                  ),
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
                            controller.formatMetricValue(value, controller.selectedMetric.value),
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.grey[600],
                            ),
                          );
                        },
                        reservedSize: 40,
                        interval: _getInterval(stats.schedule),
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: _getInterval(stats.schedule),
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[300],
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: _getScheduleBarGroups(stats.schedule),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            _buildScheduleHighlights(stats.schedule),
            SizedBox(height: 16.h),
            _buildScheduleInsights(stats.schedule),
          ],
        ),
      ),
    );
  }

  double _getMaxValue(Map<String, dynamic> schedule) {
    final metric = controller.selectedMetric.value;
    double maxValue = 0;
    for (var i = 0; i < 24; i++) {
      final value = schedule['$i']?[metric]?.toDouble() ?? 0.0;
      if (value > maxValue) maxValue = value;
    }
    return maxValue * 1.2; // 留出20%的空间
  }

  double _getInterval(Map<String, dynamic> schedule) {
    final maxValue = _getMaxValue(schedule);
    return maxValue / 5; // 将Y轴分5个区间
  }

  Widget _buildScheduleInsights(Map<String, dynamic> schedule) {
    final metric = controller.selectedMetric.value;
    final metricLabel = controller.getMetricLabel(metric);
    
    // 计算统计数据
    final values = List.generate(24, (i) => schedule['$i']?[metric]?.toDouble() ?? 0.0);
    final validValues = values.where((v) => v > 0).toList();
    final avgValue = validValues.isNotEmpty ? validValues.reduce((a, b) => a + b) / validValues.length : 0.0;
    final maxValue = validValues.isNotEmpty ? validValues.reduce((a, b) => a > b ? a : b) : 0.0;
    final minValue = validValues.isNotEmpty ? validValues.reduce((a, b) => a < b ? a : b) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '数据洞察',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          '• 平均每小时$metricLabel为${controller.formatMetricValue(avgValue, metric)}',
          style: TextStyle(fontSize: 12.sp, height: 1.5),
        ),
        Text(
          '• 最高$metricLabel为${controller.formatMetricValue(maxValue, metric)}，'
          '最低为${controller.formatMetricValue(minValue, metric)}',
          style: TextStyle(fontSize: 12.sp, height: 1.5),
        ),
        Text(
          '• 建议在效果最好的时段增加投放预算，提高广告效果',
          style: TextStyle(fontSize: 12.sp, height: 1.5),
        ),
        Text(
          '• 可以考虑在效果较差的时段降低出价或暂停投放',
          style: TextStyle(fontSize: 12.sp, height: 1.5),
        ),
        if (metric == 'cost') Text(
          '• 建议优化高成本时段的投放策略，控制广告支出',
          style: TextStyle(fontSize: 12.sp, height: 1.5),
        ),
        if (metric == 'ctr' || metric == 'cvr') Text(
          '• 可以参考高转化时段的投放策略，优化其他时段效果',
          style: TextStyle(fontSize: 12.sp, height: 1.5),
        ),
      ],
    );
  }

  List<BarChartGroupData> _getScheduleBarGroups(Map<String, dynamic> schedule) {
    final metric = controller.selectedMetric.value;
    return List.generate(24, (hour) {
      final value = schedule['$hour']?[metric]?.toDouble() ?? 0.0;
      return BarChartGroupData(
        x: hour,
        barRods: [
          BarChartRodData(
            toY: value,
            color: _getBarColor(value, metric),
            width: 16.w,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ],
      );
    });
  }

  Color _getBarColor(double value, String metric) {
    switch (metric) {
      case 'ctr':
      case 'cvr':
        if (value >= 5) return Colors.red;
        if (value >= 3) return Colors.orange;
        if (value >= 2) return Colors.blue;
        if (value >= 1) return Colors.green;
        return Colors.grey;
      case 'cost':
        // 成本指标颜色反转，越高越红
        if (value >= 1000) return Colors.red;
        if (value >= 500) return Colors.orange;
        if (value >= 200) return Colors.blue;
        if (value >= 100) return Colors.green;
        return Colors.grey;
      default:
        // 展示量、点击量等常规指标
        if (value >= _getMaxValue(schedule) * 0.8) return Colors.red;
        if (value >= _getMaxValue(schedule) * 0.6) return Colors.orange;
        if (value >= _getMaxValue(schedule) * 0.4) return Colors.blue;
        if (value >= _getMaxValue(schedule) * 0.2) return Colors.green;
        return Colors.grey;
    }
  }

  Widget _buildScheduleHighlights(Map<String, dynamic> schedule) {
    final metric = controller.selectedMetric.value;
    final metricLabel = controller.getMetricLabel(metric);
    
    // 根据选中的指标排序
    final sortedHours = schedule.entries.toList()
      ..sort((a, b) => (b.value[metric] as num)
          .compareTo(a.value[metric] as num));

    final bestHours = sortedHours.take(3).toList();
    final worstHours = sortedHours.reversed.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '时段洞察',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        _buildHighlightItem(
          '$metricLabel最高时段',
          bestHours.map((e) => '${e.key}:00').join('、'),
          '平均${metricLabel}为${controller.formatMetricValue(
            bestHours.map((e) => e.value[metric] as num).reduce((a, b) => a + b) / 3,
            metric,
          )}',
          Colors.green,
        ),
        SizedBox(height: 8.h),
        _buildHighlightItem(
          '$metricLabel最低时段',
          worstHours.map((e) => '${e.key}:00').join('、'),
          '平均${metricLabel}为${controller.formatMetricValue(
            worstHours.map((e) => e.value[metric] as num).reduce((a, b) => a + b) / 3,
            metric,
          )}',
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildHighlightItem(
    String title,
    String hours,
    String description,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 4.w,
          height: 32.h,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                hours,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Text(
          description,
          style: TextStyle(
            fontSize: 12.sp,
            color: color,
          ),
        ),
      ],
    );
  }

  Future<void> _showExportDialog(BuildContext context) async {
    final format = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('导出报告'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('PDF格式'),
              onTap: () => Navigator.pop(context, 'pdf'),
            ),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Excel格式'),
              onTap: () => Navigator.pop(context, 'excel'),
            ),
          ],
        ),
      ),
    );

    if (format != null) {
      final stats = controller.stats.value;
      if (stats == null) return;

      try {
        await controller.exportReport(
          stats,
          format: format,
          dateRange: controller.selectedDateRange.value!,
        );
        Get.snackbar('提示', '报告导出成功');
      } catch (e) {
        Get.snackbar('错误', '报告导出失败：${e.toString()}');
      }
    }
  }

  Widget _buildComparisonButton() {
    return TextButton.icon(
      onPressed: () => _showComparisonDialog(Get.context!),
      icon: const Icon(Icons.compare_arrows),
      label: const Text('数据对比'),
    );
  }

  Future<void> _showComparisonDialog(BuildContext context) async {
    final result = await showDialog<DateTimeRange>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择对比时间段'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '当前时间段：${DateFormat('yyyy-MM-dd').format(controller.selectedDateRange.value!.start)} 至 '
              '${DateFormat('yyyy-MM-dd').format(controller.selectedDateRange.value!.end)}',
              style: TextStyle(fontSize: 12.sp),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () async {
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  Navigator.pop(context, picked);
                }
              },
              child: const Text('选择对比时间段'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      await controller.loadComparisonStats(result);
    }
  }
} 