import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('登录'),
        automaticallyImplyLeading: false,
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
              SizedBox(height: 32.h),
              ElevatedButton(
                onPressed: controller.login,
                child: const Text('登录'),
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('���没有账号?'),
                  TextButton(
                    onPressed: () => Get.toNamed(Routes.REGISTER),
                    child: const Text('立即注册'),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildThirdPartyLogin(
                    'assets/images/wechat.png',
                    () => controller.thirdPartyLogin('wechat'),
                  ),
                  _buildThirdPartyLogin(
                    'assets/images/qq.png',
                    () => controller.thirdPartyLogin('qq'),
                  ),
                  _buildThirdPartyLogin(
                    'assets/images/alipay.png',
                    () => controller.thirdPartyLogin('alipay'),
                  ),
                ],
              ),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThirdPartyLogin(String imagePath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44.w,
        height: 44.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Image.asset(imagePath),
      ),
    );
  }
} 