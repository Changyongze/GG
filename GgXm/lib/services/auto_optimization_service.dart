import 'package:get/get.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'performance_service.dart';
import 'log_service.dart';
import '../utils/cache_util.dart';

class AutoOptimizationService extends GetxService {
  final PerformanceService _performanceService = Get.find<PerformanceService>();
  final LogService _logService = Get.find<LogService>();
  
  Timer? _optimizationTimer;
  final isOptimizing = false.obs;

  // 优化阈值
  static const int CACHE_SIZE_THRESHOLD = 100 * 1024 * 1024; // 100MB
  static const int LOG_RETENTION_DAYS = 7;
  static const int MAX_IMAGE_CACHE_ENTRIES = 100;

  @override
  void onInit() {
    super.onInit();
    _setupOptimizationSchedule();
  }

  @override
  void onClose() {
    _optimizationTimer?.cancel();
    super.onClose();
  }

  void _setupOptimizationSchedule() {
    // 每6小时运行一次优化
    _optimizationTimer = Timer.periodic(
      const Duration(hours: 6),
      (_) => runOptimization(),
    );
  }

  Future<void> runOptimization() async {
    if (isOptimizing.value) return;
    
    isOptimizing.value = true;
    try {
      await _logService.logInfo('开始自动优化');

      // 检查并优化缓存
      await _optimizeCache();

      // 清理过期日志
      await _cleanupLogs();

      // 优化图片缓存
      await _optimizeImageCache();

      // 优化数据库
      await _optimizeDatabase();

      await _logService.logInfo('自动优化完成');
    } catch (e, stackTrace) {
      await _logService.logError(e, '自动优化失败', stackTrace: stackTrace);
    } finally {
      isOptimizing.value = false;
    }
  }

  Future<void> _optimizeCache() async {
    try {
      final cacheDir = await getTemporaryDirectory();
      final cacheSize = await _calculateDirSize(cacheDir);

      if (cacheSize > CACHE_SIZE_THRESHOLD) {
        // 清理过期缓存
        await CacheUtil.cleanExpiredCache();
        
        // 如果仍然超过阈值，清理最旧的文件
        final newSize = await _calculateDirSize(cacheDir);
        if (newSize > CACHE_SIZE_THRESHOLD) {
          await CacheUtil.cleanOldestCache(
            targetSize: CACHE_SIZE_THRESHOLD * 0.8, // 保留80%空间
          );
        }

        await _logService.logInfo(
          '缓存优化完成',
          data: {
            'before_size': cacheSize,
            'after_size': await _calculateDirSize(cacheDir),
          },
        );
      }
    } catch (e) {
      print('缓存优化失败: $e');
    }
  }

  Future<void> _cleanupLogs() async {
    try {
      final logsDir = await getApplicationDocumentsDirectory();
      final logFiles = await logsDir
          .list()
          .where((entity) => 
              entity is File && 
              entity.path.endsWith('.log'))
          .toList();

      final now = DateTime.now();
      var deletedCount = 0;
      
      for (final entity in logFiles) {
        if (entity is File) {
          final stat = await entity.stat();
          final age = now.difference(stat.modified).inDays;
          
          if (age > LOG_RETENTION_DAYS) {
            await entity.delete();
            deletedCount++;
          }
        }
      }

      if (deletedCount > 0) {
        await _logService.logInfo(
          '日志清理完成',
          data: {'deleted_files': deletedCount},
        );
      }
    } catch (e) {
      print('日志清理失败: $e');
    }
  }

  Future<void> _optimizeImageCache() async {
    try {
      final imageCache = PaintingBinding.instance.imageCache;
      if (imageCache.currentSize > MAX_IMAGE_CACHE_ENTRIES) {
        imageCache.clear();
        imageCache.maximumSize = MAX_IMAGE_CACHE_ENTRIES;
        
        await _logService.logInfo(
          '图片缓存已优化',
          data: {'max_entries': MAX_IMAGE_CACHE_ENTRIES},
        );
      }
    } catch (e) {
      print('图片缓存优化失败: $e');
    }
  }

  Future<void> _optimizeDatabase() async {
    try {
      // TODO: 实现数据库优化逻辑
      // 1. 清理过期数据
      // 2. 执行VACUUM
      // 3. 重建索引
    } catch (e) {
      print('数据库优化失败: $e');
    }
  }

  Future<int> _calculateDirSize(Directory dir) async {
    int size = 0;
    try {
      await for (final entity in dir.list(recursive: true)) {
        if (entity is File) {
          size += await entity.length();
        }
      }
    } catch (e) {
      print('计算目录大小失败: $e');
    }
    return size;
  }

  // 获取优化状态报告
  Future<Map<String, dynamic>> getOptimizationReport() async {
    final cacheDir = await getTemporaryDirectory();
    final cacheSize = await _calculateDirSize(cacheDir);
    
    return {
      'last_optimization': await _getLastOptimizationTime(),
      'cache_size': cacheSize,
      'cache_status': cacheSize > CACHE_SIZE_THRESHOLD ? '需要优化' : '正常',
      'image_cache_entries': PaintingBinding.instance.imageCache.currentSize,
      'memory_usage': _performanceService.currentMemoryUsage.value,
      'performance_status': _getPerformanceStatus(),
    };
  }

  Future<DateTime?> _getLastOptimizationTime() async {
    // TODO: 实现获取上次优化时间的逻辑
    return null;
  }

  String _getPerformanceStatus() {
    if (_performanceService.currentMemoryUsage.value > PerformanceService.MEMORY_THRESHOLD) {
      return '内存使用过高';
    }
    if (_performanceService.currentCpuUsage.value > PerformanceService.CPU_USAGE_THRESHOLD) {
      return 'CPU使用过高';
    }
    return '正常';
  }
} 