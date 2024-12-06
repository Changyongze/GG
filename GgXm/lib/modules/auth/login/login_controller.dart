import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/auth_service.dart';

class LoginController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  
  final phoneController = TextEditingController();
  final codeController = TextEditingController();
  
  final canGetCode = true.obs;
  final countdown = 60.obs;

  void getVerificationCode() async {
    if (phoneController.text.isEmpty) {
      Get.snackbar('提示', '请输入手机号');
      return;
    }

    try {
      await _authService.sendVerificationCode(phoneController.text);
      startCountdown();
      Get.snackbar('提示', '验证码已发送');
    } catch (e) {
      Get.snackbar('错误', e.toString());
    }
  }

  void startCountdown() {
    canGetCode.value = false;
    countdown.value = 60;
    
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      countdown.value--;
      if (countdown.value == 0) {
        canGetCode.value = true;
        return false;
      }
      return true;
    });
  }

  void login() async {
    if (phoneController.text.isEmpty || codeController.text.isEmpty) {
      Get.snackbar('提示', '请输入手机号和验证码');
      return;
    }

    try {
      final result = await _authService.login(
        phoneController.text,
        codeController.text,
      );
      
      if (result) {
        if (_authService.currentUser.value?.nickname == null) {
          Get.offAllNamed(Routes.PROFILE_SETUP);
        } else {
          Get.offAllNamed(Routes.HOME);
        }
      }
    } catch (e) {
      Get.snackbar('错误', e.toString());
    }
  }

  void thirdPartyLogin(String platform) {
    // TODO: 实现第三方登录
    Get.snackbar('提示', '暂未实现$platform登录');
  }

  @override
  void onClose() {
    phoneController.dispose();
    codeController.dispose();
    super.onClose();
  }
} 