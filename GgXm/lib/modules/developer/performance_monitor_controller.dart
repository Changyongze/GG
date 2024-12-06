import 'package:get/get.dart';
import 'dart:async';
import '../../services/performance_service.dart';
import '../../services/log_service.dart';

class PerformanceMonitorController extends GetxController {
  final PerformanceService _performanceService = Get.find<PerformanceService>();
  final LogService _logService = Get.find<LogService>();
  
  static const int MAX_DATA_POINTS = 60; // 显示最近60个数据点
  
  final selectedMetric = '帧时间'.obs;
  final chartData = <double>[].obs;
  final timeLabels = <String>[].obs;

  Timer? _updateTimer;

  @override
  void onInit() {
    super.onInit();
    _setupDataCollection();
  }

  @override
  void onClose() {
    _updateTimer?.cancel();
    super.onClose();
  }

  void _setupDataCollection() {
    // 每秒更新一次数据
    _updateTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateChartData(),
    );
  }

  void _updateChartData() {
    final now = DateTime.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    double value;
    switch (selectedMetric.value) {
      case '帧时间':
        value = _performanceService.currentFrameTime.value;
        break;
      case '内存使用':
        value = _performanceService.currentMemoryUsage.value;
        break;
      case 'CPU使用':
        value = _performanceService.currentCpuUsage.value.toDouble();
        break;
      default:
        value = 0;
    }

    // 添加新数据点
    chartData.add(value);
    timeLabels.add(timeStr);

    // 保持固定数量的数据点
    if (chartData.length > MAX_DATA_POINTS) {
      chartData.removeAt(0);
      timeLabels.removeAt(0);
    }

    // 记录性能问题
    _checkPerformanceIssues(value);
  }

  void _checkPerformanceIssues(double value) {
    switch (selectedMetric.value) {
      case '帧时间':
        if (value > PerformanceService.FRAME_TIME_THRESHOLD) {
          _logPerformanceIssue('帧时间过高', value);
        }
        break;
      case '内存使用':
        if (value > PerformanceService.MEMORY_THRESHOLD) {
          _logPerformanceIssue('内存使用过高', value);
        }
        break;
      case 'CPU使用':
        if (value > PerformanceService.CPU_USAGE_THRESHOLD) {
          _logPerformanceIssue('CPU使用过高', value);
        }
        break;
    }
  }

  void _logPerformanceIssue(String issue, double value) {
    _logService.logInfo(
      issue,
      data: {
        'metric': selectedMetric.value,
        'value': value,
        'threshold': _getThreshold(),
      },
    );
  }

  double _getThreshold() {
    switch (selectedMetric.value) {
      case '帧时间':
        return PerformanceService.FRAME_TIME_THRESHOLD;
      case '内存使用':
        return PerformanceService.MEMORY_THRESHOLD;
      case 'CPU使用':
        return PerformanceService.CPU_USAGE_THRESHOLD;
      default:
        return 0;
    }
  }

  void changeMetric(String? metric) {
    if (metric != null && metric != selectedMetric.value) {
      selectedMetric.value = metric;
      // 清空历史数据
      chartData.clear();
      timeLabels.clear();
    }
  }

  double get chartInterval {
    switch (selectedMetric.value) {
      case '帧时间':
        return 5.0;
      case '内存使用':
        return 20.0;
      case 'CPU使用':
        return 20.0;
      default:
        return 10.0;
    }
  }

  double get chartMaxValue {
    switch (selectedMetric.value) {
      case '帧时间':
        return 50.0; // 最大50ms
      case '内存使用':
        return 200.0; // 最大200MB
      case 'CPU使用':
        return 100.0; // 最大100%
      default:
        return 100.0;
    }
  }

  // 导出性能数据
  Future<void> exportPerformanceData() async {
    try {
      final data = {
        'metric': selectedMetric.value,
        'timestamp': DateTime.now().toIso8601String(),
        'data_points': List.generate(
          chartData.length,
          (i) => {
            'time': timeLabels[i],
            'value': chartData[i],
          },
        ),
      };

      // TODO: 实现数据导出逻辑
    } catch (e) {
      print('导出性能数据失败: $e');
    }
  }
} 