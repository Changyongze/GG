import 'package:get/get.dart';
import 'dart:async';
import 'database_service.dart';
import 'cache_service.dart';
import '../api/api_service.dart';
import '../models/sync_status.dart';

class SyncService extends GetxService {
  final DatabaseService _db = Get.find<DatabaseService>();
  final CacheService _cache = Get.find<CacheService>();
  final ApiService _api = Get.find<ApiService>();
  
  final syncStatus = Rx<SyncStatus>(SyncStatus.idle);
  final lastSyncTime = Rxn<DateTime>();
  Timer? _syncTimer;

  @override
  void onInit() {
    super.onInit();
    _setupPeriodicSync();
    lastSyncTime.value = _cache.getLastSyncTime();
  }

  @override
  void onClose() {
    _syncTimer?.cancel();
    super.onClose();
  }

  void _setupPeriodicSync() {
    // 每小时检查一次是否需要同步
    _syncTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      if (_cache.isCacheExpired()) {
        syncData();
      }
    });
  }

  Future<void> syncData() async {
    if (syncStatus.value == SyncStatus.syncing) return;
    
    syncStatus.value = SyncStatus.syncing;
    try {
      // 同步用户数据
      await _syncUserData();
      
      // 同步广告数据
      await _syncAdData();
      
      // 同步统计数据
      await _syncStatsData();
      
      // 同步用户行为数据
      await _syncBehaviorData();
      
      // 更新同步时间
      lastSyncTime.value = DateTime.now();
      await _cache.setLastSyncTime(lastSyncTime.value!);
      
      syncStatus.value = SyncStatus.completed;
    } catch (e) {
      print('同步失败: $e');
      syncStatus.value = SyncStatus.failed;
    }
  }

  Future<void> _syncUserData() async {
    // 获取本地最后更新时间
    final lastSync = await _db.getLastUserSync();
    
    // 获取服务器更新的数据
    final updates = await _api.getUserUpdates(since: lastSync);
    
    // 更新本地数据库
    for (final user in updates) {
      await _db.insertUser(user);
    }
  }

  Future<void> _syncAdData() async {
    final lastSync = await _db.getLastAdSync();
    final updates = await _api.getAdUpdates(since: lastSync);
    
    for (final ad in updates) {
      await _db.insertAdvertisement(ad);
    }
    
    // 更新缓存
    if (updates.isNotEmpty) {
      final cachedAds = await _db.getAdvertisements(limit: 50);
      await _cache.cacheAds(cachedAds);
    }
  }

  Future<void> _syncStatsData() async {
    final lastSync = await _db.getLastStatsSync();
    final updates = await _api.getStatsUpdates(since: lastSync);
    
    for (final stats in updates) {
      await _db.insertAdStats(stats);
    }
  }

  Future<void> _syncBehaviorData() async {
    // 获取本地未同步的行为数据
    final unsyncedBehaviors = await _db.getUnsyncedBehaviors();
    
    // 上传到服务器
    if (unsyncedBehaviors.isNotEmpty) {
      await _api.uploadBehaviors(unsyncedBehaviors);
      await _db.markBehaviorsSynced(unsyncedBehaviors);
    }
    
    // 获取服务器新数据
    final lastSync = await _db.getLastBehaviorSync();
    final updates = await _api.getBehaviorUpdates(since: lastSync);
    
    for (final behavior in updates) {
      await _db.insertUserBehavior(behavior);
    }
  }

  // 强制同步
  Future<void> forceSyncData() async {
    await syncData();
  }

  // 检查是否需要同步
  bool needsSync() {
    return _cache.isCacheExpired();
  }
} 