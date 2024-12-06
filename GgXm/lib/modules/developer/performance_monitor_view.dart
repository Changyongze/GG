import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/performance_service.dart';

class PerformanceMonitorView extends GetView<PerformanceService> {
  const PerformanceMonitorView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('性能监控'),
        actions: [
          Obx(() => Switch(
            value: controller.isMonitoring.value,
            onChanged: (value) {
              if (value) {
                controller.startMonitoring();
              } else {
                controller.stopMonitoring();
              }
            },
          )),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          children: [
            _buildMetricsOverview(),
            SizedBox(height: 24.h),
            _buildPerformanceChart(),
            SizedBox(height: 24.h),
            _buildOptimizationSuggestions(),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsOverview() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '实时指标',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            Obx(() => _buildMetricItem(
              '帧时间',
              '${controller.currentFrameTime.value.toStringAsFixed(1)}ms',
              controller.currentFrameTime.value > PerformanceService.FRAME_TIME_THRESHOLD,
            )),
            SizedBox(height: 12.h),
            Obx(() => _buildMetricItem(
              '内存使用',
              '${controller.currentMemoryUsage.value.toStringAsFixed(1)}MB',
              controller.currentMemoryUsage.value > PerformanceService.MEMORY_THRESHOLD,
            )),
            SizedBox(height: 12.h),
            Obx(() => _buildMetricItem(
              'CPU使用',
              '${controller.currentCpuUsage.value}%',
              controller.currentCpuUsage.value > PerformanceService.CPU_USAGE_THRESHOLD,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, bool isWarning) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: isWarning ? Colors.red : null,
          ),
        ),
        if (isWarning) ...[
          SizedBox(width: 4.w),
          Icon(
            Icons.warning,
            color: Colors.red,
            size: 16.r,
          ),
        ],
      ],
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
                  '性能趋势',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                DropdownButton<String>(
                  value: controller.selectedMetric.value,
                  items: ['帧时间', '内存使用', 'CPU使用'].map((metric) {
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
              child: Obx(() => LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: controller.chartInterval,
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            _formatMetricValue(value),
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
                        reservedSize: 22,
                        interval: 5,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= controller.timeLabels.length) {
                            return const SizedBox();
                          }
                          return Text(
                            controller.timeLabels[index],
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
                  lineBarsData: [
                    LineChartBarData(
                      spots: controller.chartData.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value);
                      }).toList(),
                      isCurved: true,
                      color: _getMetricColor(controller.selectedMetric.value),
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: _getMetricColor(controller.selectedMetric.value)
                            .withOpacity(0.1),
                      ),
                    ),
                  ],
                  minY: 0,
                  maxY: controller.chartMaxValue,
                ),
              )),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(
                  controller.selectedMetric.value,
                  _getMetricColor(controller.selectedMetric.value),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12.w,
          height: 2.h,
          color: color,
        ),
        SizedBox(width: 4.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _formatMetricValue(double value) {
    switch (controller.selectedMetric.value) {
      case '帧时间':
        return '${value.toStringAsFixed(1)}ms';
      case '内存使用':
        return '${value.toStringAsFixed(1)}MB';
      case 'CPU使用':
        return '${value.toStringAsFixed(0)}%';
      default:
        return value.toString();
    }
  }

  Color _getMetricColor(String metric) {
    switch (metric) {
      case '帧时间':
        return Colors.blue;
      case '内存使用':
        return Colors.green;
      case 'CPU使用':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildOptimizationSuggestions() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '优化建议',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            Obx(() {
              final suggestions = controller.getOptimizationSuggestions();
              if (suggestions.isEmpty) {
                return Text(
                  '暂无优化建议',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                );
              }
              return Column(
                children: suggestions.map((suggestion) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: Colors.orange,
                          size: 16.r,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            suggestion,
                            style: TextStyle(fontSize: 14.sp),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }
} 