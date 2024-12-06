import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/auth_service.dart';

class RegisterController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  
  final phoneController = TextEditingController();
  final codeController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  
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

  void register() async {
    if (phoneController.text.isEmpty || 
        codeController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      Get.snackbar('提示', '请填写完整信息');
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar('提示', '两次输入的密码不一致');
      return;
    }

    try {
      final result = await _authService.register(
        phoneController.text,
        codeController.text,
        passwordController.text,
      );
      
      if (result) {
        Get.snackbar('提示', '注册成功');
        Get.offAllNamed(Routes.PROFILE_SETUP);
      }
    } catch (e) {
      Get.snackbar('错误', e.toString());
    }
  }

  @override
  void onClose() {
    phoneController.dispose();
    codeController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
} 