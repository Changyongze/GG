import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('个人中心'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Get.toNamed(Routes.SETTINGS),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildPoints(),
            _buildMenuList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16.r),
      color: Colors.blue,
      child: Row(
        children: [
          Obx(() => CircleAvatar(
            radius: 32.r,
            backgroundImage: controller.user.value?.avatar != null
                ? NetworkImage(controller.user.value!.avatar!)
                : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
          )),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => Text(
                  controller.user.value?.nickname ?? '未设置昵称',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                )),
                SizedBox(height: 4.h),
                Obx(() => Text(
                  controller.user.value?.phone ?? '',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14.sp,
                  ),
                )),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () => Get.toNamed(Routes.PROFILE_EDIT),
          ),
        ],
      ),
    );
  }

  Widget _buildPoints() {
    return Container(
      padding: EdgeInsets.all(16.r),
      color: Colors.white,
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '我的积分',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 4.h),
              Obx(() => Text(
                '${controller.points}',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              )),
            ],
          ),
          const Spacer(),
          TextButton(
            onPressed: () => Get.toNamed(Routes.POINTS_HISTORY),
            child: const Text('积分明细'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuList() {
    return Container(
      margin: EdgeInsets.only(top: 12.h),
      color: Colors.white,
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.card_giftcard,
            title: '我的优惠券',
            onTap: () => Get.toNamed(Routes.MY_COUPONS),
          ),
          _buildMenuItem(
            icon: Icons.notifications_outlined,
            title: '消息通知',
            onTap: () => Get.toNamed(Routes.NOTIFICATIONS),
          ),
          _buildMenuItem(
            icon: Icons.help_outline,
            title: '帮助中心',
            onTap: () => Get.toNamed(Routes.HELP_CENTER),
          ),
          _buildMenuItem(
            icon: Icons.info_outline,
            title: '关于我们',
            onTap: () => Get.toNamed(Routes.ABOUT),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black54),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: Colors.black26),
      onTap: onTap,
    );
  }
} 