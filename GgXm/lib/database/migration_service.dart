import 'package:sqflite/sqflite.dart';
import 'database_service.dart';

class MigrationService {
  final migrations = {
    2: (Database db) async {
      // 添加用户积分字段
      await db.execute('ALTER TABLE users ADD COLUMN points INTEGER DEFAULT 0');
    },
    3: (Database db) async {
      // 添加广告评分表
      await db.execute('''
        CREATE TABLE ad_ratings (
          id TEXT PRIMARY KEY,
          ad_id TEXT NOT NULL,
          user_id TEXT NOT NULL,
          rating INTEGER NOT NULL,
          comment TEXT,
          created_at TEXT NOT NULL,
          FOREIGN KEY (ad_id) REFERENCES advertisements (id),
          FOREIGN KEY (user_id) REFERENCES users (id)
        )
      ''');
    },
    4: (Database db) async {
      // 添加广告标签关联表
      await db.execute('''
        CREATE TABLE ad_tags (
          ad_id TEXT NOT NULL,
          tag TEXT NOT NULL,
          PRIMARY KEY (ad_id, tag),
          FOREIGN KEY (ad_id) REFERENCES advertisements (id)
        )
      ''');
      
      // 迁移现有标签数据
      final ads = await db.query('advertisements');
      for (final ad in ads) {
        final tags = (ad['tags'] as String).split(',');
        for (final tag in tags) {
          await db.insert('ad_tags', {
            'ad_id': ad['id'],
            'tag': tag.trim(),
          });
        }
      }
    },
  };

  Future<void> migrate(Database db, int oldVersion, int newVersion) async {
    for (var i = oldVersion + 1; i <= newVersion; i++) {
      if (migrations.containsKey(i)) {
        await migrations[i]!(db);
      }
    }
  }
} 