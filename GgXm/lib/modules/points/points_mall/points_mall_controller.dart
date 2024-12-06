import 'package:get/get.dart';
import '../../../models/coupon.dart';
import '../../../services/auth_service.dart';
import '../../../api/points_api.dart';

class PointsMallController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final PointsApi _pointsApi = PointsApi();
  
  final isLoading = false.obs;
  final points = 0.obs;
  final coupons = <Coupon>[].obs;

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
        loadCoupons(),
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
  }

  Future<void> loadCoupons() async {
    final response = await _pointsApi.getCoupons();
    coupons.value = response;
  }

  Future<void> refreshCoupons() async {
    await loadData();
  }

  void showCouponDetail(Coupon coupon) {
    Get.toNamed(
      Routes.COUPON_DETAIL,
      arguments: coupon,
    );
  }

  void exchangeCoupon(Coupon coupon) async {
    if (points.value < coupon.points) {
      Get.snackbar('提示', '积分不足');
      return;
    }

    try {
      await _pointsApi.exchangeCoupon(coupon.id);
      Get.snackbar('提示', '兑换成功');
      await loadPoints(); // 刷新积分
    } catch (e) {
      Get.snackbar('错误', e.toString());
    }
  }
} 