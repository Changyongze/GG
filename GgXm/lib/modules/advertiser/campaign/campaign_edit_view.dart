import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';
import 'campaign_edit_controller.dart';
import 'package:intl/intl.dart';

class CampaignEditView extends GetView<CampaignEditController> {
  const CampaignEditView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.campaign.value == null ? '创建广告' : '编辑广告'),
        actions: [
          TextButton(
            onPressed: controller.saveCampaign,
            child: Text(
              '保存',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Form(
          key: controller.formKey,
          child: ListView(
            padding: EdgeInsets.all(16.r),
            children: [
              _buildBasicInfo(),
              SizedBox(height: 24.h),
              _buildVideoUpload(),
              SizedBox(height: 24.h),
              _buildTargetAudience(),
              SizedBox(height: 24.h),
              _buildScheduleSettings(),
              SizedBox(height: 24.h),
              _buildRegionSettings(),
              SizedBox(height: 24.h),
              _buildBudgetSettings(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildBasicInfo() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '基本信息',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            TextFormField(
              controller: controller.titleController,
              decoration: const InputDecoration(
                labelText: '广告标题',
                hintText: '请输入广告标题',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入广告标题';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),
            TextFormField(
              controller: controller.descriptionController,
              decoration: const InputDecoration(
                labelText: '广告描述',
                hintText: '请输入广告描述',
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入广告描述';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),
            DropdownButtonFormField<String>(
              value: controller.selectedCategory.value.isEmpty ? null : controller.selectedCategory.value,
              decoration: const InputDecoration(
                labelText: '广告分类',
                hintText: '请选择广告分类',
              ),
              items: controller.categoryOptions.map((option) {
                return DropdownMenuItem(
                  value: option['value'] as String,
                  child: Text(option['label'] as String),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  controller.selectedCategory.value = value;
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请选择广告分类';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoUpload() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '广告视频',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            if (controller.videoUrl.isNotEmpty || controller.videoFile.value != null)
              _buildVideoPreview()
            else
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.video_library_outlined,
                      size: 48.r,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
              ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: controller.pickVideo,
                  icon: const Icon(Icons.video_library),
                  label: const Text('选择视频'),
                ),
                if (controller.videoFile.value != null) ...[
                  SizedBox(width: 16.w),
                  Obx(() {
                    if (controller.isUploading.value) {
                      return Column(
                        children: [
                          CircularProgressIndicator(
                            value: controller.compressionProgress.value,
                            backgroundColor: Colors.grey[200],
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            controller.compressionProgress.value < 1
                                ? '压缩中 ${(controller.compressionProgress.value * 100).toInt()}%'
                                : '上传中...',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      );
                    }
                    return ElevatedButton.icon(
                      onPressed: controller.uploadVideo,
                      icon: const Icon(Icons.upload),
                      label: const Text('上传视频'),
                    );
                  }),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPreview() {
    return GetBuilder<CampaignEditController>(
      builder: (_) {
        if (controller.previewController?.value.isInitialized != true) {
          controller.initPreviewController();
          return AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          );
        }

        return Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: VideoPlayer(controller.previewController!),
                  ),
                ),
                Positioned.fill(
                  child: GestureDetector(
                    onTap: controller.togglePreview,
                    child: Container(
                      color: Colors.transparent,
                      child: Center(
                        child: Obx(() => AnimatedOpacity(
                          opacity: controller.isPreviewPlaying.value ? 0.0 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            padding: EdgeInsets.all(16.r),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              controller.isPreviewPlaying.value
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: Colors.white,
                              size: 32.r,
                            ),
                          ),
                        )),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            ValueListenableBuilder<VideoPlayerValue>(
              valueListenable: controller.previewController!,
              builder: (context, value, child) {
                return Column(
                  children: [
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 2.h,
                        thumbShape: RoundSliderThumbShape(
                          enabledThumbRadius: 6.r,
                        ),
                        overlayShape: RoundSliderOverlayShape(
                          overlayRadius: 12.r,
                        ),
                      ),
                      child: Slider(
                        value: value.position.inMilliseconds.toDouble(),
                        min: 0,
                        max: value.duration.inMilliseconds.toDouble(),
                        onChanged: (position) {
                          controller.seekTo(Duration(
                            milliseconds: position.toInt(),
                          ));
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(value.position),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            _formatDuration(value.duration),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Widget _buildTargetAudience() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '目标受众',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            DropdownButtonFormField<String>(
              value: controller.targetAudience['gender'] as String,
              decoration: const InputDecoration(
                labelText: '性别',
                hintText: '请选择目标性别',
              ),
              items: controller.audienceOptions['gender']!.map((option) {
                return DropdownMenuItem(
                  value: option['value'] as String,
                  child: Text(option['label'] as String),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  controller.updateTargetAudience('gender', value);
                }
              },
            ),
            SizedBox(height: 16.h),
            DropdownButtonFormField<String>(
              value: controller.targetAudience['age'] as String,
              decoration: const InputDecoration(
                labelText: '年龄',
                hintText: '请选择目标年龄',
              ),
              items: controller.audienceOptions['age']!.map((option) {
                return DropdownMenuItem(
                  value: option['value'] as String,
                  child: Text(option['label'] as String),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  controller.updateTargetAudience('age', value);
                }
              },
            ),
            SizedBox(height: 16.h),
            Text(
              '兴趣标签',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: controller.audienceOptions['interests']!.map((option) {
                return Obx(() {
                  final interests = List<String>.from(controller.targetAudience['interests']);
                  return FilterChip(
                    label: Text(option['label'] as String),
                    selected: interests.contains(option['value']),
                    onSelected: (selected) {
                      final newInterests = List<String>.from(interests);
                      if (selected) {
                        newInterests.add(option['value'] as String);
                      } else {
                        newInterests.remove(option['value']);
                      }
                      controller.updateTargetAudience('interests', newInterests);
                    },
                  );
                });
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleSettings() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '投放时间',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Obx(() => Switch(
                  value: controller.scheduleEnabled.value,
                  onChanged: controller.toggleSchedule,
                )),
              ],
            ),
            SizedBox(height: 16.h),
            InkWell(
              onTap: controller.selectDateRange,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: '投放日期',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Obx(() => Text(
                  controller.startDate.value != null && controller.endDate.value != null
                      ? '${DateFormat('yyyy-MM-dd').format(controller.startDate.value!)} 至 '
                        '${DateFormat('yyyy-MM-dd').format(controller.endDate.value!)}'
                      : '请选择投放日期',
                )),
              ),
            ),
            SizedBox(height: 16.h),
            Obx(() {
              if (!controller.scheduleEnabled.value) {
                return const SizedBox();
              }
              return _buildScheduleSelector();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleSelector() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              onPressed: controller.selectWorkdayHours,
              icon: const Icon(Icons.work),
              label: const Text('工作日'),
            ),
            SizedBox(width: 8.w),
            TextButton.icon(
              onPressed: controller.selectWeekendHours,
              icon: const Icon(Icons.weekend),
              label: const Text('周末'),
            ),
            SizedBox(width: 8.w),
            TextButton.icon(
              onPressed: controller.clearSchedule,
              icon: const Icon(Icons.clear_all),
              label: const Text('清空'),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        // ... 保持现有代码 ...
      ],
    );
  }

  Widget _buildRegionSettings() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '地域定向',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Obx(() => Switch(
                  value: controller.regionEnabled.value,
                  onChanged: controller.toggleRegion,
                )),
              ],
            ),
            SizedBox(height: 16.h),
            Obx(() {
              if (!controller.regionEnabled.value) {
                return const SizedBox();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '选择地区',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: controller.regionOptions.map((region) {
                      return Obx(() => FilterChip(
                        label: Text(region['name'] as String),
                        selected: controller.selectedProvinces.contains(region['code']),
                        onSelected: (selected) {
                          controller.toggleProvince(region['code'] as String);
                        },
                      ));
                    }).toList(),
                  ),
                  if (controller.selectedProvinces.isNotEmpty) ...[
                    SizedBox(height: 16.h),
                    Text(
                      '选择城市',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    ...controller.selectedProvinces.map((code) => _buildCitySelector(code)).toList(),
                  ],
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCitySelector(String provinceCode) {
    final cities = [
      // 北京市
      if (provinceCode == '110000') ...[
        {'code': '110101', 'name': '东城区'},
        {'code': '110102', 'name': '西城区'},
        {'code': '110105', 'name': '朝阳区'},
        {'code': '110106', 'name': '丰台区'},
      ],
      // 上海市
      if (provinceCode == '310000') ...[
        {'code': '310101', 'name': '黄浦区'},
        {'code': '310104', 'name': '徐汇区'},
        {'code': '310105', 'name': '长宁区'},
        {'code': '310106', 'name': '静安区'},
      ],
      // 广东省
      if (provinceCode == '440000') ...[
        {'code': '440100', 'name': '广州市'},
        {'code': '440300', 'name': '深圳市'},
        {'code': '440400', 'name': '珠海市'},
        {'code': '440600', 'name': '佛山市'},
      ],
    ];

    if (cities.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              onPressed: () => controller.selectAllCities(provinceCode),
              icon: const Icon(Icons.select_all),
              label: const Text('全选'),
            ),
            SizedBox(width: 8.w),
            TextButton.icon(
              onPressed: () => controller.clearCities(provinceCode),
              icon: const Icon(Icons.clear_all),
              label: const Text('清空'),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: cities.map((city) {
            return Obx(() => FilterChip(
              label: Text(city['name'] as String),
              selected: controller.selectedCities.contains(city['code']),
              onSelected: (selected) {
                controller.toggleCity(city['code'] as String);
              },
            ));
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBudgetSettings() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '预算设置',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            TextFormField(
              initialValue: controller.budget.value.toString(),
              decoration: const InputDecoration(
                labelText: '总预算',
                hintText: '请输入广告总预算',
                prefixText: '¥',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                controller.budget.value = double.tryParse(value) ?? 0.0;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入广告总预算';
                }
                if (double.tryParse(value) == null) {
                  return '请输入有效的金额';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),
            TextFormField(
              initialValue: controller.costPerView.value.toString(),
              decoration: const InputDecoration(
                labelText: '单次观看成本',
                hintText: '请输入单次观看成本',
                prefixText: '¥',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                controller.costPerView.value = double.tryParse(value) ?? 0.0;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入单次观看成本';
                }
                if (double.tryParse(value) == null) {
                  return '请输入有效的金额';
                }
                return null;
              },
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: controller.estimateEffects,
                icon: const Icon(Icons.analytics),
                label: const Text('预估投放效果'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '预算预警',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Obx(() => Switch(
                  value: controller.budgetWarningEnabled.value,
                  onChanged: controller.toggleBudgetWarning,
                )),
              ],
            ),
            SizedBox(height: 16.h),
            Obx(() {
              if (!controller.budgetWarningEnabled.value) {
                return const SizedBox();
              }
              return Column(
                children: [
                  Text(
                    '当预算使用达到以下比例时发送通知：',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Slider(
                    value: controller.budgetWarningThreshold.value,
                    min: 0.5,
                    max: 0.9,
                    divisions: 4,
                    label: '${(controller.budgetWarningThreshold.value * 100).toInt()}%',
                    onChanged: controller.updateBudgetWarningThreshold,
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    initialValue: controller.budgetWarningEmail.value,
                    decoration: const InputDecoration(
                      labelText: '通知邮箱',
                      hintText: '请输入接收通知的邮箱',
                    ),
                    onChanged: (value) => controller.budgetWarningEmail.value = value,
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    initialValue: controller.budgetWarningPhone.value,
                    decoration: const InputDecoration(
                      labelText: '通知手机',
                      hintText: '请输入接收通知的手机号',
                    ),
                    onChanged: (value) => controller.budgetWarningPhone.value = value,
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
} 