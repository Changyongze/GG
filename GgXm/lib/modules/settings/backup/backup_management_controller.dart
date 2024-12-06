import 'package:get/get.dart';
import 'dart:io';
import '../../../database/backup_service.dart';
import '../../../models/backup_info.dart';
import '../../../utils/error_handler.dart';

class BackupManagementController extends GetxController {
  final BackupService _backupService = Get.find<BackupService>();
  final isLoading = false.obs;
  final backups = <BackupInfo>[].obs;
  final encryptBackup = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadBackups();
  }

  Future<void> loadBackups() async {
    isLoading.value = true;
    try {
      final list = await _backupService.getBackupList();
      backups.value = list;
    } catch (e) {
      ErrorHandler.handleError(e, '加载备份列表失败');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createBackup() async {
    isLoading.value = true;
    try {
      final path = await _backupService.createBackup(
        encrypt: encryptBackup.value,
      );
      if (path.isNotEmpty) {
        await loadBackups();
        Get.snackbar('成功', '备份已创建');
      }
    } catch (e) {
      ErrorHandler.handleError(e, '��建备份失败');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> restoreBackup(BackupInfo backup) async {
    isLoading.value = true;
    try {
      final success = await _backupService.restoreBackup(backup.path);
      if (success) {
        Get.snackbar('成功', '备份已恢复');
        // 重新初始化应用
        Get.offAllNamed('/');
      } else {
        Get.snackbar('错误', '恢复备份失败');
      }
    } catch (e) {
      ErrorHandler.handleError(e, '恢复备份失败');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteBackup(BackupInfo backup) async {
    isLoading.value = true;
    try {
      final file = File(backup.path);
      if (await file.exists()) {
        await file.delete();
        backups.removeWhere((b) => b.path == backup.path);
        Get.snackbar('成功', '备份已删除');
      }
    } catch (e) {
      ErrorHandler.handleError(e, '删除备份失败');
    } finally {
      isLoading.value = false;
    }
  }

  // 自动备份设置
  Future<void> configureAutoBackup({
    required bool enabled,
    required int frequency, // 天数
    required bool encrypt,
  }) async {
    try {
      await _backupService.configureAutoBackup(
        enabled: enabled,
        frequency: frequency,
        encrypt: encrypt,
      );
      Get.snackbar('成功', '自动备份设置已更新');
    } catch (e) {
      ErrorHandler.handleError(e, '更新自动备份设置失败');
    }
  }

  // 清理旧备份
  Future<void> cleanOldBackups({required int keepCount}) async {
    try {
      final deleted = await _backupService.cleanOldBackups(keepCount: keepCount);
      if (deleted > 0) {
        await loadBackups();
        Get.snackbar('成功', '已清理 $deleted 个旧备份');
      }
    } catch (e) {
      ErrorHandler.handleError(e, '清理旧备份失败');
    }
  }
} 