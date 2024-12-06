import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import 'material_upload_controller.dart';

class MaterialUploadView extends GetView<MaterialUploadController> {
  const MaterialUploadView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('上传素材'),
        actions: [
          TextButton(
            onPressed: controller.uploadMaterial,
            child: Text(
              '上传',
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
              _buildTypeSelector(),
              SizedBox(height: 24.h),
              _buildMediaUpload(),
              SizedBox(height: 24.h),
              _buildBasicInfo(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTypeSelector() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '素材类型',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: Obx(() => RadioListTile<String>(
                    title: const Text('视频'),
                    value: 'video',
                    groupValue: controller.mediaType.value,
                    onChanged: (value) {
                      if (value != null) controller.setMediaType(value);
                    },
                  )),
                ),
                Expanded(
                  child: Obx(() => RadioListTile<String>(
                    title: const Text('图片'),
                    value: 'image',
                    groupValue: controller.mediaType.value,
                    onChanged: (value) {
                      if (value != null) controller.setMediaType(value);
                    },
                  )),
                ),
              ],
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
              '素材上传',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            _buildMediaPicker(),
            if (controller.mediaType.value == 'video') ...[
              SizedBox(height: 16.h),
              _buildCoverPicker(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMediaPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          controller.mediaType.value == 'video' ? '视频' : '图片',
          style: TextStyle(fontSize: 14.sp),
        ),
        SizedBox(height: 8.h),
        InkWell(
          onTap: controller.pickMedia,
          child: Container(
            height: 160.h,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Obx(() {
              if (controller.mediaFile.value == null) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      controller.mediaType.value == 'video'
                          ? Icons.video_library
                          : Icons.image,
                      size: 48.r,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '点击上传${controller.mediaType.value == 'video' ? '视频' : '图片'}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                );
              }
              return Stack(
                children: [
                  if (controller.mediaType.value == 'image')
                    Image.file(
                      controller.mediaFile.value!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    )
                  else
                    Center(
                      child: Icon(
                        Icons.play_circle_outline,
                        size: 48.r,
                      ),
                    ),
                  Positioned(
                    right: 8.r,
                    top: 8.r,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => controller.mediaFile.value = null,
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildCoverPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '视频封面',
          style: TextStyle(fontSize: 14.sp),
        ),
        SizedBox(height: 8.h),
        InkWell(
          onTap: controller.pickCover,
          child: Container(
            height: 160.h,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Obx(() {
              if (controller.coverFile.value == null) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image, size: 48.r),
                    SizedBox(height: 8.h),
                    Text(
                      '点击上传封面图',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                );
              }
              return Stack(
                children: [
                  Image.file(
                    controller.coverFile.value!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    right: 8.r,
                    top: 8.r,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => controller.coverFile.value = null,
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ],
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
                labelText: '素材标题',
                hintText: '请输入素材标题',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入素材标题';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),
            TextFormField(
              controller: controller.descriptionController,
              decoration: const InputDecoration(
                labelText: '素材描述',
                hintText: '请输入素材描述',
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入素材描述';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
} 