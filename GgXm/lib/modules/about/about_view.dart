import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'about_controller.dart';

class AboutView extends GetView<AboutController> {
  const AboutView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('关于我们'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildVersion(),
            _buildContent(),
            _buildLinks(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 32.h),
      alignment: Alignment.center,
      child: Column(
        children: [
          Image.asset(
            'assets/images/logo.png',
            width: 80.w,
            height: 80.w,
          ),
          SizedBox(height: 16.h),
          Text(
            '广告积分',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersion() {
    return Container(
      padding: EdgeInsets.all(16.r),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('当前版本'),
          Obx(() => Text(
            'v${controller.version}',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      margin: EdgeInsets.only(top: 12.h),
      padding: EdgeInsets.all(16.r),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '公司简介',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            '我们是一家专注于广告营销的创新科技公司，致力于为用户提供优质的广告观看体验，'
            '同时为广告主提供精准的营销服务。通过积分奖励机制，让用户在观看广告的同时获得实际收益，'
            '实现用户、广告主和平台的多方共赢。',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            '联系方式',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          _buildContactItem(
            icon: Icons.phone,
            title: '客服电话',
            content: '400-123-4567',
          ),
          _buildContactItem(
            icon: Icons.access_time,
            title: '工作时间',
            content: '周一至周日 9:00-21:00',
          ),
          _buildContactItem(
            icon: Icons.email,
            title: '商务合作',
            content: 'business@example.com',
          ),
          _buildContactItem(
            icon: Icons.location_on,
            title: '公司地址',
            content: '北京市朝阳区xxx大厦',
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Icon(icon, size: 20.r, color: Colors.grey),
          SizedBox(width: 8.w),
          Text(
            '$title：',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
          Text(
            content,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinks() {
    return Container(
      margin: EdgeInsets.only(top: 12.h),
      color: Colors.white,
      child: Column(
        children: [
          _buildLinkItem(
            title: '用户协议',
            onTap: controller.openUserAgreement,
          ),
          _buildLinkItem(
            title: '隐私政策',
            onTap: controller.openPrivacyPolicy,
          ),
          _buildLinkItem(
            title: '免责声明',
            onTap: controller.openDisclaimer,
          ),
        ],
      ),
    );
  }

  Widget _buildLinkItem({
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
} 