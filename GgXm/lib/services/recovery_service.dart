import 'package:get/get.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:archive/archive.dart';
import '../database/backup_service.dart';
import '../utils/enhanced_encryption_util.dart';
import 'log_service.dart';

class RecoveryService extends GetxService {
  final BackupService _backupService = Get.find<BackupService>();
  final LogService _logService = Get.find<LogService>();
  
  // 恢复点状态
  final isCreatingRecoveryPoint = false.obs;
  final isRestoring = false.obs;

  // 创建恢复点
  Future<String?> createRecoveryPoint(String description) async {
    isCreatingRecoveryPoint.value = true;
    try {
      // 创建备份
      final backupPath = await _backupService.createBackup(
        encrypt: true,
        tag: 'recovery_point',
        metadata: {
          'description': description,
          'type': 'recovery_point',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      await _logService.logInfo(
        '创建恢复点',
        data: {'path': backupPath, 'description': description},
      );

      return backupPath;
    } catch (e, stackTrace) {
      await _logService.logError(e, '创建恢复点失败', stackTrace: stackTrace);
      return null;
    } finally {
      isCreatingRecoveryPoint.value = false;
    }
  }

  // 从恢复点恢复
  Future<bool> restoreFromPoint(String recoveryPointPath, String password) async {
    isRestoring.value = true;
    try {
      // 验证恢复点
      if (!await _verifyRecoveryPoint(recoveryPointPath)) {
        throw Exception('恢复点验证失败');
      }

      // 创建临时备份
      final tempBackup = await _createTempBackup();

      try {
        // 执行恢复
        final success = await _backupService.restoreBackup(
          recoveryPointPath,
          password: password,
        );

        if (!success) {
          // 恢复失败，还原临时备份
          await _restoreTempBackup(tempBackup);
          throw Exception('恢复失败');
        }

        await _logService.logInfo('从恢复点恢复成功');
        return true;
      } catch (e) {
        // 发生错误，尝试还原临时备份
        await _restoreTempBackup(tempBackup);
        rethrow;
      } finally {
        // 清理临时备份
        await _cleanupTempBackup(tempBackup);
      }
    } catch (e, stackTrace) {
      await _logService.logError(e, '从恢复点恢复失败', stackTrace: stackTrace);
      return false;
    } finally {
      isRestoring.value = false;
    }
  }

  // 验证恢复点
  Future<bool> _verifyRecoveryPoint(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return false;

      final bytes = await file.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      
      // 检查必要文件
      final requiredFiles = ['database.db', 'metadata.json'];
      for (final fileName in requiredFiles) {
        if (archive.findFile(fileName) == null) return false;
      }

      // 验证元数据
      final metadataFile = archive.findFile('metadata.json')!;
      final metadata = json.decode(utf8.decode(metadataFile.content));
      
      return metadata['type'] == 'recovery_point';
    } catch (e) {
      return false;
    }
  }

  // 创建临时备份
  Future<String> _createTempBackup() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final tempPath = await _backupService.createBackup(
      encrypt: true,
      tag: 'temp_backup_$timestamp',
    );
    return tempPath;
  }

  // 还原临时备份
  Future<void> _restoreTempBackup(String tempBackupPath) async {
    try {
      await _backupService.restoreBackup(tempBackupPath);
      await _logService.logInfo('还原临时备份成功');
    } catch (e, stackTrace) {
      await _logService.logError(e, '还原临时备份失败', stackTrace: stackTrace);
      rethrow;
    }
  }

  // 清理临时备份
  Future<void> _cleanupTempBackup(String tempBackupPath) async {
    try {
      final file = File(tempBackupPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('清理临时备份失败: $e');
    }
  }
} 