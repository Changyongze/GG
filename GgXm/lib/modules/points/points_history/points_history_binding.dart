import 'package:get/get.dart';
import 'points_history_controller.dart';

class PointsHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PointsHistoryController>(() => PointsHistoryController());
  }
} 