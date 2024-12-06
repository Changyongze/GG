import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';

class LoginController extends GetxController {
  final PCAuthController _authController = Get.find<PCAuthController>();
  
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  
  final showPassword = false.obs;
  final isLoading = false.obs;

  void togglePasswordVisibility() {
    showPassword.value = !showPassword.value;
  }

  Future<void> login() async {
    if (usernameController.text.isEmpty) {
      Get.snackbar('提示', '请输入用户名');
      return;
    }
    if (passwordController.text.isEmpty) {
      Get.snackbar('提示', '请输入密码');
      return;
    }

    isLoading.value = true;
    try {
      await _authController.login(
        usernameController.text,
        passwordController.text,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
} 