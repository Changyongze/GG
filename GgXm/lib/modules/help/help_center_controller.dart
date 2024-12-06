import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/faq.dart';
import '../../api/help_api.dart';

class HelpCenterController extends GetxController {
  final HelpApi _helpApi = HelpApi();
  
  final searchController = TextEditingController();
  final isLoading = false.obs;
  final faqs = <FAQ>[].obs;
  final filteredFAQs = <FAQ>[].obs;
  final expandedIndexes = <int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadFAQs();
  }

  Future<void> loadFAQs() async {
    isLoading.value = true;
    try {
      final response = await _helpApi.getFAQs();
      faqs.value = response;
      filteredFAQs.value = response;
    } catch (e) {
      Get.snackbar('错误', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void searchFAQs(String keyword) {
    if (keyword.isEmpty) {
      filteredFAQs.value = faqs;
      return;
    }

    filteredFAQs.value = faqs.where((faq) {
      return faq.question.toLowerCase().contains(keyword.toLowerCase()) ||
             faq.answer.toLowerCase().contains(keyword.toLowerCase());
    }).toList();
  }

  void toggleFAQ(int index) {
    if (expandedIndexes.contains(index)) {
      expandedIndexes.remove(index);
    } else {
      expandedIndexes.add(index);
    }
  }

  void contactCustomerService() async {
    const url = 'https://example.com/customer-service';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      Get.snackbar('错误', '无法打开客服链接');
    }
  }

  void submitFeedback() {
    Get.toNamed(Routes.FEEDBACK);
  }

  void contactUs() {
    Get.dialog(
      AlertDialog(
        title: const Text('联系我们'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('客服电话：400-123-4567'),
            const SizedBox(height: 8),
            const Text('工作时间：周一至周日 9:00-21:00'),
            const SizedBox(height: 8),
            const Text('邮箱：support@example.com'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
} 