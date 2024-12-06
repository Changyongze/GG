import 'package:get/get.dart';
import 'ad_detail_controller.dart';

class AdDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdDetailController>(() => AdDetailController());
  }
} 