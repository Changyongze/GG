import 'package:get/get.dart';
import 'dart:async';
import 'package:shared_preferences.dart';
import '../database/backup_service.dart';
import 'log_service.dart';

class AutoBackupService extends GetxService {
  static const String KEY_ENABLED = 'auto_backup_enabled';
  static const String KEY_FREQUENCY = 'auto_backup_frequency';
  static const String KEY_ENCRYPT = 'auto_backup_encrypt';
  static const String KEY_LAST_BACKUP = 'auto_backup_last_time';

  final BackupService _backupService = Get.find<BackupService>();
  final LogService _logService = Get.find<LogService>();
  late SharedPreferences _prefs;
  Timer? _backupTimer;

  bool get isEnabled => _prefs.getBool(KEY_ENABLED) ?? false;
  int get frequency => _prefs.getInt(KEY_FREQUENCY) ?? 7; // 默认7天
  bool get shouldEncrypt => _prefs.getBool(KEY_ENCRYPT) ?? true;

  Future<AutoBackupService> init() async {
    _prefs = await SharedPreferences.getInstance();
    _setupBackupTimer();
    return this;
  }

  void _setupBackupTimer() {
    _backupTimer?.cancel();
    if (!isEnabled) return;

    // 检查是否需要备份
    _checkAndBackup();

    // 每天检查��次
    _backupTimer = Timer.periodic(
      const Duration(days: 1),
      (_) => _checkAndBackup(),
    );
  }

  Future<void> _checkAndBackup() async {
    if (!isEnabled) return;

    final lastBackup = DateTime.fromMillisecondsSinceEpoch(
      _prefs.getInt(KEY_LAST_BACKUP) ?? 0,
    );
    final now = DateTime.now();
    final daysSinceLastBackup = now.difference(lastBackup).inDays;

    if (daysSinceLastBackup >= frequency) {
      await _performAutoBackup();
    }
  }

  Future<void> _performAutoBackup() async {
    try {
      final path = await _backupService.createBackup(
        encrypt: shouldEncrypt,
      );
      
      if (path.isNotEmpty) {
        await _prefs.setInt(KEY_LAST_BACKUP, DateTime.now().millisecondsSinceEpoch);
        await _logService.logInfo(
          '自动备份成功',
          data: {'path': path, 'encrypted': shouldEncrypt},
        );
      }
    } catch (e, stackTrace) {
      await _logService.logError(
        e,
        '自动备份失败',
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> configure({
    required bool enabled,
    required int frequency,
    required bool encrypt,
  }) async {
    await _prefs.setBool(KEY_ENABLED, enabled);
    await _prefs.setInt(KEY_FREQUENCY, frequency);
    await _prefs.setBool(KEY_ENCRYPT, encrypt);
    
    _setupBackupTimer();
  }

  @override
  void onClose() {
    _backupTimer?.cancel();
    super.onClose();
  }
} 