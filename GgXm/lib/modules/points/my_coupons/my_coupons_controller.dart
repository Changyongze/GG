import 'package:get/get.dart';
import '../../../models/user_coupon.dart';
import '../../../api/points_api.dart';
import 'package:share_plus/share_plus.dart';

class MyCouponsController extends GetxController {
  final PointsApi _pointsApi = Get.find<PointsApi>();
  
  final coupons = <UserCoupon>[].obs;
  final isLoading = false.obs;
  final selectedStatus = 'available'.obs; // available/used/expired
  final notificationEnabled = true.obs;
  final notificationDays = 7.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadCoupons();
  }

  Future<void> loadCoupons() async {
    isLoading.value = true;
    try {
      final response = await _pointsApi.getUserCoupons(
        status: selectedStatus.value,
      );
      coupons.value = response;
    } catch (e) {
      Get.snackbar('错误', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void filterByStatus(String status) {
    selectedStatus.value = status;
    loadCoupons();
  }

  void viewCouponDetail(UserCoupon coupon) {
    Get.toNamed(
      Routes.COUPON_DETAIL,
      arguments: coupon,
    );
  }

  Future<void> useCoupon(UserCoupon coupon) async {
    if (!coupon.isAvailable) return;

    try {
      await _pointsApi.useCoupon(coupon.id);
      Get.snackbar('成功', '优惠券使用成功');
      loadCoupons();
    } catch (e) {
      Get.snackbar('错误', e.toString());
    }
  }

  Future<void> shareCoupon(UserCoupon coupon) async {
    try {
      final text = '''
【${coupon.name}】
${coupon.description}
面值：${coupon.valueText}
有效期至：${_formatDate(coupon.endDate)}
''';
      await Share.share(text);
    } catch (e) {
      Get.snackbar('错误', '分享失败');
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void toggleNotification(bool enabled) {
    notificationEnabled.value = enabled;
    // TODO: 保存设置
  }

  void updateNotificationDays(int days) {
    notificationDays.value = days;
    // TODO: 保存设置
  }
} 