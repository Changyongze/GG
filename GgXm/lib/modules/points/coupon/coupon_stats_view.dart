import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../models/coupon_stats.dart';
import '../../../api/points_api.dart';
import '../../../services/download_service.dart';

class CouponStatsView extends StatefulWidget {
  const CouponStatsView({Key? key}) : super(key: key);

  @override
  State<CouponStatsView> createState() => _CouponStatsViewState();
}

class _CouponStatsViewState extends State<CouponStatsView> {
  final _pointsApi = Get.find<PointsApi>();
  final _downloadService = Get.find<DownloadService>();
  CouponStats? _stats;
  bool _isLoading = false;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final stats = await _pointsApi.getCouponStats();
      setState(() {
        _stats = stats;
      });
    } catch (e) {
      Get.snackbar('错误', e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('优惠券统计'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _selectDateRange,
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _showExportDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _stats == null
              ? const Center(child: Text('加载失败'))
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    children: [
                      _buildOverview(),
                      SizedBox(height: 24.h),
                      _buildTypeDistribution(),
                      SizedBox(height: 24.h),
                      _buildMonthlyUsage(),
                      SizedBox(height: 24.h),
                      _buildTopUsedCoupons(),
                      SizedBox(height: 24.h),
                      _buildTimeDistribution(),
                      SizedBox(height: 24.h),
                      _buildUserProfile(),
                    ],
                  ),
                ),
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
                  child: _buildOverviewItem(
                    '总数量',
                    _stats!.totalCount.toString(),
                    '已使用 ${(_stats!.useRate * 100).toStringAsFixed(1)}%',
                    Colors.blue,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _buildOverviewItem(
                    '总价值',
                    '¥${_stats!.totalValue.toStringAsFixed(2)}',
                    '已使用 ${(_stats!.valueUseRate * 100).toStringAsFixed(1)}%',
                    Colors.red,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: _buildOverviewItem(
                    '已使用',
                    _stats!.usedCount.toString(),
                    '¥${_stats!.usedValue.toStringAsFixed(2)}',
                    Colors.green,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _buildOverviewItem(
                    '已过期',
                    _stats!.expiredCount.toString(),
                    '¥${_stats!.expiredValue.toStringAsFixed(2)}',
                    Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewItem(
    String title,
    String value,
    String subtitle,
    Color color,
  ) {
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
            title,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12.sp,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeDistribution() {
    final data = _stats!.typeDistribution.entries.map((e) {
      final type = CouponType.values.byName(e.key);
      return PieChartSectionData(
        value: e.value.toDouble(),
        title: '${_getTypeLabel(type)}\n${e.value}',
        color: _getTypeColor(type),
        radius: 100.r,
        titleStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '类型分布',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            AspectRatio(
              aspectRatio: 1,
              child: PieChart(
                PieChartData(
                  sections: data,
                  sectionsSpace: 2,
                  centerSpaceRadius: 40.r,
                  startDegreeOffset: 180,
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      if (response?.touchedSection != null) {
                        // 处理点击事件
                      }
                    },
                  ),
                  centerSpaceColor: Colors.white,
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTypeLabel(CouponType type) {
    switch (type) {
      case CouponType.discount:
        return '折扣券';
      case CouponType.cash:
        return '现金券';
      case CouponType.exchange:
        return '兑换券';
      case CouponType.gift:
        return '礼品券';
    }
  }

  Color _getTypeColor(CouponType type) {
    switch (type) {
      case CouponType.discount:
        return Colors.orange;
      case CouponType.cash:
        return Colors.red;
      case CouponType.exchange:
        return Colors.blue;
      case CouponType.gift:
        return Colors.purple;
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 30)),
        end: DateTime.now(),
      ),
    );

    if (picked != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final stats = await _pointsApi.getCouponStats(
          startDate: picked.start,
          endDate: picked.end,
        );
        setState(() {
          _stats = stats;
        });
      } catch (e) {
        Get.snackbar('错误', e.toString());
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildMonthlyUsage() {
    final months = _stats!.monthlyUsage.keys.toList()..sort();
    final maxValue = _stats!.monthlyUsage.values.reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '月度使用趋势',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            AspectRatio(
              aspectRatio: 1.5,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '¥${value.toInt()}',
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
                          if (value.toInt() >= months.length) return const SizedBox();
                          return Text(
                            months[value.toInt()].substring(5), // 只显示月份
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 10.sp,
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: months.asMap().entries.map((e) {
                        return FlSpot(
                          e.key.toDouble(),
                          _stats!.monthlyUsage[e.value]!,
                        );
                      }).toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.1),
                      ),
                    ),
                  ],
                  minY: 0,
                  maxY: maxValue * 1.2,
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: Colors.blueAccent,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          return LineTooltipItem(
                            '¥${spot.y.toStringAsFixed(2)}',
                            TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                    handleBuiltInTouches: true,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopUsedCoupons() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '热门优惠券',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            ..._stats!.topUsedCoupons.map((coupon) => _buildCouponItem(coupon)),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponItem(CouponUsageStats coupon) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: _getTypeColor(coupon.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: Text(
                _getTypeLabel(coupon.type)[0],
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: _getTypeColor(coupon.type),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  coupon.name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  '使用${coupon.usedCount}次 · 平均订单¥${coupon.avgOrderAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            '¥${coupon.totalValue.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('导出数据'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Excel格式'),
              onTap: () => _exportStats('excel'),
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file),
              title: const Text('CSV格式'),
              onTap: () => _exportStats('csv'),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('PDF格式'),
              onTap: () => _exportStats('pdf'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportStats(String format) async {
    Get.back();
    setState(() {
      _isExporting = true;
    });

    try {
      final url = await _pointsApi.exportCouponStats(format: format);
      await _downloadService.downloadFile(
        url,
        'coupon_stats.$format',
        onProgress: (progress) {
          Get.dialog(
            WillPopScope(
              onWillPop: () async => false,
              child: AlertDialog(
                title: const Text('导出中'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(value: progress),
                    SizedBox(height: 16.h),
                    Text('${(progress * 100).toInt()}%'),
                  ],
                ),
              ),
            ),
            barrierDismissible: false,
          );
        },
      );
      Get.back(); // 关闭进度对话框
      Get.snackbar('成功', '文件已导出');
    } catch (e) {
      Get.snackbar('错误', e.toString());
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  Widget _buildTimeDistribution() {
    return FutureBuilder<Map<String, int>>(
      future: _pointsApi.getCouponUsageTimeDistribution(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        }

        final data = snapshot.data!;
        final maxValue = data.values.reduce((a, b) => a > b ? a : b).toDouble();

        return Card(
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '使用时段分布',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.h),
                AspectRatio(
                  aspectRatio: 2,
                  child: BarChart(
                    BarChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: maxValue / 5,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey[300],
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
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
                              return Text(
                                '${value.toInt()}:00',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 10.sp,
                                ),
                              );
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(24, (index) {
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: data['$index']?.toDouble() ?? 0,
                              color: Colors.blue,
                              width: 12.w,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ],
                        );
                      }),
                      maxY: maxValue * 1.2,
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          tooltipBgColor: Colors.blueAccent,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              '${group.x}:00\n${rod.toY.toInt()}次',
                              TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Center(
                  child: Text(
                    '24小时使用分布',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserProfile() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _pointsApi.getCouponUserProfile(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        }

        final data = snapshot.data!;
        return Card(
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '用户画像',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.h),
                _buildProfileSection(
                  '年龄分布',
                  Map<String, double>.from(data['age_distribution']),
                  Colors.orange,
                ),
                SizedBox(height: 16.h),
                _buildProfileSection(
                  '性别分布',
                  Map<String, double>.from(data['gender_distribution']),
                  Colors.blue,
                ),
                SizedBox(height: 16.h),
                _buildProfileSection(
                  '消费能力',
                  Map<String, double>.from(data['spending_power']),
                  Colors.green,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileSection(
    String title,
    Map<String, double> data,
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
        SizedBox(height: 8.h),
        ...data.entries.map((e) => Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 80.w,
                  child: Text(
                    e.key,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
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
                        widthFactor: e.value,
                        child: Container(
                          height: 16.h,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  '${(e.value * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
          ],
        )),
      ],
    );
  }
} 