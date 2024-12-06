import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../controllers/auth_controller.dart';
import '../../../services/auth_service.dart';

class ProfileController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final PCAuthController _authController = Get.find<PCAuthController>();

  final isLoading = false.obs;
  final avatarUrl = ''.obs;
  final gender = '男'.obs;

  late final TextEditingController nicknameController;
  late final TextEditingController ageController;
  late final TextEditingController phoneController;
  late final TextEditingController emailController;
  late final TextEditingController oldPasswordController;
  late final TextEditingController newPasswordController;
  late final TextEditingController confirmPasswordController;

  @override
  void onInit() {
    super.onInit();
    final user = _authController.currentUser.value;
    
    nicknameController = TextEditingController(text: user?.nickname);
    ageController = TextEditingController(text: user?.age?.toString());
    phoneController = TextEditingController(text: user?.phone);
    emailController = TextEditingController(text: user?.email);
    oldPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();

    if (user?.avatar != null) {
      avatarUrl.value = user!.avatar!;
    }
    if (user?.gender != null) {
      gender.value = user!.gender!;
    }
  }

  Future<void> pickAvatar() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      isLoading.value = true;
      try {
        final url = await _authService.uploadAvatar(image.path);
        avatarUrl.value = url;
      } catch (e) {
        Get.snackbar('错误', '上传头像失败');
      } finally {
        isLoading.value = false;
      }
    }
  }

  Future<void> saveProfile() async {
    // 验证密码
    if (newPasswordController.text.isNotEmpty) {
      if (oldPasswordController.text.isEmpty) {
        Get.snackbar('提示', '请输入原密码');
        return;
      }
      if (newPasswordController.text != confirmPasswordController.text) {
        Get.snackbar('提示', '两次输入的新密码不一致');
        return;
      }
    }

    isLoading.value = true;
    try {
      await _authService.updateProfile(
        nickname: nicknameController.text,
        gender: gender.value,
        age: int.tryParse(ageController.text),
        phone: phoneController.text,
        email: emailController.text,
        oldPassword: oldPasswordController.text.isEmpty ? null : oldPasswordController.text,
        newPassword: newPasswordController.text.isEmpty ? null : newPasswordController.text,
      );
      
      Get.snackbar('成功', '个人信息已更新');
    } catch (e) {
      Get.snackbar('错误', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nicknameController.dispose();
    ageController.dispose();
    phoneController.dispose();
    emailController.dispose();
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
} 