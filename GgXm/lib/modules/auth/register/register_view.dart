import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('注册'),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 48.h),
              TextField(
                controller: controller.phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: '手机号',
                  prefixIcon: Icon(Icons.phone_android),
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.codeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '验证码',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Obx(() => SizedBox(
                    width: 120.w,
                    child: ElevatedButton(
                      onPressed: controller.canGetCode.value 
                        ? controller.getVerificationCode 
                        : null,
                      child: Text(
                        controller.canGetCode.value 
                          ? '获取验证码' 
                          : '${controller.countdown.value}s'
                      ),
                    ),
                  )),
                ],
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: controller.passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '设置密码',
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: controller.confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '确认密码',
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              SizedBox(height: 32.h),
              ElevatedButton(
                onPressed: controller.register,
                child: const Text('注册'),
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('已有账号?'),
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('立即登录'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 