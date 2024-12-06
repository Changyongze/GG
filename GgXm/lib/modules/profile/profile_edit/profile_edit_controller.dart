import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/user.dart';
import '../../../services/auth_service.dart';

class ProfileEditController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  
  final user = Rxn<User>();
  final avatarPath = ''.obs;
  final gender = '男'.obs;
  final selectedRegion = '北京市'.obs;
  final selectedInterests = <String>{}.obs;
  
  final nicknameController = TextEditingController();
  final ageController = TextEditingController();
  
  final regions = [
    '北京市', '上海市', '广州市', '深圳市', '杭州市',
    '成都市', '武汉市', '南京市', '西安市', '重庆市'
  ];
  
  final interests = [
    '美食', '旅游', '电影', '音乐', '运动', '游戏',
    '购物', '摄影', '阅读', '科技', '时尚', '汽车'
  ];

  @override
  void onInit() {
    super.onInit();
    loadUserInfo();
  }

  void loadUserInfo() {
    user.value = _authService.currentUser.value;
    if (user.value != null) {
      nicknameController.text = user.value!.nickname ?? '';
      gender.value = user.value!.gender ?? '男';
      ageController.text = user.value!.age?.toString() ?? '';
      selectedRegion.value = user.value!.region ?? '北京市';
      if (user.value!.interests != null) {
        selectedInterests.addAll(user.value!.interests!);
      }
    }
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 90,
    );
    
    if (image != null) {
      avatarPath.value = image.path;
    }
  }

  void saveProfile() async {
    if (nicknameController.text.isEmpty) {
      Get.snackbar('提示', '请输入昵称');
      return;
    }

    final age = int.tryParse(ageController.text);
    if (age == null || age <= 0 || age >= 120) {
      Get.snackbar('提示', '请输入有效年龄');
      return;
    }

    if (selectedInterests.isEmpty) {
      Get.snackbar('提示', '请至少选择一个兴趣爱好');
      return;
    }

    try {
      final result = await _authService.updateUserInfo(
        nickname: nicknameController.text,
        gender: gender.value,
        age: age,
        region: selectedRegion.value,
        interests: selectedInterests.toList(),
        avatar: avatarPath.value.isNotEmpty ? avatarPath.value : null,
      );
      
      if (result) {
        Get.back(result: true);
        Get.snackbar('提示', '保存成功');
      }
    } catch (e) {
      Get.snackbar('错误', e.toString());
    }
  }

  @override
  void onClose() {
    nicknameController.dispose();
    ageController.dispose();
    super.onClose();
  }
} 