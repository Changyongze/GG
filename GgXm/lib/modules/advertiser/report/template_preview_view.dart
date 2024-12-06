import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'template_preview_controller.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';

class TemplatePreviewView extends GetView<TemplatePreviewController> {
  const TemplatePreviewView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('模板预览'),
      ),
      body: Obx(() {
        if (controller.template.value == null) {
          return const Center(child: Text('无预览数据'));
        }

        return Column(
          children: [
            _buildSectionTabs(),
            Expanded(
              child: PageView.builder(
                controller: PageController(
                  initialPage: controller.currentSection.value,
                ),
                onPageChanged: (index) => controller.currentSection.value = index,
                itemCount: controller.sections.length,
                itemBuilder: (context, index) {
                  final section = controller.sections[index];
                  return _buildSectionContent(section);
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSectionTabs() {
    return Container(
      height: 48.h,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: controller.sections.length,
        itemBuilder: (context, index) {
          final section = controller.sections[index];
          return Obx(() => Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: ChoiceChip(
              label: Text(controller.getSectionLabel(section['type'])),
              selected: controller.currentSection.value == index,
              onSelected: (selected) {
                if (selected) controller.currentSection.value = index;
              },
            ),
          ));
        },
      ),
    );
  }

  Widget _buildSectionContent(Map<String, dynamic> section) {
    final type = section['type'] as String;
    final metrics = List<String>.from(section['metrics']);
    final data = controller.getSectionData(type);

    if (data == null) {
      return const Center(child: Text('暂无数据'));
    }

    switch (type) {
      case 'overview':
        return _buildOverviewSection(metrics, data);
      case 'trend':
        return _buildTrendSection(metrics, data);
      case 'comparison':
        return _buildComparisonSection(metrics, data);
      case 'audience':
        return _buildAudienceSection(metrics, data);
      case 'region':
        return _buildRegionSection(metrics, data);
      case 'schedule':
        return _buildScheduleSection(metrics, data);
      default:
        return Center(
          child: Text('${controller.getSectionLabel(type)}开发中...'),
        );
    }
  }

  Widget _buildOverviewSection(List<String> metrics, Map<String, dynamic> data) {
    return ListView(
      padding: EdgeInsets.all(16.r),
      children: [
        Card(
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
                  children: metrics.map((metric) {
                    final value = data[metric] as num?;
                    return _buildMetricCard(
                      label: controller.getMetricLabel(metric),
                      value: controller.formatMetricValue(value, metric),
                      color: value != null ? controller.getMetricColor(metric, value) : Colors.grey,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
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
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendSection(List<String> metrics, List<dynamic> data) {
    return ListView(
      padding: EdgeInsets.all(16.r),
      children: [
        Card(
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
                      value: metrics.first,
                      items: metrics.map((metric) {
                        return DropdownMenuItem(
                          value: metric,
                          child: Text(controller.getMetricLabel(metric)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        // TODO: 切换指标
                      },
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                AspectRatio(
                  aspectRatio: 1.7,
                  child: charts.LineChart(
                    charts.LineChartData(
                      gridData: charts.FlGridData(show: false),
                      titlesData: charts.FlTitlesData(
                        leftTitles: charts.AxisTitles(
                          sideTitles: charts.SideTitles(
                            showTitles: true,
                            reservedSize: 40.w,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                controller.formatMetricValue(value, metrics.first),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 10.sp,
                                ),
                              );
                            },
                          ),
                        ),
                        bottomTitles: charts.AxisTitles(
                          sideTitles: charts.SideTitles(
                            showTitles: true,
                            reservedSize: 22.h,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= 0 && value.toInt() < data.length) {
                                final date = DateTime.parse(data[value.toInt()]['date']);
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
                        rightTitles: const charts.AxisTitles(
                          sideTitles: charts.SideTitles(showTitles: false),
                        ),
                        topTitles: const charts.AxisTitles(
                          sideTitles: charts.SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: charts.FlBorderData(show: false),
                      lineBarsData: [
                        charts.LineChartBarData(
                          spots: _getTrendSpots(data, metrics.first),
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 2,
                          isStrokeCapRound: true,
                          dotData: const charts.FlDotData(show: false),
                          belowBarData: charts.BarAreaData(
                            show: true,
                            color: Colors.blue.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<charts.FlSpot> _getTrendSpots(List<dynamic> data, String metric) {
    return List.generate(data.length, (index) {
      final item = data[index] as Map<String, dynamic>;
      final value = item[metric]?.toDouble() ?? 0.0;
      return charts.FlSpot(index.toDouble(), value);
    });
  }

  Widget _buildComparisonSection(List<String> metrics, Map<String, dynamic> data) {
    return ListView(
      padding: EdgeInsets.all(16.r),
      children: [
        Card(
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '同比分析',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.h),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: metrics.length,
                  separatorBuilder: (context, index) => Divider(height: 24.h),
                  itemBuilder: (context, index) {
                    final metric = metrics[index];
                    return _buildComparisonItem(
                      metric,
                      data['current'][metric] as num,
                      data['previous'][metric] as num,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonItem(String metric, num current, num previous) {
    final growth = ((current - previous) / previous * 100);
    final isPositive = growth >= 0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          controller.getMetricLabel(metric),
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.formatMetricValue(current, metric),
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '本期',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 4.h,
              ),
              decoration: BoxDecoration(
                color: (isPositive ? Colors.red : Colors.green).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 16.r,
                    color: isPositive ? Colors.red : Colors.green,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '${growth.abs().toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isPositive ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAudienceSection(List<String> metrics, Map<String, dynamic> data) {
    return ListView(
      padding: EdgeInsets.all(16.r),
      children: [
        Card(
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
                            child: charts.PieChart(
                              [
                                charts.Series<Map<String, dynamic>, String>(
                                  id: 'gender',
                                  data: [
                                    {'label': '男', 'value': data['gender']['male']},
                                    {'label': '女', 'value': data['gender']['female']},
                                  ],
                                  domainFn: (datum, _) => datum['label'] as String,
                                  measureFn: (datum, _) => datum['value'] as num,
                                  colorFn: (datum, index) => charts.ColorUtil.fromDartColor(
                                    index == 0 ? Colors.blue : Colors.pink,
                                  ),
                                  labelAccessorFn: (datum, _) => '${datum['label']}\n${datum['value']}%',
                                ),
                              ],
                              defaultRenderer: charts.ArcRendererConfig(
                                arcWidth: 60,
                                arcRendererDecorators: [
                                  charts.ArcLabelDecorator(
                                    labelPosition: charts.ArcLabelPosition.outside,
                                  ),
                                ],
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
                            child: charts.PieChart(
                              [
                                charts.Series<MapEntry<String, dynamic>, String>(
                                  id: 'age',
                                  data: data['age'].entries.toList(),
                                  domainFn: (datum, _) => datum.key,
                                  measureFn: (datum, _) => (datum.value as Map)['percentage'] as num,
                                  colorFn: (datum, index) => charts.ColorUtil.fromDartColor(
                                    [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.red][index! % 5],
                                  ),
                                  labelAccessorFn: (datum, _) => '${datum.key}\n${(datum.value as Map)['percentage']}%',
                                ),
                              ],
                              defaultRenderer: charts.ArcRendererConfig(
                                arcWidth: 60,
                                arcRendererDecorators: [
                                  charts.ArcLabelDecorator(
                                    labelPosition: charts.ArcLabelPosition.outside,
                                  ),
                                ],
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
                SizedBox(height: 16.h),
                _buildInterestChart(data['interests']),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInterestChart(Map<String, dynamic> data) {
    final sortedData = data.entries.toList()
      ..sort((a, b) => (b.value['percentage'] as num).compareTo(a.value['percentage'] as num));

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

  Widget _buildRegionSection(List<String> metrics, Map<String, dynamic> data) {
    final selectedMetric = metrics.first;
    final sortedRegions = data.entries.toList()
      ..sort((a, b) => (b.value[selectedMetric] as num).compareTo(a.value[selectedMetric] as num));

    return ListView(
      padding: EdgeInsets.all(16.r),
      children: [
        Card(
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '地域分析',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    DropdownButton<String>(
                      value: selectedMetric,
                      items: metrics.map((metric) {
                        return DropdownMenuItem(
                          value: metric,
                          child: Text(controller.getMetricLabel(metric)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        // TODO: 切换指标
                      },
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                // TODO: 添加地图热力图
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sortedRegions.length,
                  separatorBuilder: (context, index) => Divider(height: 16.h),
                  itemBuilder: (context, index) {
                    final region = sortedRegions[index];
                    return _buildRegionItem(
                      index + 1,
                      region.key,
                      region.value[selectedMetric] as num,
                      selectedMetric,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegionItem(int rank, String region, num value, String metric) {
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
            '$rank',
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
            region,
            style: TextStyle(fontSize: 14.sp),
          ),
        ),
        Expanded(
          child: Text(
            controller.formatMetricValue(value, metric),
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleSection(List<String> metrics, Map<String, dynamic> data) {
    final selectedMetric = metrics.first;
    
    return ListView(
      padding: EdgeInsets.all(16.r),
      children: [
        Card(
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
                      value: selectedMetric,
                      items: metrics.map((metric) {
                        return DropdownMenuItem(
                          value: metric,
                          child: Text(controller.getMetricLabel(metric)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        // TODO: 切换指标
                      },
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                AspectRatio(
                  aspectRatio: 1.7,
                  child: charts.BarChart(
                    [
                      charts.Series<MapEntry<String, dynamic>, String>(
                        id: selectedMetric,
                        data: data.entries.toList(),
                        domainFn: (datum, _) => '${datum.key}时',
                        measureFn: (datum, _) => datum.value[selectedMetric] as num,
                        colorFn: (datum, _) => charts.ColorUtil.fromDartColor(
                          _getBarColor(datum.value[selectedMetric] as num, selectedMetric),
                        ),
                      ),
                    ],
                    defaultRenderer: charts.BarRendererConfig(
                      cornerStrategy: const charts.ConstCornerStrategy(30),
                    ),
                    domainAxis: charts.OrdinalAxisSpec(
                      renderSpec: charts.SmallTickRendererSpec(
                        labelStyle: charts.TextStyleSpec(
                          fontSize: 10.sp.toInt(),
                          color: charts.ColorUtil.fromDartColor(Colors.grey[600]!),
                        ),
                      ),
                    ),
                    primaryMeasureAxis: charts.NumericAxisSpec(
                      renderSpec: charts.GridlineRendererSpec(
                        labelStyle: charts.TextStyleSpec(
                          fontSize: 10.sp.toInt(),
                          color: charts.ColorUtil.fromDartColor(Colors.grey[600]!),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                _buildScheduleHighlights(data, selectedMetric),
                SizedBox(height: 24.h),
                _buildScheduleInsights(data, selectedMetric),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getBarColor(num value, String metric) {
    final maxValue = value * 1.2; // 留出20%的空间
    if (value >= maxValue * 0.8) return Colors.red;
    if (value >= maxValue * 0.6) return Colors.orange;
    if (value >= maxValue * 0.4) return Colors.blue;
    if (value >= maxValue * 0.2) return Colors.green;
    return Colors.grey;
  }

  Widget _buildScheduleHighlights(Map<String, dynamic> data, String metric) {
    final sortedHours = data.entries.toList()
      ..sort((a, b) => (b.value[metric] as num).compareTo(a.value[metric] as num));

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
          '${controller.getMetricLabel(metric)}最高时段',
          bestHours.map((e) => '${e.key}:00').join('、'),
          '平均${controller.getMetricLabel(metric)}为${controller.formatMetricValue(
            bestHours.map((e) => e.value[metric] as num).reduce((a, b) => a + b) / 3,
            metric,
          )}',
          Colors.green,
        ),
        SizedBox(height: 8.h),
        _buildHighlightItem(
          '${controller.getMetricLabel(metric)}最低时段',
          worstHours.map((e) => '${e.key}:00').join('、'),
          '平均${controller.getMetricLabel(metric)}为${controller.formatMetricValue(
            worstHours.map((e) => e.value[metric] as num).reduce((a, b) => a + b) / 3,
            metric,
          )}',
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildScheduleInsights(Map<String, dynamic> data, String metric) {
    // 计算统计数据
    final values = List.generate(24, (i) => data['$i']?[metric]?.toDouble() ?? 0.0);
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
          '• 平均每小时${controller.getMetricLabel(metric)}为${controller.formatMetricValue(avgValue, metric)}',
          style: TextStyle(fontSize: 12.sp, height: 1.5),
        ),
        Text(
          '• 最高${controller.getMetricLabel(metric)}为${controller.formatMetricValue(maxValue, metric)}，'
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
                  color: Colors.grey[600],
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
} 