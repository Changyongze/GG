import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'campaign_create_controller.dart';

class CampaignCreateView extends GetView<CampaignCreateController> {
  const CampaignCreateView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('创建广告计划'),
        actions: [
          TextButton(
            onPressed: controller.createCampaign,
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
              _buildMediaUpload(),
              SizedBox(height: 24.h),
              _buildTargetingRules(),
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
              items: controller.categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  controller.selectedCategory.value = value;
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaUpload() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '媒体上传',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            _buildVideoUpload(),
            SizedBox(height: 16.h),
            _buildCoverUpload(),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoUpload() {
    return InkWell(
      onTap: controller.pickVideo,
      child: Container(
        height: 120.h,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Obx(() {
          if (controller.videoPath.isEmpty) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.video_library, size: 32.r),
                SizedBox(height: 8.h),
                const Text('点击上传广告视频'),
                Text(
                  '支持mp4格式，时长不超过1分钟',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey,
                  ),
                ),
              ],
            );
          }
          return Stack(
            children: [
              Center(
                child: Icon(Icons.play_circle_outline, size: 48.r),
              ),
              Positioned(
                right: 8.r,
                top: 8.r,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => controller.videoPath.value = '',
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildCoverUpload() {
    return InkWell(
      onTap: controller.pickCover,
      child: Container(
        height: 120.h,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Obx(() {
          if (controller.coverPath.isEmpty) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image, size: 32.r),
                SizedBox(height: 8.h),
                const Text('点击上传封面图'),
              ],
            );
          }
          return Stack(
            children: [
              Image.file(
                File(controller.coverPath.value),
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
              Positioned(
                right: 8.r,
                top: 8.r,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => controller.coverPath.value = '',
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildTargetingRules() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '投放规则',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            _buildAgeRangeSelector(),
            SizedBox(height: 16.h),
            _buildGenderSelector(),
            SizedBox(height: 16.h),
            _buildRegionSelector(),
            SizedBox(height: 16.h),
            _buildInterestSelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildAgeRangeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '年龄范围',
          style: TextStyle(fontSize: 14.sp),
        ),
        SizedBox(height: 8.h),
        Obx(() => RangeSlider(
          values: controller.targetAgeRange.value,
          min: 18,
          max: 65,
          divisions: 47,
          labels: RangeLabels(
            '${controller.targetAgeRange.value.start.round()}岁',
            '${controller.targetAgeRange.value.end.round()}岁',
          ),
          onChanged: (values) {
            controller.targetAgeRange.value = values;
          },
        )),
      ],
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '性别',
          style: TextStyle(fontSize: 14.sp),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          children: controller.genderOptions.map((option) {
            return Obx(() => FilterChip(
              label: Text(option['label'] as String),
              selected: controller.targetGenders.contains(option['value']),
              onSelected: (selected) {
                if (selected) {
                  controller.targetGenders.add(option['value'] as String);
                } else {
                  controller.targetGenders.remove(option['value']);
                }
              },
            ));
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRegionSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '地区',
              style: TextStyle(fontSize: 14.sp),
            ),
            TextButton(
              onPressed: () {
                // TODO: 实现地区选择器
                Get.snackbar('提示', '地区选择功能开发中');
              },
              child: const Text('选择地区'),
            ),
          ],
        ),
        Obx(() {
          if (controller.targetRegions.isEmpty) {
            return Text(
              '未选择',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey,
              ),
            );
          }
          return Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: controller.targetRegions.map((region) {
              return Chip(
                label: Text(region),
                onDeleted: () {
                  controller.targetRegions.remove(region);
                },
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildInterestSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '兴趣爱好',
          style: TextStyle(fontSize: 14.sp),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: controller.categories.map((interest) {
            return Obx(() => FilterChip(
              label: Text(interest),
              selected: controller.targetInterests.contains(interest),
              onSelected: (selected) {
                if (selected) {
                  controller.targetInterests.add(interest);
                } else {
                  controller.targetInterests.remove(interest);
                }
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
            _buildBudgetInputs(),
            SizedBox(height: 16.h),
            _buildScheduleSettings(),
            SizedBox(height: 16.h),
            _buildDateSettings(),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetInputs() {
    return Column(
      children: [
        TextFormField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '日预算',
            hintText: '请输入日预算金额',
            suffixText: '元',
          ),
          onChanged: (value) {
            controller.dailyBudget.value = double.tryParse(value) ?? 0;
          },
        ),
        SizedBox(height: 16.h),
        TextFormField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '总预算',
            hintText: '请输入总预算金额',
            suffixText: '元',
          ),
          onChanged: (value) {
            controller.totalBudget.value = double.tryParse(value) ?? 0;
          },
        ),
        SizedBox(height: 16.h),
        TextFormField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '出价',
            hintText: '请输入每次展示出价',
            suffixText: '元',
          ),
          onChanged: (value) {
            controller.bidAmount.value = double.tryParse(value) ?? 0;
          },
        ),
      ],
    );
  }

  Widget _buildScheduleSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Obx(() => Switch(
              value: controller.scheduleEnabled.value,
              onChanged: (value) {
                controller.scheduleEnabled.value = value;
              },
            )),
            Text(
              '投放时段',
              style: TextStyle(fontSize: 14.sp),
            ),
          ],
        ),
        Obx(() {
          if (!controller.scheduleEnabled.value) return const SizedBox();
          return Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () async {
                    final TimeOfDay? time = await showTimePicker(
                      context: Get.context!,
                      initialTime: controller.scheduleStartTime.value,
                    );
                    if (time != null) {
                      controller.scheduleStartTime.value = time;
                    }
                  },
                  child: Text(
                    '${controller.scheduleStartTime.value.format(Get.context!)}',
                  ),
                ),
              ),
              const Text('至'),
              Expanded(
                child: TextButton(
                  onPressed: () async {
                    final TimeOfDay? time = await showTimePicker(
                      context: Get.context!,
                      initialTime: controller.scheduleEndTime.value,
                    );
                    if (time != null) {
                      controller.scheduleEndTime.value = time;
                    }
                  },
                  child: Text(
                    '${controller.scheduleEndTime.value.format(Get.context!)}',
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildDateSettings() {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('开始日期'),
          trailing: TextButton(
            onPressed: () => controller.selectStartDate(Get.context!),
            child: Obx(() => Text(
              controller.startDate.value != null
                  ? DateFormat('yyyy-MM-dd').format(controller.startDate.value!)
                  : '请选择',
            )),
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('结束日期'),
          trailing: TextButton(
            onPressed: () => controller.selectEndDate(Get.context!),
            child: Obx(() => Text(
              controller.endDate.value != null
                  ? DateFormat('yyyy-MM-dd').format(controller.endDate.value!)
                  : '请选择',
            )),
          ),
        ),
      ],
    );
  }
} 