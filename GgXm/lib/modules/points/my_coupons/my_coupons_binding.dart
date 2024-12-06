import 'package:get/get.dart';
import 'my_coupons_controller.dart';

class MyCouponsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyCouponsController>(() => MyCouponsController());
  }
} 