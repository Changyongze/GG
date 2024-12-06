import 'package:get/get.dart';
import 'coupon_detail_controller.dart';

class CouponDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CouponDetailController>(() => CouponDetailController());
  }
} 