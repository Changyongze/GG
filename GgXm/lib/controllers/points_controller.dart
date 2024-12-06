class PointsController extends GetxController {
  final PointsApi _pointsApi = Get.find<PointsApi>();
  
  final balance = 0.obs;
  final records = <PointsRecord>[].obs;
  final isLoading = false.obs;
  final currentPage = 1.obs;
  final hasMore = true.obs;
  
  final watchLimit = 1000.obs;
  final interactionLimit = 500.obs;
  final todayWatchPoints = 0.obs;
  final todayInteractionPoints = 0.obs;

  static const pageSize = 20;

  @override
  void onInit() {
    super.onInit();
    loadBalance();
    loadLimits();
    loadTodayPoints();
    loadRecords(refresh: true);
  }

  Future<void> loadBalance() async {
    try {
      final points = await _pointsApi.getBalance();
      balance.value = points;
    } catch (e) {
      Get.snackbar('错误', e.toString());
    }
  }

  Future<void> loadLimits() async {
    try {
      final limits = await _pointsApi.getDailyLimits();
      watchLimit.value = limits['watch']!;
      interactionLimit.value = limits['interaction']!;
    } catch (e) {
      print('获取积分上限失败: $e');
    }
  }

  Future<void> loadTodayPoints() async {
    try {
      final points = await _pointsApi.getTodayPoints();
      todayWatchPoints.value = points['watch']!;
      todayInteractionPoints.value = points['interaction']!;
    } catch (e) {
      print('获取今日积分失败: $e');
    }
  }

  Future<void> loadRecords({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      hasMore.value = true;
    }

    if (!hasMore.value) return;

    isLoading.value = true;
    try {
      final response = await _pointsApi.getRecords(
        page: currentPage.value,
        pageSize: pageSize,
      );
      
      if (refresh) {
        records.clear();
      }
      
      if (response.length < pageSize) {
        hasMore.value = false;
      }
      
      records.addAll(response);
      currentPage.value++;
    } catch (e) {
      Get.snackbar('错误', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  bool canEarnWatchPoints() {
    return todayWatchPoints.value < watchLimit.value;
  }

  bool canEarnInteractionPoints() {
    return todayInteractionPoints.value < interactionLimit.value;
  }

  Future<void> earnWatchPoints(String adId) async {
    if (!canEarnWatchPoints()) {
      Get.snackbar('提示', '今日观看积分已达上限');
      return;
    }

    try {
      final record = await _pointsApi.earnWatchPoints(adId);
      records.insert(0, record);
      balance.value += record.points;
      todayWatchPoints.value += record.points;
    } catch (e) {
      Get.snackbar('错误', e.toString());
    }
  }

  Future<void> earnInteractionPoints(String adId, PointsType type) async {
    if (!canEarnInteractionPoints()) {
      Get.snackbar('提示', '今日互动积分已达上限');
      return;
    }

    try {
      final record = await _pointsApi.earnInteractionPoints(adId, type);
      records.insert(0, record);
      balance.value += record.points;
      todayInteractionPoints.value += record.points;
    } catch (e) {
      Get.snackbar('错误', e.toString());
    }
  }
} 