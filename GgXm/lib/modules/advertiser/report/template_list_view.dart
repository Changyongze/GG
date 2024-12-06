import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'template_list_controller.dart';

class TemplateListView extends GetView<TemplateListController> {
  const TemplateListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('报告模板'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: controller.createTemplate,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.templates.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.description_outlined,
                  size: 64.r,
                  color: Colors.grey[300],
                ),
                SizedBox(height: 16.h),
                Text(
                  '暂无报告模板',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: controller.createTemplate,
                  child: const Text('创建模板'),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.all(16.r),
          itemCount: controller.templates.length,
          separatorBuilder: (context, index) => SizedBox(height: 16.h),
          itemBuilder: (context, index) {
            final template = controller.templates[index];
            return _buildTemplateCard(template);
          },
        );
      }),
    );
  }

  Widget _buildTemplateCard(ReportTemplate template) {
    return Card(
      child: InkWell(
        onTap: () => controller.editTemplate(template),
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      template.name,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (template.isDefault)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        '默认',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  SizedBox(width: 8.w),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          controller.editTemplate(template);
                          break;
                        case 'delete':
                          _showDeleteConfirmDialog(template);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('编辑'),
                      ),
                      if (!template.isDefault)
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('删除'),
                        ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                template.description,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 16.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: template.metrics.map((metric) {
                  return Chip(
                    label: Text(metric),
                    backgroundColor: Colors.grey[100],
                  );
                }).toList(),
              ),
              SizedBox(height: 8.h),
              Text(
                '更新时间：${DateFormat('yyyy-MM-dd HH:mm').format(template.updatedAt)}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmDialog(ReportTemplate template) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('删除模板'),
        content: Text('确定要删除模板"${template.name}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      controller.deleteTemplate(template.id);
    }
  }
} 