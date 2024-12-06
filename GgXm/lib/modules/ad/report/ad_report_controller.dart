import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/ad.dart';
import '../../../api/ad_api.dart';

class AdReportController extends GetxController {
  final AdApi _adApi = Get.find<AdApi>();
  
  final selectedReason = ''.obs;
  final isSubmitting = false.obs;
  late TextEditingController descriptionController;
  late Ad ad;

  final reportReasons = [
    '广告内容虚假或误导',
    '广告内容低俗或违法',
    '广告内容侵犯权益',
    '广告质量差',
    '广告重复或刷屏',
    '其他问题',
  ];

  @override
  void onInit() {
    super.onInit();
    ad = Get.arguments as Ad;
    descriptionController = TextEditingController();
  }

  @override
  void onClose() {
    descriptionController.dispose();
    super.onClose();
  }

  void selectReason(String reason) {
    selectedReason.value = reason;
  }

  Future<void> submitReport() async {
    if (selectedReason.value.isEmpty) {
      Get.snackbar('提示', '请选择举报原因');
      return;
    }

    isSubmitting.value = true;
    try {
      await _adApi.reportAd(
        ad.id,
        selectedReason.value,
        description: descriptionController.text,
      );
      Get.back();
      Get.snackbar(
        '成功',
        '举报已提交，我们会尽快处理',
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar('错误', e.toString());
    } finally {
      isSubmitting.value = false;
    }
  }
} 