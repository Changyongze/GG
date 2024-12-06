import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import '../../../models/ad_campaign.dart';
import '../../../api/ad_api.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../../services/video_service.dart';

class CampaignEditController extends GetxController {
  final AdApi _adApi = Get.find<AdApi>();
  final VideoService _videoService = Get.find<VideoService>();
  
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  
  final selectedCategory = ''.obs;
  final videoFile = Rxn<File>();
  final videoUrl = ''.obs;
  final isUploading = false.obs;
  final isLoading = false.obs;
  
  final budget = 0.0.obs;
  final costPerView = 0.0.obs;
  
  final targetAudience = <String, dynamic>{}.obs;
  final campaign = Rxn<AdCampaign>();

  final categoryOptions = [
    {'value': 'food', 'label': '美食'},
    {'value': 'shopping', 'label': '购物'},
    {'value': 'entertainment', 'label': '娱乐'},
    {'value': 'education', 'label': '教育'},
    {'value': 'travel', 'label': '旅游'},
    {'value': 'other', 'label': '其他'},
  ];

  final audienceOptions = {
    'gender': [
      {'value': 'all', 'label': '不限'},
      {'value': 'male', 'label': '男'},
      {'value': 'female', 'label': '女'},
    ],
    'age': [
      {'value': 'all', 'label': '不限'},
      {'value': '18-24', 'label': '18-24岁'},
      {'value': '25-34', 'label': '25-34岁'},
      {'value': '35-44', 'label': '35-44岁'},
      {'value': '45+', 'label': '45岁以上'},
    ],
    'interests': [
      {'value': 'food', 'label': '美食'},
      {'value': 'shopping', 'label': '购物'},
      {'value': 'entertainment', 'label': '娱乐'},
      {'value': 'education', 'label': '教育'},
      {'value': 'travel', 'label': '旅游'},
    ],
  };

  final startDate = Rxn<DateTime>();
  final endDate = Rxn<DateTime>();
  final scheduleEnabled = false.obs;
  final schedule = <String, List<int>>{}.obs; // 每天的投放时段

  final regionEnabled = false.obs;
  final selectedProvinces = <String>{}.obs;
  final selectedCities = <String>{}.obs;

  final regionOptions = [
    {'code': '110000', 'name': '北京市'},
    {'code': '310000', 'name': '上海市'},
    {'code': '440000', 'name': '广东省'},
    // ... 其他省份
  ];

  final cityOptions = {
    '110000': [ // 北京市
      {'code': '110101', 'name': '东城区'},
      {'code': '110102', 'name': '西城区'},
      {'code': '110105', 'name': '朝阳区'},
      {'code': '110106', 'name': '丰台区'},
    ],
    '310000': [ // 上海市
      {'code': '310101', 'name': '黄浦区'},
      {'code': '310104', 'name': '徐汇区'},
      {'code': '310105', 'name': '长宁区'},
      {'code': '310106', 'name': '静安区'},
    ],
    '440000': [ // 广东省
      {'code': '440100', 'name': '广州市'},
      {'code': '440300', 'name': '深圳市'},
      {'code': '440400', 'name': '珠海市'},
      {'code': '440600', 'name': '佛山市'},
    ],
  };

  List<Map<String, String>> getCities(String provinceCode) {
    return List<Map<String, String>>.from(cityOptions[provinceCode] ?? []);
  }

  final budgetWarningEnabled = false.obs;
  final budgetWarningThreshold = 0.8.obs; // 80%
  final budgetWarningEmail = ''.obs;
  final budgetWarningPhone = ''.obs;

  // 预览相关
  final isPreviewPlaying = false.obs;
  VideoPlayerController? previewController;

  // 效果预估相关
  final estimatedImpressions = 0.obs;
  final estimatedClicks = 0.obs;
  final estimatedConversions = 0.obs;
  final estimatedCost = 0.0.obs;

  // 缩略图相关
  final thumbnailFile = Rxn<File>();

  final compressionProgress = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is AdCampaign) {
      campaign.value = Get.arguments as AdCampaign;
      _initCampaignData();
    } else {
      _initDefaultData();
    }
  }

  void _initCampaignData() {
    final data = campaign.value!;
    titleController.text = data.title;
    descriptionController.text = data.description;
    selectedCategory.value = data.category;
    videoUrl.value = data.videoUrl;
    budget.value = data.budget;
    costPerView.value = data.costPerView;
    targetAudience.value = data.targetAudience;
    startDate.value = data.startDate;
    endDate.value = data.endDate;
    if (data.targetAudience['schedule'] != null) {
      scheduleEnabled.value = true;
      schedule.value = Map<String, List<int>>.from(data.targetAudience['schedule']);
    }
    if (data.targetAudience['regions'] != null) {
      regionEnabled.value = true;
      selectedProvinces.addAll(List<String>.from(data.targetAudience['regions']['provinces']));
      selectedCities.addAll(List<String>.from(data.targetAudience['regions']['cities']));
    }
  }

  void _initDefaultData() {
    targetAudience.value = {
      'gender': 'all',
      'age': 'all',
      'interests': <String>[],
    };
    startDate.value = DateTime.now();
    endDate.value = DateTime.now().add(const Duration(days: 30));
    schedule.value = {
      'monday': [],
      'tuesday': [],
      'wednesday': [],
      'thursday': [],
      'friday': [],
      'saturday': [],
      'sunday': [],
    };
  }

  Future<void> pickVideo() async {
    final picker = ImagePicker();
    final video = await picker.pickVideo(source: ImageSource.gallery);
    
    if (video != null) {
      final file = File(video.path);
      
      // 验证视频
      if (!await _videoService.validateVideo(file)) {
        return;
      }

      // 压缩视频
      isUploading.value = true;
      try {
        final subscription = _videoService.compressionProgress.listen((progress) {
          compressionProgress.value = progress;
        });

        final compressed = await _videoService.compressVideo(file);
        subscription.cancel();

        if (compressed != null) {
          videoFile.value = compressed;
          // 生成缩略图
          final thumbnailPath = await _videoService.getThumbnail(compressed);
          if (thumbnailPath != null) {
            thumbnailFile.value = File(thumbnailPath);
          }
        }
      } finally {
        isUploading.value = false;
      }
    }
  }

  Future<void> uploadVideo() async {
    if (videoFile.value == null) return;
    
    isUploading.value = true;
    try {
      // 生成缩略图
      await generateThumbnail();
      
      // 上传视频
      final videoUrl = await _adApi.uploadVideo(videoFile.value!);
      this.videoUrl.value = videoUrl;
      
      // 上传缩略图
      if (thumbnailFile.value != null) {
        final thumbnailUrl = await _adApi.uploadImage(thumbnailFile.value!);
        // TODO: 保存缩略图URL
      }
      
      Get.snackbar('提示', '视频上传成功');
    } catch (e) {
      Get.snackbar('错误', e.toString());
    } finally {
      isUploading.value = false;
    }
  }

  Future<void> selectDateRange() async {
    final picked = await showDateRangePicker(
      context: Get.context!,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(
        start: startDate.value ?? DateTime.now(),
        end: endDate.value ?? DateTime.now().add(const Duration(days: 30)),
      ),
    );
    
    if (picked != null) {
      startDate.value = picked.start;
      endDate.value = picked.end;
    }
  }

  void toggleSchedule(bool enabled) {
    scheduleEnabled.value = enabled;
  }

  void updateSchedule(String day, List<int> hours) {
    schedule[day] = hours;
  }

  void toggleRegion(bool enabled) {
    regionEnabled.value = enabled;
  }

  void toggleProvince(String code) {
    if (selectedProvinces.contains(code)) {
      selectedProvinces.remove(code);
      // 移除该省份下的所有城市
      selectedCities.removeWhere((city) => city.startsWith(code.substring(0, 2)));
    } else {
      selectedProvinces.add(code);
    }
  }

  void toggleCity(String code) {
    if (selectedCities.contains(code)) {
      selectedCities.remove(code);
    } else {
      selectedCities.add(code);
    }
  }

  void selectWorkdayHours() {
    final workdays = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'];
    final workHours = List.generate(14, (i) => i + 8); // 8:00-22:00
    
    for (var day in workdays) {
      schedule[day] = workHours;
    }
  }

  void selectWeekendHours() {
    final weekends = ['saturday', 'sunday'];
    final weekendHours = List.generate(16, (i) => i + 8); // 8:00-24:00
    
    for (var day in weekends) {
      schedule[day] = weekendHours;
    }
  }

  void clearSchedule() {
    schedule.forEach((key, value) {
      schedule[key] = [];
    });
  }

  void selectAllCities(String provinceCode) {
    final cities = getCities(provinceCode);
    for (var city in cities) {
      selectedCities.add(city['code'] as String);
    }
  }

  void clearCities(String provinceCode) {
    final cities = getCities(provinceCode);
    for (var city in cities) {
      selectedCities.remove(city['code']);
    }
  }

  void toggleBudgetWarning(bool enabled) {
    budgetWarningEnabled.value = enabled;
  }

  void updateBudgetWarningThreshold(double value) {
    budgetWarningThreshold.value = value;
  }

  Map<String, dynamic> _getTargetAudienceData() {
    return {
      'gender': targetAudience['gender'],
      'age': targetAudience['age'],
      'interests': targetAudience['interests'],
      if (scheduleEnabled.value)
        'schedule': schedule,
      if (regionEnabled.value)
        'regions': {
          'provinces': selectedProvinces.toList(),
          'cities': selectedCities.toList(),
        },
      if (budgetWarningEnabled.value)
        'budget_warning': {
          'threshold': budgetWarningThreshold.value,
          'email': budgetWarningEmail.value,
          'phone': budgetWarningPhone.value,
        },
    };
  }

  Future<void> saveCampaign() async {
    if (!formKey.currentState!.validate()) return;
    if (videoUrl.isEmpty) {
      Get.snackbar('错误', '请上传广告视频');
      return;
    }

    isLoading.value = true;
    try {
      final data = {
        'title': titleController.text,
        'description': descriptionController.text,
        'video_url': videoUrl.value,
        'category': selectedCategory.value,
        'target_audience': _getTargetAudienceData(),
        'budget': budget.value,
        'cost_per_view': costPerView.value,
        'start_date': startDate.value?.toIso8601String(),
        'end_date': endDate.value?.toIso8601String(),
      };

      if (campaign.value != null) {
        await _adApi.updateCampaign(campaign.value!.id, data);
        Get.snackbar('提示', '广告计划更新成功');
      } else {
        await _adApi.createCampaign(data);
        Get.snackbar('提示', '广告计划创建成功');
      }
      Get.back(result: true);
    } catch (e) {
      Get.snackbar('错误', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void updateTargetAudience(String key, dynamic value) {
    targetAudience[key] = value;
  }

  void initPreviewController() {
    if (videoUrl.isNotEmpty) {
      previewController = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl.value),
      )..initialize().then((_) {
        update();
      });
    } else if (videoFile.value != null) {
      previewController = VideoPlayerController.file(
        videoFile.value!,
      )..initialize().then((_) {
        update();
      });
    }
  }

  void togglePreview() {
    if (previewController == null) return;
    
    if (previewController!.value.isPlaying) {
      previewController!.pause();
      isPreviewPlaying.value = false;
    } else {
      previewController!.play();
      isPreviewPlaying.value = true;
    }
  }

  void disposePreviewController() {
    previewController?.dispose();
    previewController = null;
  }

  Future<void> estimateEffects() async {
    if (budget.value <= 0 || costPerView.value <= 0) {
      Get.snackbar('提示', '请先设置预算和单次观看成本');
      return;
    }

    try {
      final data = {
        'budget': budget.value,
        'cost_per_view': costPerView.value,
        'target_audience': _getTargetAudienceData(),
        if (scheduleEnabled.value) 'schedule': schedule,
        if (regionEnabled.value) 'regions': {
          'provinces': selectedProvinces.toList(),
          'cities': selectedCities.toList(),
        },
      };

      final response = await _adApi.estimateEffects(data);
      estimatedImpressions.value = response['impressions'] as int;
      estimatedClicks.value = response['clicks'] as int;
      estimatedConversions.value = response['conversions'] as int;
      estimatedCost.value = response['cost'] as double;
      
      _showEstimateDialog();
    } catch (e) {
      Get.snackbar('错误', e.toString());
    }
  }

  void _showEstimateDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('预估效果'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildEstimateItem('预计展示量', estimatedImpressions.value.toString()),
            _buildEstimateItem('预计点击量', estimatedClicks.value.toString()),
            _buildEstimateItem('预计转化量', estimatedConversions.value.toString()),
            _buildEstimateItem('预计花费', '¥${estimatedCost.value.toStringAsFixed(2)}'),
            const Divider(),
            _buildEstimateItem('预计点击率', '${(estimatedClicks / estimatedImpressions * 100).toStringAsFixed(2)}%'),
            _buildEstimateItem('预计转化率', '${(estimatedConversions / estimatedClicks * 100).toStringAsFixed(2)}%'),
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

  Widget _buildEstimateItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> seekTo(Duration position) async {
    await previewController?.seekTo(position);
  }

  Future<void> generateThumbnail() async {
    if (videoFile.value == null && videoUrl.isEmpty) return;
    
    try {
      final path = videoFile.value?.path ?? videoUrl.value;
      final thumbnail = await VideoThumbnail.thumbnailFile(
        video: path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 640,
        quality: 75,
      );
      
      if (thumbnail != null) {
        thumbnailFile.value = File(thumbnail);
      }
    } catch (e) {
      print('生成缩略图失败: $e');
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    disposePreviewController();
    _videoService.cancelCompression();
    super.onClose();
  }
} 