import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../api/ad_campaign_api.dart';
import '../../../services/video_service.dart';

class CampaignCreateController extends GetxController {
  final AdCampaignApi _campaignApi = AdCampaignApi();
  final VideoService _videoService = Get.find<VideoService>();
  
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  
  final videoPath = ''.obs;
  final coverPath = ''.obs;
  final selectedCategory = ''.obs;
  final startDate = Rxn<DateTime>();
  final endDate = Rxn<DateTime>();
  final isLoading = false.obs;
  
  // 投放规则
  final targetAgeRange = RangeValues(18, 65).obs;
  final targetGenders = <String>{}.obs;
  final targetRegions = <String>[].obs;
  final targetInterests = <String>[].obs;
  
  // 预算设置
  final dailyBudget = 0.0.obs;
  final totalBudget = 0.0.obs;
  final bidAmount = 0.0.obs;
  final scheduleEnabled = false.obs;
  final scheduleStartTime = TimeOfDay.now().obs;
  final scheduleEndTime = TimeOfDay.now().obs;

  final categories = [
    '美食', '旅游', '电影', '音乐', '运动', '游戏',
    '购物', '摄影', '阅读', '科技', '时尚', '汽车'
  ];

  final genderOptions = [
    {'value': 'male', 'label': '男'},
    {'value': 'female', 'label': '女'},
  ];

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  Future<void> pickVideo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? video = await picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(minutes: 1),
    );
    
    if (video != null) {
      videoPath.value = video.path;
      // 自动生成封面图
      // TODO: 实现视频封面图生成
    }
  }

  Future<void> pickCover() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 90,
    );
    
    if (image != null) {
      coverPath.value = image.path;
    }
  }

  Future<void> selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate.value ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      startDate.value = picked;
      if (endDate.value != null && endDate.value!.isBefore(picked)) {
        endDate.value = null;
      }
    }
  }

  Future<void> selectEndDate(BuildContext context) async {
    if (startDate.value == null) {
      Get.snackbar('提示', '请先选择开始日期');
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate.value ?? startDate.value!,
      firstDate: startDate.value!,
      lastDate: startDate.value!.add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      endDate.value = picked;
    }
  }

  Future<void> createCampaign() async {
    if (!formKey.currentState!.validate()) return;
    if (videoPath.isEmpty) {
      Get.snackbar('错误', '请上传广告视频');
      return;
    }
    if (coverPath.isEmpty) {
      Get.snackbar('错误', '请上传广告封面');
      return;
    }
    if (selectedCategory.isEmpty) {
      Get.snackbar('错误', '请选择广告分类');
      return;
    }
    if (startDate.value == null) {
      Get.snackbar('错误', '请选择投放开始日期');
      return;
    }

    isLoading.value = true;
    try {
      // 上传视频��封面图
      final videoUrl = await _videoService.uploadVideo(File(videoPath.value));
      final coverUrl = await _videoService.uploadImage(File(coverPath.value));

      // 创建广告计划
      final campaign = await _campaignApi.createCampaign({
        'title': titleController.text,
        'description': descriptionController.text,
        'video_url': videoUrl,
        'cover_url': coverUrl,
        'category': selectedCategory.value,
        'targeting_rules': {
          'age_range': {
            'min': targetAgeRange.value.start.round(),
            'max': targetAgeRange.value.end.round(),
          },
          'genders': targetGenders.toList(),
          'regions': targetRegions,
          'interests': targetInterests,
        },
        'budget_settings': {
          'daily_budget': dailyBudget.value,
          'total_budget': totalBudget.value,
          'bid_amount': bidAmount.value,
          'schedule_enabled': scheduleEnabled.value,
          if (scheduleEnabled.value) ...{
            'schedule_start_time': '${scheduleStartTime.value.hour}:${scheduleStartTime.value.minute}',
            'schedule_end_time': '${scheduleEndTime.value.hour}:${scheduleEndTime.value.minute}',
          },
        },
        'start_date': startDate.value!.toIso8601String(),
        if (endDate.value != null)
          'end_date': endDate.value!.toIso8601String(),
      });

      Get.back(result: campaign);
      Get.snackbar('提示', '广告计划创建成功');
    } catch (e) {
      Get.snackbar('错误', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
} 