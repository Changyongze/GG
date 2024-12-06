import 'package:get/get.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';

class PCAuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  
  final currentUser = Rxn<User>();
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // 监听用户状态变化
    ever(_authService.currentUser, (user) {
      currentUser.value = user;
      if (user == null) {
        Get.offAllNamed(PCRoutes.LOGIN);
      }
    });
    
    checkAuth();
  }

  Future<void> checkAuth() async {
    final token = await _authService.getToken();
    if (token == null) {
      Get.offAllNamed(PCRoutes.LOGIN);
    }
  }

  Future<void> login(String username, String password) async {
    isLoading.value = true;
    try {
      final success = await _authService.login(username, password);
      if (success) {
        Get.offAllNamed(PCRoutes.DASHBOARD);
      }
    } catch (e) {
      Get.snackbar('错误', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void logout() {
    _authService.logout();
  }
} 