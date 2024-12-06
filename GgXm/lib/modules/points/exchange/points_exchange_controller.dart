import 'package:get/get.dart';
import '../../../models/coupon.dart';
import '../../../api/points_api.dart';

class PointsExchangeController extends GetxController {
  final PointsApi _pointsApi = Get.find<PointsApi>();
  
  final coupons = <Coupon>[].obs;
  final isLoading = false.obs;
  final selectedType = Rxn<CouponType>();
  final searchText = ''.obs;
  final sortBy = 'points'.obs; // points/value/endDate
  
  @override
  void onInit() {
    super.onInit();
    loadCoupons();
  }

  Future<void> loadCoupons() async {
    isLoading.value = true;
    try {
      final response = await _pointsApi.getCoupons(
        type: selectedType.value?.name,
        keyword: searchText.value,
        sortBy: sortBy.value,
      );
      coupons.value = response;
    } catch (e) {
      Get.snackbar('错误', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void filterByType(CouponType? type) {
    selectedType.value = type;
    loadCoupons();
  }

  void search(String text) {
    searchText.value = text;
    loadCoupons();
  }

  void sort(String by) {
    sortBy.value = by;
    loadCoupons();
  }

  Future<void> exchangeCoupon(Coupon coupon) async {
    try {
      await _pointsApi.exchangeCoupon(coupon.id);
      Get.snackbar('成功', '兑换成功');
      loadCoupons();
    } catch (e) {
      Get.snackbar('错误', e.toString());
    }
  }

  void viewCouponDetail(Coupon coupon) {
    Get.toNamed(
      Routes.COUPON_DETAIL,
      arguments: coupon,
    );
  }
} 