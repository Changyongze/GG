import 'package:get/get.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../services/log_service.dart';

class MigrationUtil {
  static const int CURRENT_VERSION = 1;
  
  static Future<void> migrateDatabase(Database db, int oldVersion, int newVersion) async {
    final logService = Get.find<LogService>();

    try {
      // 创建备份
      await _backupDatabase(db);

      for (var i = oldVersion + 1; i <= newVersion; i++) {
        await _runMigration(db, i);
      }

      await logService.logInfo(
        '数据库迁移成功',
        data: {
          'from_version': oldVersion,
          'to_version': newVersion,
        },
      );
    } catch (e, stackTrace) {
      await logService.logError(
        e,
        '数据库迁移失败',
        stackTrace: stackTrace,
      );
      // 恢复备份
      await _restoreDatabase(db);
      rethrow;
    }
  }

  static Future<void> _runMigration(Database db, int version) async {
    switch (version) {
      case 2:
        await _migrateToV2(db);
        break;
      case 3:
        await _migrateToV3(db);
        break;
      // 添加更多版本的迁移...
    }
  }

  static Future<void> _migrateToV2(Database db) async {
    await db.transaction((txn) async {
      // 添加新字段
      await txn.execute('ALTER TABLE users ADD COLUMN points INTEGER DEFAULT 0');
      
      // 更新数据
      await txn.execute('UPDATE users SET points = 0');
    });
  }

  static Future<void> _migrateToV3(Database db) async {
    await db.transaction((txn) async {
      // 创建新表
      await txn.execute('''
        CREATE TABLE user_settings (
          user_id TEXT PRIMARY KEY,
          theme TEXT NOT NULL DEFAULT 'light',
          language TEXT NOT NULL DEFAULT 'zh_CN',
          notification_enabled INTEGER NOT NULL DEFAULT 1,
          FOREIGN KEY (user_id) REFERENCES users (id)
        )
      ''');
      
      // 迁移数据
      await txn.execute('''
        INSERT INTO user_settings (user_id)
        SELECT id FROM users
      ''');
    });
  }

  static Future<void> _backupDatabase(Database db) async {
    final dbPath = db.path;
    final backupPath = '${dbPath}_backup_${DateTime.now().millisecondsSinceEpoch}';
    
    try {
      final dbFile = File(dbPath);
      await dbFile.copy(backupPath);
    } catch (e) {
      print('创建数据库备份失败: $e');
      rethrow;
    }
  }

  static Future<void> _restoreDatabase(Database db) async {
    final dbPath = db.path;
    final backupFile = await _findLatestBackup(dbPath);
    
    if (backupFile != null) {
      try {
        await db.close();
        final dbFile = File(dbPath);
        await dbFile.delete();
        await backupFile.copy(dbPath);
      } catch (e) {
        print('恢复数据库备份失败: $e');
        rethrow;
      }
    }
  }

  static Future<File?> _findLatestBackup(String dbPath) async {
    final directory = Directory(dirname(dbPath));
    final backupFiles = await directory
        .list()
        .where((entity) => 
            entity is File && 
            entity.path.startsWith('${dbPath}_backup_'))
        .toList();
    
    if (backupFiles.isEmpty) return null;
    
    backupFiles.sort((a, b) => b.path.compareTo(a.path));
    return backupFiles.first as File;
  }
} 