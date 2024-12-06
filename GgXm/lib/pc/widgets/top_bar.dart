import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class TopBar extends StatelessWidget {
  const TopBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<PCAuthController>();
    
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          // 页面标题
          Text(
            _getPageTitle(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const Spacer(),
          
          // 用户信息
          Obx(() {
            final user = authController.currentUser.value;
            if (user == null) return const SizedBox();
            
            return PopupMenuButton(
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(user.avatar ?? ''),
                    radius: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(user.nickname ?? ''),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'profile',
                  child: Text('个人信息'),
                ),
                const PopupMenuItem(
                  value: 'logout',
                  child: Text('退出登录'),
                ),
              ],
              onSelected: (value) {
                if (value == 'profile') {
                  Get.toNamed(PCRoutes.PROFILE);
                } else if (value == 'logout') {
                  authController.logout();
                }
              },
            );
          }),
        ],
      ),
    );
  }

  String _getPageTitle() {
    final route = Get.currentRoute;
    switch (route) {
      case PCRoutes.DASHBOARD:
        return '仪表盘';
      case PCRoutes.ADS:
        return '广告管理';
      case PCRoutes.ANALYTICS:
        return '数据分析';
      case PCRoutes.COUPONS:
        return '优惠券管理';
      case PCRoutes.USERS:
        return '用户管理';
      case PCRoutes.SETTINGS:
        return '系统设置';
      default:
        return '';
    }
  }
} 