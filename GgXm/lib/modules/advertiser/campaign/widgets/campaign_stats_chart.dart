import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class CampaignStatsChart extends StatelessWidget {
  final List<Map<String, dynamic>> dailyStats;
  final String type; // impressions/clicks/ctr/cost

  const CampaignStatsChart({
    Key? key,
    required this.dailyStats,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.7,
      child: Padding(
        padding: EdgeInsets.all(16.r),
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
                      _formatValue(value),
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
                    if (value.toInt() >= 0 && value.toInt() < dailyStats.length) {
                      final date = DateTime.parse(dailyStats[value.toInt()]['date']);
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
                spots: _getSpots(),
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
                      dailyStats[spot.x.toInt()]['date'],
                    );
                    return LineTooltipItem(
                      '${DateFormat('MM-dd').format(date)}\n'
                      '${_formatValue(spot.y)}',
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
    );
  }

  List<FlSpot> _getSpots() {
    return List.generate(dailyStats.length, (index) {
      final value = type == 'ctr'
          ? (dailyStats[index][type] ?? 0.0) * 100
          : dailyStats[index][type]?.toDouble() ?? 0.0;
      return FlSpot(index.toDouble(), value);
    });
  }

  String _formatValue(double value) {
    switch (type) {
      case 'impressions':
      case 'clicks':
        if (value >= 10000) {
          return '${(value / 10000).toStringAsFixed(1)}w';
        }
        return value.toInt().toString();
      case 'ctr':
        return '${value.toStringAsFixed(1)}%';
      case 'cost':
        if (value >= 10000) {
          return '${(value / 10000).toStringAsFixed(1)}w';
        }
        return '¥${value.toStringAsFixed(0)}';
      default:
        return value.toString();
    }
  }
} 