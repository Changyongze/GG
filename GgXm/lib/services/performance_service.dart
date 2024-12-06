import 'package:get/get.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_performance_monitor/flutter_performance_monitor.dart';
import 'log_service.dart';

class PerformanceService extends GetxService {
  final LogService _logService = Get.find<LogService>();
  final _monitor = PerformanceMonitor();
  Timer? _monitorTimer;
  
  // 性能指标阈值
  static const double FRAME_TIME_THRESHOLD = 16.0; // 毫秒
  static const double MEMORY_THRESHOLD = 100.0; // MB
  static const int CPU_USAGE_THRESHOLD = 80; // 百分比

  final isMonitoring = false.obs;
  final currentFrameTime = 0.0.obs;
  final currentMemoryUsage = 0.0.obs;
  final currentCpuUsage = 0.obs;

  @override
  void onInit() {
    super.onInit();
    if (kDebugMode) {
      startMonitoring();
    }
  }

  void startMonitoring() {
    if (isMonitoring.value) return;
    
    isMonitoring.value = true;
    _monitor.start();
    
    _monitorTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _collectMetrics(),
    );
  }

  void stopMonitoring() {
    isMonitoring.value = false;
    _monitor.stop();
    _monitorTimer?.cancel();
  }

  Future<void> _collectMetrics() async {
    try {
      // 收集帧时间
      final frameTime = await _monitor.getFrameTime();
      currentFrameTime.value = frameTime;
      
      if (frameTime > FRAME_TIME_THRESHOLD) {
        await _logService.logInfo(
          '帧时间过长',
          data: {'frame_time': frameTime},
        );
      }

      // 收集内存使用
      final memoryUsage = await _monitor.getMemoryUsage();
      currentMemoryUsage.value = memoryUsage;
      
      if (memoryUsage > MEMORY_THRESHOLD) {
        await _logService.logInfo(
          '内存使用过高',
          data: {'memory_usage': memoryUsage},
        );
      }

      // 收集CPU使用
      final cpuUsage = await _monitor.getCpuUsage();
      currentCpuUsage.value = cpuUsage;
      
      if (cpuUsage > CPU_USAGE_THRESHOLD) {
        await _logService.logInfo(
          'CPU使用过高',
          data: {'cpu_usage': cpuUsage},
        );
      }
    } catch (e, stackTrace) {
      await _logService.logError(
        e,
        '收集性能指标失败',
        stackTrace: stackTrace,
      );
    }
  }

  // 性能优化建议
  List<String> getOptimizationSuggestions() {
    final suggestions = <String>[];
    
    if (currentFrameTime.value > FRAME_TIME_THRESHOLD) {
      suggestions.add('检查是否存在复杂的UI计算或动画');
      suggestions.add('考虑使用ListView.builder代替ListView');
      suggestions.add('使用const构造函数减少重建');
    }

    if (currentMemoryUsage.value > MEMORY_THRESHOLD) {
      suggestions.add('检查是否存在内存泄漏');
      suggestions.add('及时释放大文件资源');
      suggestions.add('使用缓存管理大量图片');
    }

    if (currentCpuUsage.value > CPU_USAGE_THRESHOLD) {
      suggestions.add('优化后台计算逻辑');
      suggestions.add('使用compute处理耗时操作');
      suggestions.add('减少不必要的setState调用');
    }

    return suggestions;
  }

  // 缓存优化
  void optimizeCache() {
    // TODO: 实现缓存优化逻辑
  }

  // 图片优化
  void optimizeImages() {
    // TODO: 实现图片优化逻辑
  }

  @override
  void onClose() {
    stopMonitoring();
    super.onClose();
  }
} 