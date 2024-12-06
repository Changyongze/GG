import 'package:get/get.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';
import 'database_service.dart';
import '../utils/encryption_util.dart';

class BackupService extends GetxService {
  final DatabaseService _db = Get.find<DatabaseService>();
  final backupInProgress = false.obs;
  final restoreInProgress = false.obs;

  // 创建备份
  Future<String> createBackup({bool encrypt = true}) async {
    if (backupInProgress.value) return '';
    
    backupInProgress.value = true;
    try {
      // 获取数据库文件
      final dbFile = await _getDatabaseFile();
      
      // 创建备份目录
      final backupDir = await _getBackupDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final backupPath = join(backupDir.path, 'backup_$timestamp.zip');
      
      // 创建ZIP文件
      final encoder = ZipEncoder();
      final archive = Archive();
      
      // 添加数据库文件
      final dbBytes = await dbFile.readAsBytes();
      final dbData = encrypt ? EncryptionUtil.encrypt(dbBytes) : dbBytes;
      archive.addFile(ArchiveFile(
        'database.db',
        dbData.length,
        dbData,
      ));
      
      // 添加元数据
      final metadata = {
        'timestamp': timestamp,
        'encrypted': encrypt,
        'version': 1,
      };
      final metadataBytes = utf8.encode(json.encode(metadata));
      archive.addFile(ArchiveFile(
        'metadata.json',
        metadataBytes.length,
        metadataBytes,
      ));
      
      // 保存ZIP文件
      final zipData = encoder.encode(archive);
      if (zipData != null) {
        final backupFile = File(backupPath);
        await backupFile.writeAsBytes(zipData);
      }
      
      return backupPath;
    } catch (e) {
      print('备份失败: $e');
      return '';
    } finally {
      backupInProgress.value = false;
    }
  }

  // 恢复备份
  Future<bool> restoreBackup(String backupPath) async {
    if (restoreInProgress.value) return false;
    
    restoreInProgress.value = true;
    try {
      final backupFile = File(backupPath);
      if (!await backupFile.exists()) return false;
      
      // 读取ZIP文件
      final bytes = await backupFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      
      // 读取元数据
      final metadataFile = archive.findFile('metadata.json');
      if (metadataFile == null) return false;
      
      final metadata = json.decode(utf8.decode(metadataFile.content));
      final encrypted = metadata['encrypted'] as bool;
      
      // 读取数据库文件
      final dbFile = archive.findFile('database.db');
      if (dbFile == null) return false;
      
      var dbData = dbFile.content as List<int>;
      if (encrypted) {
        dbData = EncryptionUtil.decrypt(dbData);
      }
      
      // 恢复数据库文件
      final targetFile = await _getDatabaseFile();
      await targetFile.writeAsBytes(dbData);
      
      // 重新初始化数据库
      await _db.reInitialize();
      
      return true;
    } catch (e) {
      print('恢复失败: $e');
      return false;
    } finally {
      restoreInProgress.value = false;
    }
  }

  // 获取备份列表
  Future<List<BackupInfo>> getBackupList() async {
    final backupDir = await _getBackupDirectory();
    final files = await backupDir.list().toList();
    
    final backups = <BackupInfo>[];
    for (final file in files) {
      if (file is File && file.path.endsWith('.zip')) {
        try {
          final bytes = await file.readAsBytes();
          final archive = ZipDecoder().decodeBytes(bytes);
          final metadataFile = archive.findFile('metadata.json');
          if (metadataFile != null) {
            final metadata = json.decode(utf8.decode(metadataFile.content));
            backups.add(BackupInfo(
              path: file.path,
              timestamp: DateTime.parse(metadata['timestamp']),
              encrypted: metadata['encrypted'],
              version: metadata['version'],
              size: await file.length(),
            ));
          }
        } catch (e) {
          print('读取备份文件失败: $e');
        }
      }
    }
    
    return backups..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<File> _getDatabaseFile() async {
    final dbPath = await getDatabasesPath();
    return File(join(dbPath, 'ad_app.db'));
  }

  Future<Directory> _getBackupDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory(join(appDir.path, 'backups'));
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir;
  }
} 