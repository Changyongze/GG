import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../api/advertiser_api.dart';

class AdvertiserRegisterController extends GetxController {
  final AdvertiserApi _advertiserApi = AdvertiserApi();
  
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  
  final type = 'personal'.obs;
  final licenseNo = ''.obs;
  final idCard = ''.obs;
  final licenseFile = ''.obs;
  final idCardFrontFile = ''.obs;
  final idCardBackFile = ''.obs;
  final isLoading = false.obs;

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.onClose();
  }

  void setType(String value) {
    type.value = value;
  }

  Future<void> pickLicenseFile() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 80,
    );
    
    if (image != null) {
      licenseFile.value = image.path;
    }
  }

  Future<void> pickIdCardFile(bool isFront) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 80,
    );
    
    if (image != null) {
      if (isFront) {
        idCardFrontFile.value = image.path;
      } else {
        idCardBackFile.value = image.path;
      }
    }
  }

  Future<void> register() async {
    if (!formKey.currentState!.validate()) return;
    
    if (type.value == 'enterprise' && licenseFile.isEmpty) {
      Get.snackbar('错误', '请上传营业执照');
      return;
    }
    
    if (type.value == 'personal' && 
        (idCardFrontFile.isEmpty || idCardBackFile.isEmpty)) {
      Get.snackbar('错误', '请上传身份证正反面照片');
      return;
    }

    isLoading.value = true;
    try {
      // 注册广告主
      await _advertiserApi.registerAdvertiser({
        'name': nameController.text,
        'phone': phoneController.text,
        'email': emailController.text,
        'type': type.value,
        'license_no': licenseNo.value,
        'id_card': idCard.value,
      });

      // 上传认证材料
      final files = type.value == 'enterprise'
          ? [licenseFile.value]
          : [idCardFrontFile.value, idCardBackFile.value];
      
      await _advertiserApi.uploadVerificationFiles(
        'current_user_id', // TODO: 替换为实际用户ID
        files,
      );

      Get.snackbar('提示', '注册成功，请等待审核');
      Get.back();
    } catch (e) {
      Get.snackbar('错误', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
} 