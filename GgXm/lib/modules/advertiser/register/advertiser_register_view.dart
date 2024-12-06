import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import 'advertiser_register_controller.dart';

class AdvertiserRegisterView extends GetView<AdvertiserRegisterController> {
  const AdvertiserRegisterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('广告主注册'),
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
              _buildBasicInfo(),
              SizedBox(height: 24.h),
              _buildVerificationFiles(),
              SizedBox(height: 32.h),
              ElevatedButton(
                onPressed: controller.register,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                child: const Text('提交注册'),
              ),
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
              '注册类型',
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
                    title: const Text('个人'),
                    value: 'personal',
                    groupValue: controller.type.value,
                    onChanged: (value) {
                      if (value != null) controller.setType(value);
                    },
                  )),
                ),
                Expanded(
                  child: Obx(() => RadioListTile<String>(
                    title: const Text('企业'),
                    value: 'enterprise',
                    groupValue: controller.type.value,
                    onChanged: (value) {
                      if (value != null) controller.setType(value);
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
                labelText: '名称',
                hintText: '请输入广告主名称',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入广告主名称';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),
            TextFormField(
              controller: controller.phoneController,
              decoration: const InputDecoration(
                labelText: '联系电话',
                hintText: '请输入联系电话',
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入联系电话';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),
            TextFormField(
              controller: controller.emailController,
              decoration: const InputDecoration(
                labelText: '邮箱',
                hintText: '请输入邮箱',
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入邮箱';
                }
                if (!GetUtils.isEmail(value)) {
                  return '请输入正确的邮箱格式';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),
            Obx(() {
              if (controller.type.value == 'enterprise') {
                return TextFormField(
                  decoration: const InputDecoration(
                    labelText: '营业执照号',
                    hintText: '请输入营业执照号',
                  ),
                  onChanged: (value) => controller.licenseNo.value = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入营业执照号';
                    }
                    return null;
                  },
                );
              } else {
                return TextFormField(
                  decoration: const InputDecoration(
                    labelText: '身份证号',
                    hintText: '请输入身份证号',
                  ),
                  onChanged: (value) => controller.idCard.value = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入身份证号';
                    }
                    // TODO: 添加身份证号格式验证
                    return null;
                  },
                );
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationFiles() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '认证材料',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            Obx(() {
              if (controller.type.value == 'enterprise') {
                return _buildImageUploader(
                  title: '营业执照',
                  imagePath: controller.licenseFile.value,
                  onTap: controller.pickLicenseFile,
                );
              } else {
                return Column(
                  children: [
                    _buildImageUploader(
                      title: '身份证正面',
                      imagePath: controller.idCardFrontFile.value,
                      onTap: () => controller.pickIdCardFile(true),
                    ),
                    SizedBox(height: 16.h),
                    _buildImageUploader(
                      title: '身份证反面',
                      imagePath: controller.idCardBackFile.value,
                      onTap: () => controller.pickIdCardFile(false),
                    ),
                  ],
                );
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUploader({
    required String title,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        SizedBox(height: 8.h),
        InkWell(
          onTap: onTap,
          child: Container(
            height: 160.h,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: imagePath.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate, size: 48.r),
                      SizedBox(height: 8.h),
                      Text(
                        '点击上传图片',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  )
                : Stack(
                    children: [
                      Image.file(
                        File(imagePath),
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        right: 8.r,
                        top: 8.r,
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            if (title == '营业执照') {
                              controller.licenseFile.value = '';
                            } else if (title == '身份证正面') {
                              controller.idCardFrontFile.value = '';
                            } else {
                              controller.idCardBackFile.value = '';
                            }
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
} 