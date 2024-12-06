import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'template_edit_controller.dart';

class TemplateEditView extends GetView<TemplateEditController> {
  const TemplateEditView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.template.value == null ? '创建模板' : '编辑模板'),
        actions: [
          TextButton(
            onPressed: controller.saveTemplate,
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
              _buildMetricSelector(),
              SizedBox(height: 24.h),
              _buildDefaultSetting(),
              SizedBox(height: 24.h),
              _buildLayoutConfig(),
              SizedBox(height: 24.h),
              _buildPreviewButton(),
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
              controller: controller.nameController,
              decoration: const InputDecoration(
                labelText: '模板名称',
                hintText: '请输入模板名称',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入模板名称';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),
            TextFormField(
              controller: controller.descriptionController,
              decoration: const InputDecoration(
                labelText: '模板描述',
                hintText: '请输入模板描述',
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入模板描述';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricSelector() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '指标选择',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: controller.metricOptions.map((option) {
                return Obx(() => FilterChip(
                  label: Text(option['label'] as String),
                  selected: controller.selectedMetrics.contains(option['value']),
                  onSelected: (selected) {
                    if (selected) {
                      controller.selectedMetrics.add(option['value'] as String);
                    } else {
                      controller.selectedMetrics.remove(option['value']);
                    }
                  },
                ));
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultSetting() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '其他设置',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            Obx(() => SwitchListTile(
              title: const Text('设为默认模板'),
              subtitle: const Text('导出报告时默认使用此模板'),
              value: controller.isDefault.value,
              onChanged: (value) {
                controller.isDefault.value = value;
              },
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildLayoutConfig() {
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
                  '布局配置',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.add),
                  onSelected: controller.addSection,
                  itemBuilder: (context) => controller.sectionTypes
                      .map((section) => PopupMenuItem(
                            value: section['type'] as String,
                            child: Row(
                              children: [
                                Icon(section['icon'] as IconData),
                                SizedBox(width: 8.w),
                                Text(section['label'] as String),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Obx(() => ReorderableListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  onReorder: controller.moveSection,
                  children: [
                    for (var i = 0; i < controller.sections.length; i++)
                      _buildSectionItem(i, controller.sections[i]),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionItem(int index, Map<String, dynamic> section) {
    final type = section['type'] as String;
    return Card(
      key: ValueKey(index),
      child: ListTile(
        leading: Icon(controller.getSectionIcon(type)),
        title: Text(controller.getSectionLabel(type)),
        subtitle: Text('已选${section['metrics'].length}个指标'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => _showSectionSettings(index, section),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => controller.removeSection(index),
            ),
            const Icon(Icons.drag_handle),
          ],
        ),
      ),
    );
  }

  Future<void> _showSectionSettings(int index, Map<String, dynamic> section) async {
    final selectedMetrics = List<String>.from(section['metrics']);
    
    await Get.dialog(
      AlertDialog(
        title: Text('配置${controller.getSectionLabel(section['type'])}'),
        content: SizedBox(
          width: 0.8.sw,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: controller.metricOptions.map((option) {
                  return FilterChip(
                    label: Text(option['label'] as String),
                    selected: selectedMetrics.contains(option['value']),
                    onSelected: (selected) {
                      if (selected) {
                        selectedMetrics.add(option['value'] as String);
                      } else {
                        selectedMetrics.remove(option['value']);
                      }
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              controller.updateSectionMetrics(index, selectedMetrics);
              Get.back();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewButton() {
    return Padding(
      padding: EdgeInsets.all(16.r),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => Get.toNamed(
            Routes.TEMPLATE_PREVIEW,
            arguments: {
              'template': controller._getTemplateData(),
              'preview_data': controller.previewData.value,
            },
          ),
          icon: const Icon(Icons.preview),
          label: const Text('预览模板'),
        ),
      ),
    );
  }
} 