import 'package:get/get.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:convert';

class LogService extends GetxService {
  static const String LOG_FOLDER = 'logs';
  static const int MAX_LOG_FILES = 5;
  static const int MAX_LOG_SIZE = 5 * 1024 * 1024; // 5MB

  late Directory _logDir;
  File? _currentLogFile;
  
  Future<LogService> init() async {
    final appDir = await getApplicationDocumentsDirectory();
    _logDir = Directory(join(appDir.path, LOG_FOLDER));
    if (!await _logDir.exists()) {
      await _logDir.create(recursive: true);
    }
    await _initLogFile();
    return this;
  }

  Future<void> _initLogFile() async {
    final now = DateTime.now();
    final fileName = 'log_${now.year}${now.month}${now.day}.txt';
    _currentLogFile = File(join(_logDir.path, fileName));
    
    // 检查并清理旧日志
    await _cleanOldLogs();
  }

  Future<void> logError(dynamic error, String message, {StackTrace? stackTrace}) async {
    if (_currentLogFile == null) return;

    try {
      final timestamp = DateTime.now().toIso8601String();
      final logEntry = {
        'timestamp': timestamp,
        'level': 'ERROR',
        'message': message,
        'error': error.toString(),
        'stackTrace': stackTrace?.toString(),
      };

      final logLine = json.encode(logEntry) + '\n';
      await _currentLogFile!.writeAsString(
        logLine,
        mode: FileMode.append,
      );

      // 检查日志文件大小
      if (await _currentLogFile!.length() > MAX_LOG_SIZE) {
        await _rotateLogFile();
      }
    } catch (e) {
      print('写入日志失败: $e');
    }
  }

  Future<void> logInfo(String message, {Map<String, dynamic>? data}) async {
    if (_currentLogFile == null) return;

    try {
      final timestamp = DateTime.now().toIso8601String();
      final logEntry = {
        'timestamp': timestamp,
        'level': 'INFO',
        'message': message,
        if (data != null) 'data': data,
      };

      final logLine = json.encode(logEntry) + '\n';
      await _currentLogFile!.writeAsString(
        logLine,
        mode: FileMode.append,
      );
    } catch (e) {
      print('写入日志失败: $e');
    }
  }

  Future<void> _rotateLogFile() async {
    final now = DateTime.now();
    final newFileName = 'log_${now.year}${now.month}${now.day}_${now.hour}${now.minute}${now.second}.txt';
    final newFile = File(join(_logDir.path, newFileName));
    
    await _currentLogFile!.rename(newFile.path);
    await _initLogFile();
  }

  Future<void> _cleanOldLogs() async {
    try {
      final files = await _logDir
          .list()
          .where((entity) => entity is File && entity.path.endsWith('.txt'))
          .toList();
      
      if (files.length > MAX_LOG_FILES) {
        // 按修改时间排序
        files.sort((a, b) {
          return b.statSync().modified.compareTo(a.statSync().modified);
        });
        
        // 删除旧文件
        for (var i = MAX_LOG_FILES; i < files.length; i++) {
          await (files[i] as File).delete();
        }
      }
    } catch (e) {
      print('清理日志失败: $e');
    }
  }

  Future<List<String>> getRecentLogs({int limit = 100}) async {
    if (_currentLogFile == null || !await _currentLogFile!.exists()) {
      return [];
    }

    try {
      final lines = await _currentLogFile!.readAsLines();
      return lines.reversed.take(limit).toList();
    } catch (e) {
      print('读取日志失败: $e');
      return [];
    }
  }

  Future<void> exportLogs(String targetPath) async {
    try {
      final files = await _logDir
          .list()
          .where((entity) => entity is File && entity.path.endsWith('.txt'))
          .toList();
      
      for (final file in files) {
        if (file is File) {
          final fileName = basename(file.path);
          final targetFile = File(join(targetPath, fileName));
          await file.copy(targetFile.path);
        }
      }
    } catch (e) {
      print('导出日志失败: $e');
    }
  }
} 