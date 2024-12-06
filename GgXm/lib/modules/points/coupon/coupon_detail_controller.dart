import 'package:get/get.dart';
import '../../../models/coupon.dart';
import '../../../api/points_api.dart';

class CouponDetailController extends GetxController {
  final PointsApi _pointsApi = Get.find<PointsApi>();
  final coupon = Rxn<Coupon>();
  final isLoading = false.obs;
  final isExchanging = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is Coupon) {
      coupon.value = Get.arguments as Coupon;
    } else if (Get.arguments is String) {
      loadCouponDetail(Get.arguments as String);
    }
  }

  Future<void> loadCouponDetail(String id) async {
    isLoading.value = true;
    try {
      final response = await _pointsApi.getCouponDetail(id);
      coupon.value = response;
    } catch (e) {
      Get.snackbar('错误', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> exchangeCoupon() async {
    if (coupon.value == null) return;
    
    isExchanging.value = true;
    try {
      await _pointsApi.exchangeCoupon(coupon.value!.id);
      Get.back(result: true);
      Get.snackbar('成功', '兑换成功');
    } catch (e) {
      Get.snackbar('错误', e.toString());
    } finally {
      isExchanging.value = false;
    }
  }

  void showUseGuide() {
    if (coupon.value?.useGuide == null) return;
    
    Get.dialog(
      AlertDialog(
        title: const Text('使用说明'),
        content: Text(coupon.value!.useGuide!),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }

  void showExchangeConfirm() {
    Get.dialog(
      AlertDialog(
        title: const Text('确认兑换'),
        content: Text('确定使用${coupon.value!.points}积分兑换该优惠券吗？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              exchangeCoupon();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
} 