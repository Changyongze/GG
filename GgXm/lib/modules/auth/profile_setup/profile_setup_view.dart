import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'profile_setup_controller.dart';

class ProfileSetupView extends GetView<ProfileSetupController> {
  const ProfileSetupView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('完善个人资料'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 32.h),
              Center(
                child: Stack(
                  children: [
                    Obx(() => CircleAvatar(
                      radius: 50.r,
                      backgroundImage: controller.avatarPath.value.isEmpty
                          ? const AssetImage('assets/images/default_avatar.png')
                          : FileImage(File(controller.avatarPath.value)) as ImageProvider,
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
                            size: 20.r,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32.h),
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
              SizedBox(height: 32.h),
              ElevatedButton(
                onPressed: controller.saveProfile,
                child: const Text('保存'),
              ),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }
} 