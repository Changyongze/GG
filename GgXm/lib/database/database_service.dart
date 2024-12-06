import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models/database_models.dart';
import 'package:get/get.dart';
import 'migration_service.dart';

class DatabaseService {
  static Database? _database;
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'ad_app.db');
    return await openDatabase(
      path,
      version: 4,
      onCreate: _createTables,
      onUpgrade: (db, oldVersion, newVersion) async {
        await Get.find<MigrationService>().migrate(db, oldVersion, newVersion);
      },
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // 用户表
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        phone TEXT NOT NULL,
        nickname TEXT,
        avatar TEXT,
        gender TEXT,
        age INTEGER,
        region TEXT,
        interests TEXT,
        created_at TEXT NOT NULL,
        last_login_at TEXT
      )
    ''');

    // 广告表
    await db.execute('''
      CREATE TABLE advertisements (
        id TEXT PRIMARY KEY,
        advertiser_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        video_url TEXT NOT NULL,
        cover_url TEXT NOT NULL,
        category TEXT NOT NULL,
        tags TEXT NOT NULL,
        budget REAL NOT NULL,
        target_audience TEXT NOT NULL,
        placement TEXT NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (advertiser_id) REFERENCES users (id)
      )
    ''');

    // 广告数据表
    await db.execute('''
      CREATE TABLE ad_stats (
        id TEXT PRIMARY KEY,
        ad_id TEXT NOT NULL,
        impressions INTEGER NOT NULL,
        clicks INTEGER NOT NULL,
        likes INTEGER NOT NULL,
        comments INTEGER NOT NULL,
        shares INTEGER NOT NULL,
        region_distribution TEXT NOT NULL,
        age_distribution TEXT NOT NULL,
        gender_distribution TEXT NOT NULL,
        time_distribution TEXT NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (ad_id) REFERENCES advertisements (id)
      )
    ''');

    // 用户行为表
    await db.execute('''
      CREATE TABLE user_behaviors (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        ad_id TEXT NOT NULL,
        type TEXT NOT NULL,
        data TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (ad_id) REFERENCES advertisements (id)
      )
    ''');
  }

  // 用户相关操作
  Future<void> insertUser(User user) async {
    final db = await database;
    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<User?> getUser(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return User(
      id: maps[0]['id'],
      phone: maps[0]['phone'],
      nickname: maps[0]['nickname'],
      avatar: maps[0]['avatar'],
      gender: maps[0]['gender'],
      age: maps[0]['age'],
      region: maps[0]['region'],
      interests: maps[0]['interests'] != null 
        ? List<String>.from(maps[0]['interests'])
        : null,
      createdAt: DateTime.parse(maps[0]['created_at']),
      lastLoginAt: maps[0]['last_login_at'] != null
        ? DateTime.parse(maps[0]['last_login_at'])
        : null,
    );
  }

  Future<void> updateUser(User user) async {
    final db = await database;
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // 广告相关操作
  Future<void> insertAdvertisement(Advertisement ad) async {
    final db = await database;
    await db.insert(
      'advertisements',
      ad.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Advertisement>> getAdvertisements({
    String? category,
    String? advertiserId,
    String? status,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    
    String whereClause = '';
    List<dynamic> whereArgs = [];
    
    if (category != null) {
      whereClause += 'category = ?';
      whereArgs.add(category);
    }
    if (advertiserId != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'advertiser_id = ?';
      whereArgs.add(advertiserId);
    }
    if (status != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'status = ?';
      whereArgs.add(status);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'advertisements',
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      limit: limit,
      offset: offset,
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return Advertisement(
        id: maps[i]['id'],
        advertiserId: maps[i]['advertiser_id'],
        title: maps[i]['title'],
        description: maps[i]['description'],
        videoUrl: maps[i]['video_url'],
        coverUrl: maps[i]['cover_url'],
        category: maps[i]['category'],
        tags: List<String>.from(maps[i]['tags']),
        budget: maps[i]['budget'],
        targetAudience: List<String>.from(maps[i]['target_audience']),
        placement: List<String>.from(maps[i]['placement']),
        startDate: DateTime.parse(maps[i]['start_date']),
        endDate: DateTime.parse(maps[i]['end_date']),
        status: maps[i]['status'],
        createdAt: DateTime.parse(maps[i]['created_at']),
      );
    });
  }

  // 广告统计数据操作
  Future<void> insertAdStats(AdStats stats) async {
    final db = await database;
    await db.insert(
      'ad_stats',
      stats.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<AdStats>> getAdStats(
    String adId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await database;
    
    String whereClause = 'ad_id = ?';
    List<dynamic> whereArgs = [adId];
    
    if (startDate != null) {
      whereClause += ' AND date >= ?';
      whereArgs.add(startDate.toIso8601String());
    }
    if (endDate != null) {
      whereClause += ' AND date <= ?';
      whereArgs.add(endDate.toIso8601String());
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'ad_stats',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return AdStats(
        id: maps[i]['id'],
        adId: maps[i]['ad_id'],
        impressions: maps[i]['impressions'],
        clicks: maps[i]['clicks'],
        likes: maps[i]['likes'],
        comments: maps[i]['comments'],
        shares: maps[i]['shares'],
        regionDistribution: Map<String, int>.from(maps[i]['region_distribution']),
        ageDistribution: Map<String, int>.from(maps[i]['age_distribution']),
        genderDistribution: Map<String, int>.from(maps[i]['gender_distribution']),
        timeDistribution: Map<String, int>.from(maps[i]['time_distribution']),
        date: DateTime.parse(maps[i]['date']),
      );
    });
  }

  // 用户行为数据操作
  Future<void> insertUserBehavior(UserBehavior behavior) async {
    final db = await database;
    await db.insert(
      'user_behaviors',
      behavior.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<UserBehavior>> getUserBehaviors({
    String? userId,
    String? adId,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    
    String whereClause = '';
    List<dynamic> whereArgs = [];
    
    if (userId != null) {
      whereClause += 'user_id = ?';
      whereArgs.add(userId);
    }
    if (adId != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'ad_id = ?';
      whereArgs.add(adId);
    }
    if (type != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'type = ?';
      whereArgs.add(type);
    }
    if (startDate != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'created_at >= ?';
      whereArgs.add(startDate.toIso8601String());
    }
    if (endDate != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'created_at <= ?';
      whereArgs.add(endDate.toIso8601String());
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'user_behaviors',
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      limit: limit,
      offset: offset,
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return UserBehavior(
        id: maps[i]['id'],
        userId: maps[i]['user_id'],
        adId: maps[i]['ad_id'],
        type: maps[i]['type'],
        data: Map<String, dynamic>.from(maps[i]['data']),
        createdAt: DateTime.parse(maps[i]['created_at']),
      );
    });
  }
} 