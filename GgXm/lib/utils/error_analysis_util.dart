import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';

class ErrorAnalysisUtil {
  // 错误类型分类
  static const Map<String, List<String>> ERROR_PATTERNS = {
    'network': [
      'SocketException',
      'TimeoutException',
      'DioError',
    ],
    'database': [
      'DatabaseException',
      'SqliteException',
    ],
    'ui': [
      'FlutterError',
      'AssertionError',
    ],
    'permission': [
      'PlatformException',
      'PermissionDenied',
    ],
  };

  // 分析错误报告
  static Future<Map<String, dynamic>> analyzeErrorReports({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final reports = await _loadErrorReports(startDate, endDate);
    
    return {
      'total_errors': reports.length,
      'error_types': _analyzeErrorTypes(reports),
      'frequent_errors': _findFrequentErrors(reports),
      'error_timeline': _generateErrorTimeline(reports),
      'affected_users': _analyzeAffectedUsers(reports),
      'device_distribution': _analyzeDeviceDistribution(reports),
      'version_distribution': _analyzeVersionDistribution(reports),
    };
  }

  static Future<List<Map<String, dynamic>>> _loadErrorReports([
    DateTime? startDate,
    DateTime? endDate,
  ]) async {
    final dir = await getApplicationDocumentsDirectory();
    final reportsDir = Directory(join(dir.path, 'error_reports'));
    
    if (!await reportsDir.exists()) {
      return [];
    }

    final reports = <Map<String, dynamic>>[];
    await for (final file in reportsDir.list()) {
      if (file is File && file.path.endsWith('.json')) {
        try {
          final content = await file.readAsString();
          final report = json.decode(content);
          
          final timestamp = DateTime.parse(report['timestamp']);
          if (startDate != null && timestamp.isBefore(startDate)) continue;
          if (endDate != null && timestamp.isAfter(endDate)) continue;
          
          reports.add(report);
        } catch (e) {
          print('读取错误报告失败: $e');
        }
      }
    }
    
    return reports;
  }

  static Map<String, int> _analyzeErrorTypes(List<Map<String, dynamic>> reports) {
    final types = <String, int>{};
    
    for (final report in reports) {
      final errorType = _categorizeError(report['error']['type']);
      types[errorType] = (types[errorType] ?? 0) + 1;
    }
    
    return types;
  }

  static String _categorizeError(String errorType) {
    for (final entry in ERROR_PATTERNS.entries) {
      if (entry.value.any((pattern) => errorType.contains(pattern))) {
        return entry.key;
      }
    }
    return 'other';
  }

  static List<Map<String, dynamic>> _findFrequentErrors(
    List<Map<String, dynamic>> reports,
  ) {
    final errorCounts = <String, Map<String, dynamic>>{};
    
    for (final report in reports) {
      final error = report['error'];
      final key = '${error['type']}:${error['message']}';
      
      if (!errorCounts.containsKey(key)) {
        errorCounts[key] = {
          'type': error['type'],
          'message': error['message'],
          'count': 0,
          'first_seen': report['timestamp'],
          'last_seen': report['timestamp'],
        };
      }
      
      errorCounts[key]!['count'] = errorCounts[key]!['count'] + 1;
      errorCounts[key]!['last_seen'] = report['timestamp'];
    }
    
    final sortedErrors = errorCounts.values.toList()
      ..sort((a, b) => b['count'].compareTo(a['count']));
    
    return sortedErrors.take(10).toList(); // 返回前10个最频繁的错误
  }

  // ... 继续实现其他分析方法
} 