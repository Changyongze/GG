import 'package:get/get.dart';
import '../../../models/point_record.dart';
import '../../../services/auth_service.dart';
import '../../../api/points_api.dart';

class PointsHistoryController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final PointsApi _pointsApi = PointsApi();
  
  final isLoading = false.obs;
  final points = 0.obs;
  final monthEarned = 0.obs;
  final monthSpent = 0.obs;
  final records = <PointRecord>[].obs;
  
  final selectedType = '全部'.obs;
  final selectedSource = '全部'.obs;
  
  final _page = 1.obs;
  final _hasMore = true.obs;
  static const _pageSize = 20;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        loadPoints(),
        loadRecords(),
      ]);
    } catch (e) {
      Get.snackbar('错误', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadPoints() async {
    final response = await _pointsApi.getUserPoints();
    points.value = response['points'] ?? 0;
    monthEarned.value = response['month_earned'] ?? 0;
    monthSpent.value = response['month_spent'] ?? 0;
  }

  Future<void> loadRecords({bool refresh = false}) async {
    if (refresh) {
      _page.value = 1;
      _hasMore.value = true;
    }

    if (!_hasMore.value) return;

    try {
      final response = await _pointsApi.getPointRecords(
        type: selectedType.value == '全部' ? null : selectedType.value == '获得' ? 'earn' : 'spend',
        source: selectedSource.value == '全部' ? null : selectedSource.value.toLowerCase(),
        page: _page.value,
        pageSize: _pageSize,
      );
      
      if (refresh) {
        records.clear();
      }
      
      if (response.length < _pageSize) {
        _hasMore.value = false;
      }
      
      records.addAll(response);
      _page.value++;
    } catch (e) {
      Get.snackbar('错误', e.toString());
    }
  }

  Future<void> refreshRecords() async {
    await loadRecords(refresh: true);
  }

  void loadMore() {
    if (!isLoading.value && _hasMore.value) {
      loadRecords();
    }
  }
} 