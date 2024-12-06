import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../models/campaign_stats.dart';
import '../../../api/stats_api.dart';
import 'package:intl/intl.dart';
import '../../../api/report_api.dart';
import '../../../models/report_template.dart';

class CampaignStatsController extends GetxController {
  final StatsApi _statsApi = StatsApi();
  final ReportApi _reportApi = ReportApi();
  
  final stats = Rxn<CampaignStats>();
  final isLoading = false.obs;
  final selectedDateRange = Rxn<DateTimeRange>();
  final selectedMetric = 'impressions'.obs;
  final campaignId = ''.obs;
  final comparisonStats = Rxn<CampaignStats>();
  final isExporting = false.obs;
  final templates = <ReportTemplate>[].obs;
  final selectedTemplate = Rxn<ReportTemplate>();

  final metricOptions = [
    {'value': 'impressions', 'label': '展示量'},
    {'value': 'clicks', 'label': '点击量'},
    {'value': 'conversions', 'label': '转化量'},
    {'value': 'cost', 'label': '花费'},
    {'value': 'ctr', 'label': '点击率'},
    {'value': 'cvr', 'label': '转化率'},
  ];

  @override
  void onInit() {
    super.onInit();
    campaignId.value = Get.arguments as String;
    // 默认选择最近7天
    selectedDateRange.value = DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 7)),
      end: DateTime.now(),
    );
    loadStats();
    loadTemplates();
  }

  Future<void> loadStats() async {
    if (selectedDateRange.value == null) return;
    
    isLoading.value = true;
    try {
      final response = await _statsApi.getCampaignStats(
        campaignId.value,
        startDate: selectedDateRange.value!.start,
        endDate: selectedDateRange.value!.end,
      );
      stats.value = response;
    } catch (e) {
      Get.snackbar('错误', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectDateRange() async {
    final picked = await showDateRangePicker(
      context: Get.context!,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: selectedDateRange.value,
    );
    
    if (picked != null) {
      selectedDateRange.value = picked;
      await loadStats();
    }
  }

  void selectMetric(String metric) {
    selectedMetric.value = metric;
  }

  Future<void> refreshStats() async {
    await loadStats();
  }

  Future<void> loadSuggestions() async {
    try {
      final suggestions = await _statsApi.getOptimizationSuggestions(
        campaignId.value,
      );
      // TODO: 处理优化建议
    } catch (e) {
      Get.snackbar('错误', e.toString());
    }
  }

  String getMetricLabel(String value) {
    final option = metricOptions.firstWhere(
      (o) => o['value'] == value,
      orElse: () => {'value': value, 'label': value},
    );
    return option['label'] as String;
  }

  String formatMetricValue(double value, String metric) {
    switch (metric) {
      case 'ctr':
      case 'cvr':
        return '${value.toStringAsFixed(2)}%';
      case 'cost':
        return '¥${value.toStringAsFixed(2)}';
      default:
        if (value >= 10000) {
          return '${(value / 10000).toStringAsFixed(1)}w';
        }
        return value.toStringAsFixed(0);
    }
  }

  Future<void> exportReport(
    CampaignStats stats, {
    required String format,
    required DateTimeRange dateRange,
  }) async {
    if (isExporting.value) return;
    
    isExporting.value = true;
    try {
      final data = {
        'campaign_id': stats.campaignId,
        'format': format,
        'start_date': dateRange.start.toIso8601String(),
        'end_date': dateRange.end.toIso8601String(),
        'metrics': [
          'impressions',
          'clicks',
          'conversions',
          'cost',
          'ctr',
          'cvr',
        ],
      };

      // TODO: 实现实际的报告导出API调用
      await Future.delayed(const Duration(seconds: 2)); // 模拟API调用

      // 处理下载链接
      // final downloadUrl = response['download_url'];
      // await launchUrl(Uri.parse(downloadUrl));
    } finally {
      isExporting.value = false;
    }
  }

  Future<void> loadComparisonStats(DateTimeRange dateRange) async {
    isLoading.value = true;
    try {
      final response = await _statsApi.getCampaignStats(
        campaignId,
        startDate: dateRange.start,
        endDate: dateRange.end,
      );
      comparisonStats.value = response;
    } catch (e) {
      Get.snackbar('错误', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  double getGrowthRate(String metric) {
    if (stats.value == null || comparisonStats.value == null) return 0;
    
    final currentValue = stats.value!.overview[metric] as double;
    final comparisonValue = comparisonStats.value!.overview[metric] as double;
    
    if (comparisonValue == 0) return 0;
    return ((currentValue - comparisonValue) / comparisonValue) * 100;
  }

  String getMetricDiff(String metric) {
    if (stats.value == null || comparisonStats.value == null) return '-';
    
    final currentValue = stats.value!.overview[metric] as double;
    final comparisonValue = comparisonStats.value!.overview[metric] as double;
    final diff = currentValue - comparisonValue;
    
    return formatMetricValue(diff.abs(), metric);
  }

  void clearComparison() {
    comparisonStats.value = null;
  }

  String formatDateRange(DateTimeRange range) {
    return '${DateFormat('MM-dd').format(range.start)} - '
           '${DateFormat('MM-dd').format(range.end)}';
  }

  int getDayCount(DateTimeRange range) {
    return range.duration.inDays + 1;
  }

  double getAverageValue(String metric, CampaignStats data) {
    final value = data.overview[metric] as double;
    final days = getDayCount(DateTimeRange(
      start: data.startDate,
      end: data.endDate,
    ));
    return value / days;
  }

  String getComparisonText(String metric) {
    if (comparisonStats.value == null) return '';
    
    final growth = getGrowthRate(metric);
    final diff = getMetricDiff(metric);
    final direction = growth >= 0 ? '增长' : '下降';
    
    return '同比$direction ${growth.abs().toStringAsFixed(1)}%（${growth >= 0 ? '+' : '-'}$diff）';
  }

  Future<void> loadTemplates() async {
    try {
      final response = await _reportApi.getTemplates();
      templates.value = response;
      // 设置默认模板
      selectedTemplate.value = templates.firstWhereOrNull((t) => t.isDefault);
    } catch (e) {
      Get.snackbar('错误', e.toString());
    }
  }

  Future<void> exportCustomReport() async {
    if (selectedTemplate.value == null) {
      Get.snackbar('错误', '请选择报告模板');
      return;
    }

    isExporting.value = true;
    try {
      final data = {
        'campaign_id': campaignId.value,
        'template_id': selectedTemplate.value!.id,
        'start_date': selectedDateRange.value!.start.toIso8601String(),
        'end_date': selectedDateRange.value!.end.toIso8601String(),
        'comparison_data': comparisonStats.value?.toJson(),
      };

      final downloadUrl = await _reportApi.exportReport(data);
      // TODO: 处理下载链接
      Get.snackbar('提示', '报告生成成功');
    } catch (e) {
      Get.snackbar('错误', '报告生成失败：${e.toString()}');
    } finally {
      isExporting.value = false;
    }
  }

  Future<void> getAnalysisReport() async {
    isLoading.value = true;
    try {
      final report = await _reportApi.getAnalysisReport(campaignId.value);
      // TODO: 显示分析报告
      Get.toNamed(
        Routes.CAMPAIGN_ANALYSIS,
        arguments: report,
      );
    } catch (e) {
      Get.snackbar('错误', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
} 