import 'package:get/get.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../api/points_api.dart';

class ProfileController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final PointsApi _pointsApi = PointsApi();
  
  final user = Rxn<User>();
  final points = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
    // 监听用户信息变化
    ever(_authService.currentUser, (_) {
      user.value = _authService.currentUser.value;
    });
    user.value = _authService.currentUser.value;
  }

  Future<void> loadData() async {
    try {
      final response = await _pointsApi.getUserPoints();
      points.value = response['points'] ?? 0;
    } catch (e) {
      Get.snackbar('错误', e.toString());
    }
  }

  void logout() {
    Get.dialog(
      AlertDialog(
        title: const Text('提示'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _authService.logout();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
} 