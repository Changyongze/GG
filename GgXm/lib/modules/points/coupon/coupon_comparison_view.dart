import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../models/coupon_stats.dart';
import '../../../api/points_api.dart';
import '../../../api/download_service.dart';

class CouponComparisonView extends StatefulWidget {
  const CouponComparisonView({Key? key}) : super(key: key);

  @override
  State<CouponComparisonView> createState() => _CouponComparisonViewState();
}

class _CouponComparisonViewState extends State<CouponComparisonView> {
  final _pointsApi = Get.find<PointsApi>();
  final _downloadService = Get.find<DownloadService>();
  Map<String, CouponStats>? _stats;
  Map<String, dynamic>? _userProfile;
  bool _isLoading = false;
  bool _isExporting = false;
  
  DateTimeRange _period1 = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 60)),
    end: DateTime.now().subtract(const Duration(days: 31)),
  );
  
  DateTimeRange _period2 = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );

  @override
  void initState() {
    super.initState();
    _loadComparison();
    _loadUserProfile();
  }

  Future<void> _loadComparison() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final stats = await _pointsApi.getComparisonStats(
        startDate1: _period1.start,
        endDate1: _period1.end,
        startDate2: _period2.start,
        endDate2: _period2.end,
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

  Future<void> _loadUserProfile() async {
    try {
      final profile = await _pointsApi.getUserProfileComparison(
        startDate1: _period1.start,
        endDate1: _period1.end,
        startDate2: _period2.start,
        endDate2: _period2.end,
      );
      setState(() {
        _userProfile = profile;
      });
    } catch (e) {
      print('加载用户画像失败: $e');
    }
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
      final url = await _pointsApi.exportComparisonStats(
        startDate1: _period1.start,
        endDate1: _period1.end,
        startDate2: _period2.start,
        endDate2: _period2.end,
        format: format,
      );

      await _downloadService.downloadFile(
        url,
        'coupon_comparison.$format',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('数据对比'),
        actions: [
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
                      _buildPeriodSelector(),
                      SizedBox(height: 24.h),
                      _buildOverviewComparison(),
                      SizedBox(height: 24.h),
                      _buildTypeComparison(),
                      SizedBox(height: 24.h),
                      _buildUsageComparison(),
                      SizedBox(height: 24.h),
                      _buildAdPerformanceComparison(),
                      SizedBox(height: 24.h),
                      _buildRegionComparison(),
                      if (_userProfile != null) ...[
                        SizedBox(height: 24.h),
                        _buildUserProfileComparison(),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildPeriodSelector() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '对比时段',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: _buildPeriodItem(
                    '时段1',
                    _period1,
                    (range) {
                      setState(() {
                        _period1 = range;
                      });
                      _loadComparison();
                    },
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _buildPeriodItem(
                    '时段2',
                    _period2,
                    (range) {
                      setState(() {
                        _period2 = range;
                      });
                      _loadComparison();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodItem(
    String label,
    DateTimeRange period,
    Function(DateTimeRange) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 8.h),
        InkWell(
          onTap: () async {
            final picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
              initialDateRange: period,
            );
            if (picked != null) {
              onChanged(picked);
            }
          },
          child: Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${_formatDate(period.start)}\n${_formatDate(period.end)}',
                    style: TextStyle(fontSize: 12.sp),
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  size: 16.r,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewComparison() {
    final stats1 = _stats!['period1']!;
    final stats2 = _stats!['period2']!;

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
            _buildComparisonItem(
              '优惠券数量',
              stats1.totalCount,
              stats2.totalCount,
              suffix: '张',
            ),
            SizedBox(height: 16.h),
            _buildComparisonItem(
              '使用数量',
              stats1.usedCount,
              stats2.usedCount,
              suffix: '张',
            ),
            SizedBox(height: 16.h),
            _buildComparisonItem(
              '使用率',
              stats1.useRate * 100,
              stats2.useRate * 100,
              suffix: '%',
              decimals: 1,
            ),
            SizedBox(height: 16.h),
            _buildComparisonItem(
              '总价值',
              stats1.totalValue,
              stats2.totalValue,
              prefix: '¥',
              decimals: 2,
            ),
            SizedBox(height: 16.h),
            _buildComparisonItem(
              '已使用价值',
              stats1.usedValue,
              stats2.usedValue,
              prefix: '¥',
              decimals: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonItem(
    String label,
    num value1,
    num value2, {
    String? prefix,
    String? suffix,
    int decimals = 0,
  }) {
    final diff = value2 - value1;
    final ratio = value1 == 0 ? double.infinity : (diff / value1 * 100);
    final isPositive = diff > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: Text(
                '${prefix ?? ''}${value1.toStringAsFixed(decimals)}${suffix ?? ''}',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward,
              size: 16.r,
              color: Colors.grey,
            ),
            Expanded(
              child: Text(
                '${prefix ?? ''}${value2.toStringAsFixed(decimals)}${suffix ?? ''}',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 8.w,
                vertical: 4.h,
              ),
              decoration: BoxDecoration(
                color: (isPositive ? Colors.red : Colors.green).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                '${isPositive ? '+' : ''}${ratio.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isPositive ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Widget _buildTypeComparison() {
    final stats1 = _stats!['period1']!;
    final stats2 = _stats!['period2']!;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '类型分布对比',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '时段1',
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
                            sections: _buildPieSections(stats1.typeDistribution),
                            sectionsSpace: 2,
                            centerSpaceRadius: 40.r,
                            startDegreeOffset: 180,
                            pieTouchData: PieTouchData(
                              touchCallback: (event, response) {
                                // 处理点击事件
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '时段2',
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
                            sections: _buildPieSections(stats2.typeDistribution),
                            sectionsSpace: 2,
                            centerSpaceRadius: 40.r,
                            startDegreeOffset: 180,
                            pieTouchData: PieTouchData(
                              touchCallback: (event, response) {
                                // 处理点击事件
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            _buildTypeLegend(),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections(Map<String, int> distribution) {
    final total = distribution.values.fold<int>(0, (a, b) => a + b);
    return distribution.entries.map((e) {
      final type = CouponType.values.byName(e.key);
      final percentage = total == 0 ? 0.0 : e.value / total * 100;
      return PieChartSectionData(
        value: e.value.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        color: _getTypeColor(type),
        radius: 100.r,
        titleStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildTypeLegend() {
    return Wrap(
      spacing: 16.w,
      runSpacing: 8.h,
      children: CouponType.values.map((type) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: _getTypeColor(type),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 4.w),
            Text(
              _getTypeLabel(type),
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildUsageComparison() {
    final stats1 = _stats!['period1']!;
    final stats2 = _stats!['period2']!;

    // 合并两个时段的月份数据
    final allMonths = {...stats1.monthlyUsage.keys, ...stats2.monthlyUsage.keys}.toList()..sort();
    final maxValue = [
      ...stats1.monthlyUsage.values,
      ...stats2.monthlyUsage.values,
    ].reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '使用趋势对比',
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
                          if (value.toInt() >= allMonths.length) return const SizedBox();
                          return Text(
                            allMonths[value.toInt()].substring(5),
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
                    _buildLineChartBarData(allMonths, stats1.monthlyUsage, Colors.blue),
                    _buildLineChartBarData(allMonths, stats2.monthlyUsage, Colors.red),
                  ],
                  minY: 0,
                  maxY: maxValue * 1.2,
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: Colors.blueAccent,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final isFirstPeriod = spot.barIndex == 0;
                          return LineTooltipItem(
                            '${isFirstPeriod ? "时段1: " : "时段2: "}¥${spot.y.toStringAsFixed(2)}',
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
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('时段1', Colors.blue),
                SizedBox(width: 24.w),
                _buildLegendItem('时段2', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  LineChartBarData _buildLineChartBarData(
    List<String> months,
    Map<String, double> data,
    Color color,
  ) {
    return LineChartBarData(
      spots: months.asMap().entries.map((e) {
        return FlSpot(
          e.key.toDouble(),
          data[e.value] ?? 0,
        );
      }).toList(),
      isCurved: true,
      color: color,
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: color.withOpacity(0.1),
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

  Widget _buildUserProfileComparison() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '用���画像对比',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            _buildProfileSection(
              '年龄分布',
              _userProfile!['age_distribution1'],
              _userProfile!['age_distribution2'],
              Colors.orange,
            ),
            SizedBox(height: 16.h),
            _buildProfileSection(
              '性别分布',
              _userProfile!['gender_distribution1'],
              _userProfile!['gender_distribution2'],
              Colors.blue,
            ),
            SizedBox(height: 16.h),
            _buildProfileSection(
              '消费能力',
              _userProfile!['spending_power1'],
              _userProfile!['spending_power2'],
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(
    String title,
    Map<String, double> data1,
    Map<String, double> data2,
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
        ...data1.keys.map((key) {
          final value1 = data1[key] ?? 0.0;
          final value2 = data2[key] ?? 0.0;
          final diff = value2 - value1;
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
                    child: Stack(
                      children: [
                        Container(
                          height: 16.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        Row(
                          children: [
                            FractionallySizedBox(
                              widthFactor: value1,
                              child: Container(
                                height: 16.h,
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: value2,
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
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: (diff > 0 ? Colors.red : Colors.green).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      '${diff > 0 ? '+' : ''}${(diff * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: diff > 0 ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _buildAdPerformanceComparison() {
    final stats1 = _stats!['period1']!;
    final stats2 = _stats!['period2']!;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '广告效果对比',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            _buildAdMetricItem(
              '广告曝光量',
              stats1.impressions,
              stats2.impressions,
            ),
            SizedBox(height: 16.h),
            _buildAdMetricItem(
              '点击率(CTR)',
              stats1.ctr * 100,
              stats2.ctr * 100,
              suffix: '%',
              decimals: 2,
            ),
            SizedBox(height: 16.h),
            _buildAdMetricItem(
              '转化率(CVR)',
              stats1.cvr * 100,
              stats2.cvr * 100,
              suffix: '%',
              decimals: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdMetricItem(
    String label,
    num value1,
    num value2, {
    String? suffix,
    int decimals = 0,
  }) {
    final diff = value2 - value1;
    final ratio = value1 == 0 ? double.infinity : (diff / value1 * 100);
    final isPositive = diff > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: Text(
                '${value1.toStringAsFixed(decimals)}${suffix ?? ''}',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward,
              size: 16.r,
              color: Colors.grey,
            ),
            Expanded(
              child: Text(
                '${value2.toStringAsFixed(decimals)}${suffix ?? ''}',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 8.w,
                vertical: 4.h,
              ),
              decoration: BoxDecoration(
                color: (isPositive ? Colors.red : Colors.green).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                '${isPositive ? '+' : ''}${ratio.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isPositive ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRegionComparison() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '地区分布对比',
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
                  maxY: 100,
                  barGroups: _buildRegionBarGroups(),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}%',
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
                          final regions = ['华东', '华南', '华北', '西南', '其他'];
                          if (value.toInt() >= regions.length) {
                            return const SizedBox();
                          }
                          return Text(
                            regions[value.toInt()],
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

  List<BarChartGroupData> _buildRegionBarGroups() {
    final stats1 = _stats!['period1']!;
    final stats2 = _stats!['period2']!;
    final regions = ['华东', '华南', '华北', '西南', '其他'];
    
    return List.generate(regions.length, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: stats1.regionDistribution[regions[index]] ?? 0,
            color: Colors.blue,
            width: 12.w,
          ),
          BarChartRodData(
            toY: stats2.regionDistribution[regions[index]] ?? 0,
            color: Colors.red,
            width: 12.w,
          ),
        ],
      );
    });
  }
} 