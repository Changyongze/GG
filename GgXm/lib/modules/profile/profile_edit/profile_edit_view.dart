import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'profile_edit_controller.dart';

class ProfileEditView extends GetView<ProfileEditController> {
  const ProfileEditView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑资料'),
        actions: [
          TextButton(
            onPressed: controller.saveProfile,
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          children: [
            _buildAvatarPicker(),
            SizedBox(height: 24.h),
            _buildForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarPicker() {
    return Center(
      child: Stack(
        children: [
          Obx(() => CircleAvatar(
            radius: 50.r,
            backgroundImage: controller.avatarPath.value.isEmpty
                ? (controller.user.value?.avatar != null
                    ? NetworkImage(controller.user.value!.avatar!)
                    : const AssetImage('assets/images/default_avatar.png'))
                    as ImageProvider
                : FileImage(File(controller.avatarPath.value)),
          )),
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: controller.pickImage,
              child: Container(
                padding: EdgeInsets.all(8.r),
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20.r,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        TextField(
          controller: controller.nicknameController,
          decoration: const InputDecoration(
            labelText: '昵称',
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            const Icon(Icons.wc, color: Colors.grey),
            SizedBox(width: 16.w),
            const Text('性别'),
            SizedBox(width: 32.w),
            Obx(() => Radio<String>(
              value: '男',
              groupValue: controller.gender.value,
              onChanged: (value) => controller.gender.value = value!,
            )),
            const Text('男'),
            SizedBox(width: 16.w),
            Obx(() => Radio<String>(
              value: '女',
              groupValue: controller.gender.value,
              onChanged: (value) => controller.gender.value = value!,
            )),
            const Text('女'),
          ],
        ),
        SizedBox(height: 16.h),
        TextField(
          controller: controller.ageController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '年龄',
            prefixIcon: Icon(Icons.cake),
          ),
        ),
        SizedBox(height: 16.h),
        DropdownButtonFormField<String>(
          value: controller.selectedRegion.value,
          decoration: const InputDecoration(
            labelText: '所在地区',
            prefixIcon: Icon(Icons.location_on_outlined),
          ),
          items: controller.regions.map((region) {
            return DropdownMenuItem(
              value: region,
              child: Text(region),
            );
          }).toList(),
          onChanged: (value) => controller.selectedRegion.value = value!,
        ),
        SizedBox(height: 24.h),
        const Text('兴趣爱好', style: TextStyle(color: Colors.grey)),
        SizedBox(height: 8.h),
        Obx(() => Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: controller.interests.map((interest) {
            return FilterChip(
              label: Text(interest),
              selected: controller.selectedInterests.contains(interest),
              onSelected: (selected) {
                if (selected) {
                  controller.selectedInterests.add(interest);
                } else {
                  controller.selectedInterests.remove(interest);
                }
              },
            );
          }).toList(),
        )),
      ],
    );
  }
} 