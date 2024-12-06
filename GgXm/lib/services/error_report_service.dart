import 'package:get/get.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'log_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ErrorReportService extends GetxService {
  final LogService _logService = Get.find<LogService>();
  final _deviceInfo = DeviceInfoPlugin();
  late PackageInfo _packageInfo;
  
  Future<ErrorReportService> init() async {
    _packageInfo = await PackageInfo.fromPlatform();
    return this;
  }

  Future<void> reportError(dynamic error, StackTrace stackTrace) async {
    try {
      // 收集错误信息
      final errorReport = await _generateErrorReport(error, stackTrace);
      
      // 记录到日志
      await _logService.logError(
        error,
        '应用错误',
        stackTrace: stackTrace,
      );

      // 上传错误报告
      await _uploadErrorReport(errorReport);
    } catch (e) {
      print('生成错误报告失败: $e');
    }
  }

  Future<Map<String, dynamic>> _generateErrorReport(
    dynamic error,
    StackTrace stackTrace,
  ) async {
    final deviceInfo = await _getDeviceInfo();
    
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'app_version': _packageInfo.version,
      'build_number': _packageInfo.buildNumber,
      'device_info': deviceInfo,
      'error': {
        'type': error.runtimeType.toString(),
        'message': error.toString(),
        'stackTrace': stackTrace.toString(),
      },
      'memory_usage': await _getMemoryUsage(),
      'disk_space': await _getDiskSpace(),
      'recent_logs': await _logService.getRecentLogs(limit: 50),
    };
  }

  Future<Map<String, dynamic>> _getDeviceInfo() async {
    if (Platform.isAndroid) {
      final info = await _deviceInfo.androidInfo;
      return {
        'platform': 'Android',
        'version': info.version.release,
        'sdk': info.version.sdkInt,
        'manufacturer': info.manufacturer,
        'model': info.model,
      };
    } else if (Platform.isIOS) {
      final info = await _deviceInfo.iosInfo;
      return {
        'platform': 'iOS',
        'version': info.systemVersion,
        'model': info.model,
        'name': info.name,
      };
    }
    return {'platform': 'unknown'};
  }

  Future<int> _getMemoryUsage() async {
    // TODO: 实现内存使用统计
    return 0;
  }

  Future<Map<String, int>> _getDiskSpace() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final stat = await dir.stat();
      return {
        'total': stat.size,
        'free': await _getFreeDiskSpace(),
      };
    } catch (e) {
      return {'total': 0, 'free': 0};
    }
  }

  Future<int> _getFreeDiskSpace() async {
    // TODO: 实现剩余空间统计
    return 0;
  }

  Future<void> _uploadErrorReport(Map<String, dynamic> report) async {
    try {
      // 保存错误报告到本地
      final reportFile = await _saveReportLocally(report);
      
      // 检查网络连接
      if (!await _checkNetworkConnection()) {
        // 添加到上传队列
        await _addToUploadQueue(reportFile.path);
        return;
      }

      // 上传到服务器
      final success = await _uploadToServer(report);
      if (success) {
        // 上传成功后删除本地文件
        await reportFile.delete();
      } else {
        // 上传失败，添加到队列
        await _addToUploadQueue(reportFile.path);
      }
    } catch (e) {
      print('上传错误报告失败: $e');
    }
  }

  Future<File> _saveReportLocally(Map<String, dynamic> report) async {
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = join(dir.path, 'error_reports', 'report_$timestamp.json');
    
    final file = File(path);
    await file.create(recursive: true);
    await file.writeAsString(json.encode(report));
    
    return file;
  }

  Future<bool> _checkNetworkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  Future<void> _addToUploadQueue(String filePath) async {
    final prefs = await SharedPreferences.getInstance();
    final queue = prefs.getStringList('error_report_queue') ?? [];
    queue.add(filePath);
    await prefs.setStringList('error_report_queue', queue);
  }

  Future<bool> _uploadToServer(Map<String, dynamic> report) async {
    try {
      final response = await http.post(
        Uri.parse('https://your-error-reporting-server.com/api/reports'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getApiToken()}',
        },
        body: json.encode(report),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('上传到服务器失败: $e');
      return false;
    }
  }

  Future<String> _getApiToken() async {
    // TODO: 实现获取API令牌的逻辑
    return 'your-api-token';
  }

  // 处理上传队列
  Future<void> processUploadQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final queue = prefs.getStringList('error_report_queue') ?? [];
    
    if (queue.isEmpty) return;
    
    // 检查网络连接
    if (!await _checkNetworkConnection()) return;
    
    final successfulUploads = <String>[];
    
    for (final filePath in queue) {
      try {
        final file = File(filePath);
        if (!await file.exists()) continue;
        
        final report = json.decode(await file.readAsString());
        final success = await _uploadToServer(report);
        
        if (success) {
          await file.delete();
          successfulUploads.add(filePath);
        }
      } catch (e) {
        print('处理队列项失败: $e');
      }
    }
    
    // 更新队列
    queue.removeWhere((path) => successfulUploads.contains(path));
    await prefs.setStringList('error_report_queue', queue);
  }
} 