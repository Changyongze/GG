import 'package:get/get.dart';
import 'points_mall_controller.dart';

class PointsMallBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PointsMallController>(() => PointsMallController());
  }
} 